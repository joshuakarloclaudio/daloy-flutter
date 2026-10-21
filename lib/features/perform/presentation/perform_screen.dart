import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/device/screen_awake.dart';
import '../../../core/prefs/device_prefs.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/platform.dart';
import '../../../shared/widgets/daloy_alert.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/hairline.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../auth/application/session_controller.dart';
import '../../line_ups/data/line_ups_repository.dart';
import '../../live/application/live_session_controller.dart';
import '../../live/domain/live_state.dart';
import '../../live/presentation/live_widgets.dart';
import '../../player/application/music_player_controller.dart';
import '../../player/presentation/perform_player_strip.dart';
import '../../practice/application/practice_controller.dart';
import '../../practice/presentation/widgets/practice_widgets.dart';
import '../../songs/domain/display_prefs.dart';
import '../../songs/presentation/widgets/pinch_zoom.dart';
import '../../sync/realtime_scope.dart';
import '../../sync/workspace_realtime.dart';
import '../application/perform_controller.dart';
import '../domain/page_turn.dart';
import '../domain/perform_sections.dart';
import 'widgets/perform_chrome.dart';
import 'widgets/perform_sheets.dart';
import 'widgets/perform_song_view.dart';
import 'widgets/perform_themed.dart';

/// Perform: the set, full screen, as one chart.
///
/// The songs stack into a single scroll, so when two are played straight
/// through, the end of one and the start of the next share the screen.
/// Arrow keys and Bluetooth page-turners turn about a screen at a time,
/// across song boundaries; a sideways swipe jumps to the next or previous
/// song. A tap on a section marks it as the one being played; a tap on the
/// space around brings the chrome back (it hides itself while you play). The
/// screen stays awake, and everything reads from Drift, so a set plays with
/// no signal.
///
/// Live, the team moves together (`LiveSessionController`): a song change
/// here (however it happened) and a section pick go to everyone, and theirs
/// move the chart here. When someone has taken the lead, only their moves
/// count, and a follower who scrolls away drifts until "Back to live". Cues
/// arrive as a banner over the chart.
///
/// [practice] makes it Practice: the same chart, solo, with a transport
/// (`PracticeController`). Play/Pause walks the chart bar by bar, the click
/// is its own switch, a tapped section is where the clock goes next, and a
/// long press loops one. The chart follows the clock until you scroll away.
///
/// Playing along: the set's YouTube videos play in a capsule above the
/// transport (`MusicPlayer`), linked to the chart both ways. Going to a song
/// (a jump, a swipe, the team) cues its video, playing on if it was; a video
/// ending, or next/previous on the player, moves the chart. Reading on by
/// scrolling doesn't change the video, so the end of a song isn't cut off.
/// Live, the player is this device's own: a team move cues it, but its
/// track changes never go to the team. In Practice, starting the video
/// quiets the click.
class PerformScreen extends ConsumerStatefulWidget {
  const PerformScreen({super.key, required this.source, this.goLive = false, this.practice = false});

  /// A line-up, or (Practice only) a single song.
  final PerformSource source;

  /// Go live as soon as the screen opens.
  final bool goLive;

  /// Practice instead of Perform.
  final bool practice;

  @override
  ConsumerState<PerformScreen> createState() => _PerformScreenState();
}

class _PerformScreenState extends ConsumerState<PerformScreen> with WidgetsBindingObserver {
  static const _autoHideAfter = Duration(seconds: 4);

  /// How far a hand scroll travels up before the chrome comes back, and
  /// down before it goes (when it hides itself at all).
  static const _showAfterUp = 24.0;
  static const _hideAfterDown = 64.0;

  late final ScreenAwake _awake;
  final _scroll = ScrollController();
  final _focus = FocusNode(debugLabel: 'perform');
  final _songKeys = <String, GlobalKey>{};
  final _sectionKeys = <String, Map<String, GlobalKey>>{};

  /// A jump is gliding to this song: the songs it passes don't become current.
  int? _jumpTarget;

  bool _chromeVisible = true;

  /// Tablet: the cue panel is open beside the chart.
  bool _cuesDocked = false;

  /// The panel's width while its edge is being dragged; saved when it lets go.
  double? _cueDragWidth;

  /// How many cues had been seen when the chat was last open; later ones from
  /// others dot the top bar's button.
  int _cuesSeen = 0;
  Timer? _hideTimer;

  /// A sheet or dialog is open: the chrome stays put meanwhile.
  int _overlays = 0;

  double? _pinchZoom;
  bool _pinching = false;

  /// The team moved before the set had loaded here.
  bool _livePending = false;

  /// A hand scroll's travel since it last turned around.
  double _travel = 0;

  /// Going where the team is: the song change that causes isn't news to them.
  bool _applyingTeam = false;

  /// Practice: scrolled away from the bar playing; the chart stops following
  /// until "Follow" or the next section.
  bool _drifted = false;

  /// Practice: where the clock last was, to notice it moving on.
  ({int song, String? section})? _clockAt;

  PerformControllerProvider get _provider => performControllerProvider(widget.source);

  /// Live sessions are Perform's, and a line-up's.
  bool get _canLive => !widget.practice && widget.source is LineUpSource;
  int get _lineUpId => widget.source.lineUpId ?? 0;
  LiveSessionControllerProvider get _liveProvider => liveSessionControllerProvider(_lineUpId);
  LiveSessionController get _live => ref.read(_liveProvider.notifier);

  MusicPlayer get _player => ref.read(musicPlayerProvider.notifier);

  PracticeControllerProvider get _practiceProvider => practiceControllerProvider(widget.source);
  PracticeController get _practice => ref.read(_practiceProvider.notifier);

  /// Practice's beat, held so it can be let go of in [dispose] (no `ref` there).
  ValueNotifier<PracticeBeat?>? _clock;
  bool get _playing => widget.practice && ref.read(_practiceProvider).playing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scroll.addListener(_track);
    _awake = ref.read(screenAwakeProvider);
    unawaited(_awake.hold());
    _scheduleHide();
    if (widget.practice) _clock = _practice.beat..addListener(_onClock);
    if (widget.goLive && _canLive) WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? _goLive() : null);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The OS can drop the wake lock while the app is away; take it back.
    // The session may have moved on meanwhile, too.
    if (state == AppLifecycleState.resumed) {
      unawaited(_awake.hold());
      if (_canLive) unawaited(_live.resync());
    }
    // Practice doesn't play on in the background or with the screen locked.
    if (widget.practice && (state == AppLifecycleState.hidden || state == AppLifecycleState.paused)) {
      _practice.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock?.removeListener(_onClock);
    _hideTimer?.cancel();
    unawaited(_awake.release());
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  // -- Chrome -------------------------------------------------------------------

  void _setChrome(bool visible) {
    if (visible != _chromeVisible) {
      setState(() => _chromeVisible = visible);
      // Immersive while playing: the status and navigation bars go with the chrome.
      unawaited(SystemChrome.setEnabledSystemUIMode(visible ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky));
    }
    _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!_chromeVisible || _overlays > 0) return;
    if (!(ref.read(_provider).prefs.autoHide)) return;
    // Practice keeps its controls while paused: Play is the next thing you want.
    if (widget.practice && !_playing) return;
    _hideTimer = Timer(_autoHideAfter, () {
      if (mounted && _overlays == 0) _setChrome(false);
    });
  }

  void _toggleChrome() => _setChrome(!_chromeVisible);

  /// Runs a sheet or dialog with the chrome held open, then restarts the clock.
  Future<T?> _overlay<T>(Future<T?> Function() open) async {
    _overlays++;
    _hideTimer?.cancel();
    try {
      return await open();
    } finally {
      _overlays--;
      if (mounted) {
        _scheduleHide();
        _focus.requestFocus();
      }
    }
  }

  // -- Moving through the set ------------------------------------------------------

  bool get _animate => !MediaQuery.disableAnimationsOf(context);

  /// Just under the top chrome: where a song's heading lands on a jump, and
  /// where the first song starts.
  double get _readLine => MediaQuery.paddingOf(context).top + performTopChromeHeight + DaloySpace.s4;

  RenderBox? _box(GlobalKey? key) {
    final box = key?.currentContext?.findRenderObject();
    return box is RenderBox && box.attached ? box : null;
  }

  /// A song's top on screen, or null before it has laid out.
  double? _songTop(PerformSong song) => _box(_songKeys[song.key])?.localToGlobal(Offset.zero).dy;

  /// The scroll offset that puts [box]'s top on the read line.
  double? _offsetFor(RenderBox? box) {
    if (box == null || !_scroll.hasClients) return null;
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return null;
    return (viewport.getOffsetToReveal(box, 0).offset - _readLine).clamp(0.0, _scroll.position.maxScrollExtent);
  }

  /// The scroll offset that brings all of [box] into view between the
  /// chrome, moving as little as possible; null when it's already in view.
  double? _revealOffset(RenderBox? box) {
    if (box == null || !_scroll.hasClients) return null;
    final media = MediaQuery.of(context);
    final top = box.localToGlobal(Offset.zero).dy;
    final delta = revealDelta(
      top: top,
      bottom: top + box.size.height,
      upper: _chromeVisible ? _readLine : media.padding.top + DaloySpace.s2,
      lower:
          media.size.height -
          media.padding.bottom -
          (_chromeVisible ? _bottomChrome : 0) -
          (ref.read(musicPlayerProvider).isOpen ? performPlayerStripHeight : 0) -
          DaloySpace.s2,
    );
    if (delta == null) return null;
    return (_scroll.offset + delta).clamp(0.0, _scroll.position.maxScrollExtent);
  }

  /// Follows the song being read as the set scrolls by.
  void _track() {
    if (_jumpTarget != null || !_scroll.hasClients) return;
    // Playing, the clock says which song is current.
    if (_playing) return;
    final state = ref.read(_provider);
    // A highlighted section keeps its song current while it's on screen —
    // say the next song's intro, picked before its title reaches the top.
    if (_sectionOnScreen(state)) return;
    final tops = [for (final song in state.songs) _songTop(song) ?? double.infinity];
    final media = MediaQuery.of(context);
    final position = _scroll.position;
    // A song is current once its heading is a quarter of the way into the chart.
    final line = _readLine + (position.viewportDimension - _readLine) * 0.25;
    final current = currentSongAt(
      tops,
      readLine: line,
      atEnd: position.pixels >= position.maxScrollExtent - 1,
      viewportBottom: media.size.height - media.padding.bottom,
    );
    if (current != state.songIndex) ref.read(_provider.notifier).showSong(current);
  }

  bool _sectionOnScreen(PerformState state) {
    final id = state.activeSectionId;
    if (id == null) return false;
    final box = _box(_sectionKeys[state.current?.key]?[id]);
    if (box == null) return false;
    final top = box.localToGlobal(Offset.zero).dy;
    return top + box.size.height > _readLine && top < MediaQuery.sizeOf(context).height;
  }

  /// Glides to [offset], holding "current" on [song] until it lands.
  Future<void> _glide(double offset, int song) async {
    _jumpTarget = song;
    try {
      if (_animate) {
        await _scroll.animateTo(offset, duration: DaloyMotion.medium, curve: DaloyMotion.ease);
      } else {
        _scroll.jumpTo(offset);
      }
    } finally {
      _jumpTarget = null;
    }
  }

  /// Goes to a song. [fromTeam]: the live session moved, so don't send it
  /// back. [fromPlayer]: the video moved on, so don't cue it again.
  void _goToSong(int index, {bool fromTeam = false, bool fromPlayer = false}) {
    final state = ref.read(_provider);
    if (index < 0 || index >= state.songs.length) {
      if (!fromTeam) unawaited(HapticFeedback.heavyImpact());
      return;
    }
    final offset = _offsetFor(_box(_songKeys[state.songs[index].key]));
    if (offset == null) return;
    unawaited(HapticFeedback.selectionClick());
    if (widget.practice) {
      _drifted = false;
      _practice.seekSong(index);
    }
    if (fromPlayer) {
      // The player is this device's own: its moves aren't the team's.
      _applyingTeam = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyingTeam = false);
      if (_canLive) _live.drift();
    } else {
      _player.followChart(widget.source, index);
    }
    ref.read(_provider.notifier).showSong(index);
    unawaited(_glide(offset, index));
  }

  void _nextSong() => _goToSong(ref.read(_provider).songIndex + 1);

  /// Back to the top of this song when well into it, else the song before.
  void _previousSong() {
    final state = ref.read(_provider);
    final current = state.current;
    if (current == null) return;
    final top = _songTop(current) ?? _readLine;
    _goToSong(previousSongTarget(current: state.songIndex, currentTop: top, readLine: _readLine));
  }

  /// One page forward or back, straight across song boundaries.
  void _turn({required bool forward}) {
    if (!_scroll.hasClients) return;
    final padding = MediaQuery.paddingOf(context);
    final target = pageTurnTarget(
      offset: _scroll.offset,
      maxExtent: _scroll.position.maxScrollExtent,
      step: pageStep(_scroll.position.viewportDimension - padding.top - padding.bottom),
      forward: forward,
    );
    if (target == null) {
      unawaited(HapticFeedback.heavyImpact());
    } else if (_animate) {
      unawaited(_scroll.animateTo(target, duration: DaloyMotion.medium, curve: DaloyMotion.ease));
    } else {
      _scroll.jumpTo(target);
    }
  }

  void _selectSection(String id, {int? songIndex}) {
    if (widget.practice) {
      // Practice: a section is where the clock goes (at once, or on Play).
      setState(() => _drifted = false);
      _practice.seekSection(songIndex ?? ref.read(_provider).songIndex, id);
      _scheduleHide();
      _revealSection(id);
      return;
    }
    final notifier = ref.read(_provider.notifier);
    if (songIndex != null) notifier.showSong(songIndex);
    notifier.selectSection(id);
    final state = ref.read(_provider);
    _live.move(songIndex: state.songIndex, sectionId: state.activeSectionId, viewMode: state.viewMode, now: true);
    _scheduleHide();
    if (state.activeSectionId != null) _revealSection(id);
  }

  /// Once it has drawn as active, scrolls just enough to show all of the
  /// section — not at all when it's already in view.
  void _revealSection(String id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(_provider);
      final offset = _revealOffset(_box(_sectionKeys[state.current?.key]?[id]));
      if (offset != null) unawaited(_glide(offset, state.songIndex));
    });
  }

  // -- Practice --------------------------------------------------------------------

  Future<void> _togglePlay() async {
    final played = await _practice.toggle();
    if (!mounted) return;
    if (!played) {
      // No tempo to play at: set one first.
      unawaited(_openTempo());
      return;
    }
    setState(() => _drifted = false);
    _scheduleHide();
  }

  Future<void> _openTempo() => _overlay(() => showPracticeTempoSheet(context, widget.source));

  /// What the bottom chrome covers: the transport, and in Practice the
  /// scrubber over it when the song has bars.
  double get _bottomChrome =>
      performBottomChromeHeight +
      (widget.practice ? practiceScrubberRoom(hasBars: _practice.barsOf(_practice.clockSong).isNotEmpty) : 0);

  /// A bar or chord tapped in the chart: the clock goes there.
  void _seekBar(int song, String sectionId, {required int line, required int bar, int? atom}) {
    if (!_practice.seekBar(song, sectionId, line: line, bar: bar, atom: atom)) return;
    setState(() => _drifted = false);
    _scheduleHide();
  }

  /// Scrubbing: paused, where Play starts follows the finger; playing, the
  /// chart goes to look and the clock jumps there once it lets go.
  void _scrub(int song, int step, {required bool done}) {
    if (done || !_playing) _practice.seekStep(song, step);
    final section = _practice.barsOf(song).elementAtOrNull(step)?.sectionId;
    if (section != null) _revealSection(section);
    if (done && _drifted) setState(() => _drifted = false);
  }

  /// A bar on or back (the scrubber's arrows, ← →); a section with [section].
  void _nudge(int delta, {bool section = false}) {
    final moved = section ? _practice.stepSection(delta) : _practice.stepBar(delta);
    if (!moved) return;
    if (_drifted) setState(() => _drifted = false);
    _follow();
  }

  /// The practice speed, a notch at a time (- and =), within the sheet's range.
  void _nudgeSpeed(int delta) {
    final percent = ref.read(_practiceProvider).tempoPercent;
    final next = (percent + delta).clamp(50, 120);
    if (next == percent) {
      unawaited(HapticFeedback.heavyImpact());
      return;
    }
    _practice.setTempoPercent(next);
    _toast(next == 100 ? 'Full speed' : 'Speed $next%');
  }

  /// The clock moved: the chart follows it to each new section (or song),
  /// unless you've scrolled away — the next section brings it back.
  void _onClock() {
    final beat = _practice.beat.value;
    if (beat == null || !mounted) return;
    final now = (song: beat.position.song, section: beat.step?.sectionId);
    if (now == _clockAt) return;
    final songChanged = now.song != _clockAt?.song;
    _clockAt = now;
    if (!beat.playing) return;
    if (_drifted) setState(() => _drifted = false);
    final section = now.section;
    if (section != null) {
      _revealSection(section);
    } else if (songChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final songs = ref.read(_provider).songs;
        if (now.song >= songs.length) return;
        final offset = _offsetFor(_box(_songKeys[songs[now.song].key]));
        if (offset != null) unawaited(_glide(offset, now.song));
      });
    }
  }

  void _follow() {
    setState(() => _drifted = false);
    final section = _practice.beat.value?.step?.sectionId;
    if (section != null) _revealSection(section);
  }

  void _onSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 300) return;
    velocity < 0 ? _nextSong() : _previousSong();
  }

  // -- Live --------------------------------------------------------------------------

  /// Goes where the team is: their song, and the section they highlighted
  /// in this view. A highlight cleared on the same song leaves the chart be.
  void _applyLive() {
    final position = ref.read(_liveProvider).position;
    final state = ref.read(_provider);
    if (position == null) return;
    if (state.songs.isEmpty) {
      _livePending = true;
      return;
    }
    _livePending = false;
    final wanted = position.sectionFor(state.viewMode);
    // The section names its own song (its id carries it). A web client may
    // send the song whose title is at the top instead, with a section from
    // the next song already on screen — so trust the section.
    final owner = wanted == null ? -1 : state.songs.indexWhere((song) => song.sections.any((s) => s.id == wanted));
    final index = owner >= 0 ? owner : position.songIndex.clamp(0, state.songs.length - 1);
    final song = state.songs[index];
    final section = owner >= 0 ? wanted : null;
    final sameSong = index == state.songIndex;
    if (sameSong && section == state.activeSectionId) return;

    final notifier = ref.read(_provider.notifier);
    if (!sameSong) {
      unawaited(HapticFeedback.selectionClick());
      _player.followChart(widget.source, index);
    }
    _applyingTeam = true;
    notifier.showSong(index);
    notifier.setSection(section);
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyingTeam = false);
    if (section != null) {
      _revealSection(section);
    } else if (!sameSong) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final offset = _offsetFor(_box(_songKeys[song.key]));
        if (offset != null) unawaited(_glide(offset, index));
      });
    }
  }

  /// Following a leader, a finger on the chart drifts away from them; the
  /// idle clock runs from when it lets go.
  ///
  /// Scrolling back up a little brings the chrome back, as in Safari;
  /// reading on hides it again.
  bool _onScroll(ScrollNotification n) {
    if (n is ScrollStartNotification && n.dragDetails != null) {
      _travel = 0;
      if (_canLive) _live.drift();
      if (_playing && !_drifted) setState(() => _drifted = true);
    } else if (n is ScrollUpdateNotification && n.dragDetails != null) {
      final delta = n.scrollDelta ?? 0;
      if (delta == 0) return false;
      // Restart the count each time the finger changes direction.
      if (delta.sign != _travel.sign) _travel = 0;
      _travel += delta;
      if (!_chromeVisible && _travel <= -_showAfterUp) {
        _setChrome(true);
      } else if (_chromeVisible && _travel >= _hideAfterDown && _overlays == 0 && ref.read(_provider).prefs.autoHide) {
        _setChrome(false);
      }
    } else if (n is ScrollEndNotification && _canLive && ref.read(_liveProvider).drifted) {
      _live.drift();
    }
    return false;
  }

  Future<void> _goLive() async {
    final active = ref.read(activeLiveSessionProvider).value;
    if (active != null && active.lineUpId != _lineUpId) {
      final lineUps = ref.read(workspaceLineUpsProvider).value ?? const [];
      final title = lineUps.where((l) => l.id == active.lineUpId).firstOrNull?.title ?? 'Another line-up';
      _toast('“$title” is live now. End that session before going live here.');
      return;
    }
    unawaited(HapticFeedback.mediumImpact());
    await _live.join();
  }

  void _openLive() =>
      _overlay(() => showLiveSessionSheet(context, lineUpId: _lineUpId, onLeft: () {}, onEnded: _leave));

  /// A tablet has room to keep the cues beside the chart; a phone gets a sheet.
  bool get _canDockCues =>
      MediaQuery.sizeOf(context).shortestSide >= DaloyBreakpoints.tabletShortestSide && ref.read(_liveProvider).isIn;

  void _onCueSent(bool sent) {
    if (!sent && mounted) _toast('That cue didn’t go out. Check your connection.');
  }

  void _setCuesDocked(bool open) {
    _live.dismissIncoming();
    setState(() => _cuesDocked = open);
  }

  /// The panel's width: dragged, else the saved one, never over half the screen.
  double _cuePanelWidth(Size screen) => (_cueDragWidth ?? ref.read(devicePrefsControllerProvider).cuePanelWidth).clamp(
    DevicePrefs.minCuePanelWidth,
    screen.width / 2 < DevicePrefs.minCuePanelWidth ? DevicePrefs.minCuePanelWidth : screen.width / 2,
  );

  void _markCuesSeen() => _cuesSeen = ref.read(_liveProvider).cues.length;

  int _unreadCues(LiveState live) {
    final me = ref.read(sessionControllerProvider).value?.user.id;
    return live.cues.skip(_cuesSeen).where((cue) => cue.senderId == null || cue.senderId != me).length;
  }

  void _openCues() {
    if (_canDockCues) {
      _markCuesSeen();
      return _setCuesDocked(!_cuesDocked);
    }
    _markCuesSeen();
    unawaited(
      _overlay(() => showCueChat(context, lineUpId: _lineUpId, onSent: _onCueSent)).whenComplete(_markCuesSeen),
    );
  }

  void _onLiveEnded(LiveEnd? why) {
    if (why == null) return;
    final message = switch (why) {
      LiveEnd.endedByTeam => 'The live session has ended.',
      LiveEnd.left => null,
      LiveEnd.failed => 'Couldn’t go live. Check your connection and try again.',
    };
    if (message != null) _toast(message);
    _live.clearEnded();
    // Over for everyone: nothing left to follow here, so back to where Perform was opened.
    if (why == LiveEnd.endedByTeam) _leave();
  }

  void _toast(String message) => showDaloyToast(ScaffoldMessenger.of(context), message);

  // -- Panels ----------------------------------------------------------------------

  void _openSettings() => _overlay(() => showPerformSettingsSheet(context, widget.source));

  void _openSetlist() => _overlay(
    () => showPerformSetlistSheet(
      context,
      source: widget.source,
      onSong: _goToSong,
      onSection: (song, section) => _selectSection(section, songIndex: song),
    ),
  );

  void _openSong() => _overlay(() => showPerformSongSheet(context, widget.source));

  // -- Playing along -----------------------------------------------------------------

  /// The set's videos, from the song on screen (or the next one with a link).
  void _playAlong() {
    unawaited(HapticFeedback.lightImpact());
    _player.open(widget.source, start: ref.read(_provider).songIndex);
  }

  void _listenPlayer() {
    // The video moved on by itself (or by its own buttons): the chart follows.
    ref.listen(musicPlayerProvider.select((s) => s.serial), (_, _) {
      final player = ref.read(musicPlayerProvider);
      final index = player.currentIndex;
      if (!player.isPlayingFrom(widget.source) || player.change != TrackChange.player || index == null) return;
      if (index == ref.read(_provider).songIndex) return;
      _goToSong(index, fromPlayer: true);
    });
    if (widget.practice) {
      // The recording keeps time: the click goes quiet when it starts.
      ref.listen(musicPlayerProvider.select((s) => s.isPlaying && s.isPlayingFrom(widget.source)), (_, along) {
        if (along) _practice.muteForVideo();
      });
    }
  }

  // -- Leaving -----------------------------------------------------------------------

  Future<void> _confirmLeave() async {
    // Practice is just you: nothing to lose by leaving.
    if (widget.practice) {
      _practice.pause();
      _leave();
      return;
    }
    final live = ref.read(_liveProvider);
    if (live.isIn) {
      final alone = live.count <= 1;
      final leave = await _overlay(
        () => confirmInPerform(
          context,
          title: 'Leave the live session?',
          body: alone ? 'You’re the only one here, so the session ends.' : 'The team keeps going without you.',
          confirm: 'Leave',
          cancel: 'Keep playing',
        ),
      );
      if (leave != true || !mounted) return;
      unawaited(_live.leave());
      _leave();
      return;
    }
    final leave = await _overlay(
      () => confirmAlert(
        context,
        title: 'Leave Perform?',
        message: 'You’ll go back to the line-up.',
        confirmLabel: 'Leave',
        cancelLabel: 'Keep playing',
        native: false,
        wrap: (child) => PerformThemed(child: child),
      ),
    );
    if (leave == true && mounted) _leave();
  }

  void _leave() {
    // A sheet or dialog may be up (the session can end under it): close it first.
    Navigator.of(context).popUntil((route) => route is! PopupRoute);
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(switch (widget.source) {
        LineUpSource(:final id) => Routes.lineUp(id),
        SongSource(:final id) => Routes.song(id),
      });
    }
  }

  // -- Keys and pedals -----------------------------------------------------------------

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    // Held, ← → keep stepping.
    if (widget.practice && (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.arrowRight)) {
      _nudge(key == LogicalKeyboardKey.arrowRight ? 1 : -1, section: shift);
      return KeyEventResult.handled;
    }
    if (widget.practice && event is KeyDownEvent) {
      // Practice: space plays and pauses, M mutes the click, R restarts,
      // ← → step a bar (a section with shift), L loops the section, T opens
      // the tempo, - and = change the speed. Up/down still turn the page.
      if (key == LogicalKeyboardKey.space) {
        unawaited(_togglePlay());
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyL) {
        _practice.toggleLoopHere();
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyT) {
        unawaited(_openTempo());
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.minus || key == LogicalKeyboardKey.equal) {
        _nudgeSpeed(key == LogicalKeyboardKey.equal ? 5 : -5);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyM) {
        unawaited(_practice.setClick(!ref.read(_practiceProvider).clickOn));
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyR) {
        _practice.restart();
        return KeyEventResult.handled;
      }
    }
    // Page-turner pedals send arrows or Page Up/Down; keyboards add space.
    if (key == LogicalKeyboardKey.space) {
      _turn(forward: !shift);
    } else if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.pageDown) {
      _turn(forward: true);
    } else if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.pageUp) {
      _turn(forward: false);
    } else if (key == LogicalKeyboardKey.bracketRight || key == LogicalKeyboardKey.keyN) {
      _nextSong();
    } else if (key == LogicalKeyboardKey.bracketLeft || key == LogicalKeyboardKey.keyP) {
      _previousSong();
    } else if (key == LogicalKeyboardKey.keyC && _canLive && ref.read(_liveProvider).isIn) {
      _openCues();
    } else if (key == LogicalKeyboardKey.keyL && _canLive && ref.read(_liveProvider).drifted) {
      _live.backToLive();
    } else if (key == LogicalKeyboardKey.keyK && ref.read(musicPlayerProvider).isOpen) {
      unawaited(_player.togglePlay());
    } else if (key == LogicalKeyboardKey.escape) {
      unawaited(_confirmLeave());
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  // -- Build ---------------------------------------------------------------------------

  void _listenLive() {
    ref.listen(_liveProvider.select((s) => s.moves), (_, _) => _applyLive());
    // However the song changed here — a jump, a swipe, a pedal, a scroll —
    // it goes to the team (when this device's moves do).
    ref.listen(_provider.select((s) => s.songIndex), (_, index) {
      if (_applyingTeam) return;
      final state = ref.read(_provider);
      _live.move(songIndex: index, sectionId: state.activeSectionId, viewMode: state.viewMode);
    });
    ref.listen(_liveProvider.select((s) => s.ended), (_, why) => _onLiveEnded(why));
    ref.listen(_liveProvider.select((s) => (inSession: s.isIn, id: s.leaderId, name: s.leaderName)), (was, now) {
      // Joining a led session says who leads; leaving or an ending says nothing.
      if (!now.inSession) return;
      LiveParticipant? leader(({bool inSession, int? id, String? name})? s) =>
          s == null || !s.inSession || s.id == null ? null : LiveParticipant(userId: s.id!, name: s.name ?? 'Someone');
      final message = leaderChangeMessage(
        previous: leader(was),
        next: leader(now),
        me: ref.read(sessionControllerProvider).value?.user.id,
      );
      if (message != null) _toast(message);
    });
    ref.listen(_liveProvider.select((s) => s.incoming?.id), (_, id) {
      if (id != null) unawaited(HapticFeedback.mediumImpact());
    });
    ref.listen(_provider.select((s) => s.songs.isNotEmpty), (_, loaded) {
      if (loaded && _livePending) WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? _applyLive() : null);
    });
  }

  void _pinchEnd() {
    final zoom = _pinchZoom;
    setState(() {
      _pinchZoom = null;
      _pinching = false;
    });
    if (zoom == null) return;
    unawaited(HapticFeedback.lightImpact());
    unawaited(ref.read(_provider.notifier).setZoom(ChartPrefs.clampZoom(zoom)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_provider);
    switch (widget.source) {
      case LineUpSource(:final id):
        listenRemoteChanges(ref, context, RemoteKind.lineUp, id);
      case SongSource(:final id):
        listenRemoteChanges(ref, context, RemoteKind.song, id);
    }

    // Turning auto-hide on starts the clock; turning it off brings the chrome back.
    ref.listen(_provider.select((s) => s.prefs.autoHide), (_, on) => on ? _scheduleHide() : _setChrome(true));

    final live = _canLive ? ref.watch(_liveProvider) : const LiveState();
    if (_canLive) _listenLive();
    _listenPlayer();
    final practice = widget.practice ? ref.watch(_practiceProvider) : null;
    if (widget.practice) {
      // Paused, the controls stay; playing, they go after a while.
      ref.listen(
        _practiceProvider.select((s) => s.playing),
        (_, playing) => playing ? _scheduleHide() : _setChrome(true),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmLeave());
      },
      child: PerformThemed(
        child: Builder(
          builder: (context) => Focus(
            focusNode: _focus,
            autofocus: true,
            onKeyEvent: _onKey,
            child: Scaffold(body: _body(context, state, live, practice)),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, PerformState state, LiveState live, PracticeState? practice) {
    if (state.isLoading) return const _Skeleton();
    if (state.notFound) {
      return _Message(
        title: state.isSingleSong ? 'Song not found' : 'Line-up not found',
        body: 'It may have been removed, or it hasn’t synced to this device yet.',
        backLabel: state.isSingleSong ? 'Back to the song' : 'Back to line-up',
        onBack: _leave,
      );
    }
    if (state.songs.isEmpty) {
      return _Message(
        title: state.songsMissing ? 'Songs not on this device yet' : 'No songs in this line-up',
        body: state.songsMissing
            ? 'Open the line-up once while online so its songs sync, then play it anywhere.'
            : 'Add songs to the line-up to perform it.',
        backLabel: 'Back to line-up',
        onBack: _leave,
      );
    }

    final screen = MediaQuery.of(context);
    final docked = _cuesDocked && live.isIn && screen.size.shortestSide >= DaloyBreakpoints.tabletShortestSide;
    final panelWidth = _cuePanelWidth(screen.size);
    // The chart lays out in what the panel leaves, as if that were the screen.
    final media = docked
        ? screen.copyWith(
            size: Size(screen.size.width - panelWidth - screen.padding.right, screen.size.height),
            padding: screen.padding.copyWith(right: 0),
          )
        : screen;
    final width = media.size.width;
    final player = ref.watch(musicPlayerProvider.select((s) => (open: s.isOpen, here: s.isPlayingFrom(widget.source))));
    final strip = player.open ? performPlayerStripHeight : 0.0;
    final canPlayAlong = hasInAppPlayer && !player.here && state.songs.any((song) => song.row.hasYoutube);
    final gutter = width >= DaloyBreakpoints.tablet ? DaloySpace.s6 : DaloySpace.s1;
    final contentPadding = EdgeInsets.fromLTRB(
      gutter + media.padding.left,
      media.padding.top + performTopChromeHeight + DaloySpace.s4,
      gutter + media.padding.right,
      // Run-out under the last song, so it too can be read from the top.
      media.padding.bottom + _bottomChrome + strip + media.size.height * 0.4,
    );
    final zoom = _pinchZoom ?? state.chart.zoom.toDouble();
    final hasSetlist = state.songs.length > 1;
    final chartClock = practice == null
        ? null
        : PracticeChartClock(
            beat: _practice.beat,
            flash: practice.prefs.practiceFlash,
            loop: practice.loop,
            onLoop: _practice.toggleLoop,
            onSeekBar: _seekBar,
          );
    final loop = practice?.loop;
    final loopLabel = loop == null || loop.song >= state.songs.length
        ? null
        : () {
            final sections = state.songs[loop.song].sections;
            final i = sections.indexWhere((s) => s.id == loop.sectionId);
            return i < 0 ? null : sectionChipLabel(sections[i], i);
          }();

    final chart = Stack(
      children: [
        Positioned.fill(
          child: PinchZoom(
            onActiveChanged: (active) => setState(() => _pinching = active),
            onUpdate: (factor) => setState(
              () => _pinchZoom = (state.chart.zoom * factor).clamp(
                ChartPrefs.minZoom.toDouble(),
                ChartPrefs.maxZoom.toDouble(),
              ),
            ),
            onEnd: (_) => _pinchEnd(),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleChrome,
              onHorizontalDragEnd: _pinching ? null : _onSwipe,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: SingleChildScrollView(
                  controller: _scroll,
                  physics: _pinching ? const NeverScrollableScrollPhysics() : null,
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, song) in state.songs.indexed) ...[
                        if (i > 0) const _SongBreak(),
                        KeyedSubtree(
                          key: _songKeys.putIfAbsent(song.key, GlobalKey.new),
                          child: PerformSongView(
                            song: song,
                            number: i + 1,
                            count: state.songs.length,
                            zoom: zoom,
                            notesVisible: state.prefs.notesVisible,
                            activeSectionId: state.activeSectionId,
                            sectionKeys: _sectionKeys.putIfAbsent(song.key, () => {}),
                            onSelectSection: (id) => _selectSection(id, songIndex: i),
                            onOpenSong: () {
                              ref.read(_provider.notifier).showSong(i);
                              _openSong();
                            },
                            practice: chartClock,
                          ),
                        ),
                      ],
                      if (hasSetlist) ...[const SizedBox(height: DaloySpace.s10), const PerformSetEnd()],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: PerformChromeSlide(
            visible: _chromeVisible,
            fromTop: true,
            child: Listener(
              onPointerDown: (_) => _scheduleHide(),
              child: PerformTopBar(
                state: state,
                mode: widget.practice ? 'Practice' : 'Perform',
                onClose: _confirmLeave,
                onOpenSetlist: hasSetlist ? _openSetlist : null,
                onOpenSettings: _openSettings,
                onSelectSection: _selectSection,
                onLoopSection: practice == null ? null : (id) => _practice.toggleLoop(state.songIndex, id),
                loopSectionId: loop?.song == state.songIndex ? loop?.sectionId : null,
                live: _canLive ? PerformLiveAction(lineUpId: _lineUpId, onGoLive: _goLive, onOpen: _openLive) : null,
                onPlayAlong: canPlayAlong ? _playAlong : null,
                onOpenCues: live.isIn ? _openCues : null,
                cuesOpen: docked,
                unreadCues: docked ? 0 : _unreadCues(live),
                cuesTyping: !docked && live.typing.isNotEmpty,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: PerformChromeSlide(
            visible: _chromeVisible,
            fromTop: false,
            child: Listener(
              onPointerDown: (_) => _scheduleHide(),
              child: widget.practice
                  ? PracticeTransport(
                      source: widget.source,
                      onPlay: () => unawaited(_togglePlay()),
                      onPrev: state.hasPrev ? _previousSong : null,
                      onNext: state.hasNext ? _nextSong : null,
                      onOpenTempo: () => unawaited(_openTempo()),
                      onScrub: _scrub,
                      onNudge: _nudge,
                    )
                  : PerformTransport(
                      state: state,
                      onPrev: _previousSong,
                      onNext: _nextSong,
                      onOpenSetlist: hasSetlist ? _openSetlist : null,
                    ),
            ),
          ),
        ),
        // Playing along: the video stays when the chrome goes (it can't play unseen).
        if (player.open)
          AnimatedPositioned(
            duration: DaloyMotion.medium,
            curve: DaloyMotion.ease,
            left: 0,
            right: 0,
            // Above the transport; on its own at the bottom once that's gone.
            bottom: _chromeVisible ? _bottomChrome : 0,
            child: Listener(
              onPointerDown: (_) => _scheduleHide(),
              child: PerformPlayerStrip(source: widget.source),
            ),
          ),
        // Over everything but the panels: a cue is read at a glance, chrome or not.
        Positioned(
          top: media.padding.top + (_chromeVisible ? performTopChromeHeight : 0) + DaloySpace.s2,
          left: DaloySpace.s4 + media.padding.left,
          right: DaloySpace.s4 + media.padding.right,
          child: Center(
            child: LiveCueBanner(
              // The panel already shows it, docked.
              cue: docked ? null : live.incoming,
              onOpen: () {
                _live.dismissIncoming();
                _openCues();
              },
              onDone: _live.dismissIncoming,
            ),
          ),
        ),
        if (_canLive)
          Positioned(
            bottom: media.padding.bottom + (_chromeVisible ? _bottomChrome : 0) + strip + DaloySpace.s3,
            left: DaloySpace.s4,
            right: DaloySpace.s4,
            child: Center(child: BackToLivePill(lineUpId: _lineUpId)),
          ),
        if (practice != null) ...[
          // Counting in: big, under the top bar, chrome or not.
          Positioned(
            top: media.padding.top + (_chromeVisible ? performTopChromeHeight : 0) + DaloySpace.s4,
            left: 0,
            right: 0,
            child: Center(
              child: PracticeCountIn(
                clock: _practice.beat,
                bpm: _practice.currentTempo?.playingBpm ?? 120,
                onStop: _practice.pause,
              ),
            ),
          ),
          Positioned(
            bottom: media.padding.bottom + (_chromeVisible ? _bottomChrome : 0) + strip + DaloySpace.s3,
            left: DaloySpace.s4,
            right: DaloySpace.s4,
            child: Center(
              child: Wrap(
                spacing: DaloySpace.s2,
                runSpacing: DaloySpace.s2,
                alignment: WrapAlignment.center,
                children: [
                  if (_drifted && practice.playing)
                    PracticePill(icon: TablerIcons.focus_2, label: 'Follow', onPressed: _follow),
                  if (loopLabel != null)
                    PracticePill(
                      icon: TablerIcons.repeat,
                      label: 'Looping $loopLabel · Stop',
                      semanticLabel: 'Looping $loopLabel. Stop looping',
                      onPressed: () => _practice.setLoop(null),
                    ),
                ],
              ),
            ),
          ),
        ],
        // While the chrome is away, a quiet handle in the corner brings it back.
        Positioned(
          top: media.padding.top + DaloySpace.s2,
          right: media.padding.right + DaloySpace.s3,
          child: PerformChromeHandle(
            visible: !_chromeVisible,
            label: state.songs.length > 1 ? '${state.songIndex + 1}/${state.songs.length}' : null,
            live: live.isIn,
            onPressed: () => _setChrome(true),
          ),
        ),
      ],
    );

    if (!docked) return chart;
    return Row(
      children: [
        Expanded(
          child: MediaQuery(data: media, child: chart),
        ),
        CuePanel(
          lineUpId: _lineUpId,
          // Safe-area on the right belongs to the panel, which sits against that edge.
          width: panelWidth + screen.padding.right,
          onSent: _onCueSent,
          onClose: () {
            _markCuesSeen();
            _setCuesDocked(false);
          },
          onResize: (delta) => setState(() {
            _cueDragWidth = (panelWidth + delta).clamp(DevicePrefs.minCuePanelWidth, DevicePrefs.maxCuePanelWidth);
          }),
          onResizeEnd: () {
            final width = _cueDragWidth;
            if (width != null) ref.read(devicePrefsControllerProvider.notifier).setCuePanelWidth(width);
            setState(() => _cueDragWidth = null);
          },
        ),
      ],
    );
  }
}

/// Between songs: a hairline and some air — enough to see where one song
/// ends, little enough that a segue still fits on one screen.
class _SongBreak extends StatelessWidget {
  const _SongBreak();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: DaloySpace.s6),
    child: const Hairline(),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.body, required this.backLabel, required this.onBack});

  final String title;
  final String body;
  final String backLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(DaloySpace.s8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: context.text.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: DaloySpace.s2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground),
            ),
          ),
          const SizedBox(height: DaloySpace.s5),
          DaloyButton.outline(label: backLabel, onPressed: onBack),
        ],
      ),
    ),
  );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + performTopChromeHeight + DaloySpace.s4;
    return SkeletonPulse(
      child: Padding(
        padding: EdgeInsets.fromLTRB(DaloySpace.s5, top, DaloySpace.s5, 0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 80, height: 12),
            SizedBox(height: DaloySpace.s2),
            SkeletonBox(widthFactor: 0.7, height: 28, radius: DaloyRadii.lg),
            SizedBox(height: DaloySpace.s3),
            Row(
              children: [
                SkeletonBox(width: 80, height: 32, radius: DaloyRadii.full),
                SizedBox(width: DaloySpace.s1_5),
                SkeletonBox(width: 72, height: 32, radius: DaloyRadii.full),
              ],
            ),
            SizedBox(height: DaloySpace.s6),
            SkeletonBox(height: 220, radius: DaloyRadii.xl2),
          ],
        ),
      ),
    );
  }
}
