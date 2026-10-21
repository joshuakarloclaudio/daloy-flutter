import 'dart:convert';

import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/songs/application/song_edit_controller.dart';
import 'package:daloy_flutter/features/songs/data/song_detail_repository.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:daloy_flutter/features/songs/domain/song_field.dart';
import 'package:daloy_flutter/features/songs/domain/song_fields.dart';
import 'package:daloy_flutter/features/sync/workspace_realtime.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

void main() {
  group('merge rules', () {
    test('a set rebased onto the server keeps both sides', () {
      // Base A B C (keys 0). Here: drop B, add D, A up 2. There: add E, C's key to 5.
      final rebased = rebaseSet(
        server: const [
          (songId: 1, transposition: 0),
          (songId: 2, transposition: 0),
          (songId: 3, transposition: 5),
          (songId: 5, transposition: 0),
        ],
        base: const [(songId: 1, transposition: 0), (songId: 2, transposition: 0), (songId: 3, transposition: 0)],
        local: const [(songId: 1, transposition: 2), (songId: 3, transposition: 0), (songId: 4, transposition: 0)],
      );
      expect(rebased, const [
        (songId: 1, transposition: 2),
        (songId: 3, transposition: 5),
        (songId: 5, transposition: 0),
        (songId: 4, transposition: 0),
      ]);
    });

    test('unsent notes lay over the server list, one note at a time', () {
      const theirs = LineUpSongNote(id: 'a', line: 1, text: 'Theirs');
      const edited = LineUpSongNote(id: 'b', line: 2, text: 'Mine, edited');
      const added = LineUpSongNote(id: 'c', line: 3, text: 'Mine, new');
      final server = [
        theirs,
        const LineUpSongNote(id: 'b', line: 2, text: 'Old'),
        const LineUpSongNote(id: 'd', line: 4, text: 'Deleted here'),
      ];
      final local = [edited, added];
      expect(LineUpsRepository.overlayNotes(server, local, const [PrepNote('b'), PrepNote('c'), PrepNote('d')]), [
        theirs,
        edited,
        added,
      ]);
      // Nothing queued: the server's list stands.
      expect(LineUpsRepository.overlayNotes(server, local, const []), server);
    });

    test('field values compare with blanks as null', () {
      expect(sameSongValue(null, ''), isTrue);
      expect(sameSongValue(72, 72), isTrue);
      expect(sameSongValue('G', 'A'), isFalse);
    });
  });

  late FakeApiAdapter api;
  late Map<String, dynamic> server;
  late List<String> calls;

  setUp(() {
    calls = [];
    server = serverSongJson(7, content: '[G]Amazing grace')..addAll({'bpm': 72});
    api = FakeApiAdapter({
      'GET /api/songs/7': (_) => FakeApiAdapter.ok({...server}),
      'PATCH /api/songs/7/changes': (r) {
        calls.add(jsonEncode(r.data));
        return songChangeReply(r, server);
      },
    });
  });

  Future<(ProviderContainer, AppDatabase)> open({FakeRealtime? realtime}) async {
    final c = await createTestContainer(
      api,
      realtime: realtime,
      overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1), isOnlineProvider.overrideWithValue(true)],
    );
    final db = c.read(appDatabaseProvider);
    await db.into(db.songs).insert(SongsRepository.songCompanion(SongsRepository.songFromRow(_row(server)), 1));
    return (c, db);
  }

  group('song edits', () {
    test('a field changed elsewhere first becomes a conflict; the rest saves', () async {
      final (c, db) = await open();
      final repo = c.read(songDetailRepositoryProvider);

      // A teammate moves the key to A after this device last synced.
      server['key'] = 'A';
      await repo.setTransposition(7, 2);
      await repo.setTempo(7, bpm: 80);
      // This device also changed the key (from G).
      await repo.saveFields(7, SongFields.fromSong((await repo.loadSong(7))!).copyWith(key: 'C'));
      api.routes['PATCH /api/songs/7/changes'] = (r) {
        calls.add(jsonEncode(r.data));
        final changes = ((r.data as Map)['changes'] as Map).cast<String, dynamic>()..remove('key');
        server.addAll(changes);
        return FakeApiAdapter.error(
          409,
          'Someone else changed this song.',
          data: {
            'song': {...server},
            'conflicts': ['key'],
          },
        );
      };
      await repo.flush(1);

      expect(jsonDecode(calls.last), {
        'changes': {'transposition': 2, 'bpm': 80, 'key': 'C'},
        'base': {'transposition': 0, 'bpm': 72, 'key': 'G'},
      });
      final song = (await repo.loadSong(7))!;
      expect((song.key, song.bpm, song.transposition), ('C', 80, 2));
      expect(await repo.watchConflicts(7).first, {SongField.key: 'A'});
      expect((await db.select(db.songEdits).getSingle()).error, 'Changed on another device');

      // Keep mine: sent again with theirs as the base, and accepted.
      api.routes['PATCH /api/songs/7/changes'] = (r) {
        calls.add(jsonEncode(r.data));
        return songChangeReply(r, server);
      };
      await repo.keepMine(7, SongField.key);
      await repo.flush(1);
      expect(jsonDecode(calls.last), {
        'changes': {'key': 'C'},
        'base': {'key': 'A'},
      });
      expect(await db.select(db.songEdits).get(), isEmpty);
    });

    test('a value the server normalizes still counts as sent', () async {
      final (c, db) = await open();
      final repo = c.read(songDetailRepositoryProvider);
      // Laravel trims request strings, so the reply never matches a chart
      // ending in a newline.
      api.routes['PATCH /api/songs/7/changes'] = (r) {
        calls.add(jsonEncode(r.data));
        final changes = ((r.data as Map)['changes'] as Map).cast<String, dynamic>();
        server.addAll({
          for (final MapEntry(:key, :value) in changes.entries) key: value is String ? value.trim() : value,
        });
        return FakeApiAdapter.ok({...server});
      };
      await repo.setChords(7, '[G]Amazing grace, how sweet\n');
      await repo.flush(1);
      await repo.flush(1);

      expect(calls, hasLength(1));
      expect(await db.select(db.songEdits).get(), isEmpty);
      expect((await repo.loadSong(7))!.content, '[G]Amazing grace, how sweet');
    });

    test('use theirs takes their value and drops the edit', () async {
      final (c, db) = await open();
      final repo = c.read(songDetailRepositoryProvider);
      await db
          .into(db.songEdits)
          .insert(
            SongEditsCompanion.insert(
              songId: const Value(7),
              workspaceId: 1,
              updatedAt: DateTime(2026),
              base: const Value('{}'),
              conflicts: const Value('{"key":"A"}'),
            ),
          );
      await repo.takeTheirs(7, SongField.key);
      expect((await repo.loadSong(7))!.key, 'A');
      expect(await db.select(db.songEdits).get(), isEmpty);
    });

    test('a sync no longer overwrites an unsent chords edit', () async {
      final (c, _) = await open();
      final repo = c.read(songDetailRepositoryProvider);
      api.routes['PATCH /api/songs/7/changes'] = (r) =>
          throw DioException(requestOptions: r, type: DioExceptionType.connectionError);
      await repo.saveFields(7, SongFields.fromSong((await repo.loadSong(7))!).copyWith(chords: '[A]Amazing grace'));
      api.routes['GET /api/songs'] = (_) => (
        status: 200,
        body: {
          'data': [server],
          'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
        },
      );
      await c.read(songsRepositoryProvider).sync(1);
      expect((await repo.loadSong(7))!.content, '[A]Amazing grace');
    });
  });

  group('set outbox', () {
    test('a set changed elsewhere meanwhile is merged and sent again', () async {
      final (c, db) = await open();
      Map<String, dynamic> entry(int pivot, int order, int id) => {
        'line_up_song_id': pivot,
        'order': order,
        'transposition': 0,
        'song': {...serverSongJson(id, title: 'Song $id')},
      };
      Map<String, dynamic> detail(List<Map<String, dynamic>> songs) => {
        'id': 7,
        'title': 'Sunday',
        'date': '2999-01-04',
        'songs_count': songs.length,
        'version': 3,
        'songs': songs,
      };
      api.routes['GET /api/line-ups/7'] = (_) => FakeApiAdapter.ok(detail([entry(901, 0, 41), entry(902, 1, 42)]));
      await db
          .into(db.lineUps)
          .insert(LineUpsCompanion.insert(id: const Value(7), workspaceId: 1, title: 'Sunday', date: '2999-01-04'));
      final repo = c.read(lineUpsRepositoryProvider);
      await repo.refreshDetail(7, 1);
      await db
          .into(db.songs)
          .insert(SongsRepository.songCompanion(SongsRepository.songFromRow(_row(serverSongJson(43))), 1));

      final puts = <Map<String, dynamic>>[];
      api.routes['PUT /api/line-ups/7/songs'] = (r) {
        puts.add((r.data as Map).cast<String, dynamic>());
        if (puts.length == 1) {
          // A teammate added song 44 first.
          return FakeApiAdapter.error(
            409,
            'Someone else changed this set meanwhile.',
            data: detail([entry(901, 0, 41), entry(902, 1, 42), entry(904, 2, 44)]),
          );
        }
        return FakeApiAdapter.ok(detail([entry(901, 0, 41), entry(902, 1, 42), entry(904, 2, 44), entry(903, 3, 43)]));
      };
      expect(await repo.addSong(7, 43), AddSongResult.added);
      await repo.flushOutbox(1);

      expect(puts.first['base_song_ids'], [41, 42]);
      expect([for (final s in puts.last['songs'] as List) (s as Map)['song_id']], [41, 42, 44, 43]);
      expect(puts.last['base_song_ids'], [41, 42, 44]);
      expect([for (final e in await repo.watchSetlist(7).first) e.song.id], [41, 42, 44, 43]);
    });
  });

  group('realtime pings', () {
    test('song, line-up and capo pings land in Drift and are announced', () async {
      final realtime = FakeRealtime();
      final (c, db) = await open(realtime: realtime);
      final heard = <RemoteChange>[];
      c.listen(remoteChangesProvider, (_, next) {
        if (next.value case final v?) heard.add(v);
      });
      c.listen(workspaceRealtimeProvider, (_, _) {});
      await pumpEventQueue();
      expect(realtime.channels, contains('private-workspace.1'));

      server['title'] = 'Amazing Grace (My Chains)';
      server['version'] = 2;
      realtime.emit('private-workspace.1', 'song.changed', {
        'id': 7,
        'version': 2,
        'by': {'id': 2, 'name': 'Ana Reyes'},
      });
      await _settle();
      expect((await c.read(songDetailRepositoryProvider).loadSong(7))!.title, 'Amazing Grace (My Chains)');
      expect(heard.single.message, 'Ana updated this song.');

      // The same version again is old news: no second fetch.
      final fetches = api.requests.where((r) => r.path == '/api/songs/7' && r.method == 'GET').length;
      realtime.emit('private-workspace.1', 'song.changed', {'id': 7, 'version': 2});
      await _settle();
      expect(api.requests.where((r) => r.path == '/api/songs/7' && r.method == 'GET').length, fetches);

      api.routes['GET /api/line-ups/9'] = (_) => FakeApiAdapter.ok({
        'id': 9,
        'title': 'Youth night',
        'date': '2999-01-01',
        'songs_count': 1,
        'version': 4,
        'songs': [
          {
            'line_up_song_id': 950,
            'order': 0,
            'transposition': 0,
            'song': {...server},
          },
        ],
      });
      realtime.emit('private-workspace.1', 'line-up.changed', {
        'id': 9,
        'version': 4,
        'what': ['set'],
        'by': {'id': 2, 'name': 'Ana Reyes'},
      });
      await _settle();
      final setlist = await c.read(lineUpsRepositoryProvider).watchSetlist(9).first;
      expect(setlist.single.lineUpSongId, 950);
      expect(heard.last.message, 'Ana changed the set.');

      realtime.emit('private-workspace.1', 'line-up.deleted', {'id': 9});
      realtime.emit('private-workspace.1', 'song.deleted', {'id': 7});
      await _settle();
      expect(await c.read(lineUpsRepositoryProvider).watchLineUp(9).first, isNull);
      expect(await db.select(db.songs).get(), isEmpty);
    });

    test('my capo from another device lands unless one is waiting to go out', () async {
      final (c, db) = await open();
      final repo = c.read(songDetailRepositoryProvider);
      await repo.applyRemoteCapo(7, 3);
      expect(await repo.watchCapo(7).first, 3);

      await db
          .into(db.songCapos)
          .insertOnConflictUpdate(
            SongCaposCompanion.insert(songId: const Value(7), capo: const Value(1), dirty: const Value(true)),
          );
      await repo.applyRemoteCapo(7, 5);
      expect(await repo.watchCapo(7).first, 1);
    });
  });

  group('edit song live merge', () {
    test("a teammate's change flows into untouched fields; a shared one is a conflict", () async {
      final (c, db) = await open();
      final provider = songEditProvider(7);
      c.listen(provider, (_, _) {});
      await c.read(provider.future);
      final edit = c.read(provider.notifier);
      edit.change((f) => f.copyWith(title: 'Amazing Grace (Live)', bpm: '76'));

      // Elsewhere: the tempo and the chords change.
      await (db.update(
        db.songs,
      )..where((t) => t.id.equals(7))).write(const SongsCompanion(bpm: Value(90), content: Value('[A]Amazing grace')));
      await _settle();

      var s = c.read(provider).value!;
      expect(s.fields.chords, '[A]Amazing grace');
      expect(s.fields.bpm, '76');
      expect(s.fields.title, 'Amazing Grace (Live)');
      expect(s.conflicts, {SongField.bpm: 90});
      expect(s.remoteRevision, 1);

      edit.takeTheirs(SongField.bpm);
      s = c.read(provider).value!;
      expect(s.fields.bpm, '90');
      expect(s.conflicts, isEmpty);
      expect(s.isDirty, isTrue); // the title
    });
  });
}

Future<void> _settle() async {
  for (var i = 0; i < 6; i++) {
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
}

SongRow _row(Map<String, dynamic> json) => SongRow(
  id: json['id'] as int,
  workspaceId: 1,
  title: json['title'] as String,
  key: json['key'] as String?,
  transposition: 0,
  bpm: json['bpm'] as int?,
  content: json['content'] as String?,
  isPublic: false,
  version: 1,
);
