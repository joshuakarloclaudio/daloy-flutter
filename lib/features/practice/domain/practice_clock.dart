/// The Practice clock, without any audio or timers: which bar comes next
/// ([PracticeCourse]) and when each beat falls ([BeatScheduler]). The
/// controller feeds the scheduler an audio clock and hands the beats it
/// returns to the click and the screen. Pure Dart, so it is tested as is.
library;

import 'package:flutter/foundation.dart';

import 'bar_timeline.dart';

const minBpm = 20;
const maxBpm = 300;

/// When a song has no tempo and nothing was set.
const fallbackBpm = 120;

int clampBpm(num bpm) => bpm.round().clamp(minBpm, maxBpm);

/// A bar of the set: a song, and a step of its timeline.
@immutable
class BarPosition {
  const BarPosition(this.song, this.step);

  static const start = BarPosition(0, 0);

  final int song;
  final int step;

  @override
  bool operator ==(Object other) => other is BarPosition && other.song == song && other.step == step;

  @override
  int get hashCode => Object.hash(song, step);

  @override
  String toString() => 'BarPosition($song, $step)';
}

/// One song as the clock sees it.
class ClockSong {
  ClockSong({required this.steps, required this.beatsPerBar, required this.bpm});

  /// Empty when the song has no bars to walk (lyrics view, no chords): the
  /// clock then just counts bars in place.
  final List<BarStep> steps;
  final int beatsPerBar;

  /// Before the tempo percentage; null when the song has none.
  final int? bpm;

  late final Map<String, ({int start, int count})> runs = sectionRuns(steps);
}

/// A section played over and over: bars [start] to [end] (exclusive) of [song].
typedef BarLoop = ({int song, int start, int end});

/// The road through the set: what follows each bar, and how fast.
class PracticeCourse {
  PracticeCourse({this.songs = const [], this.loop, this.tempoPercent = 100});

  List<ClockSong> songs;
  BarLoop? loop;

  /// 100 plays at the written tempo; 75 slows to three quarters.
  int tempoPercent;

  /// Last song tempo the clock used: a song without one keeps going at it.
  int _lastBpm = fallbackBpm;

  ClockSong? _song(int index) => index >= 0 && index < songs.length ? songs[index] : null;

  /// [song]'s bars, in playing order; empty when it has none to walk.
  List<BarStep> stepsOf(int song) => _song(song)?.steps ?? const [];

  /// [song]'s sections as they run along its bars.
  Map<String, ({int start, int count})> runsOf(int song) => _song(song)?.runs ?? const {};

  BarStep? stepAt(BarPosition p) {
    final steps = _song(p.song)?.steps ?? const [];
    return p.step >= 0 && p.step < steps.length ? steps[p.step] : null;
  }

  int beatsPerBarOf(int song) => _song(song)?.beatsPerBar ?? 4;

  /// Beats [p]'s bar takes: short when the chart wrote a short bar.
  int beatsAt(BarPosition p) => stepAt(p)?.beatCount ?? beatsPerBarOf(p.song);

  /// The written tempo of [song], or the last one used when it has none.
  int songBpm(int song) => _song(song)?.bpm ?? _lastBpm;

  /// What the click runs at in [song]: its tempo, scaled.
  int bpmAt(int song) {
    final written = songBpm(song);
    if (_song(song)?.bpm != null) _lastBpm = written;
    return clampBpm(written * tempoPercent / 100);
  }

  Duration beatLength(int song) => Duration(microseconds: (60000000 / bpmAt(song)).round());

  /// The bar after [p]: round a loop, on through the song, into the next
  /// song, and back to the top of the set after the last one.
  BarPosition next(BarPosition p) {
    final loop = this.loop;
    if (loop != null && loop.song == p.song) {
      return p.step + 1 >= loop.end || p.step < loop.start
          ? BarPosition(p.song, loop.start)
          : BarPosition(p.song, p.step + 1);
    }
    final total = _song(p.song)?.steps.length ?? 0;
    if (total == 0) return p;
    if (p.step + 1 < total) return BarPosition(p.song, p.step + 1);
    return songs.length > 1 ? BarPosition((p.song + 1) % songs.length, 0) : BarPosition(p.song, 0);
  }

  /// [p] made valid for the songs as they are now (a chart was edited).
  BarPosition clamp(BarPosition p) {
    if (songs.isEmpty) return BarPosition.start;
    final song = p.song.clamp(0, songs.length - 1);
    final total = songs[song].steps.length;
    return BarPosition(song, total == 0 ? 0 : p.step.clamp(0, total - 1));
  }

  /// The first bar of [sectionId] in [song], or null when it has no bars.
  BarPosition? sectionStart(int song, String sectionId) {
    final run = _song(song)?.runs[sectionId];
    return run == null ? null : BarPosition(song, run.start);
  }

  /// [p]'s place in its section: 1-based bar number, and how many bars it plays for.
  ({int number, int count})? runAt(BarPosition p) {
    final step = stepAt(p);
    final run = step == null ? null : _song(p.song)?.runs[step.sectionId];
    return run == null ? null : (number: p.step - run.start + 1, count: run.count);
  }

  /// [sectionId]'s bars as a loop, or null when it has none.
  BarLoop? loopOf(int song, String sectionId) {
    final run = _song(song)?.runs[sectionId];
    return run == null ? null : (song: song, start: run.start, end: run.start + run.count);
  }
}

/// One click, and where the chart is when it sounds.
@immutable
class ClockBeat {
  const ClockBeat({
    required this.at,
    required this.position,
    required this.beat,
    required this.beatsInBar,
    this.countInLeft,
  });

  /// On the audio clock.
  final Duration at;

  /// The bar sounding — during the count-in, the bar about to start.
  final BarPosition position;

  /// 0-based within the bar (or the count-in).
  final int beat;
  final int beatsInBar;

  /// Counting in: clicks left including this one ("3 · 2 · 1"); else null.
  final int? countInLeft;

  bool get isCountIn => countInLeft != null;
  bool get isAccent => beat == 0;

  @override
  bool operator ==(Object other) =>
      other is ClockBeat &&
      other.at == at &&
      other.position == position &&
      other.beat == beat &&
      other.beatsInBar == beatsInBar &&
      other.countInLeft == countInLeft;

  @override
  int get hashCode => Object.hash(at, position, beat, beatsInBar, countInLeft);

  @override
  String toString() =>
      'ClockBeat(${at.inMilliseconds}ms $position ${beat + 1}/$beatsInBar${isCountIn ? ' in $countInLeft' : ''})';
}

/// Lays beats out ahead of time on an audio clock, the way a Web Audio
/// metronome does: the caller asks for everything up to a little past "now"
/// and schedules each click sample-accurately, so a late timer never makes
/// a late click.
class BeatScheduler {
  BeatScheduler(this.course);

  final PracticeCourse course;

  Duration _nextAt = Duration.zero;
  BarPosition _position = BarPosition.start;
  int _beat = 0;
  int _beatsInBar = 4;
  int _countInLeft = 0;

  /// Counting in: the beat of the bar the song comes in on.
  int _startBeat = 0;

  /// The bar the next beat belongs to.
  BarPosition get position => _position;

  /// Starts at [from] at time [at], after [countInBars] bars counted in.
  /// [beat] starts partway into the bar (on a chord after its first).
  void start(Duration at, BarPosition from, {int countInBars = 1, int beat = 0}) {
    _nextAt = at;
    _position = course.clamp(from);
    final count = course.beatsPerBarOf(_position.song);
    _countInLeft = countInBars * count;
    _startBeat = _within(beat);
    _beat = _countInLeft > 0 ? 0 : _startBeat;
    _beatsInBar = _countInLeft > 0 ? count : course.beatsAt(_position);
  }

  /// [beat] if [_position]'s bar has it, else its downbeat.
  int _within(int beat) => beat >= 0 && beat < course.beatsAt(_position) ? beat : 0;

  /// Plays [to] from the next beat on, keeping the pulse: the beat count
  /// carries on into [to]'s bar (from its downbeat if the bar is too short).
  /// [from] is the first beat handed out but not yet heard: the clock lays
  /// it out again at [to], so the caller drops it and the ones after it.
  /// Null when nothing is waiting. [beat] is where in [to]'s bar to go on
  /// (a chord picked); null carries the count on.
  void jump(BarPosition to, {ClockBeat? from, int? beat}) {
    if (from != null) {
      _nextAt = from.at;
      _beat = from.beat;
      _beatsInBar = from.beatsInBar;
      _countInLeft = from.countInLeft ?? 0;
    }
    _position = course.clamp(to);
    // Counting in: the count carries on, into [to].
    if (_countInLeft > 0) {
      _startBeat = _within(beat ?? 0);
      return;
    }
    _beatsInBar = course.beatsAt(_position);
    _beat = beat == null ? _within(_beat) : _within(beat);
  }

  /// Every beat that falls before [until], in order.
  List<ClockBeat> fill(Duration until) {
    final beats = <ClockBeat>[];
    while (_nextAt < until) {
      beats.add(
        ClockBeat(
          at: _nextAt,
          position: _position,
          beat: _beat,
          beatsInBar: _beatsInBar,
          countInLeft: _countInLeft > 0 ? _countInLeft : null,
        ),
      );
      _nextAt += course.beatLength(_position.song);
      _advance();
    }
    return beats;
  }

  void _advance() {
    if (_countInLeft > 0) {
      _countInLeft--;
      _beat++;
      if (_countInLeft == 0) {
        _beat = _startBeat;
        _beatsInBar = course.beatsAt(_position);
      }
      return;
    }
    _beat++;
    if (_beat < _beatsInBar) return;
    _beat = 0;
    _position = course.next(_position);
    _beatsInBar = course.beatsAt(_position);
  }
}
