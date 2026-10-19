import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/device/screen_awake.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/perform/application/perform_controller.dart';
import 'package:daloy_flutter/features/perform/data/perform_prefs_repository.dart';
import 'package:daloy_flutter/features/perform/domain/page_turn.dart';
import 'package:daloy_flutter/features/perform/domain/perform_sections.dart';
import 'package:daloy_flutter/features/perform/domain/perform_theme.dart';
import 'package:daloy_flutter/features/perform/presentation/perform_screen.dart';
import 'package:daloy_flutter/features/perform/presentation/widgets/perform_chrome.dart';
import 'package:daloy_flutter/features/songs/domain/display_prefs.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

const _oceans =
    'Verse:\n[D]You call me out\n[A]upon the waters\n\nChorus: x2\n[G]I will call\n[D]upon your name\n\nBridge:\n[Bm]Spirit lead me';

Map<String, dynamic> _song(int id, String title, {String content = _oceans, String? key = 'D'}) => {
  'id': id,
  'title': title,
  'artist': 'Hillsong',
  'key': key,
  'transposition': 0,
  'bpm': 72,
  'time_signature': '4/4',
  'content': content,
  'lyrics': 'You call me out\nupon the waters',
  'is_public': false,
  'created_at': '2026-10-15T08:00:00+00:00',
};

Map<String, dynamic> _detail() => {
  'id': 7,
  'title': 'Sunday Service',
  'date': '2999-01-04',
  'worship_leader': 'Ana',
  'songs_count': 2,
  'songs': [
    {
      'line_up_song_id': 901,
      'order': 0,
      'transposition': 2,
      'song': _song(41, 'Oceans'),
      'notes': [
        {'id': 'b4e1c7a0-0000-4000-8000-000000000001', 'line': 5, 'text': 'Build here'},
      ],
      // Bridge first, then the verse; the chorus is cut.
      'section_arrangement': {
        'chords': {
          'order': [2, 0],
          'removed': [1],
        },
        'lyrics': {'order': <int>[], 'removed': <int>[]},
      },
    },
    {
      'line_up_song_id': 902,
      'order': 1,
      'transposition': 0,
      'song': _song(42, 'Cornerstone', content: '[C]My hope is built'),
      'section_arrangement': null,
    },
  ],
};

class _FakeAwake extends ScreenAwake {
  int held = 0;
  int released = 0;

  @override
  Future<void> hold() async => held++;

  @override
  Future<void> release() async => released++;
}

void main() {
  group('sections', () {
    test('headers start sections; blank lines split them; repeats carry', () {
      final s = groupBySections(_oceans, 'k');
      expect([for (final b in s) b.label], ['Verse', 'Chorus', 'Bridge']);
      expect(s[1].repeat, 2);
      expect(s[0].startLine, 1);
      expect(s[1].startLine, 5);
      expect(s[0].lines, ['[D]You call me out', '[A]upon the waters']);
      expect([for (final b in s) b.id], ['k-section-0', 'k-section-2', 'k-section-4']);
    });

    test('a stanza inside a section continues it unlabelled; a lead-in is "Start"', () {
      final s = groupBySections('[G]Intro line\nVerse:\n[C]One\n\n[D]Two', 'k');
      expect([for (final b in s) b.label], ['Start', 'Verse', '']);
      expect(s[2].lines, ['[D]Two']);
    });

    test('no headers: every stanza is a section', () {
      final s = groupBySections('a\nb\n\n\nc', 'k');
      expect(
        [for (final b in s) b.lines],
        [
          ['a', 'b'],
          ['c'],
        ],
      );
      expect(s[1].startLine, 4);
    });

    test('arrangement reorders, cuts, appends new sections and never empties', () {
      final s = groupBySections(_oceans, 'k');
      List<String> labels(SectionArrangementField f) => [for (final b in applyArrangement(s, f)) b.label];

      expect(labels(const SectionArrangementField(order: [2, 0], removed: [1])), ['Bridge', 'Verse']);
      expect(labels(const SectionArrangementField(order: [1])), ['Chorus', 'Verse', 'Bridge']);
      expect(labels(const SectionArrangementField(order: [9, 1, 1])), ['Chorus', 'Verse', 'Bridge']);
      expect(labels(const SectionArrangementField(removed: [0, 1, 2])), ['Verse', 'Chorus', 'Bridge']);
      expect(applyArrangement(s, null), s);
    });

    test('a note just past a section belongs to it', () {
      final verse = groupBySections(_oceans, 'k').first;
      const notes = [
        LineUpSongNote(id: 'a', line: 1, text: 'top'),
        LineUpSongNote(id: 'b', line: 3, text: 'after'),
        LineUpSongNote(id: 'c', line: 4, text: 'chorus header'),
      ];
      expect([for (final n in notesForSection(notes, verse)) n.id], ['a', 'b']);
    });
  });

  group('page turns', () {
    test('turn a screen at a time, straight across songs, and stop at the ends', () {
      expect(pageStep(800), 728);
      expect(pageTurnTarget(offset: 0, maxExtent: 1000, step: 700, forward: true), 700);
      expect(pageTurnTarget(offset: 700, maxExtent: 1000, step: 700, forward: true), 1000);
      expect(pageTurnTarget(offset: 1000, maxExtent: 1000, step: 700, forward: true), isNull);
      expect(pageTurnTarget(offset: 300, maxExtent: 1000, step: 700, forward: false), 0);
      expect(pageTurnTarget(offset: 0, maxExtent: 1000, step: 700, forward: false), isNull);
    });

    test('the current song is the last heading past the read line', () {
      const tops = [-900.0, 150.0, 700.0];
      expect(currentSongAt(tops, readLine: 300, atEnd: false, viewportBottom: 800), 1);
      expect(currentSongAt(tops, readLine: 100, atEnd: false, viewportBottom: 800), 0);
      // At the bottom of the set, a short closing song counts once it shows.
      expect(currentSongAt(tops, readLine: 100, atEnd: true, viewportBottom: 800), 2);
      expect(currentSongAt(const [], readLine: 100, atEnd: true, viewportBottom: 800), 0);
    });

    test('a highlight scrolls only as far as it takes to show the whole section', () {
      // In view: stay put.
      expect(revealDelta(top: 200, bottom: 400, upper: 150, lower: 700), isNull);
      // Cut off below: up just enough.
      expect(revealDelta(top: 600, bottom: 800, upper: 150, lower: 700), 100);
      // Under the top chrome: down just enough.
      expect(revealDelta(top: 100, bottom: 300, upper: 150, lower: 700), -50);
      // Taller than the space: its top to the top.
      expect(revealDelta(top: 400, bottom: 1400, upper: 150, lower: 700), 250);
      expect(revealDelta(top: 150, bottom: 1400, upper: 150, lower: 700), isNull);
    });

    test('previous goes to the top of this song first', () {
      expect(previousSongTarget(current: 2, currentTop: -400, readLine: 100), 2);
      expect(previousSongTarget(current: 2, currentTop: 100, readLine: 100), 1);
      expect(previousSongTarget(current: 0, currentTop: 100, readLine: 100), 0);
    });
  });

  group('themes', () {
    test('Default follows the device; named themes never do', () {
      expect(PerformTheme.appDefault.resolve(Brightness.dark).brightness, Brightness.dark);
      expect(PerformTheme.paper.resolve(Brightness.dark).brightness, Brightness.light);
      expect(PerformTheme.eInk.resolve(Brightness.light).flat, isTrue);
      expect(PerformTheme.parse('eInkDark'), PerformTheme.eInkDark);
      expect(PerformTheme.parse('nonsense'), PerformTheme.appDefault);
    });
  });

  late FakeApiAdapter api;
  setUp(() {
    api = FakeApiAdapter({
      'GET /api/line-ups/7': (_) => FakeApiAdapter.ok(_detail()),
      'GET /api/line-ups/7/line-up-songs/capos': (_) => FakeApiAdapter.ok({
        'capos': [
          {'line_up_song_id': 901, 'capo': 2},
          {'line_up_song_id': 902, 'capo': 0},
        ],
      }),
    });
  });

  Future<ProviderContainer> container({List<Override> extra = const []}) => createTestContainer(
    api,
    overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1), isOnlineProvider.overrideWithValue(true), ...extra],
  );

  Future<void> seed(AppDatabase db) => db
      .into(db.lineUps)
      .insert(
        LineUpsCompanion.insert(
          id: const Value(7),
          workspaceId: 1,
          title: 'Sunday Service',
          date: '2999-01-04',
          songsCount: const Value(2),
        ),
      );

  group('data', () {
    test('the line-up arrangement reaches the device and Perform plays it', () async {
      final c = await container();
      await seed(c.read(appDatabaseProvider));
      await c.read(lineUpsRepositoryProvider).refreshDetail(7, 1);

      final setlist = await c.read(lineUpsRepositoryProvider).watchSetlist(7).first;
      expect(setlist[0].sectionArrangement?.chords.order, [2, 0]);
      expect(setlist[1].sectionArrangement, isNull);

      final sub = c.listen(performControllerProvider(PerformSource.lineUp(7)), (_, _) {});
      addTearDown(sub.close);
      await pumpEventQueue();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = c.read(performControllerProvider(PerformSource.lineUp(7)));
      expect([for (final s in state.songs[0].sections) s.label], ['Bridge', 'Verse']);
      expect(state.songs[0].notes.single.text, 'Build here');
    });

    test('Perform prefs live on the device', () async {
      final c = await container();
      final repo = c.read(performPrefsRepositoryProvider);
      expect(await repo.watch().first, const PerformPrefs());

      await repo.setTheme(PerformTheme.paper);
      await repo.setAutoHide(false);
      await repo.setNotesVisible(false);
      expect(
        await repo.watch().first,
        const PerformPrefs(theme: PerformTheme.paper, autoHide: false, notesVisible: false),
      );

      await repo.setTheme(PerformTheme.appDefault);
      expect((await repo.watch().first).theme, PerformTheme.appDefault);
    });
  });

  group('screen', () {
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<(ProviderContainer, _FakeAwake)> pump(
      WidgetTester tester, {
      Size size = const Size(390, 844),
      bool autoHide = false,
    }) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final awake = _FakeAwake();
      final c = await container(extra: [screenAwakeProvider.overrideWithValue(awake)]);
      await seed(c.read(appDatabaseProvider));
      await c.read(performPrefsRepositoryProvider).setAutoHide(autoHide);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: DaloyTheme.light(),
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
            home: const PerformScreen(source: PerformSource.lineUp(7)),
          ),
        ),
      );
      await settle(tester);
      return (c, awake);
    }

    bool chromeVisible(WidgetTester tester) =>
        tester.widgetList<PerformChromeSlide>(find.byType(PerformChromeSlide)).every((w) => w.visible);

    testWidgets('opens on the first song, in its line-up key and arrangement', (tester) async {
      final (_, awake) = await pump(tester);

      expect(find.text('SONG 1 OF 2'), findsOneWidget);
      expect(find.text('Oceans'), findsWidgets);
      expect(find.text('Key E'), findsOneWidget);
      expect(find.text('Capo 2'), findsOneWidget);
      // Chips follow the arrangement: the chorus is cut.
      expect(find.text('Bridge'), findsOneWidget);
      expect(find.text('Verse'), findsOneWidget);
      expect(find.text('Chorus'), findsNothing);
      expect(
        tester.getTopLeft(find.text('BRIDGE', findRichText: true)).dy,
        lessThan(tester.getTopLeft(find.text('VERSE', findRichText: true)).dy),
      );
      expect(awake.held, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the set is one scroll: a song runs into the next', (tester) async {
      await pump(tester);

      // Both songs are laid out in one chart, the second right after the first.
      final end = tester.getTopLeft(find.text('VERSE', findRichText: true)).dy;
      final next = tester.getTopLeft(find.text('SONG 2 OF 2')).dy;
      expect(next, greaterThan(end));
      expect(find.byType(PageView), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolling into the next song makes it current', (tester) async {
      final (c, _) = await pump(tester);

      await tester.drag(find.text('SONG 1 OF 2'), const Offset(0, -1200));
      await settle(tester);
      expect(c.read(performControllerProvider(PerformSource.lineUp(7))).songIndex, 1);
      expect(find.text('2 of 2 · Cornerstone'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('next, previous, swipes and pedals move through the set', (tester) async {
      final (c, _) = await pump(tester);
      int current() => c.read(performControllerProvider(PerformSource.lineUp(7))).songIndex;
      double offset() => tester.state<ScrollableState>(find.byType(Scrollable).first).position.pixels;

      await tester.tap(find.bySemanticsLabel('Next song'));
      await settle(tester);
      expect(current(), 1);

      await tester.tap(find.bySemanticsLabel('Previous song'));
      await settle(tester);
      expect(current(), 0);
      expect(offset(), 0);

      // A swipe sideways jumps a song; it doesn't page.
      await tester.fling(find.text('SONG 1 OF 2'), const Offset(-300, 0), 1000);
      await settle(tester);
      expect(current(), 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.bracketLeft);
      await settle(tester);
      expect(current(), 0);

      // A pedal turns a page, straight on into the next song.
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await settle(tester);
      expect(offset(), greaterThan(0));
      expect(current(), 1);

      // Page Up turns back.
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await settle(tester);
      expect(offset(), 0);
      expect(current(), 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tap anywhere on a section marks it; again clears it; in view, nothing scrolls', (tester) async {
      final (c, _) = await pump(tester);
      double offset() => tester.state<ScrollableState>(find.byType(Scrollable).last).position.pixels;

      // Near the left edge, which used to turn pages.
      await tester.tapAt(
        tester.getTopLeft(find.textContaining('Spirit', findRichText: true).first) + const Offset(4, 4),
      );
      await settle(tester);
      expect(c.read(performControllerProvider(PerformSource.lineUp(7))).activeSectionId, 'song-901-section-4');
      expect(offset(), 0);

      await tester.tapAt(
        tester.getTopLeft(find.textContaining('Spirit', findRichText: true).first) + const Offset(4, 4),
      );
      await settle(tester);
      expect(c.read(performControllerProvider(PerformSource.lineUp(7))).activeSectionId, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a section chip marks the section being played', (tester) async {
      final (c, _) = await pump(tester);

      await tester.tap(find.text('Verse'));
      await settle(tester);
      expect(c.read(performControllerProvider(PerformSource.lineUp(7))).activeSectionId, 'song-901-section-0');
      expect(find.textContaining('NOW', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('notes show in place and can be hidden', (tester) async {
      final (c, _) = await pump(tester);
      expect(find.text('Build here'), findsNothing); // On the cut chorus.

      // Played as written, the chorus and its note come back.
      final db = c.read(appDatabaseProvider);
      await (db.update(
        db.lineUpSongs,
      )..where((t) => t.lineUpSongId.equals(901))).write(const LineUpSongsCompanion(sectionArrangement: Value(null)));
      await settle(tester);
      expect(find.text('Build here'), findsOneWidget);

      await c.read(performPrefsRepositoryProvider).setNotesVisible(false);
      await settle(tester);
      expect(find.text('Build here'), findsNothing);
    });

    testWidgets('the chrome hides itself and a tap brings it back', (tester) async {
      await pump(tester, autoHide: true);
      expect(chromeVisible(tester), isTrue);

      await tester.pump(const Duration(seconds: 5));
      expect(chromeVisible(tester), isFalse);

      await tester.tap(find.text('SONG 1 OF 2'));
      await tester.pump();
      expect(chromeVisible(tester), isTrue);
      expect(find.text('SONG 1 OF 2'), findsOneWidget);
    });

    testWidgets('hidden chrome comes back from the corner handle, or a little scroll up', (tester) async {
      await pump(tester, autoHide: true);
      bool handleVisible() => tester.widget<PerformChromeHandle>(find.byType(PerformChromeHandle)).visible;
      expect(handleVisible(), isFalse);

      await tester.pump(const Duration(seconds: 5));
      expect(chromeVisible(tester), isFalse);
      expect(handleVisible(), isTrue);
      expect(find.text('1/2'), findsOneWidget);

      await tester.tap(find.text('1/2'));
      await tester.pump();
      expect(chromeVisible(tester), isTrue);
      expect(handleVisible(), isFalse);

      // Reading on hides it; a short scroll back up brings it back.
      final chart = find.byType(SingleChildScrollView);
      final gesture = await tester.startGesture(tester.getCenter(chart));
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(0, -20));
        await tester.pump();
      }
      expect(chromeVisible(tester), isFalse);
      for (var i = 0; i < 3; i++) {
        await gesture.moveBy(const Offset(0, 15));
        await tester.pump();
      }
      expect(chromeVisible(tester), isTrue);
      await gesture.up();
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('the theme repaints the page', (tester) async {
      final (c, _) = await pump(tester);
      await c.read(performPrefsRepositoryProvider).setTheme(PerformTheme.paper);
      await settle(tester);

      final scaffold = tester.element(find.byType(Scaffold).first);
      expect(Theme.of(scaffold).scaffoldBackgroundColor, PerformPalette.paper.colors.background);
    });

    testWidgets('display settings change the chart', (tester) async {
      final (c, _) = await pump(tester);

      await tester.tap(find.bySemanticsLabel('Display'));
      await settle(tester);
      expect(find.text('Hide controls while playing'), findsOneWidget);
      await tester.tap(find.text('Lyrics'));
      await settle(tester);
      expect(c.read(performControllerProvider(PerformSource.lineUp(7))).viewMode, SongViewMode.lyrics);
      expect(tester.takeException(), isNull);
    });

    testWidgets('leaving asks first and lets the screen sleep', (tester) async {
      final (_, awake) = await pump(tester);

      await tester.tap(find.bySemanticsLabel('Leave Perform'));
      await settle(tester);
      expect(find.text('Leave Perform?'), findsOneWidget);
      await tester.tap(find.text('Keep playing'));
      await settle(tester);
      expect(find.text('SONG 1 OF 2'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      expect(awake.released, 1);
    });

    testWidgets('tablets in landscape set the chart in two columns', (tester) async {
      await pump(tester, size: const Size(1366, 1024));

      final bridge = tester.getTopLeft(find.text('BRIDGE', findRichText: true));
      final verse = tester.getTopLeft(find.text('VERSE', findRichText: true));
      expect(verse.dx, greaterThan(bridge.dx + 200));
      expect(verse.dy, closeTo(bridge.dy, 1));
      expect(tester.takeException(), isNull);
    });
  });
}
