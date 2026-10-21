import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/connectivity/online_status.dart';
import '../../auth/application/session_controller.dart';
import '../../perform/application/perform_controller.dart';
import '../../perform/data/perform_prefs_repository.dart';
import '../../songs/data/song_detail_repository.dart';
import '../../songs/domain/display_prefs.dart';
import '../data/click_output.dart';
import '../domain/bar_timeline.dart';
import '../domain/practice_clock.dart';

part 'practice_controller.g.dart';

/// A tempo set for this practice only, on top of what the song has saved.
@immutable
class TempoOverride {
  const TempoOverride({this.bpm, this.timeSignature});

  final int? bpm;
  final String? timeSignature;

  TempoOverride copyWith({int? bpm, String? timeSignature}) =>
      TempoOverride(bpm: bpm ?? this.bpm, timeSignature: timeSignature ?? this.timeSignature);

  @override
  bool operator ==(Object other) => other is TempoOverride && other.bpm == bpm && other.timeSignature == timeSignature;

  @override
  int get hashCode => Object.hash(bpm, timeSignature);
}

/// A section being looped.
typedef SectionLoop = ({int song, String sectionId});

/// Where the clock is, beat by beat. Kept out of [PracticeState] (in
/// [PracticeController.beat]) so a click doesn't rebuild the whole screen —
/// only what draws the beat listens.
@immutable
class PracticeBeat {
  const PracticeBeat({
    required this.position,
    this.step,
    this.beat,
    this.beatsInBar = 4,
    this.countInLeft,
    this.playing = false,
    this.serial = 0,
    this.barNumber,
    this.barCount,
    this.startBeat = 0,
  });

  final BarPosition position;

  /// Waiting (paused, counting in): the beat of [step] the song comes in on —
  /// past 0 when it starts on a chord after the bar's first.
  final int startBeat;

  /// Counts up with every beat heard, so a flash can tell two beats apart
  /// even on a one-bar loop.
  final int serial;

  /// 1-based bar within its section, and the bars the section plays for
  /// (repeats included); null with no bars to walk.
  final int? barNumber;
  final int? barCount;

  /// The bar in the chart, or null when the song has no bars to walk.
  final BarStep? step;

  /// 0-based beat sounding, or null while paused.
  final int? beat;
  final int beatsInBar;

  /// Counting in: the number to say. Null once the song is under way.
  final int? countInLeft;
  final bool playing;

  bool get isCountIn => countInLeft != null;
  bool get isAccent => beat == 0;

  bool get isWaiting => !playing || isCountIn || beat == null;

  /// The atom sounding in [step] (or, waiting, the one it starts on), or
  /// null to light the whole bar.
  int? get atom => isWaiting ? (startBeat == 0 ? null : step?.atomAt(startBeat)) : step?.atomAt(beat!);

  @override
  bool operator ==(Object other) =>
      other is PracticeBeat &&
      other.position == position &&
      other.step == step &&
      other.beat == beat &&
      other.beatsInBar == beatsInBar &&
      other.countInLeft == countInLeft &&
      other.playing == playing &&
      other.serial == serial &&
      other.barNumber == barNumber &&
      other.barCount == barCount &&
      other.startBeat == startBeat;

  @override
  int get hashCode =>
      Object.hash(position, step, beat, beatsInBar, countInLeft, playing, serial, barNumber, barCount, startBeat);
}

@immutable
class PracticeState {
  const PracticeState({
    this.playing = false,
    this.noAudio = false,
    this.tempoPercent = 100,
    this.overrides = const {},
    this.loop,
    this.prefs = const PerformPrefs(),
    this.videoMuted = false,
  });

  /// Play/Pause: the clock and the chord highlights run.
  final bool playing;

  /// Audio wouldn't start: the clock runs, silently.
  final bool noAudio;

  /// 100 is the written tempo; lower slows everything down.
  final int tempoPercent;

  /// By song id: a tempo or metre set just for this practice.
  final Map<int, TempoOverride> overrides;
  final SectionLoop? loop;

  /// The click, haptic and flash switches (per device).
  final PerformPrefs prefs;

  /// The song's YouTube video started, so the click went quiet (the
  /// recording keeps time). For this practice only; the switch is untouched.
  final bool videoMuted;

  bool get clickOn => prefs.practiceClick && !videoMuted;

  PracticeState copyWith({
    bool? playing,
    bool? noAudio,
    int? tempoPercent,
    Map<int, TempoOverride>? overrides,
    SectionLoop? Function()? loop,
    PerformPrefs? prefs,
    bool? videoMuted,
  }) => PracticeState(
    playing: playing ?? this.playing,
    noAudio: noAudio ?? this.noAudio,
    tempoPercent: tempoPercent ?? this.tempoPercent,
    overrides: overrides ?? this.overrides,
    loop: loop == null ? this.loop : loop(),
    prefs: prefs ?? this.prefs,
    videoMuted: videoMuted ?? this.videoMuted,
  );
}

/// One song's tempo as Practice shows it: what's saved, what's set here,
/// and what the click actually runs at.
@immutable
class SongTempo {
  const SongTempo({
    required this.savedBpm,
    required this.savedTimeSignature,
    required this.override,
    required this.tempoPercent,
  });

  final int? savedBpm;
  final String? savedTimeSignature;
  final TempoOverride? override;
  final int tempoPercent;

  /// Before the percentage.
  int? get bpm => override?.bpm ?? savedBpm;
  String? get timeSignature => override?.timeSignature ?? savedTimeSignature;
  int get beats => beatsPerBar(timeSignature);
  bool get hasTempo => bpm != null;

  /// What the click runs at.
  int? get playingBpm => bpm == null ? null : clampBpm(bpm! * tempoPercent / 100);

  /// Set here and different from the song: offer to save it.
  bool get differsFromSong =>
      (override?.bpm != null && override!.bpm != savedBpm) ||
      (override?.timeSignature != null && override!.timeSignature != savedTimeSignature);
}

/// Practice's clock: Play/Pause runs the bar clock and the chord highlights;
/// the click is a separate switch, so the chart can move with the metronome
/// muted. Per device, never sent to a live session.
///
/// Beats are laid out ahead on the click output's clock ([BeatScheduler]),
/// so the click is sample-accurate; the screen hears about each beat when it
/// sounds, through [beat].
@riverpod
class PracticeController extends _$PracticeController {
  static const _tick = Duration(milliseconds: 25);

  /// How far ahead clicks are scheduled: longer than a late timer, short
  /// enough that a tempo change or a mute is heard at once.
  static const _lookahead = Duration(milliseconds: 150);

  /// Time for the output to take the first click.
  static const _startLead = Duration(milliseconds: 80);

  final beat = ValueNotifier<PracticeBeat?>(null);

  late ClickOutput _output;
  late final PracticeCourse _course = PracticeCourse();
  late final BeatScheduler _scheduler = BeatScheduler(_course);
  Future<bool>? _opening;
  Timer? _timer;

  /// Beats laid out, by the timer that shows each one when it sounds.
  final _deliveries = <Timer, ClockBeat>{};
  int _serial = 0;

  /// Where Play starts from: the bar paused on, or the one picked since,
  /// and the beat in it (a chord after the bar's first).
  BarPosition? _held;
  int _heldBeat = 0;

  @override
  PracticeState build(PerformSource source) {
    _output = ref.watch(clickOutputProvider);
    ref.listen(performControllerProvider(source), (_, perform) => _syncCourse(perform), fireImmediately: true);
    ref.listen(performPrefsProvider, (_, prefs) {
      final value = prefs.value;
      if (value != null) state = state.copyWith(prefs: value);
    });
    ref.onDispose(() {
      _stopTimers();
      unawaited(_output.close());
      beat.dispose();
    });
    return PracticeState(prefs: ref.read(performPrefsProvider).value ?? const PerformPrefs());
  }

  PerformState get _perform => ref.read(performControllerProvider(source));
  PerformController get _performer => ref.read(performControllerProvider(source).notifier);

  // -- The songs, as the clock walks them ---------------------------------------

  void _syncCourse(PerformState perform) {
    _course
      ..tempoPercent = stateOrNull?.tempoPercent ?? 100
      ..songs = [for (final song in perform.songs) _clockSong(song, perform.viewMode)];
    _syncLoop();
    // A chart edit can leave the shown bar behind; redraw where the clock is.
    final shown = beat.value;
    if (shown != null && !shown.playing) _publishHeld(_course.clamp(shown.position));
  }

  ClockSong _clockSong(PerformSong song, SongViewMode viewMode) {
    final tempo = tempoOf(song);
    return ClockSong(
      // Only a chord chart has bars to walk; in lyrics the click is just a click.
      steps: viewMode == SongViewMode.chords ? songBarTimeline(song.sections, tempo.beats) : const [],
      beatsPerBar: tempo.beats,
      bpm: tempo.bpm,
    );
  }

  /// [song]'s tempo as saved, as set here, and as played.
  SongTempo tempoOf(PerformSong song) => SongTempo(
    savedBpm: song.row.entry.song.bpm,
    savedTimeSignature: song.row.entry.song.timeSignature,
    override: (stateOrNull?.overrides ?? const {})[song.songId],
    tempoPercent: stateOrNull?.tempoPercent ?? 100,
  );

  /// The bars of [song] as the clock walks them; empty with none (lyrics).
  List<BarStep> barsOf(int song) => _course.stepsOf(song);

  /// The song the clock is on (or would start on).
  int get clockSong => beat.value?.position.song ?? _perform.songIndex;

  /// The tempo of the song the clock is on (or would start on).
  SongTempo? get currentTempo {
    final perform = _perform;
    final index = beat.value?.position.song ?? perform.songIndex;
    if (perform.songs.isEmpty) return null;
    return tempoOf(perform.songs[index.clamp(0, perform.songs.length - 1)]);
  }

  // -- Play / Pause -------------------------------------------------------------

  /// Plays, or pauses. False when the song has no tempo to play at — set one first.
  Future<bool> toggle() async {
    if (state.playing) {
      pause();
      return true;
    }
    return play();
  }

  Future<bool> play() async {
    if (state.playing) return true;
    final perform = _perform;
    if (perform.songs.isEmpty) return false;
    final from = _course.clamp(_held ?? _startOf(perform));
    if (!(currentTempoAt(from.song)?.hasTempo ?? false)) return false;

    _held = from;
    state = state.copyWith(playing: true);
    final audio = await (_opening ??= _output.open());
    if (!ref.mounted || !state.playing) return true;
    if (!audio && !state.noAudio) state = state.copyWith(noAudio: true);

    // A bar picked while the audio opened is where it starts.
    _scheduler.start(
      _output.now() + _startLead,
      _course.clamp(_held!),
      countInBars: state.prefs.practiceCountIn,
      beat: _heldBeat,
    );
    _pump();
    _timer = Timer.periodic(_tick, (_) => _pump());
    return true;
  }

  SongTempo? currentTempoAt(int song) {
    final songs = _perform.songs;
    return song >= 0 && song < songs.length ? tempoOf(songs[song]) : null;
  }

  /// The bar to start from with nothing held: the picked section, or the
  /// top of the song on screen.
  BarPosition _startOf(PerformState perform) {
    final section = perform.activeSectionId;
    final start = section == null ? null : _course.sectionStart(perform.songIndex, section);
    return start ?? BarPosition(perform.songIndex, 0);
  }

  /// Holds the chord being played; Play picks up from it (after a count-in,
  /// if one is set).
  void pause() {
    if (!state.playing) return;
    _stopTimers();
    _output.cancelPending();
    final shown = beat.value;
    _held = shown?.position ?? _held;
    if (shown != null && !shown.isCountIn && shown.beat != null) _heldBeat = shown.step?.chordStart(shown.beat!) ?? 0;
    state = state.copyWith(playing: false);
    if (_held != null) _publishHeld(_held!);
  }

  /// Back to the first bar of the song on screen.
  void restart() {
    final perform = _perform;
    final song = beat.value?.position.song ?? perform.songIndex;
    _goTo(BarPosition(song, 0));
    unawaited(HapticFeedback.mediumImpact());
  }

  void _stopTimers() {
    _timer?.cancel();
    _timer = null;
    for (final t in _deliveries.keys) {
      t.cancel();
    }
    _deliveries.clear();
  }

  /// Schedules every beat up to the lookahead and its delivery to the screen.
  void _pump() {
    if (!state.playing) return;
    final now = _output.now();
    final volume = state.clickOn ? 1.0 : 0.0;
    for (final b in _scheduler.fill(now + _lookahead)) {
      _output.click(b.at, accent: b.isAccent, volume: volume);
      final wait = b.at - now;
      late final Timer delivery;
      delivery = Timer(wait.isNegative ? Duration.zero : wait, () {
        _deliveries.remove(delivery);
        _deliver(b);
      });
      _deliveries[delivery] = b;
    }
  }

  void _deliver(ClockBeat b) {
    if (!ref.mounted || !state.playing) return;
    final step = _course.stepAt(b.position);
    final previous = beat.value;
    final run = _course.runAt(b.position);
    beat.value = PracticeBeat(
      position: b.position,
      step: step,
      beat: b.beat,
      beatsInBar: b.beatsInBar,
      countInLeft: b.countInLeft,
      playing: true,
      serial: ++_serial,
      barNumber: run?.number,
      barCount: run?.count,
      startBeat: b.isCountIn ? _startBeatAt(b.position) : 0,
    );
    _held = b.position;
    if (!b.isCountIn) _heldBeat = 0;

    // Haptics: the count-in always (it's how you know it's coming), the rest by choice.
    if (b.isCountIn || state.prefs.practiceHaptics) {
      unawaited(b.isAccent ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact());
    }

    // The chart follows the clock: song, then section.
    if (previous?.position != b.position || previous?.isCountIn != b.isCountIn) _followClock(b.position, step);
  }

  void _followClock(BarPosition position, BarStep? step) {
    final perform = _perform;
    if (position.song != perform.songIndex) _performer.showSong(position.song);
    if (step != null && step.sectionId != perform.activeSectionId) _performer.setSection(step.sectionId);
  }

  // -- Moving the clock ---------------------------------------------------------

  /// A section was picked: playing, the clock goes there at once, on the
  /// beat it's on; paused, Play will start there.
  void seekSection(int song, String sectionId) {
    final start = _course.sectionStart(song, sectionId);
    if (start == null) {
      // No bars here (lyrics): just mark it.
      _performer.showSong(song);
      _performer.setSection(sectionId);
      return;
    }
    // Picking a section outside the loop ends the loop.
    final loop = state.loop;
    if (loop != null && (loop.song != song || loop.sectionId != sectionId)) setLoop(null);
    _goTo(start);
  }

  /// A song was jumped to (swipe, setlist, next/previous).
  void seekSong(int song) => _goTo(BarPosition(song, 0));

  /// A chord tapped in the chart: the written bar [line]/[bar] of
  /// [sectionId], from [atom]'s beat (null: the bar's first). A repeated bar
  /// goes to the time round the clock is on. False when the bar isn't played.
  bool seekBar(int song, String sectionId, {required int line, required int bar, int? atom}) {
    final at = beat.value?.position;
    final step = stepForBar(
      _course.stepsOf(song),
      sectionId: sectionId,
      line: line,
      bar: bar,
      near: at?.song == song ? at!.step : null,
    );
    if (step == null) return false;
    final to = BarPosition(song, step);
    _seek(to, onBeat: _course.stepAt(to)!.beatOf(atom));
    unawaited(HapticFeedback.selectionClick());
    return true;
  }

  /// A bar picked on the scrubber.
  void seekStep(int song, int step) => _seek(BarPosition(song, step));

  /// One bar on ([delta] 1) or back (-1) within the song. False at either end.
  bool stepBar(int delta) {
    final at = _clockAt;
    final count = _course.stepsOf(at.song).length;
    final to = at.step + delta;
    if (count == 0 || to < 0 || to >= count) {
      unawaited(HapticFeedback.heavyImpact());
      return false;
    }
    _seek(BarPosition(at.song, to));
    unawaited(HapticFeedback.selectionClick());
    return true;
  }

  /// The next section ([delta] 1), or back (-1): to the top of the one
  /// playing, or the one before when already at its top. False at either end.
  bool stepSection(int delta) {
    final at = _clockAt;
    final runs = _course.runsOf(at.song).values.map((r) => r.start).toList()..sort();
    final current = runs.lastIndexWhere((start) => start <= at.step);
    final int? to;
    if (delta > 0) {
      to = current + 1 < runs.length ? runs[current + 1] : null;
    } else if (current >= 0 && runs[current] < at.step) {
      to = runs[current];
    } else {
      to = current > 0 ? runs[current - 1] : null;
    }
    if (to == null) {
      unawaited(HapticFeedback.heavyImpact());
      return false;
    }
    _seek(BarPosition(at.song, to));
    unawaited(HapticFeedback.selectionClick());
    return true;
  }

  /// Where the clock is, or would start.
  BarPosition get _clockAt => _course.clamp(beat.value?.position ?? _held ?? _startOf(_perform));

  /// Goes to [to], ending a loop it's outside of.
  void _seek(BarPosition to, {int? onBeat}) {
    final target = _course.clamp(to);
    final loop = _course.loop;
    if (loop != null && (loop.song != target.song || target.step < loop.start || target.step >= loop.end)) {
      setLoop(null);
    }
    _goTo(target, onBeat: onBeat);
  }

  void _goTo(BarPosition to, {int? onBeat}) {
    final target = _course.clamp(to);
    if (_timer != null) {
      _jump(target, onBeat: onBeat);
    } else {
      _held = target;
      _heldBeat = onBeat ?? 0;
      _publishHeld(target);
    }
  }

  /// Playing: the clock goes to [to] now, keeping the pulse — from [onBeat]
  /// of its bar, or carrying the count on. Beats laid out but not heard yet
  /// are dropped and laid out again at [to].
  void _jump(BarPosition to, {int? onBeat}) {
    final now = _output.now();
    final waiting = _deliveries.entries.where((e) => e.value.at > now).toList()
      ..sort((a, b) => a.value.at.compareTo(b.value.at));
    for (final e in waiting) {
      e.key.cancel();
      _deliveries.remove(e.key);
    }
    _output.cancelPending();
    _scheduler.jump(to, from: waiting.firstOrNull?.value, beat: onBeat);
    _held = to;
    _heldBeat = onBeat ?? 0;

    // Show it now, not on the next beat; the beat on screen moves with it.
    final shown = beat.value;
    final step = _course.stepAt(to);
    final run = _course.runAt(to);
    final counting = shown?.isCountIn ?? false;
    final beats = counting ? shown!.beatsInBar : _course.beatsAt(to);
    final at = counting ? shown!.beat : onBeat ?? shown?.beat;
    beat.value = PracticeBeat(
      position: to,
      step: step,
      beat: at == null || at >= beats ? null : at,
      beatsInBar: beats,
      countInLeft: shown?.countInLeft,
      playing: true,
      serial: shown?.serial ?? _serial,
      barNumber: run?.number,
      barCount: run?.count,
      startBeat: counting ? _startBeatAt(to) : 0,
    );
    _followClock(to, step);
    _pump();
  }

  /// Shows where Play will start, without a beat.
  void _publishHeld(BarPosition at) {
    final step = _course.stepAt(at);
    final run = _course.runAt(at);
    beat.value = PracticeBeat(
      position: at,
      step: step,
      beatsInBar: _course.beatsAt(at),
      barNumber: run?.number,
      barCount: run?.count,
      startBeat: _startBeatAt(at),
    );
    _followClock(at, step);
  }

  /// The held beat, if [at]'s bar has it.
  int _startBeatAt(BarPosition at) => _heldBeat < _course.beatsAt(at) ? _heldBeat : 0;

  // -- Looping ----------------------------------------------------------------------

  /// Loops [sectionId] (again stops looping). The clock goes there if it's elsewhere.
  void toggleLoop(int song, String sectionId) {
    final loop = state.loop;
    if (loop != null && loop.song == song && loop.sectionId == sectionId) {
      setLoop(null);
      return;
    }
    if (_course.loopOf(song, sectionId) == null) return;
    setLoop((song: song, sectionId: sectionId));
    final at = beat.value?.position;
    final inside = at != null && at.song == song && _course.stepAt(at)?.sectionId == sectionId;
    if (!inside) _goTo(_course.sectionStart(song, sectionId)!);
    unawaited(HapticFeedback.selectionClick());
  }

  /// Loops the section the clock is in (again stops looping).
  void toggleLoopHere() {
    final at = _clockAt;
    final section = _course.stepAt(at)?.sectionId;
    if (section != null) toggleLoop(at.song, section);
  }

  void setLoop(SectionLoop? loop) {
    state = state.copyWith(loop: () => loop);
    _syncLoop();
  }

  void _syncLoop() {
    final loop = stateOrNull?.loop;
    _course.loop = loop == null ? null : _course.loopOf(loop.song, loop.sectionId);
  }

  // -- Tempo ------------------------------------------------------------------------

  void setTempoPercent(int percent) {
    state = state.copyWith(tempoPercent: percent.clamp(50, 150));
    _course.tempoPercent = state.tempoPercent;
  }

  /// Sets the current song's tempo for this practice.
  void setBpm(int bpm) => _override((o) => o.copyWith(bpm: clampBpm(bpm)));

  void setTimeSignature(String timeSignature) => _override((o) => o.copyWith(timeSignature: timeSignature));

  void _override(TempoOverride Function(TempoOverride current) change) {
    final song = _songAtClock;
    if (song == null) return;
    final overrides = {...state.overrides};
    overrides[song.songId] = change(overrides[song.songId] ?? const TempoOverride());
    state = state.copyWith(overrides: overrides);
    _syncCourse(_perform);
  }

  /// Back to what the song has saved.
  void resetTempo() {
    final song = _songAtClock;
    if (song == null) return;
    state = state.copyWith(overrides: {...state.overrides}..remove(song.songId));
    _syncCourse(_perform);
  }

  /// Saves this practice's tempo to the song, for everyone. Lands on this
  /// device at once and reaches the server when it can.
  Future<void> saveTempoToSong() async {
    final song = _songAtClock;
    final override = song == null ? null : state.overrides[song.songId];
    if (song == null || override == null) return;
    final repo = ref.read(songDetailRepositoryProvider);
    await repo.setTempo(song.songId, bpm: override.bpm, timeSignature: override.timeSignature);
    if (!ref.mounted) return;
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId != null && ref.read(isOnlineProvider)) unawaited(repo.flush(workspaceId));
    // The song has it now; nothing left to override.
    state = state.copyWith(overrides: {...state.overrides}..remove(song.songId));
  }

  PerformSong? get _songAtClock {
    final perform = _perform;
    if (perform.songs.isEmpty) return null;
    final index = beat.value?.position.song ?? perform.songIndex;
    return perform.songs[index.clamp(0, perform.songs.length - 1)];
  }

  // -- Switches (this device) -----------------------------------------------------

  /// The click on or off; the clock and highlights carry on either way.
  Future<void> setClick(bool on) {
    state = state.copyWith(prefs: state.prefs.copyWithPractice(click: on), videoMuted: false);
    _output.setPendingVolume(on ? 1 : 0);
    return ref.read(performPrefsRepositoryProvider).setPracticeClick(on);
  }

  /// The video started playing along: quiet the click, without saving it
  /// as the switch's setting.
  void muteForVideo() {
    if (!state.clickOn) return;
    state = state.copyWith(videoMuted: true);
    _output.setPendingVolume(0);
  }

  Future<void> setHaptics(bool on) {
    state = state.copyWith(prefs: state.prefs.copyWithPractice(haptics: on));
    return ref.read(performPrefsRepositoryProvider).setPracticeHaptics(on);
  }

  /// Bars counted in before Play starts; 0 starts straight away.
  Future<void> setCountIn(int bars) {
    state = state.copyWith(prefs: state.prefs.copyWithPractice(countIn: bars));
    return ref.read(performPrefsRepositoryProvider).setPracticeCountIn(bars);
  }

  Future<void> setFlash(bool on) {
    state = state.copyWith(prefs: state.prefs.copyWithPractice(flash: on));
    return ref.read(performPrefsRepositoryProvider).setPracticeFlash(on);
  }
}
