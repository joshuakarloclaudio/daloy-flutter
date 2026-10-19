import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/network/api_exception.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/songs/application/song_deletions.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:daloy_flutter/features/songs/presentation/song_actions.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

void main() {
  late FakeApiAdapter api;
  late List<String> calls;
  var deleteStatus = 200;
  var online = true;

  setUp(() {
    deleteStatus = 200;
    online = true;
    calls = [];
    FakeReply guard(RequestOptions r, FakeReply Function() reply) {
      calls.add('${r.method} ${r.path}');
      if (!online) throw DioException(requestOptions: r, type: DioExceptionType.connectionError);
      return reply();
    }

    api = FakeApiAdapter({
      'DELETE /api/songs/7': (r) =>
          guard(r, () => deleteStatus == 200 ? FakeApiAdapter.ok(null) : FakeApiAdapter.error(deleteStatus, 'Nope.')),
      // The library list is a raw paginator, with no envelope.
      'GET /api/songs': (r) => guard(
        r,
        () => (
          status: 200,
          body: {
            'data': [
              {'id': 7, 'title': 'Amazing Grace'},
            ],
            'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
          },
        ),
      ),
    });
  });

  Future<(ProviderContainer, AppDatabase)> open() async {
    final container = await createTestContainer(
      api,
      overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1), isOnlineProvider.overrideWithValue(true)],
    );
    final db = container.read(appDatabaseProvider);
    await db
        .into(db.songs)
        .insert(
          SongsCompanion.insert(
            id: const Value(7),
            workspaceId: 1,
            title: 'Amazing Grace',
            content: const Value('[G]Hi'),
          ),
        );
    await db
        .into(db.songEdits)
        .insert(SongEditsCompanion.insert(songId: const Value(7), workspaceId: 1, updatedAt: DateTime(2026)));
    await db.into(db.songCapos).insert(SongCaposCompanion.insert(songId: const Value(7), capo: const Value(3)));
    await db
        .into(db.recentSongAccesses)
        .insert(
          RecentSongAccessesCompanion.insert(songId: const Value(7), workspaceId: 1, lastAccessedAt: DateTime(2026)),
        );
    return (container, db);
  }

  Future<List<int>> songIds(AppDatabase db) async => [for (final r in await db.select(db.songs).get()) r.id];

  group('repository', () {
    test('removing takes the song and everything that hangs off it, and undo puts it all back', () async {
      final (container, db) = await open();
      final repo = container.read(songsRepositoryProvider);

      final removed = await repo.removeLocal(7);
      expect(removed, isNotNull);
      expect(await songIds(db), isEmpty);
      expect(await db.select(db.songEdits).get(), isEmpty);
      expect(await db.select(db.songCapos).get(), isEmpty);
      expect(await db.select(db.recentSongAccesses).get(), isEmpty);
      expect(calls, isEmpty); // nothing reached the server

      await repo.restore(removed!);
      final row = await (db.select(db.songs)..where((t) => t.id.equals(7))).getSingle();
      expect((row.title, row.content), ('Amazing Grace', '[G]Hi'));
      expect((await db.select(db.songEdits).get()).single.songId, 7);
      expect((await db.select(db.songCapos).get()).single.capo, 3);
      expect(await db.select(db.recentSongAccesses).get(), hasLength(1));
    });

    test('a song that is not here cannot be removed', () async {
      final (container, _) = await open();
      expect(await container.read(songsRepositoryProvider).removeLocal(99), isNull);
    });

    test('a library sync during the undo window does not bring the song back', () async {
      final (container, db) = await open();
      final repo = container.read(songsRepositoryProvider);
      final removed = (await repo.removeLocal(7))!;

      await repo.sync(1);
      expect(await songIds(db), isEmpty); // the server still has it, but it is mid-delete

      await repo.restore(removed);
      await repo.sync(1);
      expect(await songIds(db), [7]);
    });

    test('the delete goes to the server and the song stays gone', () async {
      final (container, db) = await open();
      final repo = container.read(songsRepositoryProvider);
      await repo.deleteRemote((await repo.removeLocal(7))!);
      expect(calls, ['DELETE /api/songs/7']);
      expect(await songIds(db), isEmpty);
    });

    test('a refused delete puts the song back and says why', () async {
      deleteStatus = 403;
      final (container, db) = await open();
      final repo = container.read(songsRepositoryProvider);
      final removed = (await repo.removeLocal(7))!;
      await expectLater(repo.deleteRemote(removed), throwsA(isA<ApiException>()));
      expect(await songIds(db), [7]);
      expect((await db.select(db.songEdits).get()).single.songId, 7);
    });

    test('a song already gone on the server (404) is simply gone', () async {
      deleteStatus = 404;
      final (container, db) = await open();
      final repo = container.read(songsRepositoryProvider);
      await repo.deleteRemote((await repo.removeLocal(7))!);
      expect(await songIds(db), isEmpty);
    });

    test('offline, the song comes back', () async {
      online = false;
      final (container, db) = await open();
      final repo = container.read(songsRepositoryProvider);
      final removed = (await repo.removeLocal(7))!;
      await expectLater(repo.deleteRemote(removed), throwsA(isA<NetworkException>()));
      expect(await songIds(db), [7]);
    });
  });

  group('SongDeletions', () {
    test('start removes the song at once; undo restores it and the server never hears', () async {
      final (container, db) = await open();
      container.listen(songDeletionsProvider, (_, _) {});
      final deletions = container.read(songDeletionsProvider.notifier);

      expect(await deletions.start(7, onFailed: (_) {}), isTrue);
      expect(await songIds(db), isEmpty);
      await deletions.undo(7);
      expect(await songIds(db), [7]);
      expect(calls, isEmpty);
    });

    test('there is nothing to start for an unknown song, nor to undo', () async {
      final (container, _) = await open();
      container.listen(songDeletionsProvider, (_, _) {});
      final deletions = container.read(songDeletionsProvider.notifier);
      expect(await deletions.start(99, onFailed: (_) {}), isFalse);
      await deletions.undo(99); // no throw
    });
  });

  group('the delete action', () {
    Future<(ProviderContainer, AppDatabase)> pump(WidgetTester tester, {bool isOnline = true}) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final container = await tester.runAsync(
        () => createTestContainer(
          api,
          overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1), isOnlineProvider.overrideWithValue(isOnline)],
        ),
      );
      final db = container!.read(appDatabaseProvider);
      await tester.runAsync(
        () =>
            db.into(db.songs).insert(SongsCompanion.insert(id: const Value(7), workspaceId: 1, title: 'Amazing Grace')),
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Consumer(
              builder: (context, ref, _) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () async =>
                        deleteSongWithUndo(context, ref, (await ref.read(songsRepositoryProvider).findLocal(7))!),
                    child: const Text('Delete'),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(theme: DaloyTheme.light(), routerConfig: router),
        ),
      );
      return (container, db);
    }

    testWidgets('deleting shows an Undo toast, and Undo brings the song back', (tester) async {
      final (_, db) = await pump(tester);
      await tester.tap(find.text('Delete'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      expect(find.text('Deleted “Amazing Grace”.'), findsOneWidget);
      expect(await tester.runAsync(() => songIds(db)), isEmpty);

      await tester.pump(const Duration(milliseconds: 500)); // the toast finishes sliding in
      await tester.tap(find.text('Undo'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      expect(await tester.runAsync(() => songIds(db)), [7]);
      expect(calls, isEmpty);
    });

    testWidgets('offline it refuses, and keeps the song', (tester) async {
      final (_, db) = await pump(tester, isOnline: false);
      await tester.tap(find.text('Delete'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      expect(find.text('Connect to the internet to delete songs.'), findsOneWidget);
      expect(await tester.runAsync(() => songIds(db)), [7]);
    });
  });
}
