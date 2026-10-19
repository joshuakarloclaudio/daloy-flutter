import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/app_database.dart';
import '../../auth/application/session_controller.dart';
import '../../line_ups/domain/line_up.dart';
import '../domain/new_song.dart';
import '../domain/song.dart';
import '../domain/song_field.dart';
import '../domain/song_list_query.dart';
import 'song_sync_activity.dart';

part 'songs_repository.g.dart';

/// `/api/songs` calls.
class SongsService {
  const SongsService(this._api);

  final ApiClient _api;

  Future<SongsPage> list({int page = 1, String? search}) => _api.getDirect(
    '/api/songs',
    Decode.object(SongsPage.fromJson),
    query: {'page': page, if (search != null && search.isNotEmpty) 'search': search},
  );

  /// Writes only [changes] (`{api_field: value}`). [base] is each one's
  /// value as this device found it: a field someone else changed since is
  /// refused (409, `ApiConflictException` with `{song, conflicts}`), the
  /// others still save. An empty [base] writes the fields as given.
  Future<Song> change(int id, Map<String, Object?> changes, Map<String, Object?> base) => _api.patch(
    '/api/songs/$id/changes',
    Decode.object(Song.fromJson),
    body: {'changes': changes, if (base.isNotEmpty) 'base': base},
  );

  Future<int> capo(int songId) => _api.get('/api/songs/$songId/capo', (json) => (json! as JsonMap)['capo'] as int);

  Future<int> setCapo(int songId, int capo) =>
      _api.patch('/api/songs/$songId/capo', (json) => (json! as JsonMap)['capo'] as int, body: {'capo': capo});

  Future<List<LineUp>> upcomingLineUps(int songId) =>
      _api.get('/api/songs/$songId/upcoming-line-ups', (json) => LineUpListPage.fromJson(json! as JsonMap).lineUps);

  Future<void> delete(int id) => _api.delete('/api/songs/$id');

  Future<Song> show(int id) => _api.get('/api/songs/$id', Decode.object(Song.fromJson));

  Future<Song> create(NewSong song) => _api.post('/api/songs', Decode.object(Song.fromJson), body: song.toJson());
}

/// The workspace song library: reads from Drift, refreshed from the API.
class SongsRepository {
  SongsRepository(this._db, this._service, [this._reporter]);

  final AppDatabase _db;
  final SongsService _service;
  final SongSyncReporter? _reporter;

  SongsService get service => _service;

  /// Songs removed here whose server delete hasn't gone out yet (the undo
  /// window). A library sync must not bring them back meanwhile.
  final _removing = <int>{};

  /// Newest first — "Recently added songs".
  Stream<List<Song>> watchRecent(int workspaceId, {int limit = 5}) =>
      (_db.select(_db.songs)
            ..where((t) => t.workspaceId.equals(workspaceId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt), (t) => OrderingTerm.desc(t.id)])
            ..limit(limit))
          .watch()
          .map((rows) => rows.map(songFromRow).toList());

  /// The Songs screen's query, run in SQLite so search/filter/sort cost
  /// nothing in Dart. Selects only the columns a list row draws — never the
  /// chart or lyrics, which can be kilobytes per song — so the returned
  /// [Song]s carry just id, title, artist, key and visibility.
  Stream<List<Song>> watchLibrary(int workspaceId, SongListQuery q) {
    final s = _db.songs;

    final query = _db.selectOnly(s)..addColumns([s.id, s.title, s.artist, s.key, s.isPublic]);

    var where = s.workspaceId.equals(workspaceId);

    final term = q.search.trim().toLowerCase();
    if (term.isNotEmpty) {
      // `instr` rather than LIKE so `%` and `_` in what the user types stay literal.
      Expression<bool> has(Expression<String> column) =>
          FunctionCallExpression<int>('instr', [column.lower(), Variable<String>(term)]).isBiggerThanValue(0);
      var match = has(s.title) | has(s.artist) | has(s.key);
      // Lyrics are the big column; one letter would match nearly everything.
      if (term.length >= 2) match = match | has(s.lyrics);
      where = where & match;
    }

    if (q.key != null) where = where & s.key.equals(q.key!);
    where = switch (q.content) {
      SongContentFilter.hasChords => where & _blank(s.content, false),
      SongContentFilter.hasLyrics => where & _blank(s.lyrics, false),
      SongContentFilter.draft => where & _blank(s.content, true) & _blank(s.lyrics, true),
      null => where,
    };
    query.where(where);

    final byTitle = OrderingTerm(expression: s.title.collate(Collate.noCase));
    query.orderBy(switch (q.sort) {
      SongSort.az => [byTitle],
      SongSort.za => [OrderingTerm(expression: s.title.collate(Collate.noCase), mode: OrderingMode.desc)],
      SongSort.recent => [OrderingTerm.desc(s.createdAt), OrderingTerm.desc(s.id)],
      SongSort.recentlyUsed => [
        OrderingTerm(expression: s.lastUsedAt, mode: OrderingMode.desc, nulls: NullsOrder.last),
        byTitle,
      ],
    });

    return query.watch().map(
      (rows) => [
        for (final r in rows)
          Song(
            id: r.read(s.id)!,
            title: r.read(s.title)!,
            artist: r.read(s.artist),
            key: r.read(s.key),
            isPublic: r.read(s.isPublic) ?? false,
          ),
      ],
    );
  }

  /// Whether a nullable text column is empty once trimmed (web: `hasSongChords`).
  static Expression<bool> _blank(GeneratedColumn<String> column, bool blank) =>
      CustomExpression<bool>("TRIM(COALESCE(songs.${column.name}, '')) ${blank ? '=' : '!='} ''");

  /// Songs opened on this device, newest first — "Jump back in".
  Stream<List<Song>> watchRecentlyOpened(int workspaceId, {int limit = 10}) {
    final query =
        _db.select(_db.recentSongAccesses).join([
            innerJoin(_db.songs, _db.songs.id.equalsExp(_db.recentSongAccesses.songId)),
          ])
          ..where(_db.recentSongAccesses.workspaceId.equals(workspaceId))
          ..orderBy([OrderingTerm.desc(_db.recentSongAccesses.lastAccessedAt)])
          ..limit(limit);
    return query.watch().map((rows) => rows.map((r) => songFromRow(r.readTable(_db.songs))).toList());
  }

  Future<void> recordOpened(int songId, int workspaceId, {DateTime? at}) => _db
      .into(_db.recentSongAccesses)
      .insertOnConflictUpdate(
        RecentSongAccessesCompanion.insert(
          songId: Value(songId),
          workspaceId: workspaceId,
          lastAccessedAt: at ?? DateTime.now(),
        ),
      );

  /// Artists already in the library, most-used first (case-insensitive), for
  /// the new-song form's suggestions.
  Stream<List<String>> watchArtists(int workspaceId) {
    final s = _db.songs;
    final count = s.id.count();
    final query = _db.selectOnly(s)
      ..addColumns([s.artist, count])
      ..where(s.workspaceId.equals(workspaceId) & s.artist.isNotNull() & _blank(s.artist, false))
      ..groupBy([s.artist.lower()])
      ..orderBy([OrderingTerm.desc(count), OrderingTerm(expression: s.artist.collate(Collate.noCase))]);
    return query.watch().map((rows) => [for (final r in rows) r.read(s.artist)!.trim()]);
  }

  /// Saves a new song on this device at once and queues it for the server.
  /// Returns the local (negative) id — call [flushOutbox] to push it.
  Future<int> createLocal(int workspaceId, NewSong song, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    // Microseconds since the epoch: unique per device, and negative below.
    final localId = -at.microsecondsSinceEpoch;
    await _db.transaction(() async {
      await _db
          .into(_db.songs)
          .insert(
            SongsCompanion.insert(
              id: Value(localId),
              workspaceId: workspaceId,
              title: song.title,
              artist: Value(song.artist),
              key: Value(song.key),
              bpm: Value(song.bpm),
              timeSignature: Value(song.timeSignature),
              content: Value(song.content),
              lyrics: Value(song.lyrics),
              createdAt: Value(at),
            ),
          );
      await _db
          .into(_db.songOutbox)
          .insert(SongOutboxCompanion.insert(localId: Value(localId), workspaceId: workspaceId, createdAt: at));
    });
    return localId;
  }

  Future<Song?> findLocal(int id) async {
    final row = await (_db.select(_db.songs)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : songFromRow(row);
  }

  /// Local song ids waiting on the server, with why the last attempt failed
  /// (null: just waiting).
  Stream<Map<int, String?>> watchOutbox(int workspaceId) => (_db.select(
    _db.songOutbox,
  )..where((t) => t.workspaceId.equals(workspaceId))).watch().map((rows) => {for (final r in rows) r.localId: r.error});

  /// Drops a song that never reached the server.
  Future<void> discardPending(int localId) => _db.transaction(() async {
    await (_db.delete(_db.songOutbox)..where((t) => t.localId.equals(localId))).go();
    await (_db.delete(_db.songs)..where((t) => t.id.equals(localId))).go();
  });

  bool _flushing = false;
  bool _flushAgain = false;

  /// Sends queued songs oldest-first. Stops at the first network failure
  /// (the rest would fail too, and order is kept); a song the server
  /// refuses keeps its error and is retried on the next flush.
  /// Overlapping calls fold into one run so nothing is posted twice.
  Future<void> flushOutbox(int workspaceId) async {
    if (_flushing) {
      _flushAgain = true;
      return;
    }
    _flushing = true;
    try {
      do {
        _flushAgain = false;
        final queued =
            await (_db.select(_db.songOutbox)
                  ..where((t) => t.workspaceId.equals(workspaceId))
                  ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
                .get();
        for (final entry in queued) {
          if (!await _push(entry)) return;
        }
      } while (_flushAgain);
    } finally {
      _flushing = false;
    }
  }

  /// `false` when the queue should stop (offline).
  Future<bool> _push(SongOutboxRow entry) async {
    final row = await (_db.select(_db.songs)..where((t) => t.id.equals(entry.localId))).getSingleOrNull();
    if (row == null) {
      await (_db.delete(_db.songOutbox)..where((t) => t.localId.equals(entry.localId))).go();
      return true;
    }

    int? serverId;
    _reporter?.sending(entry.localId);
    try {
      final created = await _service.create(
        NewSong(
          title: row.title,
          artist: row.artist,
          key: row.key,
          bpm: row.bpm,
          timeSignature: row.timeSignature,
          content: row.content,
          lyrics: row.lyrics,
        ),
      );
      await _db.transaction(() async {
        await (_db.delete(_db.songs)..where((t) => t.id.equals(entry.localId))).go();
        await (_db.delete(_db.songOutbox)..where((t) => t.localId.equals(entry.localId))).go();
        await _db.into(_db.songs).insertOnConflictUpdate(songCompanion(created, entry.workspaceId));
      });
      serverId = created.id;
      return true;
    } on NetworkException {
      return false;
    } on ApiException catch (e) {
      await (_db.update(
        _db.songOutbox,
      )..where((t) => t.localId.equals(entry.localId))).write(SongOutboxCompanion(error: Value(e.message)));
      return true;
    } finally {
      _reporter?.finished(entry.localId, synced: serverId != null, serverId: serverId);
    }
  }

  // -- Delete with undo ----------------------------------------------------

  /// Takes the song off this device — with its queued edit, capo and place in
  /// "recently opened" — and returns what's needed to put it back. Nothing
  /// reaches the server until [deleteRemote].
  Future<RemovedSong?> removeLocal(int id) => _db.transaction(() async {
    final row = await (_db.select(_db.songs)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final removed = RemovedSong(
      row: row,
      edit: await (_db.select(_db.songEdits)..where((t) => t.songId.equals(id))).getSingleOrNull(),
      capo: await (_db.select(_db.songCapos)..where((t) => t.songId.equals(id))).getSingleOrNull(),
      access: await (_db.select(_db.recentSongAccesses)..where((t) => t.songId.equals(id))).getSingleOrNull(),
    );
    _removing.add(id);
    await _deleteLocalRows(id);
    return removed;
  });

  /// Undo: puts a removed song back exactly as it was.
  Future<void> restore(RemovedSong removed) async {
    _removing.remove(removed.row.id);
    await _db.transaction(() async {
      await _db.into(_db.songs).insertOnConflictUpdate(removed.row);
      if (removed.edit case final e?) await _db.into(_db.songEdits).insertOnConflictUpdate(e);
      if (removed.capo case final c?) await _db.into(_db.songCapos).insertOnConflictUpdate(c);
      if (removed.access case final a?) await _db.into(_db.recentSongAccesses).insertOnConflictUpdate(a);
    });
  }

  /// Sends the delete. On failure the song is restored and the error
  /// rethrown; a 404 means it's already gone, which is the goal.
  Future<void> deleteRemote(RemovedSong removed) async {
    try {
      await _service.delete(removed.row.id);
    } on ApiHttpException catch (e) {
      if (e.status != 404) {
        await restore(removed);
        rethrow;
      }
    } on ApiException {
      await restore(removed);
      rethrow;
    } finally {
      _removing.remove(removed.row.id);
    }
  }

  Future<void> _deleteLocalRows(int id) async {
    await (_db.delete(_db.songEdits)..where((t) => t.songId.equals(id))).go();
    await (_db.delete(_db.songCapos)..where((t) => t.songId.equals(id))).go();
    await (_db.delete(_db.recentSongAccesses)..where((t) => t.songId.equals(id))).go();
    await (_db.delete(_db.songs)..where((t) => t.id.equals(id))).go();
  }

  /// A newer copy of [song] from the server (a teammate's save, in a live
  /// session or by realtime ping). Kept as the server has it, except fields
  /// changed here and not yet sent, as in [sync]. A song taken off this
  /// device for an undoable delete isn't brought back.
  Future<void> applyRemote(Song song, int workspaceId) => _db.transaction(() async {
    if (_removing.contains(song.id)) return;
    final edit = await (_db.select(_db.songEdits)..where((t) => t.songId.equals(song.id))).getSingleOrNull();
    final local = edit == null ? null : await findLocal(song.id);
    await _db.into(_db.songs).insertOnConflictUpdate(songCompanion(keepPending(song, local, edit), workspaceId));
  });

  /// Puts the song on (or takes it off) Discover. Online only, like the
  /// web: sharing is public, so it never waits in a queue. Returns the
  /// server's copy, also written here.
  Future<Song> setShared(int songId, int workspaceId, {required bool shared}) async {
    final server = await _service.change(songId, {'is_public': shared}, const {});
    await applyRemote(server, workspaceId);
    return server;
  }

  /// A teammate deleted the song: off this device, with its queued edit.
  Future<void> applyRemoteDelete(int id) => _db.transaction(() => _deleteLocalRows(id));

  /// The version of the song on this device, or null when it isn't here.
  Future<int?> localVersion(int id) async =>
      (await (_db.select(_db.songs)..where((t) => t.id.equals(id))).getSingleOrNull())?.version;

  /// [server] with this device's unsent changes ([edit]) laid over it — they
  /// win until they're sent (or settled, for a conflict).
  static Song keepPending(Song server, Song? local, SongEditRow? edit) {
    if (local == null || edit == null) return server;
    var out = server;
    for (final f in pendingFields(edit)) {
      out = f.write(out, f.read(local));
    }
    return out;
  }

  /// The fields an edit still has to send or settle. A row from before
  /// per-field saves (no base) covers the whole song.
  static Set<SongField> pendingFields(SongEditRow edit) {
    if (edit.base == null) return SongField.values.toSet();
    return {
      for (final api in [...decodeFields(edit.base).keys, ...decodeFields(edit.conflicts).keys]) ?SongField.byApi(api),
    };
  }

  static Map<String, Object?> decodeFields(String? json) {
    if (json == null || json.isEmpty) return {};
    try {
      return (jsonDecode(json) as Map).cast<String, Object?>();
    } on Object {
      return {};
    }
  }

  static String? encodeFields(Map<String, Object?> fields) => fields.isEmpty ? null : jsonEncode(fields);

  /// Pulls every page, then makes the local table match the server.
  Future<void> sync(int workspaceId) async {
    final songs = <Song>[];
    var page = 1;
    while (true) {
      final result = await _service.list(page: page);
      songs.addAll(result.data);
      if (result.meta.currentPage >= result.meta.lastPage) break;
      page++;
    }

    await _db.transaction(() async {
      // A field changed here and not yet sent beats the server's copy.
      final edits = {for (final e in await _db.select(_db.songEdits).get()) e.songId: e};
      final local = edits.isEmpty
          ? const <int, Song>{}
          : {
              for (final r in await (_db.select(_db.songs)..where((t) => t.id.isIn(edits.keys))).get())
                r.id: songFromRow(r),
            };
      // Negative ids are songs still waiting to be sent — the server can't know them yet.
      await (_db.delete(_db.songs)..where(
            (t) =>
                t.workspaceId.equals(workspaceId) & t.id.isBiggerOrEqualValue(0) & t.id.isNotIn(songs.map((s) => s.id)),
          ))
          .go();
      await _db.batch(
        (b) => b.insertAllOnConflictUpdate(_db.songs, [
          for (final s in songs)
            if (!_removing.contains(s.id))
              songCompanion(
                keepPending(s, local[s.id], edits[s.id]),
                workspaceId,
              ).copyWith(lastUsedAt: Value(s.lastUsedAt)),
        ]),
      );
    });
  }

  /// A full [Song] (chart and lyrics included) from its row.
  static Song songFromRow(SongRow row) => Song(
    id: row.id,
    title: row.title,
    artist: row.artist,
    key: row.key,
    transposition: row.transposition,
    bpm: row.bpm,
    timeSignature: row.timeSignature,
    content: row.content,
    lyrics: row.lyrics,
    youtubeUrl: row.youtubeUrl,
    spotifyUrl: row.spotifyUrl,
    appleMusicUrl: row.appleMusicUrl,
    otherUrl: row.otherUrl,
    isPublic: row.isPublic,
    createdAt: row.createdAt,
    lastUsedAt: row.lastUsedAt,
    version: row.version,
  );

  /// The row for a server [Song]. A missing [Song.lastUsedAt] leaves the
  /// cached one alone: only the library list carries it.
  static SongsCompanion songCompanion(Song s, int workspaceId) => SongsCompanion.insert(
    id: Value(s.id),
    workspaceId: workspaceId,
    title: s.title,
    artist: Value(s.artist),
    key: Value(s.key),
    transposition: Value(s.transposition),
    bpm: Value(s.bpm),
    timeSignature: Value(s.timeSignature),
    content: Value(s.content),
    lyrics: Value(s.lyrics),
    youtubeUrl: Value(s.youtubeUrl),
    spotifyUrl: Value(s.spotifyUrl),
    appleMusicUrl: Value(s.appleMusicUrl),
    otherUrl: Value(s.otherUrl),
    isPublic: Value(s.isPublic),
    createdAt: Value(s.createdAt),
    lastUsedAt: Value.absentIfNull(s.lastUsedAt),
    version: Value(s.version),
  );
}

/// A song taken off this device while its delete can still be undone.
class RemovedSong {
  const RemovedSong({required this.row, this.edit, this.capo, this.access});

  final SongRow row;
  final SongEditRow? edit;
  final SongCapoRow? capo;
  final RecentSongAccessRow? access;
}

@Riverpod(keepAlive: true)
SongsRepository songsRepository(Ref ref) => SongsRepository(
  ref.watch(appDatabaseProvider),
  SongsService(ref.watch(apiClientProvider)),
  ref.watch(songSyncActivityProvider.notifier),
);

@riverpod
Stream<List<String>> libraryArtists(Ref ref) {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(songsRepositoryProvider).watchArtists(id);
}

/// Songs matching [search], A–Z, for pickers — kept apart from the Songs
/// screen's own query so picking never disturbs it.
@riverpod
Stream<List<Song>> songSearch(Ref ref, String search) {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(songsRepositoryProvider).watchLibrary(id, SongListQuery(search: search));
}

/// Pending songs (by local id) and the server's last complaint about each.
@riverpod
Stream<Map<int, String?>> songOutbox(Ref ref) {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return Stream.value(const {});
  return ref.watch(songsRepositoryProvider).watchOutbox(id);
}

@riverpod
Stream<List<Song>> recentSongs(Ref ref) {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(songsRepositoryProvider).watchRecent(id);
}

@riverpod
Stream<List<Song>> recentlyOpenedSongs(Ref ref) {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(songsRepositoryProvider).watchRecentlyOpened(id);
}
