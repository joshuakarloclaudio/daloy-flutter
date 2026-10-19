import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/songs/application/song_sync.dart';
import 'package:daloy_flutter/features/songs/data/song_detail_repository.dart';
import 'package:daloy_flutter/features/songs/data/song_sync_activity.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:daloy_flutter/features/songs/domain/new_song.dart';
import 'package:daloy_flutter/features/songs/presentation/widgets/song_sync_badge.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

Map<String, dynamic> _serverSong(int id) => {
  'id': id,
  'title': 'Oceans',
  'artist': null,
  'key': 'G',
  'transposition': 0,
  'bpm': null,
  'time_signature': null,
  'content': null,
  'lyrics': null,
  'is_public': false,
  'created_at': '2026-10-15T08:00:00+00:00',
};

void main() {
  group('songSyncStates', () {
    final at = DateTime(2026, 10, 16, 9);

    test('waiting, sending, refused and just-landed songs each get their state', () {
      final states = songSyncStates(
        outbox: {-5: null, -6: 'Title taken.'},
        edits: {7: null, 8: null},
        activity: SongSyncActivityState(sending: const {8}, syncedAt: {101: at}),
      );
      expect(states[-5]!.status, SongSyncStatus.onDevice);
      expect(states[-5]!.isNew, isTrue);
      expect((states[-6]!.status, states[-6]!.error), (SongSyncStatus.failed, 'Title taken.'));
      expect(states[7]!.status, SongSyncStatus.onDevice);
      expect(states[7]!.isNew, isFalse);
      expect(states[8]!.status, SongSyncStatus.syncing);
      expect((states[101]!.status, states[101]!.syncedAt), (SongSyncStatus.synced, at));
      expect(states, hasLength(5));
    });

    test('a song queued again after it landed reads as on device, not synced', () {
      final states = songSyncStates(
        outbox: const {},
        edits: {7: null},
        activity: SongSyncActivityState(syncedAt: {7: at}),
      );
      expect(states[7]!.status, SongSyncStatus.onDevice);
    });

    test('a retry of a refused song shows as syncing', () {
      final states = songSyncStates(
        outbox: const {},
        edits: {7: 'Nope.'},
        activity: const SongSyncActivityState(sending: {7}),
      );
      expect(states[7]!.status, SongSyncStatus.syncing);
    });

    test('Synced lasts three seconds', () {
      final s = SongSync(SongSyncStatus.synced, syncedAt: at);
      expect(s.syncedRemaining(at.add(const Duration(seconds: 1))), const Duration(seconds: 2));
      expect(s.syncedRemaining(at.add(const Duration(seconds: 4))).isNegative, isTrue);
    });
  });

  group('outboxes report as they push', () {
    late FakeApiAdapter api;
    var online = true;

    setUp(() {
      online = true;
      api = FakeApiAdapter({
        'POST /api/songs': (r) {
          if (!online) throw DioException(requestOptions: r, type: DioExceptionType.connectionError);
          return FakeApiAdapter.ok(_serverSong(101), status: 201);
        },
        'PATCH /api/songs/7/changes': (r) {
          if (!online) throw DioException(requestOptions: r, type: DioExceptionType.connectionError);
          return songChangeReply(r, serverSongJson(7));
        },
      });
    });

    test('a new song: on device, then synced under its server id', () async {
      final container = await createTestContainer(api);
      final songs = container.read(songsRepositoryProvider);
      final seen = <SongSyncActivityState>[];
      container.listen(songSyncActivityProvider, (_, next) => seen.add(next), fireImmediately: true);

      final id = await songs.createLocal(1, const NewSong(title: 'Oceans', key: 'G'));
      await songs.flushOutbox(1);

      expect(seen.any((s) => s.sending.contains(id)), isTrue);
      final last = container.read(songSyncActivityProvider);
      expect(last.sending, isEmpty);
      expect(last.syncedAt.keys, [101]);
    });

    test('offline: the request ends without a synced mark, and the song stays on device', () async {
      online = false;
      final container = await createTestContainer(api);
      final songs = container.read(songsRepositoryProvider);
      final id = await songs.createLocal(1, const NewSong(title: 'Oceans'));
      await songs.flushOutbox(1);

      final activity = container.read(songSyncActivityProvider);
      expect(activity.sending, isEmpty);
      expect(activity.syncedAt, isEmpty);
      final db = container.read(appDatabaseProvider);
      expect((await db.select(db.songOutbox).get()).single.localId, id);
    });

    test('an edit: synced once the server has it', () async {
      final container = await createTestContainer(api);
      final db = container.read(appDatabaseProvider);
      await db.into(db.songs).insert(SongsCompanion.insert(id: const Value(7), workspaceId: 1, title: 'Oceans'));
      await db
          .into(db.songEdits)
          .insert(SongEditsCompanion.insert(songId: const Value(7), workspaceId: 1, updatedAt: DateTime(2026)));

      await container.read(songDetailRepositoryProvider).flush(1);

      expect(container.read(songSyncActivityProvider).syncedAt.keys, [7]);
      expect(await db.select(db.songEdits).get(), isEmpty);
    });
  });

  group('SongSyncBadge', () {
    Future<void> pump(WidgetTester tester, SongSync? sync) => tester.pumpWidget(
      MaterialApp(
        theme: DaloyTheme.light(),
        home: Scaffold(
          body: Row(children: [SongSyncBadge(sync: sync)]),
        ),
      ),
    );

    testWidgets('names each state', (tester) async {
      await pump(tester, const SongSync(SongSyncStatus.onDevice));
      expect(find.text('ON DEVICE'), findsOneWidget);
      await pump(tester, const SongSync(SongSyncStatus.failed, error: 'x'));
      await tester.pumpAndSettle();
      expect(find.text('NOT SYNCED'), findsOneWidget);
      await pump(tester, const SongSync(SongSyncStatus.syncing));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('SYNCING'), findsOneWidget);
    });

    testWidgets('Synced shows for a moment, then fades away', (tester) async {
      await pump(tester, SongSync(SongSyncStatus.synced, syncedAt: DateTime.now()));
      expect(find.text('SYNCED'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(find.text('SYNCED'), findsNothing);
    });
  });

  test('the activity tracker forgets old synced marks', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(songSyncActivityProvider.notifier).finished(1, synced: true);
    container.read(songSyncActivityProvider.notifier).finished(2, synced: false);
    expect(container.read(songSyncActivityProvider).syncedAt.keys, [1]);
  });
}
