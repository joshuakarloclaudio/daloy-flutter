import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderSubscription;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/connectivity/online_status.dart';
import '../../../core/utils/platform.dart';
import '../../auth/application/session_controller.dart';
import '../../line_ups/application/line_up_detail_controller.dart';
import '../../perform/application/perform_controller.dart';
import '../../songs/application/song_detail_controller.dart';
import '../../songs/data/song_detail_repository.dart';
import '../../songs/domain/youtube_link.dart';
import '../data/youtube_engine.dart';
import '../domain/player_queue.dart';

part 'music_player_controller.g.dart';

enum PlayerStatus { loading, playing, paused, buffering, ended }

/// Who moved the player to its current track.
enum TrackChange {
  /// The player itself: a song ended, next/previous, a pick in the queue,
  /// a video that wouldn't play. A linked chart follows.
  player,

  /// The chart moved and the player followed; nothing to send back.
  chart,
}

@immutable
class PlaybackProgress {
  const PlaybackProgress(this.position, this.duration);

  static const zero = PlaybackProgress(Duration.zero, Duration.zero);

  final Duration position;
  final Duration duration;

  double get fraction =>
      duration.inMilliseconds <= 0 ? 0 : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

  @override
  bool operator ==(Object other) =>
      other is PlaybackProgress && other.position == position && other.duration == duration;

  @override
  int get hashCode => Object.hash(position, duration);
}

@immutable
class MusicPlayerState {
  const MusicPlayerState({
    this.source,
    this.title,
    this.tracks = const [],
    this.currentIndex,
    this.status = PlayerStatus.loading,
    this.unavailable = const {},
    this.change = TrackChange.player,
    this.serial = 0,
  });

  /// What's playing from — a line-up or a song, the same way Perform names
  /// it, so the two can tell they're showing the same set. Null: closed.
  final PerformSource? source;

  /// The line-up's or the song's title.
  final String? title;
  final List<PlayerTrack> tracks;
  final int? currentIndex;
  final PlayerStatus status;

  /// Videos YouTube wouldn't play here, by id.
  final Set<String> unavailable;

  /// Why [currentIndex] last changed; [serial] counts the changes.
  final TrackChange change;
  final int serial;

  bool get isOpen => source != null && current != null;
  PlayerTrack? get current => currentIndex == null || currentIndex! >= tracks.length ? null : tracks[currentIndex!];
  bool get isPlaying => status == PlayerStatus.playing || status == PlayerStatus.buffering;
  int? get nextIndex =>
      currentIndex == null ? null : findPlayableIndex(tracks, currentIndex!, 1, unavailable: unavailable);
  int? get previousIndex =>
      currentIndex == null ? null : findPlayableIndex(tracks, currentIndex!, -1, unavailable: unavailable);
  bool get hasNext => nextIndex != null;
  bool get hasPrevious => previousIndex != null;
  int get playableCount => tracks.where((t) => t.hasVideo).length;

  bool isUnavailable(PlayerTrack track) => track.videoId != null && unavailable.contains(track.videoId);
  bool canPlay(PlayerTrack track) => isPlayable(track, unavailable);

  /// The player is on [source]: a chart showing it is linked to it.
  bool isPlayingFrom(PerformSource other) => isOpen && source == other;

  MusicPlayerState copyWith({
    String? title,
    List<PlayerTrack>? tracks,
    int? currentIndex,
    PlayerStatus? status,
    Set<String>? unavailable,
    TrackChange? change,
    int? serial,
  }) => MusicPlayerState(
    source: source,
    title: title ?? this.title,
    tracks: tracks ?? this.tracks,
    currentIndex: currentIndex ?? this.currentIndex,
    status: status ?? this.status,
    unavailable: unavailable ?? this.unavailable,
    change: change ?? this.change,
    serial: serial ?? this.serial,
  );
}

/// The places the video can be drawn: the now-playing screen, the mini
/// player, Perform's strip. The newest one on screen gets it (the video
/// moves there without reloading); with none on screen the player pauses,
/// since YouTube's terms don't allow it to play unseen.
class PlayerSlots extends ChangeNotifier {
  PlayerSlots(this._onNoneVisible);

  final VoidCallback _onNoneVisible;
  final _visible = <Object, int>{};
  var _seq = 0;
  var _commitQueued = false;
  Object? _owner;
  var _disposed = false;

  /// Moves the video between slots without rebuilding it.
  final surfaceKey = GlobalKey(debugLabel: 'youtube-surface');

  /// The slot holding the video.
  Object? get owner => _owner;

  /// A slot came on screen; the newest one wins.
  void show(Object slot) {
    if (_visible.containsKey(slot)) return;
    _visible[slot] = _seq++;
    _queueCommit();
  }

  /// A slot left the screen (its route was covered, or it went away).
  void hide(Object slot) {
    if (_visible.remove(slot) == null) return;
    _queueCommit();
  }

  /// Slots come and go while the tree builds; the video changes hands
  /// after the frame, so the old and new holder rebuild together and a
  /// route change that swaps one slot for another doesn't pause.
  void _queueCommit() {
    if (_commitQueued) return;
    _commitQueued = true;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => _commit())
      ..ensureVisualUpdate();
  }

  void _commit() {
    _commitQueued = false;
    if (_disposed) return;
    Object? best;
    var top = -1;
    _visible.forEach((slot, seq) {
      if (seq > top) {
        top = seq;
        best = slot;
      }
    });
    if (best != _owner) {
      _owner = best;
      notifyListeners();
    }
    if (best == null) _onNoneVisible();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// The music player: plays a line-up's (or a song's) YouTube links in order
/// — the twin of `use-music-player.ts`, but one for the whole app, so it
/// plays on from screen to screen. The video is always on screen, through
/// [slots]; there's no background audio. Songs without a link stay in the
/// queue and are skipped; a video YouTube refuses is marked and skipped.
@Riverpod(keepAlive: true)
class MusicPlayer extends _$MusicPlayer {
  /// Going back this far into a song restarts it; any sooner, the song before.
  static const restartThreshold = Duration(seconds: 3);

  final progress = ValueNotifier(PlaybackProgress.zero);
  late final slots = PlayerSlots(() => unawaited(pause()));

  YouTubeEngine? _engine;
  StreamSubscription<EngineEvent>? _events;
  ProviderSubscription<Object?>? _queue;
  AppLifecycleListener? _lifecycle;

  /// The video in the engine, to keep it across queue rebuilds.
  String? _loaded;

  /// The video last counted as played, so a pause and resume isn't another play.
  String? _played;

  /// Opened before the queue had loaded: where to start, and whether to play.
  int? _startAt;
  bool _startPlaying = true;

  @override
  MusicPlayerState build() {
    // Another workspace (or signing out): its songs aren't this one's.
    ref.listen(activeWorkspaceIdProvider, (was, now) {
      if (was != now) close();
    });
    ref.onDispose(() {
      _teardown();
      progress.dispose();
      slots.dispose();
    });
    return const MusicPlayerState();
  }

  /// The YouTube player, while open.
  YouTubeEngine? get engine => _engine;

  // -- Opening and closing ----------------------------------------------------------

  /// Plays [source] from [start] (its index in the set), or from the first
  /// song with a link. Already playing it: goes to [start] if given.
  void open(PerformSource source, {int? start, bool play = true}) {
    if (!hasInAppPlayer) return;
    if (state.source == source && state.isOpen) {
      if (start != null && start != state.currentIndex && state.canPlay(state.tracks[start])) {
        _select(start, play: play, change: TrackChange.player);
      } else if (play && !state.isPlaying) {
        unawaited(_engine?.play());
      }
      return;
    }
    _teardown();
    state = MusicPlayerState(source: source, serial: state.serial + 1);
    _startAt = start;
    _startPlaying = play;
    _queue = switch (source) {
      LineUpSource(:final id) => ref.listen<LineUpDetailState>(
        lineUpDetailControllerProvider(id),
        (_, d) => _onQueue(d.lineUp?.title, buildLineUpQueue(d.songs), loading: d.isLoading),
        fireImmediately: true,
      ),
      SongSource(:final id) => ref.listen<SongDetailState>(
        songDetailControllerProvider(id),
        (_, d) => _onQueue(d.song?.title, buildSongQueue(d.song, d.displayKey), loading: d.isLoading),
        fireImmediately: true,
      ),
    };
  }

  void close() {
    if (_engine != null) unawaited(ref.read(analyticsProvider).track(AnalyticsEvent.musicPlayerClosed));
    _teardown();
    state = MusicPlayerState(serial: state.serial + 1);
  }

  void _teardown() {
    _queue?.close();
    _queue = null;
    unawaited(_events?.cancel());
    _events = null;
    final engine = _engine;
    _engine = null;
    if (engine != null) unawaited(engine.dispose());
    _lifecycle?.dispose();
    _lifecycle = null;
    _loaded = null;
    _played = null;
    progress.value = PlaybackProgress.zero;
  }

  void _onQueue(String? title, List<PlayerTrack> tracks, {required bool loading}) {
    if (state.source == null) return;
    if (state.current == null) {
      state = state.copyWith(title: title, tracks: tracks);
      // The set can read as empty for a moment while its songs come out of Drift.
      if (loading || tracks.isEmpty) return;
      final from = _startAt;
      final start = from != null && from < tracks.length && state.canPlay(tracks[from])
          ? from
          : findPlayableIndex(tracks, (from ?? 0) - 1, 1, unavailable: state.unavailable) ??
                findPlayableIndex(tracks, -1, 1, unavailable: state.unavailable);
      if (start == null) {
        close();
        return;
      }
      _start(start);
      return;
    }

    // A team edit rebuilt the set: stay on the video playing, wherever it went.
    var index = state.currentIndex!;
    if (index >= tracks.length || tracks[index].videoId != _loaded) {
      index = tracks.indexWhere((t) => t.videoId == _loaded);
    }
    if (index < 0) {
      // The song playing left the set, or lost its link.
      close();
      return;
    }
    state = state.copyWith(title: title, tracks: tracks, currentIndex: index);
  }

  void _start(int index) {
    final engine = ref.read(youtubeEngineFactoryProvider)();
    _engine = engine;
    _events = engine.events.listen(_onEvent);
    _lifecycle = AppLifecycleListener(onHide: () => unawaited(pause()));
    unawaited(
      ref
          .read(analyticsProvider)
          .track(
            AnalyticsEvent.musicPlayerOpened,
            properties: {'queue_size': state.tracks.where(state.canPlay).length, 'autoplay': _startPlaying},
          ),
    );
    _select(index, play: _startPlaying, change: TrackChange.player);
  }

  void _select(int index, {required bool play, required TrackChange change}) {
    final video = state.tracks[index].videoId;
    final engine = _engine;
    if (video == null || engine == null) return;
    state = state.copyWith(currentIndex: index, status: PlayerStatus.loading, change: change, serial: state.serial + 1);
    progress.value = PlaybackProgress.zero;
    _loaded = video;
    unawaited(play ? engine.load(video) : engine.cue(video));
  }

  void _onEvent(EngineEvent event) {
    switch (event) {
      case EngineStatusChanged(:final status):
        switch (status) {
          case EngineStatus.ended:
            final next = state.nextIndex;
            if (next != null) {
              _select(next, play: true, change: TrackChange.player);
            } else {
              state = state.copyWith(status: PlayerStatus.ended);
            }
          case EngineStatus.cued:
            state = state.copyWith(status: PlayerStatus.paused);
          case EngineStatus.loading:
            state = state.copyWith(status: PlayerStatus.loading);
          case EngineStatus.playing:
            state = state.copyWith(status: PlayerStatus.playing);
            final track = state.current;
            if (track != null && _played != _loaded) {
              _played = _loaded;
              unawaited(
                ref
                    .read(analyticsProvider)
                    .track(AnalyticsEvent.musicTrackPlayed, properties: {'song_id': track.songId}),
              );
            }
          case EngineStatus.paused:
            state = state.copyWith(status: PlayerStatus.paused);
          case EngineStatus.buffering:
            state = state.copyWith(status: PlayerStatus.buffering);
        }
      case EngineFailed():
        final video = state.current?.videoId;
        if (video == null) return;
        unawaited(
          ref
              .read(analyticsProvider)
              .track(AnalyticsEvent.musicTrackUnavailable, properties: {'song_id': state.current!.songId}),
        );
        state = state.copyWith(unavailable: {...state.unavailable, video});
        final next = state.nextIndex;
        if (next != null) {
          _select(next, play: true, change: TrackChange.player);
        } else {
          state = state.copyWith(status: PlayerStatus.ended);
        }
      case EngineProgress(:final position, :final duration):
        progress.value = PlaybackProgress(position, duration);
    }
  }

  // -- Transport ----------------------------------------------------------------------

  Future<void> togglePlay() async => state.isPlaying ? pause() : play();

  Future<void> play() async {
    final engine = _engine;
    if (engine == null) return;
    // Over the end of the set: the last song again.
    if (state.status == PlayerStatus.ended) await engine.seekTo(Duration.zero);
    await engine.play();
  }

  Future<void> pause() async {
    if (!state.isOpen) return;
    await _engine?.pause();
  }

  void next() {
    final next = state.nextIndex;
    if (next != null) _select(next, play: true, change: TrackChange.player);
  }

  /// Back to the start of this song when into it, else the song before.
  Future<void> previous() async {
    final engine = _engine;
    if (engine == null) return;
    final previous = state.previousIndex;
    final at = await engine.position();
    if (previous == null || at > restartThreshold) {
      await engine.seekTo(Duration.zero);
      return;
    }
    _select(previous, play: true, change: TrackChange.player);
  }

  /// A song picked in the queue; the one playing plays or pauses.
  void playTrack(int index) {
    if (index == state.currentIndex) {
      unawaited(togglePlay());
      return;
    }
    if (index < 0 || index >= state.tracks.length || !state.canPlay(state.tracks[index])) return;
    _select(index, play: true, change: TrackChange.player);
  }

  Future<void> seek(Duration to) async {
    progress.value = PlaybackProgress(to, progress.value.duration);
    await _engine?.seekTo(to);
  }

  /// The chart went to song [index] of [source]: cue its video, playing on
  /// if the player was. A song without a link leaves the player be.
  void followChart(PerformSource source, int index) {
    if (!state.isPlayingFrom(source) || index == state.currentIndex) return;
    if (index < 0 || index >= state.tracks.length || !state.canPlay(state.tracks[index])) return;
    _select(index, play: state.isPlaying, change: TrackChange.chart);
  }

  // -- Adding a link -----------------------------------------------------------------

  /// Saves [input] as [track]'s YouTube link: on this device at once (so it
  /// plays straight away, offline too), and to the server when it can.
  /// Returns why it wasn't saved, or null.
  Future<String?> saveLink(PlayerTrack track, String input) async {
    final video = resolveYouTubeVideoId(input);
    if (video == null) return "That doesn't look like a YouTube link.";
    final repo = ref.read(songDetailRepositoryProvider);
    await repo.setYoutubeUrl(track.songId, canonicalYouTubeUrl(video));
    if (!ref.mounted) return null;
    // A second chance for a link the player had given up on.
    if (state.unavailable.contains(video)) state = state.copyWith(unavailable: {...state.unavailable}..remove(video));
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId != null && ref.read(isOnlineProvider)) unawaited(repo.flush(workspaceId));
    return null;
  }
}
