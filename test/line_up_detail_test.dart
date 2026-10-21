import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/application/line_up_detail_controller.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/presentation/line_up_detail_screen.dart';
import 'package:daloy_flutter/features/line_ups/presentation/widgets/setlist_row.dart';
import 'package:daloy_flutter/features/songs/chart/nashville.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

Map<String, dynamic> _song(int id, String title, {String? key = 'G', String? youtube}) => {
  'id': id,
  'title': title,
  'artist': 'Hillsong',
  'key': key,
  'transposition': 0,
  'bpm': 72,
  'time_signature': '4/4',
  'content': '[G]Amazing [C]grace',
  'lyrics': 'Amazing grace',
  'youtube_url': youtube,
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
        {'id': 'b4e1c7a0-0000-4000-8000-000000000001', 'line': 3, 'text': 'Build here'},
      ],
    },
    {'line_up_song_id': 902, 'order': 1, 'transposition': 0, 'song': _song(42, 'Untitled hymn', key: null)},
  ],
};

void main() {
  late FakeApiAdapter api;
  late List<String> calls;
  var online = true;
  var deleteStatus = 200;

  setUp(() {
    online = true;
    deleteStatus = 200;
    calls = [];
    FakeReply guard(RequestOptions r, FakeReply Function() reply) {
      calls.add('${r.method} ${r.path}');
      if (!online) throw DioException(requestOptions: r, type: DioExceptionType.connectionError);
      return reply();
    }

    api = FakeApiAdapter({
      'GET /api/line-ups/7': (r) => guard(r, () => FakeApiAdapter.ok(_detail())),
      'GET /api/line-ups/7/line-up-songs/capos': (r) => guard(
        r,
        () => FakeApiAdapter.ok({
          'capos': [
            {'line_up_song_id': 901, 'capo': 2},
            {'line_up_song_id': 902, 'capo': 0},
          ],
        }),
      ),
      'PATCH /api/line-ups/7/line-up-songs/901': (r) => guard(r, () => FakeApiAdapter.ok({})),
      'PATCH /api/line-ups/7/line-up-songs/901/capo': (r) =>
          guard(r, () => FakeApiAdapter.ok({'line_up_song_id': 901, 'capo': (r.data as Map)['capo']})),
      'PUT /api/line-ups/7/songs': (r) => guard(r, () => FakeApiAdapter.ok(_detail())),
      'POST /api/line-ups/7/share': (r) =>
          guard(r, () => FakeApiAdapter.ok({'enabled': true, 'token': 'abc', 'share_path': '/share/l/abc'})),
      'DELETE /api/line-ups/7': (r) =>
          guard(r, () => deleteStatus == 200 ? FakeApiAdapter.ok(null) : FakeApiAdapter.error(deleteStatus, 'Nope.')),
      'GET /api/line-ups': (r) => guard(
        r,
        () => FakeApiAdapter.ok({
          'line_ups': [
            {'id': 7, 'title': 'Sunday Service', 'date': '2999-01-04', 'worship_leader': 'Ana', 'songs_count': 2},
          ],
        }),
      ),
    });
  });

  Future<ProviderContainer> container({bool isOnline = true}) => createTestContainer(
    api,
    overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1), isOnlineProvider.overrideWithValue(isOnline)],
  );

  Future<void> seedLineUp(AppDatabase db) => db
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

  group('repository', () {
    test('the detail brings songs, notes and capos onto the device', () async {
      final c = await container();
      final repo = c.read(lineUpsRepositoryProvider);
      await seedLineUp(c.read(appDatabaseProvider));

      await repo.refreshDetail(7, 1);
      await repo.refreshCapos(7);

      final set = await repo.watchSetlist(7).first;
      expect(
        [for (final e in set) (e.song.title, e.transposition, e.lineUpSongId)],
        [('Oceans', 2, 901), ('Untitled hymn', 0, 902)],
      );
      expect(set.first.notes.single.text, 'Build here');
      expect(await repo.watchCapos(7).first, {901: 2, 902: 0});
    });

    test('a key change is a PATCH when online, and queues the set when not', () async {
      final c = await container();
      final repo = c.read(lineUpsRepositoryProvider);
      final db = c.read(appDatabaseProvider);
      await seedLineUp(db);
      await repo.refreshDetail(7, 1);

      await repo.setSongTransposition(7, 0, 3);
      await repo.pushSongTransposition(7, 0);
      expect(calls.last, 'PATCH /api/line-ups/7/line-up-songs/901');
      expect(api.requests.last.data, {'transposition': 3});
      expect(await db.select(db.lineUpOutbox).get(), isEmpty);

      online = false;
      await repo.setSongTransposition(7, 0, 4);
      await repo.pushSongTransposition(7, 0);
      expect((await db.select(db.lineUpOutbox).get()).single.songsDirty, isTrue);
      expect((await repo.watchSetlist(7).first).first.transposition, 4);

      online = true;
      await repo.flushOutbox(1);
      expect(calls.last, 'PUT /api/line-ups/7/songs');
      expect(await db.select(db.lineUpOutbox).get(), isEmpty);
    });

    test('a capo change applies at once and is sent', () async {
      final c = await container();
      final repo = c.read(lineUpsRepositoryProvider);
      await seedLineUp(c.read(appDatabaseProvider));
      await repo.refreshDetail(7, 1);

      online = false;
      await repo.setCapo(7, 901, 5);
      expect(await repo.watchCapos(7).first, {901: 5});

      // A refresh doesn't overwrite a capo that hasn't been sent.
      online = true;
      await repo.refreshCapos(7);
      expect((await repo.watchCapos(7).first)[901], 5);

      await repo.flushCapos();
      expect(api.requests.last.data, {'capo': 5});
    });

    test('a removed line-up stays gone through a sync, and undo restores it', () async {
      final c = await container();
      final repo = c.read(lineUpsRepositoryProvider);
      await seedLineUp(c.read(appDatabaseProvider));
      await repo.refreshDetail(7, 1);

      final removed = (await repo.removeLocal(7))!;
      expect(await repo.watchLineUp(7).first, isNull);

      await repo.sync(1);
      expect(await repo.watchLineUp(7).first, isNull, reason: 'the server still lists it during the undo window');

      await repo.restore(removed);
      expect((await repo.watchLineUp(7).first)!.title, 'Sunday Service');
      expect((await repo.watchSetlist(7).first).length, 2);
    });

    test('a refused delete puts the line-up back', () async {
      final c = await container();
      final repo = c.read(lineUpsRepositoryProvider);
      await seedLineUp(c.read(appDatabaseProvider));
      await repo.refreshDetail(7, 1);
      deleteStatus = 403;

      final removed = (await repo.removeLocal(7))!;
      await expectLater(repo.deleteRemote(removed), throwsA(anything));
      expect(await repo.watchLineUp(7).first, isNotNull);
    });
  });

  group('controller', () {
    test('each song carries its line-up key, capo and notation', () async {
      final c = await container();
      await seedLineUp(c.read(appDatabaseProvider));
      final sub = c.listen(lineUpDetailControllerProvider(7), (_, _) {});
      addTearDown(sub.close);
      await c.read(lineUpDetailRefreshProvider(7).future);
      await c.read(lineUpsRepositoryProvider).setCapo(7, 901, 2);
      await c.read(lineUpsRepositoryProvider).watchSetlist(7).first;
      await pumpEventQueue();

      final state = c.read(lineUpDetailControllerProvider(7));
      final [oceans, hymn] = state.songs;
      expect((oceans.displayKey, oceans.isTransposed, oceans.capo, oceans.chartTransposition), ('A', true, 2, 0));
      expect(oceans.tempo, '72 BPM · 4/4');
      expect(hymn.displayKey, isNull);
      expect(state.keyFlow, ['A']);
      expect(state.canListen, isFalse);

      await c.read(lineUpDetailControllerProvider(7).notifier).setNotation(ChordNotation.numbers);
      await pumpEventQueue();
      final numbers = c.read(lineUpDetailControllerProvider(7));
      expect((numbers.songs[0].notation, numbers.songs[1].notation), (ChordNotation.numbers, ChordNotation.letters));
    });
  });

  group('screen', () {
    /// Lets Drift's real-async streams land between frames.
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<ProviderContainer> pump(WidgetTester tester, {Size size = const Size(390, 844)}) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = await container();
      await seedLineUp(c.read(appDatabaseProvider));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: DaloyTheme.light(),
            // The cover's drift loops forever; tests settle without it.
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
            home: const LineUpDetailScreen(lineUpId: 7),
          ),
        ),
      );
      await settle(tester);
      return c;
    }

    testWidgets('shows the cover, the ways in and the set', (tester) async {
      await pump(tester);

      expect(find.text('Sunday Service'), findsWidgets);
      expect(find.text('Led by Ana · 2 songs'), findsOneWidget);
      expect(find.text('Go live'), findsOneWidget);
      expect(find.text('Practice'), findsOneWidget);
      expect(find.text('Present'), findsOneWidget);
      expect(find.text('Listen'), findsOneWidget);
      expect(find.text('Oceans'), findsOneWidget);
      expect(find.text('Untitled hymn'), findsOneWidget);
      final badge = tester.widget<KeyBadge>(find.byType(KeyBadge));
      expect((badge.keyName, badge.highlighted, badge.capo), ('A', true, 2));
      expect(find.text('Hillsong · 72 BPM · 4/4'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a song opens in its line-up key, and swipes to the next', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Oceans'));
      await settle(tester);
      expect(find.text('SONG 1 OF 2'), findsOneWidget);
      expect(find.text('Key A'), findsOneWidget);
      expect(find.text('Capo 2'), findsWidgets);
      expect(find.textContaining('Build here', findRichText: true), findsOneWidget);

      await tester.fling(find.text('Key A'), const Offset(-400, 0), 1000);
      await settle(tester);
      expect(find.text('SONG 2 OF 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the song sheet’s pencil goes straight to the lyrics editor and saves to the song', (tester) async {
      final c = await pump(tester);

      await tester.tap(find.text('Oceans'));
      await settle(tester);
      await tester.tap(find.text('Lyrics'));
      await settle(tester);
      await tester.tap(find.bySemanticsLabel('Edit lyrics'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Amazing grace, how sweet');
      await tester.tap(find.text('Done'));
      await settle(tester);

      final db = c.read(appDatabaseProvider);
      final song = await tester.runAsync(() => (db.select(db.songs)..where((t) => t.id.equals(41))).getSingle());
      expect(song!.lyrics, 'Amazing grace, how sweet');
      expect(find.text('Lyrics saved to “Oceans”.'), findsOneWidget);
      // Back on the sheet, showing the new words.
      expect(find.text('SONG 1 OF 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablets put the set beside the cover', (tester) async {
      await pump(tester, size: const Size(1024, 768));

      final cover = tester.getCenter(find.text('Go live'));
      final song = tester.getCenter(find.text('Oceans'));
      expect(song.dx, greaterThan(cover.dx));
      expect(tester.takeException(), isNull);
    });
  });
}
