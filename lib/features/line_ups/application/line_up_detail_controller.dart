import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/realtime/realtime_client.dart';
import '../../../core/realtime/whisper_ids.dart';
import '../../auth/application/session_controller.dart';
import '../../songs/application/song_detail_controller.dart' show maxCapo;
import '../../songs/chart/chord_math.dart';
import '../../songs/chart/nashville.dart';
import '../../songs/data/song_detail_repository.dart';
import '../../songs/domain/display_prefs.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up.dart';
import '../domain/live_session.dart';
import '../domain/setlist_entry.dart';

part 'line_up_detail_controller.g.dart';

/// One song in the set with everything the page draws for it worked out —
/// the twin of `LineUpSongRow` in `use-line-up-detail-page.ts`.
class SetlistSong {
  const SetlistSong({required this.entry, required this.number, this.capo = 0, this.preferNumbers = false});

  final SetlistEntry entry;

  /// 1-based place in the set.
  final int number;

  /// This user's capo; folded into [chartTransposition].
  final int capo;
  final bool preferNumbers;

  int get position => entry.position;
  String get title => entry.song.title;
  String? get artist => _blank(entry.song.artist);
  int get transposition => entry.transposition;
  String? get originalKey => _blank(entry.song.key);

  /// The key the band plays it in at this service.
  String? get displayKey => originalKey == null ? null : transposeKey(originalKey!, transposition);
  bool get canTranspose => originalKey != null;
  bool get isTransposed => transposition % 12 != 0 && originalKey != null;

  /// What the chart is shifted by: the line-up's key change, less the capo.
  int get chartTransposition => transposition - capo;

  bool get canShowNumbers => canUseNumbers(originalKey);

  /// A keyless song falls back to letters while its neighbours show numbers.
  ChordNotation get notation => preferNumbers && canShowNumbers ? ChordNotation.numbers : ChordNotation.letters;
  String? get numberingReference => notation == ChordNotation.numbers ? numberingLabel(displayKey) : null;

  bool get hasChords => _blank(entry.song.content) != null;
  bool get hasLyrics => _blank(entry.song.lyrics) != null;
  bool get hasYoutube => _blank(entry.song.youtubeUrl) != null;
  bool get canEditCapo => entry.lineUpSongId != null;

  /// "72 BPM · 4/4", or null.
  String? get tempo {
    final parts = [if (entry.song.bpm case final bpm?) '$bpm BPM', ?_blank(entry.song.timeSignature)];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  static String? _blank(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
}

class LineUpDetailState {
  const LineUpDetailState({
    this.lineUp,
    this.isLoading = true,
    this.notFound = false,
    this.songsLoaded = false,
    this.songs = const [],
    this.prefs = const ChartPrefs(),
    this.accountNotation = ChordNotation.letters,
    this.isOnline = true,
    this.hasPendingChanges = false,
  });

  final LineUp? lineUp;
  final bool isLoading;

  /// Neither on this device nor on the server.
  final bool notFound;

  /// The song list is on this device (not just the count).
  final bool songsLoaded;
  final List<SetlistSong> songs;
  final ChartPrefs prefs;
  final ChordNotation accountNotation;
  final bool isOnline;

  /// Edits made here that the server hasn't taken yet.
  final bool hasPendingChanges;

  ChordNotation get notation => prefs.notation ?? accountNotation;

  bool get hasSongs => songs.isNotEmpty;

  /// Songs exist on the server but haven't reached this device.
  bool get songsMissing => !songsLoaded && (lineUp?.songsCount ?? 0) > 0;

  bool get canListen => songs.any((s) => s.hasYoutube);

  /// Each song's key in order, for the cover's "key flow".
  List<String> get keyFlow => [for (final s in songs) ?s.displayKey];

  bool get canShowNumbers => songs.any((s) => s.canShowNumbers);
}

/// What opening a line-up does once: pull its songs and this user's capos.
/// Returns false only when the server says it doesn't exist. Watches just
/// the connection and workspace, so writing results to Drift can't re-run it.
@riverpod
Future<bool> lineUpDetailRefresh(Ref ref, int lineUpId) async {
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  final online = ref.watch(isOnlineProvider);
  if (!online || workspaceId == null || lineUpId <= 0) return true;

  final repo = ref.read(lineUpsRepositoryProvider);
  try {
    await Future.wait([repo.refreshDetail(lineUpId, workspaceId), repo.refreshCapos(lineUpId), repo.flushCapos()]);
  } on ApiHttpException catch (e) {
    if (e.status == 404) return false;
  } on ApiException {
    // Offline or flaky: the cached copy stands.
  }
  return true;
}

@riverpod
Stream<LineUp?> lineUpById(Ref ref, int id) => ref.watch(lineUpsRepositoryProvider).watchLineUp(id);

@riverpod
Stream<bool> lineUpSongsLoaded(Ref ref, int id) => ref.watch(lineUpsRepositoryProvider).watchSongsLoaded(id);

@riverpod
Stream<List<SetlistEntry>> lineUpSetlist(Ref ref, int id) => ref.watch(lineUpsRepositoryProvider).watchSetlist(id);

@riverpod
Stream<Map<int, int>> lineUpCapos(Ref ref, int id) => ref.watch(lineUpsRepositoryProvider).watchCapos(id);

/// The line-up details screen — the twin of `use-line-up-detail-route.ts`.
/// Reads only from Drift, so it opens offline; key and capo changes land on
/// the device at once and reach the server when they can.
@riverpod
class LineUpDetailController extends _$LineUpDetailController {
  static const _pushDelay = Duration(milliseconds: 1200);

  /// Per song (by position): taps arrive faster than requests should go.
  /// Not tied to this notifier — it rebuilds on every Drift write, and
  /// leaving mid-wait should still send.
  static final _pushTimers = <(int, int), Timer>{};

  /// Per song: the id the latest key was whispered under, for its save.
  static final _changeIds = <(int, int), String>{};

  @override
  LineUpDetailState build(int lineUpId) {
    final lineUp = ref.watch(lineUpByIdProvider(lineUpId));
    final setlist = ref.watch(lineUpSetlistProvider(lineUpId));
    final capos = ref.watch(lineUpCaposProvider(lineUpId)).value ?? const {};
    final prefs = ref.watch(chartPrefsProvider).value ?? const ChartPrefs();
    final accountNotation = ChordNotation.parse(ref.watch(sessionControllerProvider).value?.user.chordNotation);
    final refresh = ref.watch(lineUpDetailRefreshProvider(lineUpId));
    final outbox = ref.watch(lineUpOutboxProvider).value ?? const {};

    final preferNumbers = (prefs.notation ?? accountNotation) == ChordNotation.numbers;
    final entries = setlist.value ?? const <SetlistEntry>[];

    return LineUpDetailState(
      lineUp: lineUp.value,
      // Wait for the first fetch only when there's nothing cached to show.
      isLoading: !lineUp.hasValue || (lineUp.value == null && refresh.isLoading),
      notFound: lineUp.hasValue && lineUp.value == null && !refresh.isLoading,
      songsLoaded: ref.watch(lineUpSongsLoadedProvider(lineUpId)).value ?? false,
      songs: [
        for (final (i, e) in entries.indexed)
          SetlistSong(
            entry: e,
            number: i + 1,
            capo: e.lineUpSongId == null ? 0 : capos[e.lineUpSongId] ?? 0,
            preferNumbers: preferNumbers,
          ),
      ],
      prefs: prefs,
      accountNotation: accountNotation,
      isOnline: ref.watch(isOnlineProvider),
      hasPendingChanges: outbox.containsKey(lineUpId),
    );
  }

  LineUpsRepository get _repo => ref.read(lineUpsRepositoryProvider);

  SetlistSong? _song(int position) => state.songs.where((s) => s.position == position).firstOrNull;

  // -- Key (for everyone) ---------------------------------------------------

  void transposeUp(int position) => _transpose(position, 1);
  void transposeDown(int position) => _transpose(position, -1);

  /// Back to the key the song is written in.
  void resetKey(int position) {
    final song = _song(position);
    if (song == null || song.transposition == 0) return;
    _setTransposition(position, 0);
  }

  void _transpose(int position, int by) {
    final song = _song(position);
    if (song == null || !song.canTranspose) return;
    // Kept within an octave either way (the server allows ±24).
    var next = song.transposition + by;
    if (next > 11) next -= 12;
    if (next < -11) next += 12;
    _setTransposition(position, next);
  }

  void _setTransposition(int position, int transposition) {
    unawaited(_repo.setSongTransposition(lineUpId, position, transposition));
    final key = (lineUpId, position);
    if (_whisperTransposition(position, transposition) case final changeId?) {
      _changeIds[key] = changeId;
    } else {
      _changeIds.remove(key);
    }
    _pushTimers.remove(key)?.cancel();
    final repo = _repo;
    final id = lineUpId;
    _pushTimers[key] = Timer(_pushDelay, () {
      _pushTimers.remove(key);
      unawaited(repo.pushSongTransposition(id, position, changeId: _changeIds.remove(key)));
    });
  }

  /// Live in this line-up's session (Perform keeps it open): the key goes
  /// to the team at once, on every tap, instead of after the save settles.
  /// Returns the id it went under, or null when it didn't go.
  String? _whisperTransposition(int position, int transposition) {
    final pivot = _song(position)?.entry.lineUpSongId;
    // Only read when something already watches it — reading would start a fetch.
    if (pivot == null || !ref.exists(activeLiveSessionProvider)) return null;
    final session = ref.read(activeLiveSessionProvider).value;
    if (session == null || session.lineUpId != lineUpId) return null;
    final changeId = whisperId();
    final sent = ref.read(realtimeClientProvider).whisper(liveSessionChannel(session.id), 'transposed', {
      'change_id': changeId,
      'user_id': ref.read(sessionControllerProvider).value?.user.id,
      'line_up_song_id': pivot,
      'transposition': transposition,
    });
    return sent ? changeId : null;
  }

  // -- Capo (just me) -------------------------------------------------------

  void capoUp(int position) => _setCapo(position, 1);
  void capoDown(int position) => _setCapo(position, -1);

  void _setCapo(int position, int by) {
    final song = _song(position);
    final pivot = song?.entry.lineUpSongId;
    if (song == null || pivot == null) return;
    final next = (song.capo + by).clamp(0, maxCapo);
    if (next != song.capo) unawaited(_repo.setCapo(lineUpId, pivot, next));
  }

  // -- Display (this device) -------------------------------------------------

  SongDetailRepository get _prefs => ref.read(songDetailRepositoryProvider);

  Future<void> setViewMode(SongViewMode mode) => _prefs.setViewMode(mode);

  Future<void> zoomIn() => _prefs.setZoom(state.prefs.zoom + ChartPrefs.zoomStep);
  Future<void> zoomOut() => _prefs.setZoom(state.prefs.zoom - ChartPrefs.zoomStep);
  Future<void> setZoom(int zoom) => _prefs.setZoom(zoom);

  Future<void> setNotation(ChordNotation notation) => _prefs.setNotation(notation);
}

/// Deletes that can still be undone. Kept alive: the window outlasts the
/// screen the delete started on.
@Riverpod(keepAlive: true)
class LineUpDeletions extends _$LineUpDeletions {
  static const undoWindow = Duration(seconds: 5);

  final _pending = <int, ({RemovedLineUp removed, Timer timer})>{};

  @override
  void build() {
    ref.onDispose(() {
      for (final p in _pending.values) {
        p.timer.cancel();
      }
    });
  }

  /// Takes the line-up off this device now and deletes it on the server once
  /// [undoWindow] passes. [onFailed] runs if the server refuses; the line-up
  /// is back by then.
  Future<bool> start(int lineUpId, {required void Function(String message) onFailed}) async {
    final repo = ref.read(lineUpsRepositoryProvider);
    final removed = await repo.removeLocal(lineUpId);
    if (removed == null) return false;
    _pending[lineUpId]?.timer.cancel();
    _pending[lineUpId] = (
      removed: removed,
      timer: Timer(undoWindow, () async {
        _pending.remove(lineUpId);
        try {
          await repo.deleteRemote(removed);
        } on ApiException catch (e) {
          onFailed(e is NetworkException ? "Couldn't reach the server. The line-up is back." : e.message);
        }
      }),
    );
    return true;
  }

  Future<void> undo(int lineUpId) async {
    final pending = _pending.remove(lineUpId);
    if (pending == null) return;
    pending.timer.cancel();
    await ref.read(lineUpsRepositoryProvider).restore(pending.removed);
  }
}
