import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/application/line_up_edit_controller.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up_draft.dart';
import 'package:daloy_flutter/features/songs/chart/chord_math.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:daloy_flutter/features/songs/domain/song.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

Map<String, dynamic> _song(int id, String title, {String? key = 'G'}) => {
  'id': id,
  'title': title,
  'artist': 'Hillsong',
  'key': key,
  'transposition': 0,
  'bpm': null,
  'time_signature': null,
  'content': null,
  'lyrics': null,
  'is_public': false,
  'created_at': '2026-10-15T08:00:00+00:00',
};

Map<String, dynamic> _detail(
  int id,
  Map<String, dynamic> body, {
  List<({int songId, int transposition})> songs = const [],
}) => {
  'id': id,
  'title': body['title'] ?? 'Sunday Service',
  'date': body['date'] ?? '2026-10-18',
  'worship_leader': body['worship_leader'],
  'songs_count': songs.length,
  'songs': [
    for (final (i, s) in songs.indexed)
      {
        'line_up_song_id': 900 + i,
        'order': i,
        'transposition': s.transposition,
        'song': _song(s.songId, 'Song ${s.songId}'),
      },
  ],
};

const _details = LineUpDetails(title: 'Sunday Service', date: '2026-10-18', worshipLeader: ' Ana ');

void main() {
  group('helpers', () {
    test('next Sunday is today on a Sunday, else the coming one', () {
      expect(nextSunday(DateTime(2026, 10, 18, 9)).day, 18); // Sunday
      expect(nextSunday(DateTime(2026, 10, 15, 23)).day, 18); // Thursday
      expect(nextSunday(DateTime(2026, 10, 19)).day, 25); // Monday
    });

    test('title suggestion follows the weekday', () {
      expect(suggestedLineUpTitle('2026-10-18'), 'Sunday Service');
      expect(suggestedLineUpTitle('2026-10-21'), 'Wednesday Service');
    });

    test('transposition between keys takes the short way round', () {
      expect(transpositionBetweenKeys('G', 'A'), 2);
      expect(transpositionBetweenKeys('G', 'F'), -2);
      expect(transpositionBetweenKeys('Em', 'F#m'), 2);
      expect(transpositionBetweenKeys('C', 'F#'), 6);
      expect(transpositionBetweenKeys('Bb', 'G'), -3);
      expect(transpositionBetweenKeys('G', 'nope'), 0);
      expect(transposedKeys('Em').take(3), ['Em', 'Fm', 'F#m']);
    });
  });

  group('repository', () {
    late FakeApiAdapter api;
    late List<String> calls;
    var online = true;
    var nextId = 500;

    setUp(() {
      online = true;
      nextId = 500;
      calls = [];
      FakeReply guard(RequestOptions r, FakeReply Function() reply) {
        calls.add('${r.method} ${r.path}');
        if (!online) throw DioException(requestOptions: r, type: DioExceptionType.connectionError);
        return reply();
      }

      api = FakeApiAdapter({
        'POST /api/line-ups': (r) => guard(r, () {
          final body = r.data as Map<String, dynamic>;
          return FakeApiAdapter.ok(_detail(++nextId, body), status: 201);
        }),
        'PATCH /api/line-ups/501': (r) =>
            guard(r, () => FakeApiAdapter.ok(_detail(501, r.data as Map<String, dynamic>))),
        'PUT /api/line-ups/501/songs': (r) => guard(r, () {
          final songs = [
            for (final s in ((r.data as Map)['songs'] as List).cast<Map<String, dynamic>>())
              (songId: s['song_id'] as int, transposition: s['transposition'] as int),
          ];
          return FakeApiAdapter.ok(_detail(501, const {}, songs: songs));
        }),
        'GET /api/line-ups/7': (r) => guard(
          r,
          () => FakeApiAdapter.ok(
            _detail(
              7,
              const {'title': 'Midweek', 'date': '2026-10-21'},
              songs: [(songId: 41, transposition: 2), (songId: 42, transposition: 0)],
            ),
          ),
        ),
        'GET /api/line-ups': (r) => guard(r, () => FakeApiAdapter.ok({'line_ups': <Object>[]})),
      });
    });

    Future<(LineUpsRepository, AppDatabase)> repo() async {
      final container = await createTestContainer(api);
      return (container.read(lineUpsRepositoryProvider), container.read(appDatabaseProvider));
    }

    Future<void> seedSong(AppDatabase db, int id, String title, {String? key = 'G'}) =>
        db.into(db.songs).insert(SongsCompanion.insert(id: Value(id), workspaceId: 1, title: title, key: Value(key)));

    test('a new line-up is listed at once under a negative id, ready to edit', () async {
      final (lineUps, db) = await repo();
      final id = await lineUps.createLocal(1, _details);

      expect(id, isNegative);
      final listed = (await lineUps.watchAll(1).first).single;
      expect(
        (listed.title, listed.date, listed.worshipLeader, listed.isPending),
        ('Sunday Service', '2026-10-18', 'Ana', true),
      );
      expect(await lineUps.watchOutbox(1).first, {id: null});
      final editable = (await lineUps.loadEditable(id))!;
      expect(editable.songsKnown, isTrue);
      expect(editable.songs, isEmpty);
    });

    test('flushing posts it and moves it to the server id', () async {
      final (lineUps, db) = await repo();
      final id = await lineUps.createLocal(1, _details);

      await lineUps.flushOutbox(1);

      expect(calls, ['POST /api/line-ups']);
      expect(api.requests.single.data, {'title': 'Sunday Service', 'date': '2026-10-18', 'worship_leader': 'Ana'});
      expect((await db.select(db.lineUps).get()).map((r) => r.id), [501]);
      expect(await db.select(db.lineUpOutbox).get(), isEmpty);
      expect(lineUps.resolveId(id), 501);
      expect((await lineUps.loadEditable(id))!.id, 501);
    });

    test('offline it stays queued and goes through on the next flush', () async {
      final (lineUps, db) = await repo();
      final id = await lineUps.createLocal(1, _details);

      online = false;
      await lineUps.flushOutbox(1);
      expect((await db.select(db.lineUps).get()).single.id, id);
      expect(await lineUps.watchOutbox(1).first, {id: null});

      online = true;
      await lineUps.flushOutbox(1);
      expect((await db.select(db.lineUps).get()).single.id, 501);
    });

    test('songs added before it ever synced go up after the POST, in order', () async {
      final (lineUps, db) = await repo();
      await seedSong(db, 41, 'Oceans');
      await seedSong(db, 42, 'Way Maker', key: 'E');
      final id = await lineUps.createLocal(1, _details);
      final songs = await (db.select(db.songs)).get();
      Song song(int id) => SongsRepository.songFromRow(songs.firstWhere((s) => s.id == id));

      await lineUps.save(
        id,
        _details,
        songs: [
          LineUpDraftSong(song: song(42)),
          LineUpDraftSong(song: song(41), transposition: 2),
        ],
      );
      expect((await lineUps.watchAll(1).first).single.songsCount, 2);

      await lineUps.flushOutbox(1);

      // The POST carried the details, so there's no PATCH.
      expect(calls, ['POST /api/line-ups', 'PUT /api/line-ups/501/songs']);
      expect(api.requests.last.data, {
        'songs': [
          {'song_id': 42, 'transposition': 0},
          {'song_id': 41, 'transposition': 2},
        ],
      });
      final rows = await db.select(db.lineUpSongs).get();
      expect(rows.map((r) => (r.lineUpId, r.songId, r.lineUpSongId)), [(501, 42, 900), (501, 41, 901)]);
      expect(await db.select(db.lineUpOutbox).get(), isEmpty);
    });

    test('editing a synced line-up sends only what changed', () async {
      final (lineUps, db) = await repo();
      await lineUps.flushOutbox(1);
      final id = await lineUps.createLocal(1, _details);
      await lineUps.flushOutbox(1);
      calls.clear();

      await lineUps.save(id, const LineUpDetails(title: 'Sunday AM', date: '2026-10-18', worshipLeader: 'Ana'));
      await lineUps.flushOutbox(1);
      expect(calls, ['PATCH /api/line-ups/501']);
      expect((await db.select(db.lineUps).get()).single.title, 'Sunday AM');

      calls.clear();
      await seedSong(db, 41, 'Oceans');
      final oceans = SongsRepository.songFromRow((await db.select(db.songs).get()).single);
      await lineUps.save(
        id,
        const LineUpDetails(title: 'Sunday AM', date: '2026-10-18', worshipLeader: 'Ana'),
        songs: [LineUpDraftSong(song: oceans)],
      );
      await lineUps.flushOutbox(1);
      expect(calls, ['PUT /api/line-ups/501/songs']);
      // The song PUT answered with the server's (older) details; ours stay.
      expect((await db.select(db.lineUps).get()).single.title, 'Sunday AM');
    });

    test('a refusal is kept on the entry and the line-up stays', () async {
      api.routes['POST /api/line-ups'] = (r) => FakeApiAdapter.error(
        422,
        'Invalid',
        data: {
          'errors': {
            'date': ['The date field must be a valid date.'],
          },
        },
      );
      final (lineUps, db) = await repo();
      final id = await lineUps.createLocal(1, _details);

      await lineUps.flushOutbox(1);

      expect(await lineUps.watchOutbox(1).first, {id: 'Validation failed'});
      expect((await db.select(db.lineUps).get()).single.id, id);

      await lineUps.discardPending(id);
      expect(await db.select(db.lineUps).get(), isEmpty);
      expect(await db.select(db.lineUpOutbox).get(), isEmpty);
    });

    test('a pull keeps line-ups that are still waiting to go up', () async {
      final (lineUps, db) = await repo();
      final id = await lineUps.createLocal(1, _details);
      await db
          .into(db.lineUps)
          .insert(
            LineUpsCompanion.insert(id: const Value(3), workspaceId: 1, title: 'Deleted elsewhere', date: '2026-10-01'),
          );

      online = true;
      await lineUps.sync(1);

      expect((await db.select(db.lineUps).get()).map((r) => r.id), [id]);
    });

    test('opening a synced line-up fetches its songs; unfetched ones are read-only', () async {
      final (lineUps, db) = await repo();
      await db
          .into(db.lineUps)
          .insert(
            LineUpsCompanion.insert(
              id: const Value(7),
              workspaceId: 1,
              title: 'Midweek',
              date: '2026-10-21',
              songsCount: const Value(2),
            ),
          );

      expect((await lineUps.loadEditable(7))!.songsKnown, isFalse);

      await lineUps.refreshDetail(7, 1);
      final editable = (await lineUps.loadEditable(7))!;
      expect(editable.songsKnown, isTrue);
      expect(editable.songs.map((s) => (s.song.title, s.transposition)), [('Song 41', 2), ('Song 42', 0)]);
    });
  });

  group('edit controller', () {
    late ProviderContainer container;
    late LineUpsRepository lineUps;
    late AppDatabase db;
    late int id;

    setUp(() async {
      container = await createTestContainer(
        FakeApiAdapter({}),
        overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1), isOnlineProvider.overrideWithValue(false)],
      );
      lineUps = container.read(lineUpsRepositoryProvider);
      db = container.read(appDatabaseProvider);
      for (final (songId, title, key) in [(41, 'Oceans', 'G'), (42, 'Way Maker', 'E'), (43, 'Untitled', null)]) {
        await db
            .into(db.songs)
            .insert(SongsCompanion.insert(id: Value(songId), workspaceId: 1, title: title, key: Value(key)));
      }
      id = await lineUps.createLocal(1, _details);
    });

    Future<List<Song>> library() async => [
      for (final r in await db.select(db.songs).get()) SongsRepository.songFromRow(r),
    ];

    test('adds, reorders, transposes and removes on a draft, then saves it', () async {
      final provider = lineUpEditProvider(id);
      final sub = container.listen(provider, (_, _) {});
      addTearDown(sub.close);
      await container.read(provider.future);
      final edit = container.read(provider.notifier);

      expect(container.read(provider).value!.isDirty, isFalse);

      final songs = await library();
      edit.addSongs(songs);
      edit.addSongs([songs.first]); // already there — ignored
      expect(container.read(provider).value!.songs.map((s) => s.songId), [41, 42, 43]);

      edit.reorder(2, 0);
      expect(container.read(provider).value!.songs.map((s) => s.songId), [43, 41, 42]);

      edit.setPerformanceKey(1, 'A');
      edit.setPerformanceKey(0, 'A'); // no key on the song — nothing to transpose
      expect(container.read(provider).value!.songs.map((s) => s.transposition), [0, 2, 0]);

      edit.removeAt(0);
      edit.insertAt(0, container.read(provider).value!.songs.first); // duplicate — ignored
      expect(container.read(provider).value!.songs.map((s) => s.songId), [41, 42]);

      edit.setTitle('  ');
      expect(container.read(provider).value!.canSave, isFalse);
      edit.setTitle('Sunday PM');
      expect(container.read(provider).value!.canSave, isTrue);

      expect(await edit.save(), isTrue);
      expect(container.read(provider).value!.isDirty, isFalse);

      final saved = (await lineUps.loadEditable(id))!;
      expect(saved.details.title, 'Sunday PM');
      expect(saved.songs.map((s) => (s.songId, s.transposition)), [(41, 2), (42, 0)]);
      final queued = (await db.select(db.lineUpOutbox).get()).single;
      expect((queued.isNew, queued.songsDirty), (true, true));
    });
  });
}
