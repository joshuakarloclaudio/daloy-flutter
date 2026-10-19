import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:daloy_flutter/features/songs/domain/new_song.dart';
import 'package:daloy_flutter/features/songs/domain/tap_tempo.dart';
import 'package:daloy_flutter/features/songs/presentation/new_song_sheet.dart';
import 'package:daloy_flutter/shared/widgets/daloy_button.dart';
import 'package:daloy_flutter/shared/widgets/pressable.dart';
import 'package:daloy_flutter/shared/widgets/sheet_nav_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

Map<String, dynamic> _serverSong(int id, String title) => {
  'id': id,
  'title': title,
  'artist': 'Hillsong',
  'key': 'G',
  'transposition': 0,
  'bpm': 72,
  'time_signature': '4/4',
  'content': null,
  'lyrics': null,
  'is_public': false,
  'created_at': '2026-10-15T08:00:00+00:00',
};

const _song = NewSong(title: 'Oceans', artist: 'Hillsong', key: 'G', bpm: 72, timeSignature: '4/4');

void main() {
  late FakeApiAdapter api;
  var online = true;
  var created = 0;

  setUp(() {
    online = true;
    created = 0;
    api = FakeApiAdapter({
      'POST /api/songs': (r) {
        if (!online) throw DioException(requestOptions: r, type: DioExceptionType.connectionError);
        final body = r.data as Map<String, dynamic>;
        if ((body['title'] as String).isEmpty) {
          return FakeApiAdapter.error(
            422,
            'Invalid',
            data: {
              'errors': {
                'title': ['Required.'],
              },
            },
          );
        }
        return FakeApiAdapter.ok(_serverSong(100 + ++created, body['title'] as String), status: 201);
      },
      'GET /api/songs': (_) => (
        status: 200,
        body: {
          'data': <Object>[],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 0},
        },
      ),
    });
  });

  Future<(SongsRepository, AppDatabase)> repo() async {
    final container = await createTestContainer(api);
    return (container.read(songsRepositoryProvider), container.read(appDatabaseProvider));
  }

  test('a new song is in the library at once, under a negative local id', () async {
    final (songs, db) = await repo();
    final id = await songs.createLocal(1, _song);

    expect(id, isNegative);
    final row = await (db.select(db.songs)..where((t) => t.id.equals(id))).getSingle();
    expect((row.title, row.key, row.bpm, row.timeSignature), ('Oceans', 'G', 72, '4/4'));
    expect((await songs.findLocal(id))!.isPending, isTrue);
    expect(await songs.watchOutbox(1).first, {id: null});
  });

  test('flushing swaps the local song for the server row', () async {
    final (songs, db) = await repo();
    final id = await songs.createLocal(1, _song);

    await songs.flushOutbox(1);

    expect(api.requests.single.data, {
      'title': 'Oceans',
      'artist': 'Hillsong',
      'key': 'G',
      'bpm': 72,
      'time_signature': '4/4',
    });
    final rows = await db.select(db.songs).get();
    expect(rows.map((r) => r.id), [101]);
    expect(rows.single.workspaceId, 1);
    expect(await db.select(db.songOutbox).get(), isEmpty);
    expect(await songs.findLocal(id), isNull);
  });

  test('offline it stays queued, and goes through on the next flush', () async {
    final (songs, db) = await repo();
    final id = await songs.createLocal(1, _song);

    online = false;
    await songs.flushOutbox(1);
    expect((await songs.findLocal(id))!.isPending, isTrue);
    expect(await songs.watchOutbox(1).first, {id: null});

    online = true;
    await songs.flushOutbox(1);
    expect((await db.select(db.songs).get()).map((r) => r.id), [101]);
  });

  test('a network failure stops the queue so order is kept', () async {
    final (songs, _) = await repo();
    await songs.createLocal(1, const NewSong(title: 'One'), now: DateTime(2026, 1, 1));
    await songs.createLocal(1, const NewSong(title: 'Two'), now: DateTime(2026, 1, 2));

    online = false;
    await songs.flushOutbox(1);
    expect(api.requests, hasLength(1));
  });

  test('a song the server refuses keeps its error and does not block the rest', () async {
    final (songs, db) = await repo();
    final bad = await songs.createLocal(1, const NewSong(title: ''), now: DateTime(2026, 1, 1));
    await songs.createLocal(1, const NewSong(title: 'Good'), now: DateTime(2026, 1, 2));

    await songs.flushOutbox(1);

    expect(await songs.watchOutbox(1).first, {bad: 'Validation failed'});
    expect((await db.select(db.songs).get()).map((r) => r.title), unorderedEquals(['', 'Good']));

    await songs.discardPending(bad);
    expect(await songs.watchOutbox(1).first, isEmpty);
    expect((await db.select(db.songs).get()).map((r) => r.title), ['Good']);
  });

  test('overlapping flushes post each song once', () async {
    final (songs, _) = await repo();
    await songs.createLocal(1, _song);

    await Future.wait([songs.flushOutbox(1), songs.flushOutbox(1), songs.flushOutbox(1)]);

    expect(api.requests.where((r) => r.method == 'POST'), hasLength(1));
  });

  test('a library sync keeps songs that are still waiting to send', () async {
    final (songs, db) = await repo();
    online = false;
    final id = await songs.createLocal(1, _song);

    await songs.sync(1);

    expect((await db.select(db.songs).get()).map((r) => r.id), [id]);
  });

  test('artists come back most-used first, case-insensitively', () async {
    final (songs, _) = await repo();
    for (final (title, artist) in [
      ('a', 'Hillsong'),
      ('b', 'Elevation'),
      ('c', 'hillsong'),
      ('d', null),
      ('e', '  '),
    ]) {
      await songs.createLocal(
        1,
        NewSong(title: title, artist: artist),
        now: DateTime(2026, 1, title.codeUnitAt(0)),
      );
    }
    final artists = await songs.watchArtists(1).first;
    expect(artists.length, 2);
    expect(artists.first.toLowerCase(), 'hillsong');
    expect(artists.last, 'Elevation');
  });

  group('TapTempo', () {
    final t0 = DateTime(2026);

    test('needs two taps, then averages the gaps', () {
      final tempo = TapTempo();
      expect(tempo.tap(t0), isNull);
      expect(tempo.tap(t0.add(const Duration(milliseconds: 500))), 120);
      expect(tempo.tap(t0.add(const Duration(milliseconds: 1000))), 120);
    });

    test('a long pause starts over', () {
      final tempo = TapTempo();
      tempo.tap(t0);
      tempo.tap(t0.add(const Duration(milliseconds: 500)));
      expect(tempo.tap(t0.add(const Duration(seconds: 10))), isNull);
    });

    test('stays inside the range the API accepts', () {
      final tempo = TapTempo();
      tempo.tap(t0);
      expect(tempo.tap(t0.add(const Duration(milliseconds: 10))), NewSong.maxBpm);
    });
  });

  testWidgets('the sheet saves a song locally and returns its id', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    final container = await createTestContainer(api, overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1)]);
    int? result;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: DaloyTheme.light(),
          home: Builder(
            builder: (context) =>
                TextButton(onPressed: () async => result = await showNewSongSheet(context), child: const Text('open')),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Save waits for a title.
    expect(
      tester
          .widget<Pressable>(find.descendant(of: find.byKey(SheetNavBar.actionKey), matching: find.byType(Pressable)))
          .onPressed,
      isNull,
    );

    await tester.enterText(find.widgetWithText(TextField, 'Song title'), '  Oceans ');
    // Key, tempo and time open the same pickers as the edit screen.
    await tester.tap(find.text('KEY'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('G'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TEMPO'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '–'), '72');
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('TIME'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3/4'));
    await tester.pumpAndSettle();
    expect(find.text('72 BPM', findRichText: true), findsOneWidget);
    await tester.tap(find.byKey(SheetNavBar.actionKey));
    // Not pumpAndSettle: the background push to the server is still in flight.
    // Drift finishes on the real event loop, so let it, then play the sheet's exit.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    expect(result, isNegative);
    // Saved on the device and pushed straight away (the fake server answers
    // with its own row, which has replaced the local one by now).
    expect(api.requests.single.data, {
      'title': 'Oceans',
      'artist': null,
      'key': 'G',
      'bpm': 72,
      'time_signature': '3/4',
    });
    final db = container.read(appDatabaseProvider);
    expect((await db.select(db.songs).get()).map((r) => r.id), [101]);
  });

  testWidgets("the sheet's tempo picker refuses a tempo the API would", (tester) async {
    tester.view
      ..physicalSize = const Size(390, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    final container = await createTestContainer(api, overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1)]);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: DaloyTheme.light(),
          home: Builder(
            builder: (context) => TextButton(onPressed: () => showNewSongSheet(context), child: const Text('open')),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Song title'), 'Oceans');
    await tester.tap(find.text('TEMPO'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, '–'), '900');
    await tester.pump();

    expect(find.text('Between 20 and 300 BPM.'), findsOneWidget);
    expect(tester.widget<DaloyButton>(find.widgetWithText(DaloyButton, 'Done')).onPressed, isNull);
    final db = container.read(appDatabaseProvider);
    expect(await db.select(db.songs).get(), isEmpty);
  });
}
