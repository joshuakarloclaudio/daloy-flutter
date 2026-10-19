import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/songs/application/song_detail_controller.dart';
import 'package:daloy_flutter/features/songs/chart/nashville.dart';
import 'package:daloy_flutter/features/songs/data/song_detail_repository.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:daloy_flutter/features/songs/domain/display_prefs.dart';
import 'package:daloy_flutter/features/songs/presentation/song_detail_screen.dart';
import 'package:daloy_flutter/shared/widgets/segmented_control.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

const _chart = 'Verse 1:\n[G]Amazing [C]grace\n| [G] [D] | [Em] |';

void main() {
  late FakeApiAdapter api;
  var online = true;
  var capoOnServer = 0;

  setUp(() {
    online = true;
    capoOnServer = 0;
    FakeReply guarded(FakeReply Function(RequestOptions) reply, RequestOptions r) {
      if (!online) throw DioException(requestOptions: r, type: DioExceptionType.connectionError);
      return reply(r);
    }

    api = FakeApiAdapter({
      'PATCH /api/songs/7/changes': (r) => guarded((r) => songChangeReply(r, serverSongJson(7, content: _chart)), r),
      'GET /api/songs/7/capo': (r) => guarded((_) => FakeApiAdapter.ok({'song_id': 7, 'capo': capoOnServer}), r),
      'PATCH /api/songs/7/capo': (r) => guarded((r) {
        capoOnServer = (r.data as Map)['capo'] as int;
        return FakeApiAdapter.ok({'song_id': 7, 'capo': capoOnServer});
      }, r),
      'GET /api/songs/7/upcoming-line-ups': (r) => guarded(
        (_) => FakeApiAdapter.ok({
          'line_ups': [
            {'id': 3, 'title': 'Sunday AM', 'date': '2999-01-02', 'worship_leader': null, 'songs_count': 4},
          ],
        }),
        r,
      ),
    });
  });

  Future<(SongDetailRepository, AppDatabase)> open() async {
    final container = await createTestContainer(api);
    final db = container.read(appDatabaseProvider);
    await db
        .into(db.songs)
        .insert(
          SongsCompanion.insert(
            id: const Value(7),
            workspaceId: 1,
            title: 'Amazing Grace',
            artist: const Value('Newton'),
            key: const Value('G'),
            transposition: const Value(0),
            content: const Value(_chart),
            lyrics: const Value('Amazing grace'),
          ),
        );
    return (container.read(songDetailRepositoryProvider), db);
  }

  group('transposition', () {
    test('is saved on the device at once and queued', () async {
      final (repo, db) = await open();
      await repo.setTransposition(7, 2);

      expect((await (db.select(db.songs)..where((t) => t.id.equals(7))).getSingle()).transposition, 2);
      expect((await db.select(db.songEdits).get()).single.songId, 7);
      expect(api.requests, isEmpty);
    });

    test('flush sends just the transposition with its starting value, then clears the queue', () async {
      final (repo, db) = await open();
      await repo.setTransposition(7, 3);
      await repo.flush(1);

      final patch = api.requests.singleWhere((r) => r.method == 'PATCH' && r.path == '/api/songs/7/changes');
      expect(patch.data, {
        'changes': {'transposition': 3},
        'base': {'transposition': 0},
      });
      expect(await db.select(db.songEdits).get(), isEmpty);
    });

    test('offline keeps the edit queued for the next flush', () async {
      final (repo, db) = await open();
      online = false;
      await repo.setTransposition(7, 1);
      await repo.flush(1);
      expect(await db.select(db.songEdits).get(), hasLength(1));

      online = true;
      await repo.flush(1);
      expect(await db.select(db.songEdits).get(), isEmpty);
    });

    test('a pull from the server does not undo an unsent change', () async {
      final container = await createTestContainer(api);
      final db = container.read(appDatabaseProvider);
      await db
          .into(db.songs)
          .insert(
            SongsCompanion.insert(
              id: const Value(7),
              workspaceId: 1,
              title: 'Amazing Grace',
              transposition: const Value(0),
            ),
          );
      final repo = container.read(songDetailRepositoryProvider);
      await repo.setTransposition(7, 4);

      api.routes['GET /api/songs'] = (_) => (
        status: 200,
        body: {
          'data': [
            {'id': 7, 'title': 'Amazing Grace', 'key': 'G', 'transposition': 0},
          ],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
        },
      );
      await container.read(songsRepositoryProvider).sync(1);

      final row = await (db.select(db.songs)..where((t) => t.id.equals(7))).getSingle();
      expect((row.transposition, row.key), (4, 'G'));
    });
  });

  group('capo', () {
    test('applies at once and reaches the server', () async {
      final (repo, db) = await open();
      await repo.setCapo(7, 3);

      expect(await repo.watchCapo(7).first, 3);
      expect(capoOnServer, 3);
      expect((await db.select(db.songCapos).getSingle()).dirty, isFalse);
    });

    test('offline stays dirty, and an account refresh does not overwrite it', () async {
      final (repo, db) = await open();
      online = false;
      await repo.setCapo(7, 5);
      expect((await db.select(db.songCapos).getSingle()).dirty, isTrue);

      online = true;
      capoOnServer = 1;
      await repo.refreshCapo(7);
      expect(await repo.watchCapo(7).first, 5);

      await repo.flush(1);
      expect(capoOnServer, 5);
      expect((await db.select(db.songCapos).getSingle()).dirty, isFalse);
    });

    test('mirrors the account when nothing is waiting', () async {
      final (repo, _) = await open();
      capoOnServer = 2;
      await repo.refreshCapo(7);
      expect(await repo.watchCapo(7).first, 2);
    });
  });

  test('upcoming line-ups are cached and survive going offline', () async {
    final (repo, _) = await open();
    await repo.refreshUpcomingLineUps(7);
    online = false;
    await repo.refreshUpcomingLineUps(7);

    final lineUps = await repo.watchUpcomingLineUps(7).first;
    expect(lineUps.map((l) => (l.id, l.title, l.date)), [(3, 'Sunday AM', '2999-01-02')]);
  });

  test('display prefs default, persist and clamp', () async {
    final (repo, _) = await open();
    expect((await repo.watchPrefs().first).zoom, 100);

    await repo.setViewMode(SongViewMode.lyrics);
    await repo.setZoom(500);
    await repo.setNotation(ChordNotation.numbers);

    final prefs = await repo.watchPrefs().first;
    expect((prefs.viewMode, prefs.zoom, prefs.notation), (SongViewMode.lyrics, 200, ChordNotation.numbers));
    expect(ChartPrefs.clampZoom(101), 100);
  });

  group('screen', () {
    Future<ProviderContainer> pump(WidgetTester tester, {int songId = 7}) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = await createTestContainer(
        api,
        overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1), isOnlineProvider.overrideWithValue(online)],
      );
      final db = container.read(appDatabaseProvider);
      await db
          .into(db.songs)
          .insert(
            SongsCompanion.insert(
              id: const Value(7),
              workspaceId: 1,
              title: 'Amazing Grace',
              artist: const Value('Newton'),
              key: const Value('G'),
              bpm: const Value(72),
              transposition: const Value(0),
              content: const Value(_chart),
              lyrics: const Value('How sweet the sound'),
            ),
          );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: DaloyTheme.light(),
            // The artwork drifts forever otherwise; reduced motion stills it.
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
            home: SongDetailScreen(songId: songId),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('shows the song, its key and the chart', (tester) async {
      await pump(tester);

      expect(find.text('Amazing Grace'), findsWidgets);
      expect(find.text('Newton'), findsOneWidget);
      expect(find.text('Key G'), findsOneWidget);
      expect(find.text('72 BPM'), findsOneWidget);
      expect(find.text('VERSE 1'), findsOneWidget);
      expect(find.textContaining('Amazing', findRichText: true), findsWidgets);
      expect(find.text('COMING UP IN'), findsOneWidget);
      expect(find.text('Sunday AM'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('transposing moves the key and the chart, and records the edit', (tester) async {
      final container = await pump(tester);

      await tester.tap(find.bySemanticsLabel('Transpose up'));
      await tester.pumpAndSettle();

      expect(find.text('Key G#'), findsOneWidget);
      expect(find.text('Written in G'), findsOneWidget);
      expect(find.text('Changes saved on this device. Syncing soon.'), findsOneWidget);
      final db = container.read(appDatabaseProvider);
      expect((await db.select(db.songEdits).get()).single.songId, 7);

      // The save goes out once the taps pause.
      await tester.pump(const Duration(seconds: 2));
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
        await tester.pump();
      }
      expect(api.requests.where((r) => r.method == 'PATCH' && r.path == '/api/songs/7/changes'), hasLength(1));
      await tester.pump();
      expect(find.text('Changes synced.'), findsOneWidget);
      // The moment passes and the line goes away.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('Changes synced.'), findsNothing);
      expect(find.textContaining('on this device'), findsNothing);
    });

    testWidgets('the capo shifts the chart down and updates its label', (tester) async {
      await pump(tester);
      expect(find.text('No capo'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Capo up'));
      await tester.pumpAndSettle();

      expect(find.text('Capo 1'), findsOneWidget);
      expect(capoOnServer, 1);
    });

    testWidgets('a song that is not on the device says so', (tester) async {
      await pump(tester, songId: 99);
      expect(find.text('Song not available'), findsOneWidget);
    });

    testWidgets('the Chords/Lyrics toggle switches the body, by tap or by dragging across', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Lyrics'));
      await tester.pumpAndSettle();
      expect(find.textContaining('How sweet the sound', findRichText: true), findsOneWidget);
      expect(find.text('VERSE 1'), findsNothing);

      final trough = tester.getRect(find.byType(SegmentedControl<SongViewMode>));
      await tester.dragFrom(Offset(trough.right - 20, trough.center.dy), Offset(-trough.width, 0));
      await tester.pumpAndSettle();
      expect(find.text('VERSE 1'), findsOneWidget);
    });

    testWidgets('the display sheet offers notation and size, not the view mode', (tester) async {
      await pump(tester);
      await tester.tap(find.byTooltip('Display'));
      await tester.pumpAndSettle();

      expect(find.text('CHORDS AS'), findsOneWidget);
      expect(find.text('100%'), findsWidgets);
      expect(find.text('SHOW'), findsNothing);
      // This song has a key, so numbers can be chosen.
      await tester.tap(find.text('Numbers'));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(tester.element(find.byType(SongDetailScreen)));
      expect(container.read(songDetailControllerProvider(7)).numberingReference, '1 = G');
    });

    testWidgets('numbers need a key', (tester) async {
      await pump(tester);
      final container = ProviderScope.containerOf(tester.element(find.byType(SongDetailScreen)));
      await container.read(songDetailRepositoryProvider).setNotation(ChordNotation.numbers);
      await tester.pumpAndSettle();

      expect(container.read(songDetailControllerProvider(7)).numberingReference, '1 = G');
    });
  });
}
