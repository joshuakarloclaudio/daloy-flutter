import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/device/screen_awake.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/application/line_up_detail_controller.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/setlist_entry.dart';
import 'package:daloy_flutter/features/perform/application/perform_controller.dart';
import 'package:daloy_flutter/features/perform/data/perform_prefs_repository.dart';
import 'package:daloy_flutter/features/perform/domain/perform_sections.dart';
import 'package:daloy_flutter/features/perform/presentation/perform_screen.dart';
import 'package:daloy_flutter/features/practice/application/practice_controller.dart';
import 'package:daloy_flutter/features/practice/data/click_output.dart';
import 'package:daloy_flutter/features/practice/domain/bar_timeline.dart';
import 'package:daloy_flutter/features/practice/domain/practice_clock.dart';
import 'package:daloy_flutter/features/practice/presentation/widgets/practice_widgets.dart';
import 'package:daloy_flutter/features/songs/chart/chart_parser.dart';
import 'package:daloy_flutter/features/songs/data/song_detail_repository.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:daloy_flutter/features/songs/domain/display_prefs.dart';
import 'package:daloy_flutter/features/songs/domain/song.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

List<List<Segment>> _atoms(String bar) => switch (classifyLine('| $bar |')) {
  BarChartLine(:final bars) => bars.single.atoms,
  _ => throw StateError('not a bar line'),
};

PerformSection _section(String id, List<String> lines, {int repeat = 1}) =>
    PerformSection(id: id, label: id, startLine: 0, lines: lines, repeat: repeat);

/// A song with a verse (two bars, twice) and a chorus (two bars).
const _chart = 'Verse:\n| [G] | [C] | x2\n\nChorus:\n| [D] | [Em] |';

PerformSong _performSong(int id, {int? bpm = 120, String? timeSignature = '4/4', String content = _chart}) =>
    PerformSong(
      row: SetlistSong(
        entry: SetlistEntry(
          position: id,
          lineUpSongId: 900 + id,
          song: Song(id: id, title: 'Song $id', bpm: bpm, timeSignature: timeSignature, content: content),
        ),
        number: id + 1,
      ),
      viewMode: SongViewMode.chords,
    );

/// Perform's state without Drift: just the songs, and the cursor moving.
class _FakePerform extends PerformController {
  _FakePerform(this._songs);

  final List<PerformSong> _songs;

  @override
  PerformState build(PerformSource source) => PerformState(isLoading: false, songs: _songs);

  @override
  void showSong(int index) => state = PerformState(
    isLoading: false,
    songs: state.songs,
    songIndex: index,
    activeSectionId: state.activeSectionId,
  );

  @override
  void setSection(String? id) =>
      state = PerformState(isLoading: false, songs: state.songs, songIndex: state.songIndex, activeSectionId: id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bar timeline', () {
    test('time signatures give the beats to click', () {
      expect(beatsPerBar('3/4'), 3);
      expect(beatsPerBar('6/8'), 6);
      expect(beatsPerBar(null), 4);
      expect(beatsPerBar('waltz'), 4);
    });

    test('separators place the chords on the beats; bars are as long as they add up to', () {
      expect(barBeatMap(_atoms('[C] - [G] -'), 4), [0, 0, 2, 2]);
      expect(barBeatMap(_atoms('[A] .'), 4), [0, 0]);
      expect(barBeatMap(_atoms('[F#m] . [Bm] . . .'), 4), [0, 0, 2, 2, 2, 2]);
    });

    test('chords with no separators split the bar evenly; one chord lights the whole bar', () {
      expect(barBeatMap(_atoms('[C] [G]'), 4), [0, 0, 1, 1]);
      expect(barBeatMap(_atoms('[C] [G] [Am]'), 4), isNull, reason: "3 doesn't divide 4");
      expect(barBeatMap(_atoms('[C]'), 4), isNull);
    });

    test("a bar's time signature sets its length", () {
      expect(barBeatMap(_atoms('[Em] [F#m]'), 4, meter: 2), [0, 1]);
      expect(barBeatMap(_atoms('[G] . .'), 4, meter: 3), [0, 0, 0]);
      expect(barBeatMap(_atoms('[G] .'), 4, meter: 3), isNull, reason: "separators that don't add up are ignored");
    });

    test('repeats expand, % carries the last chords, lyrics take no time', () {
      final steps = songBarTimeline([
        _section('v', ['| [G] | % | x2', '[C]words with a chord']),
        _section('c', ['[D] [Em]'], repeat: 2),
      ], 4);
      expect([for (final s in steps) s.chords.join()], ['G', 'G', 'G', 'G', 'D', 'Em', 'D', 'Em']);
      expect([for (final s in steps) s.sectionId], ['v', 'v', 'v', 'v', 'c', 'c', 'c', 'c']);
      expect(steps[1].bar, 1);
      expect(steps[4].line, 0);
      expect(sectionRuns(steps), {'v': (start: 0, count: 4), 'c': (start: 4, count: 4)});
    });

    test('a short bar is short for the click, and % after it too', () {
      final steps = songBarTimeline([
        _section('s', ['| [A] . | % | [B] |']),
      ], 4);
      expect([for (final s in steps) s.beatCount], [2, 2, 4]);
      expect(steps.first.atomAt(1), 0);
    });

    test('a six-count bar, written whole or as 4 + 2', () {
      final whole = songBarTimeline([
        _section('s', ['| [G] . [A] . | [F#m] . [Bm] . . . |']),
      ], 4);
      expect([for (final s in whole) s.beatCount], [4, 6]);
      expect(whole[1].atomAt(5), 2, reason: 'Bm holds to the end');

      final split = songBarTimeline([
        _section('s', ['| [F#m] . [Bm] . | . . | % |']),
      ], 4);
      expect([for (final s in split) s.beatCount], [4, 2, 2]);
      expect(split[1].chords, ['Bm'], reason: 'the held beats keep Bm sounding');
      expect(split[1].beatMap, isNull, reason: 'lit whole, not on the dot');
      expect(split[2].chords, ['Bm']);
    });

    test('a 2/4 bar of one-count chords in a 4/4 song', () {
      final steps = songBarTimeline([
        _section('s', ['| 2/4 [Em] [F#m] | [G] . [A] . | % |']),
      ], 4);
      expect([for (final s in steps) s.beatCount], [2, 4, 4]);
      expect([steps[0].atomAt(0), steps[0].atomAt(1)], [0, 1]);
      expect(steps[0].chords, ['Em', 'F#m']);
    });
  });

  group('picking a bar', () {
    test('each bar knows its time round; a chord knows its beat', () {
      final steps = songBarTimeline([
        _section('v', ['| [G] | [C] [D] | x2'], repeat: 2),
      ], 4);
      expect(
        [for (final s in steps) (s.cycle, s.pass)],
        [(0, 0), (0, 0), (0, 1), (0, 1), (1, 0), (1, 0), (1, 1), (1, 1)],
      );
      expect(steps[1].beatOf(1), 2, reason: 'D comes in on beat 3');
      expect(steps[1].beatOf(null), 0);
      expect(steps[1].chordStart(3), 2);
      expect(steps[0].beatOf(0), 0, reason: 'one chord: the whole bar');
    });

    test('a repeated bar goes to the time round the clock is on, else the first', () {
      final steps = songBarTimeline([
        _section('v', ['| [G] | [C] | x2', '| [Am] |'], repeat: 2),
        _section('c', ['| [D] |']),
      ], 4);
      // v: G C G C Am (0–4), again (5–9); c: D (10).
      int? find(String section, int line, int bar, {int? near}) =>
          stepForBar(steps, sectionId: section, line: line, bar: bar, near: near);
      expect(find('v', 0, 1), 1, reason: 'nowhere near: the first');
      expect(find('v', 0, 1, near: 2), 3, reason: 'on the line, second pass: its second pass');
      expect(find('v', 0, 0, near: 9), 5, reason: 'second cycle, other line: that cycle, first pass');
      expect(find('v', 1, 0, near: 6), 9);
      expect(find('v', 0, 0, near: 10), 0, reason: 'from another section: the first');
      expect(find('v', 3, 0), isNull, reason: 'not played');
    });
  });

  group('course', () {
    PracticeCourse course() => PracticeCourse(
      songs: [
        ClockSong(steps: songBarTimeline(groupBySections(_chart, 'a'), 4), beatsPerBar: 4, bpm: 120),
        ClockSong(steps: songBarTimeline(groupBySections(_chart, 'b'), 3), beatsPerBar: 3, bpm: null),
      ],
    );

    test('runs through a song into the next, and back to the top after the last', () {
      final c = course();
      expect(c.next(const BarPosition(0, 2)), const BarPosition(0, 3));
      expect(c.next(const BarPosition(0, 5)), const BarPosition(1, 0));
      expect(c.next(const BarPosition(1, 5)), const BarPosition(0, 0));
    });

    test('a loop goes round its section', () {
      final c = course();
      c.loop = c.loopOf(0, 'a-section-2');
      expect(c.loop, (song: 0, start: 4, end: 6));
      expect(c.next(const BarPosition(0, 4)), const BarPosition(0, 5));
      expect(c.next(const BarPosition(0, 5)), const BarPosition(0, 4));
      // Outside the loop, the next bar is the loop's first.
      expect(c.next(const BarPosition(0, 1)), const BarPosition(0, 4));
    });

    test('a song without a tempo keeps the one before; the percentage scales it', () {
      final c = course();
      expect(c.bpmAt(0), 120);
      expect(c.bpmAt(1), 120);
      c.tempoPercent = 75;
      expect(c.bpmAt(0), 90);
      expect(c.beatLength(0), const Duration(microseconds: 666667));
    });

    test('a single song wraps; a song with nothing to walk stays put', () {
      final single = PracticeCourse(
        songs: [ClockSong(steps: songBarTimeline(groupBySections(_chart, 'a'), 4), beatsPerBar: 4, bpm: 90)],
      );
      expect(single.next(const BarPosition(0, 5)), const BarPosition(0, 0));
      final empty = PracticeCourse(songs: [ClockSong(steps: const [], beatsPerBar: 4, bpm: 90)]);
      expect(empty.next(BarPosition.start), BarPosition.start);
    });
  });

  group('scheduler', () {
    BeatScheduler scheduler({String content = _chart, int beats = 4}) => BeatScheduler(
      PracticeCourse(
        songs: [ClockSong(steps: songBarTimeline(groupBySections(content, 'a'), beats), beatsPerBar: beats, bpm: 120)],
      ),
    );

    test('a bar of count-in, held on the first bar, then the bars on the beat', () {
      final s = scheduler()..start(Duration.zero, BarPosition.start);
      final beats = s.fill(const Duration(milliseconds: 4100));
      expect(beats, hasLength(9));
      expect([for (final b in beats.take(4)) b.countInLeft], [4, 3, 2, 1]);
      expect(beats.take(4).every((b) => b.position == BarPosition.start), isTrue);
      expect(beats[4].isCountIn, isFalse);
      expect(beats[4].isAccent, isTrue);
      expect(beats[4].at, const Duration(seconds: 2));
      expect(beats[8].position, const BarPosition(0, 1));
      expect(beats[8].at, const Duration(seconds: 4));
    });

    test('nothing is scheduled twice', () {
      final s = scheduler()..start(Duration.zero, BarPosition.start, countInBars: 0);
      final first = s.fill(const Duration(milliseconds: 1100));
      final second = s.fill(const Duration(milliseconds: 1600));
      expect(first, hasLength(3));
      expect(second.single.at, const Duration(milliseconds: 1500));
    });

    test('a jump goes there on the next beat, keeping the count', () {
      final s = scheduler()..start(Duration.zero, BarPosition.start, countInBars: 0);
      final laid = s.fill(const Duration(milliseconds: 600)); // beats 1 and 2 of bar 1
      // Beat 2 isn't heard yet: it's laid out again, in the chorus.
      s.jump(const BarPosition(0, 4), from: laid[1]);
      final rest = s.fill(const Duration(milliseconds: 2100));
      expect(
        [for (final b in rest) (b.position.step, b.beat, b.at.inMilliseconds)],
        [(4, 1, 500), (4, 2, 1000), (4, 3, 1500), (5, 0, 2000)],
      );
    });

    test('a jump into a shorter bar starts it on its downbeat', () {
      final s = scheduler(content: '| [A] | [B] . |')..start(Duration.zero, BarPosition.start, countInBars: 0);
      s.fill(const Duration(milliseconds: 1100)); // beats 1–3 of bar 1
      s.jump(const BarPosition(0, 1));
      expect(
        [for (final b in s.fill(const Duration(milliseconds: 2600))) (b.position.step, b.beat)],
        [(1, 0), (1, 1), (0, 0)],
      );
    });

    test('a jump during the count-in moves where the song starts', () {
      final s = scheduler()..start(Duration.zero, BarPosition.start);
      s.fill(const Duration(milliseconds: 600));
      s.jump(const BarPosition(0, 4));
      final rest = s.fill(const Duration(milliseconds: 2100));
      expect([for (final b in rest) b.countInLeft], [2, 1, null]);
      expect(rest.last.position, const BarPosition(0, 4));
    });

    test('starts partway into a bar: straight in, or after the count-in', () {
      final straight = scheduler(content: '| [C] [G] | [D] |')
        ..start(Duration.zero, BarPosition.start, countInBars: 0, beat: 2);
      expect(
        [for (final b in straight.fill(const Duration(milliseconds: 1100))) (b.position.step, b.beat)],
        [(0, 2), (0, 3), (1, 0)],
      );

      final counted = scheduler(content: '| [C] [G] | [D] |')..start(Duration.zero, BarPosition.start, beat: 2);
      final beats = counted.fill(const Duration(milliseconds: 2100));
      expect([for (final b in beats.take(4)) b.countInLeft], [4, 3, 2, 1]);
      expect((beats[4].position.step, beats[4].beat, beats[4].isCountIn), (0, 2, false));
    });

    test('two bars of count-in, or none', () {
      final two = scheduler()..start(Duration.zero, BarPosition.start, countInBars: 2);
      expect(two.fill(const Duration(milliseconds: 3600)).every((b) => b.isCountIn), isTrue);
      final none = scheduler()..start(Duration.zero, BarPosition.start, countInBars: 0);
      expect(none.fill(const Duration(milliseconds: 100)).single.isCountIn, isFalse);
    });

    test('a jump to a chord plays on from its beat', () {
      final s = scheduler(content: '| [A] | [C] [G] |')..start(Duration.zero, BarPosition.start, countInBars: 0);
      final laid = s.fill(const Duration(milliseconds: 600));
      s.jump(const BarPosition(0, 1), from: laid[1], beat: 2);
      expect(
        [for (final b in s.fill(const Duration(milliseconds: 1600))) (b.position.step, b.beat, b.at.inMilliseconds)],
        [(1, 2, 500), (1, 3, 1000), (0, 0, 1500)],
      );
    });

    test('a short bar hands over early', () {
      final s = scheduler(content: '| [A] . | [B] |')..start(Duration.zero, BarPosition.start, countInBars: 0);
      final beats = s.fill(const Duration(milliseconds: 1100));
      expect([for (final b in beats) (b.position.step, b.beat)], [(0, 0), (0, 1), (1, 0)]);
    });

    test('a tempo change applies from the next beat', () {
      final course = PracticeCourse(
        songs: [ClockSong(steps: songBarTimeline(groupBySections(_chart, 'a'), 4), beatsPerBar: 4, bpm: 120)],
      );
      final s = BeatScheduler(course)..start(Duration.zero, BarPosition.start, countInBars: 0);
      s.fill(const Duration(milliseconds: 100));
      course.tempoPercent = 50;
      expect(s.fill(const Duration(milliseconds: 1600)).map((b) => b.at), [
        const Duration(milliseconds: 500),
        const Duration(milliseconds: 1500),
      ]);
    });
  });

  group('controller', () {
    const source = PerformSource.lineUp(7);

    ({ProviderContainer container, SilentClickOutput output}) setUpPractice(FakeAsync async, List<PerformSong> songs) {
      final output = SilentClickOutput(clock: () => async.elapsed);
      final container = ProviderContainer(
        overrides: [
          performControllerProvider(source).overrideWith(() => _FakePerform(songs)),
          performPrefsProvider.overrideWith((ref) => Stream.value(const PerformPrefs())),
          performPrefsRepositoryProvider.overrideWithValue(_NoPrefs()),
          clickOutputProvider.overrideWithValue(output),
        ],
      );
      container.listen(practiceControllerProvider(source), (_, _) {});
      async.flushMicrotasks();
      return (container: container, output: output);
    }

    test('Play walks the chart in time; Pause holds the bar; Play picks up there', () {
      fakeAsync((async) {
        final (:container, :output) = setUpPractice(async, [_performSong(0)]);
        final practice = container.read(practiceControllerProvider(source).notifier);

        practice.play();
        async.elapse(const Duration(milliseconds: 100));
        expect(container.read(practiceControllerProvider(source)).playing, isTrue);
        expect(practice.beat.value?.countInLeft, 4);

        // Count-in (4 × 500ms), then two bars of 4/4 at 120.
        async.elapse(const Duration(milliseconds: 6000));
        expect(practice.beat.value?.isCountIn, isFalse);
        expect(practice.beat.value?.position, const BarPosition(0, 2));
        expect(container.read(performControllerProvider(source)).activeSectionId, 'song-900-section-0');

        practice.pause();
        expect(practice.beat.value?.playing, isFalse);
        expect(practice.beat.value?.position, const BarPosition(0, 2));
        final clicked = output.clicks.length;
        async.elapse(const Duration(seconds: 2));
        expect(output.clicks.length, clicked, reason: 'paused: no clicks');

        practice.play();
        async.elapse(const Duration(milliseconds: 2200));
        expect(practice.beat.value?.isCountIn, isFalse);
        expect(practice.beat.value?.position, const BarPosition(0, 2), reason: 'resumes on the held bar');
        container.dispose();
      });
    });

    test('the click mutes without stopping the clock', () {
      fakeAsync((async) {
        final (:container, :output) = setUpPractice(async, [_performSong(0)]);
        final practice = container.read(practiceControllerProvider(source).notifier);
        practice.setClick(false);
        practice.play();
        async.elapse(const Duration(seconds: 3));
        expect(output.clicks, isNotEmpty);
        expect(output.clicks.every((c) => c.volume == 0), isTrue);
        expect(practice.beat.value?.playing, isTrue);
        expect(practice.beat.value?.isCountIn, isFalse);
        container.dispose();
      });
    });

    test('a picked section is where the next bar goes; a loop stays there', () {
      fakeAsync((async) {
        final (:container, output: _) = setUpPractice(async, [_performSong(0)]);
        final practice = container.read(practiceControllerProvider(source).notifier);

        practice.seekSection(0, 'song-900-section-2');
        expect(practice.beat.value?.position, const BarPosition(0, 4), reason: 'paused: Play starts here');
        expect(practice.beat.value?.playing, isFalse);

        practice.toggleLoop(0, 'song-900-section-2');
        practice.play();
        async.elapse(const Duration(milliseconds: 2100 + 4000 * 3));
        expect(practice.beat.value?.position.step, inInclusiveRange(4, 5));
        expect(practice.beat.value?.barNumber, isNotNull);

        practice.toggleLoop(0, 'song-900-section-2');
        expect(container.read(practiceControllerProvider(source)).loop, isNull);
        container.dispose();
      });
    });

    test('a section picked while playing shows at once and plays from the next beat', () {
      fakeAsync((async) {
        final (:container, :output) = setUpPractice(async, [_performSong(0)]);
        final practice = container.read(practiceControllerProvider(source).notifier);
        practice.play();
        // Count-in (2s from 80ms), then into beat 2 of the first bar, with
        // beat 3 already laid out.
        async.elapse(const Duration(milliseconds: 2080 + 900));
        expect(practice.beat.value?.position, BarPosition.start);
        expect(practice.beat.value?.beat, 1);

        practice.seekSection(0, 'song-900-section-2');
        expect(practice.beat.value?.position, const BarPosition(0, 4), reason: 'no waiting for the bar to end');
        expect(container.read(performControllerProvider(source)).activeSectionId, 'song-900-section-2');

        async.elapse(const Duration(milliseconds: 500));
        expect(practice.beat.value?.position, const BarPosition(0, 4));
        expect(practice.beat.value?.beat, 2, reason: 'the pulse carries on');
        final times = [for (final c in output.clicks) c.at];
        expect(times.toSet(), hasLength(times.length - 1), reason: 'the beat dropped was laid out once more, no more');
        container.dispose();
      });
    });

    test('without a tempo Play asks for one; a tempo set here plays and can be saved', () {
      fakeAsync((async) {
        final (:container, output: _) = setUpPractice(async, [_performSong(0, bpm: null, timeSignature: null)]);
        final practice = container.read(practiceControllerProvider(source).notifier);

        late bool played;
        practice.play().then((v) => played = v);
        async.flushMicrotasks();
        expect(played, isFalse);
        expect(practice.currentTempo?.hasTempo, isFalse);

        practice.setBpm(84);
        practice.setTimeSignature('3/4');
        expect(practice.currentTempo?.bpm, 84);
        expect(practice.currentTempo?.beats, 3);
        expect(practice.currentTempo?.differsFromSong, isTrue);

        practice.setTempoPercent(50);
        expect(practice.currentTempo?.playingBpm, 42);

        practice.play();
        async.elapse(const Duration(milliseconds: 100));
        expect(practice.beat.value?.countInLeft, 3, reason: 'counts in a bar of 3/4');
        container.dispose();
      });
    });

    test('with the count-in off, Play starts on the bar at once', () {
      fakeAsync((async) {
        final (:container, output: _) = setUpPractice(async, [_performSong(0)]);
        final practice = container.read(practiceControllerProvider(source).notifier);
        practice.setCountIn(0);
        practice.play();
        async.elapse(const Duration(milliseconds: 100));
        expect(practice.beat.value?.isCountIn, isFalse);
        expect((practice.beat.value?.position, practice.beat.value?.beat), (BarPosition.start, 0));
        container.dispose();
      });
    });

    test('a chord picked is where Play starts, on its beat; Pause holds the chord', () {
      fakeAsync((async) {
        final (:container, output: _) = setUpPractice(async, [_performSong(0, content: 'Verse:\n| [G] | [C] [D] |')]);
        final practice = container.read(practiceControllerProvider(source).notifier);
        const verse = 'song-900-section-0';

        expect(practice.seekBar(0, verse, line: 0, bar: 1, atom: 1), isTrue);
        expect(practice.beat.value?.position, const BarPosition(0, 1));
        expect(practice.beat.value?.atom, 1, reason: 'D shows as where it starts');

        practice.setCountIn(0);
        practice.play();
        async.elapse(const Duration(milliseconds: 100));
        expect((practice.beat.value?.position.step, practice.beat.value?.beat), (1, 2));

        // Into D's second beat, then pause: Play comes back in on D.
        async.elapse(const Duration(milliseconds: 500));
        expect(practice.beat.value?.beat, 3);
        practice.pause();
        expect(practice.beat.value?.atom, 1);
        practice.play();
        async.elapse(const Duration(milliseconds: 100));
        expect((practice.beat.value?.position.step, practice.beat.value?.beat), (1, 2));
        container.dispose();
      });
    });

    test('a chord picked while playing plays from its beat, on the pulse', () {
      fakeAsync((async) {
        final (:container, output: _) = setUpPractice(async, [_performSong(0, content: 'Verse:\n| [G] | [C] [D] |')]);
        final practice = container.read(practiceControllerProvider(source).notifier);
        practice.setCountIn(0);
        practice.play();
        async.elapse(const Duration(milliseconds: 100)); // beat 1 of G, at 80ms
        practice.seekBar(0, 'song-900-section-0', line: 0, bar: 1, atom: 1);
        expect(practice.beat.value?.position.step, 1);
        async.elapse(const Duration(milliseconds: 500)); // the next beat, at 580ms
        expect((practice.beat.value?.position.step, practice.beat.value?.beat), (1, 2));
        container.dispose();
      });
    });

    test('a bar or a section on and back; past the end it stays', () {
      fakeAsync((async) {
        final (:container, output: _) = setUpPractice(async, [_performSong(0)]);
        final practice = container.read(practiceControllerProvider(source).notifier);
        // Verse: G C G C (0–3); chorus: D Em (4–5).
        expect(practice.stepBar(-1), isFalse);
        expect(practice.stepBar(1), isTrue);
        expect(practice.beat.value?.position.step, 1);
        expect(practice.stepSection(1), isTrue);
        expect(practice.beat.value?.position.step, 4);
        expect(practice.stepSection(1), isFalse);
        practice.stepBar(1);
        expect(practice.stepSection(-1), isTrue, reason: 'back to the top of the chorus');
        expect(practice.beat.value?.position.step, 4);
        expect(practice.stepSection(-1), isTrue, reason: 'at its top: the verse');
        expect(practice.beat.value?.position.step, 0);
        practice.seekStep(0, 5);
        expect(practice.stepBar(1), isFalse);
        container.dispose();
      });
    });

    test('going outside a loop ends it; inside it stays', () {
      fakeAsync((async) {
        final (:container, output: _) = setUpPractice(async, [_performSong(0)]);
        final practice = container.read(practiceControllerProvider(source).notifier);
        practice.seekStep(0, 4);
        practice.toggleLoopHere();
        expect(container.read(practiceControllerProvider(source)).loop?.sectionId, 'song-900-section-2');
        practice.stepBar(1);
        expect(container.read(practiceControllerProvider(source)).loop, isNotNull);
        practice.seekStep(0, 1);
        expect(container.read(practiceControllerProvider(source)).loop, isNull);
        container.dispose();
      });
    });

    test('playing into the next song moves the chart to it', () {
      fakeAsync((async) {
        final (:container, output: _) = setUpPractice(async, [_performSong(0), _performSong(1, bpm: 60)]);
        final practice = container.read(practiceControllerProvider(source).notifier);
        practice.seekSection(0, 'song-900-section-2');
        practice.play();
        // Count-in, then the chorus's two bars at 120, then into song 2.
        async.elapse(const Duration(milliseconds: 2000 + 4000 + 100));
        expect(practice.beat.value?.position, const BarPosition(1, 0));
        expect(container.read(performControllerProvider(source)).songIndex, 1);
        container.dispose();
      });
    });
  });

  group('saving the tempo', () {
    test('lands on the device, queues for the server, and survives a sync', () async {
      final api = FakeApiAdapter({
        // The song list isn't wrapped in the envelope.
        'GET /api/songs': (_) => (
          status: 200,
          body: {
            'data': [
              {'id': 41, 'title': 'Oceans', 'bpm': 72, 'time_signature': '4/4', 'is_public': false},
            ],
            'meta': {'current_page': 1, 'last_page': 1, 'per_page': 50, 'total': 1},
          },
        ),
      });
      final c = await createTestContainer(
        api,
        overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1), isOnlineProvider.overrideWithValue(false)],
      );
      final db = c.read(appDatabaseProvider);
      await db.into(db.songs).insert(SongsCompanion.insert(id: const Value(41), workspaceId: 1, title: 'Oceans'));

      await c.read(songDetailRepositoryProvider).setTempo(41, bpm: 68, timeSignature: '6/8');
      final song = await c.read(songDetailRepositoryProvider).watchSong(41).first;
      expect(song?.bpm, 68);
      expect(song?.timeSignature, '6/8');
      expect(await db.select(db.songEdits).get(), hasLength(1));

      // The server still has the old tempo: the edit here wins until it's sent.
      await c.read(songsRepositoryProvider).sync(1);
      final after = await c.read(songDetailRepositoryProvider).watchSong(41).first;
      expect(after?.bpm, 68);
      expect(after?.timeSignature, '6/8');
    });
  });

  group('screen', () {
    Map<String, dynamic> songJson(int id, String title, {int? bpm = 120}) => {
      'id': id,
      'title': title,
      'key': 'D',
      'transposition': 0,
      'bpm': bpm,
      'time_signature': '4/4',
      'content': _chart,
      'is_public': false,
    };

    Future<ProviderContainer> open(WidgetTester tester, {int? bpm = 120}) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final api = FakeApiAdapter({
        'GET /api/line-ups/7': (_) => FakeApiAdapter.ok({
          'id': 7,
          'title': 'Sunday Service',
          'date': '2999-01-04',
          'songs_count': 1,
          'songs': [
            {'line_up_song_id': 901, 'order': 0, 'transposition': 0, 'song': songJson(41, 'Oceans', bpm: bpm)},
          ],
        }),
        'GET /api/line-ups/7/line-up-songs/capos': (_) => FakeApiAdapter.ok({'capos': <Object>[]}),
      });
      final start = tester.binding.clock.now();
      final c = await tester.runAsync(
        () => createTestContainer(
          api,
          overrides: [
            activeWorkspaceIdProvider.overrideWith((ref) => 1),
            isOnlineProvider.overrideWithValue(true),
            screenAwakeProvider.overrideWithValue(_StillAwake()),
            clickOutputProvider.overrideWith(
              (ref) => SilentClickOutput(clock: () => tester.binding.clock.now().difference(start)),
            ),
          ],
        ),
      );
      final db = c!.read(appDatabaseProvider);
      await tester.runAsync(() async {
        await db
            .into(db.lineUps)
            .insert(
              LineUpsCompanion.insert(
                id: const Value(7),
                workspaceId: 1,
                title: 'Sunday Service',
                date: '2999-01-04',
                songsCount: const Value(1),
              ),
            );
        await c.read(lineUpsRepositoryProvider).refreshDetail(7, 1);
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: DaloyTheme.light(),
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
            home: const PerformScreen(source: PerformSource.lineUp(7), practice: true),
          ),
        ),
      );
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
      return c;
    }

    testWidgets('Play counts in, then lights the bar; the click is its own switch', (tester) async {
      final c = await open(tester);
      expect(find.byType(PracticeTransport), findsOneWidget);
      expect(find.text('♩120'), findsOneWidget);
      expect(find.bySemanticsLabel('Mute the click'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Play'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(PracticeCountIn), findsOneWidget);
      expect(find.text('4'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('4'), findsNothing, reason: 'counted in');
      expect(find.bySemanticsLabel(RegExp('^Playing')), findsWidgets);
      expect(c.read(practiceControllerProvider(const PerformSource.lineUp(7))).playing, isTrue);

      await tester.tap(find.bySemanticsLabel('Mute the click'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.bySemanticsLabel('Turn the click on'), findsOneWidget);
      expect(
        c.read(practiceControllerProvider(const PerformSource.lineUp(7))).playing,
        isTrue,
        reason: 'still playing',
      );

      await tester.tap(find.bySemanticsLabel('Pause'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.bySemanticsLabel(RegExp('^Starts here')), findsWidgets);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('the scrubber says where Play starts; its arrows and a tapped chord move it', (tester) async {
      final c = await open(tester);
      final practice = c.read(practiceControllerProvider(const PerformSource.lineUp(7)).notifier);
      expect(find.byType(PracticeScrubber), findsOneWidget);
      expect(find.text('Verse · Bar 1/4 · G'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Bar on'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Verse · Bar 2/4 · C'), findsOneWidget);

      await tester.tap(find.text('Em', findRichText: true).first);
      await tester.pump(const Duration(milliseconds: 100));
      expect(practice.beat.value?.position, const BarPosition(0, 5));
      expect(find.text('Chorus · Bar 2/2 · Em'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('no tempo: Play opens the tempo sheet', (tester) async {
      await open(tester, bpm: null);
      expect(find.text('Set tempo'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Play'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('This song has no tempo yet. Tap along, or set one.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });

  test('the click is a short WAV', () {
    final wav = clickWav(frequency: 1000, gain: 0.5);
    expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
    expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
    expect(wav.length, 44 + 2 * (44100 * 45 ~/ 1000));
  });
}

class _NoPrefs implements PerformPrefsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

class _StillAwake extends ScreenAwake {
  @override
  Future<void> hold() async {}

  @override
  Future<void> release() async {}
}
