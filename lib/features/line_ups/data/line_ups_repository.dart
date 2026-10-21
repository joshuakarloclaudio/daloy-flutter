import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/connectivity/online_status.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/realtime/realtime_client.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/application/session_controller.dart';
import '../../songs/data/songs_repository.dart';
import '../../songs/domain/song.dart';
import '../domain/line_up.dart';
import '../domain/line_up_draft.dart';
import '../domain/line_up_list_query.dart';
import '../domain/live_session.dart';
import '../domain/setlist_entry.dart';

part 'line_ups_repository.g.dart';

/// `/api/line-ups` and `/api/live-session` calls.
class LineUpsService {
  const LineUpsService(this._api);

  final ApiClient _api;

  Future<List<LineUp>> list() => _api.get('/api/line-ups', (json) => LineUpListPage.fromJson(json! as JsonMap).lineUps);

  Future<LineUpDetail> detail(int id) => _api.get('/api/line-ups/$id', Decode.object(LineUpDetail.fromJson));

  Future<LineUpDetail> create(LineUpDetails details) =>
      _api.post('/api/line-ups', Decode.object(LineUpDetail.fromJson), body: details.toJson());

  Future<LineUpDetail> update(int id, LineUpDetails details) =>
      _api.patch('/api/line-ups/$id', Decode.object(LineUpDetail.fromJson), body: details.toJson());

  /// Replaces the line-up's songs with [songs], in order. Songs that stay
  /// keep their notes and arrangement on the server.
  Future<LineUpDetail> syncSongs(int id, List<({int songId, int transposition})> songs, {List<int>? baseSongIds}) =>
      _api.put(
        '/api/line-ups/$id/songs',
        Decode.object(LineUpDetail.fromJson),
        body: {
          'songs': [
            for (final s in songs) {'song_id': s.songId, 'transposition': s.transposition},
          ],
          'base_song_ids': ?baseSongIds,
        },
      );

  Future<void> delete(int id) => _api.delete('/api/line-ups/$id');

  /// Turns the public link on (idempotent) and returns it.
  Future<LineUpShareLink> enableShareLink(int id) =>
      _api.post('/api/line-ups/$id/share', Decode.object(LineUpShareLink.fromJson));

  Future<void> revokeShareLink(int id) => _api.delete('/api/line-ups/$id/share');

  /// This user's capo for each song, already resolved by the server.
  Future<Map<int, int>> capos(int id) => _api.get('/api/line-ups/$id/line-up-songs/capos', (json) {
    final list = ((json! as JsonMap)['capos'] as List).cast<JsonMap>();
    return {for (final c in list) c['line_up_song_id'] as int: c['capo'] as int};
  });

  Future<void> setCapo(int id, int lineUpSongId, int capo) =>
      _api.patch('/api/line-ups/$id/line-up-songs/$lineUpSongId/capo', (_) {}, body: {'capo': capo});

  /// [changeId] is the id the same change was whispered under in a live session.
  Future<void> setTransposition(int id, int lineUpSongId, int transposition, {String? changeId}) => _api.patch(
    '/api/line-ups/$id/line-up-songs/$lineUpSongId',
    (_) {},
    body: {'transposition': transposition, 'change_id': ?changeId},
  );

  /// Adds one note, or rewrites it when its id is already there (so a
  /// resend can't duplicate).
  Future<void> putNote(int id, int lineUpSongId, LineUpSongNote note) =>
      _api.post('/api/line-ups/$id/line-up-songs/$lineUpSongId/notes', (_) {}, body: note.toJson());

  /// Removes one note; already gone counts as done.
  Future<void> deleteNote(int id, int lineUpSongId, String noteId) =>
      _api.delete('/api/line-ups/$id/line-up-songs/$lineUpSongId/notes/$noteId');

  /// Replaces the team's notes on one song in the line-up.
  Future<void> setNotes(int id, int lineUpSongId, List<LineUpSongNote> notes) => _api.patch(
    '/api/line-ups/$id/line-up-songs/$lineUpSongId/notes',
    (_) {},
    body: {
      'notes': [for (final n in notes) n.toJson()],
    },
  );

  /// Replaces one view's section order and cuts; the other view is kept.
  /// With [base] (the view as this device found it) a stale write is
  /// refused: 409 with the entry as the server has it.
  Future<void> setArrangement(
    int id,
    int lineUpSongId,
    SongArrangementView view,
    SectionArrangementField field, {
    SectionArrangementField? base,
  }) => _api.patch(
    '/api/line-ups/$id/line-up-songs/$lineUpSongId/section-arrangement',
    (_) {},
    body: {
      'field': view.name,
      'order': field.order,
      'removed': field.removed,
      if (base != null) 'base': {'order': base.order, 'removed': base.removed},
    },
  );

  Future<LiveSession?> activeLiveSession() => _api.get('/api/live-session', Decode.nullable(LiveSession.fromJson));
}

class LineUpsRepository {
  LineUpsRepository(this._db, this._service);

  final AppDatabase _db;
  final LineUpsService _service;

  /// Local id → server id, for line-ups pushed while a screen still holds
  /// the local id. In memory only: nothing outlives the screen that needs it.
  final _serverIds = <int, int>{};

  /// The id a line-up goes by now — its server id once a local one is pushed.
  int resolveId(int id) => _serverIds[id] ?? id;

  /// Line-ups removed here whose server delete hasn't gone out yet (the undo
  /// window). A list sync must not bring them back meanwhile.
  final _removing = <int>{};

  // -- One line-up ---------------------------------------------------------

  Stream<LineUp?> watchLineUp(int id) => (_db.select(
    _db.lineUps,
  )..where((t) => t.id.equals(id))).watchSingleOrNull().map((row) => row == null ? null : _fromRow(row));

  /// Whether this device has the line-up's songs (not just their count).
  Stream<bool> watchSongsLoaded(int id) => (_db.select(_db.lineUps)..where((t) => t.id.equals(id)))
      .watchSingleOrNull()
      .map((row) => row != null && (row.songsLoaded || row.songsCount == 0));

  /// The set in order, each song read from the library so key or chart
  /// edits show at once.
  Stream<List<SetlistEntry>> watchSetlist(int id) {
    final l = _db.lineUpSongs;
    final s = _db.songs;
    return (_db.select(l).join([innerJoin(s, s.id.equalsExp(l.songId))])
          ..where(l.lineUpId.equals(id))
          ..orderBy([OrderingTerm.asc(l.position)]))
        .watch()
        .map((rows) => [for (final r in rows) _entryOf(r.readTable(l), SongsRepository.songFromRow(r.readTable(s)))]);
  }

  static SetlistEntry _entryOf(LineUpSongRow row, Song song) => SetlistEntry(
    position: row.position,
    song: song,
    lineUpSongId: row.lineUpSongId,
    transposition: row.transposition,
    notes: decodeNotes(row.notes),
    sectionArrangement: decodeArrangement(row.sectionArrangement),
  );

  static SectionArrangement? decodeArrangement(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      final arrangement = SectionArrangement.fromJson(jsonDecode(json) as JsonMap);
      return arrangement.isEmpty ? null : arrangement;
    } on Object {
      return null;
    }
  }

  static String? encodeArrangement(SectionArrangement? arrangement) =>
      arrangement == null || arrangement.isEmpty ? null : jsonEncode(arrangement.toJson());

  static List<LineUpSongNote> decodeNotes(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      return [for (final n in (jsonDecode(json) as List).cast<JsonMap>()) LineUpSongNote.fromJson(n)];
    } on Object {
      return const [];
    }
  }

  static String? encodeNotes(List<LineUpSongNote> notes) =>
      notes.isEmpty ? null : jsonEncode([for (final n in notes) n.toJson()]);

  /// Changes one song's key for this line-up, on this device only. Call
  /// [pushSongTransposition] once the taps settle.
  Future<void> setSongTransposition(int lineUpId, int position, int transposition) =>
      (_db.update(_db.lineUpSongs)..where((t) => t.lineUpId.equals(lineUpId) & t.position.equals(position))).write(
        LineUpSongsCompanion(transposition: Value(transposition)),
      );

  /// Sends one song's key: a PATCH when the server knows the entry and
  /// nothing else is queued, else the whole set goes through the outbox
  /// (which only knows how to send the song list).
  Future<void> pushSongTransposition(int lineUpId, int position, {String? changeId, DateTime? now}) async {
    final row = await (_db.select(
      _db.lineUpSongs,
    )..where((t) => t.lineUpId.equals(lineUpId) & t.position.equals(position))).getSingleOrNull();
    if (row == null) return;
    final pivot = row.lineUpSongId;
    if (pivot != null && lineUpId > 0 && await _outboxEntry(lineUpId) == null) {
      try {
        await _service.setTransposition(lineUpId, pivot, row.transposition, changeId: changeId);
        return;
      } on ApiException {
        // Offline or refused: the queue retries, and keeps any refusal.
      }
    }
    final workspaceId = await _queueSongs(lineUpId, now ?? DateTime.now());
    if (workspaceId != null) await flushOutbox(workspaceId);
  }

  // -- Changes from a live session ------------------------------------------

  /// A teammate changed a song's key mid-session. An unsent local change to
  /// this set wins until it goes out, as it does for a sync.
  Future<void> applyRemoteTransposition(int lineUpId, int lineUpSongId, int transposition) async {
    if (await _outboxEntry(lineUpId) != null) return;
    await _writeLineUpSong(lineUpId, lineUpSongId, LineUpSongsCompanion(transposition: Value(transposition)));
  }

  /// A teammate changed a song's notes. Notes changed here and not yet
  /// sent keep their local form; the rest take the team's.
  Future<void> applyRemoteNotes(int lineUpId, int lineUpSongId, List<LineUpSongNote> notes) =>
      _db.transaction(() async {
        final row = await _rowByPivot(lineUpId, lineUpSongId);
        if (row == null) return;
        final merged = overlayNotes(notes, decodeNotes(row.notes), await _prepKinds(lineUpId, row.songId));
        await _writeLineUpSong(lineUpId, lineUpSongId, LineUpSongsCompanion(notes: Value(encodeNotes(merged))));
      });

  /// One view's arrangement changed; the other view's is kept.
  Future<void> applyRemoteArrangement(
    int lineUpId,
    int lineUpSongId,
    SongArrangementView view,
    SectionArrangementField field,
  ) => _db.transaction(() async {
    final row = await _rowByPivot(lineUpId, lineUpSongId);
    if (row == null || await _prepEntry(lineUpId, row.songId, PrepKind.of(view)) != null) return;
    final current = decodeArrangement(row.sectionArrangement) ?? const SectionArrangement();
    final next = switch (view) {
      SongArrangementView.chords => current.copyWith(chords: field),
      SongArrangementView.lyrics => current.copyWith(lyrics: field),
    };
    await _writeLineUpSong(
      lineUpId,
      lineUpSongId,
      LineUpSongsCompanion(sectionArrangement: Value(encodeArrangement(next))),
    );
  });

  Future<LineUpSongRow?> _rowByPivot(int lineUpId, int lineUpSongId) => (_db.select(
    _db.lineUpSongs,
  )..where((t) => t.lineUpId.equals(lineUpId) & t.lineUpSongId.equals(lineUpSongId))).getSingleOrNull();

  Future<void> _writeLineUpSong(int lineUpId, int lineUpSongId, LineUpSongsCompanion change) => (_db.update(
    _db.lineUpSongs,
  )..where((t) => t.lineUpId.equals(lineUpId) & t.lineUpSongId.equals(lineUpSongId))).write(change);

  /// Marks the set as changed for the outbox. Returns the workspace to flush.
  /// [baseIds]: the set as the server had it before this change (taken from
  /// the device's rows when omitted — right when only a key changed).
  Future<int?> _queueSongs(int lineUpId, DateTime at, {List<SetSong>? baseIds}) async {
    final row = await _row(lineUpId);
    if (row == null) return null;
    final queued = await _outboxEntry(lineUpId);
    final base = queued?.songsDirty ?? false
        ? queued!.baseSongIds
        : (queued?.isNew ?? false) || lineUpId < 0
        ? null
        : encodeSetBase(
            baseIds ?? [for (final r in await _songRows(lineUpId)) (songId: r.songId, transposition: r.transposition)],
          );
    await _db
        .into(_db.lineUpOutbox)
        .insertOnConflictUpdate(
          LineUpOutboxCompanion.insert(
            lineUpId: Value(lineUpId),
            workspaceId: row.workspaceId,
            isNew: Value(queued?.isNew ?? false),
            detailsDirty: Value(queued?.detailsDirty ?? false),
            songsDirty: const Value(true),
            baseSongIds: Value(base),
            createdAt: queued?.createdAt ?? at,
            updatedAt: at,
            error: const Value(null),
          ),
        );
    return row.workspaceId;
  }

  // -- Prep: team notes and section arrangement (for everyone) -------------

  /// Unsent notes / arrangement changes in a line-up: song id → the server's
  /// last complaint about one of them (null: just waiting).
  Stream<Map<int, String?>> watchPrepOutbox(int lineUpId) =>
      (_db.select(_db.lineUpPrepOutbox)..where((t) => t.lineUpId.equals(lineUpId))).watch().map((rows) {
        final out = <int, String?>{};
        for (final r in rows) {
          out[r.songId] = out[r.songId] ?? r.error;
        }
        return out;
      });

  /// Replaces a song's notes in the line-up, on this device at once. Each
  /// note that changed is queued on its own (added/edited, or deleted), so a
  /// teammate's note added meanwhile survives; the server hears of it now if
  /// it can, else on the next flush.
  Future<void> setNotes(int lineUpId, int songId, List<LineUpSongNote> notes, {DateTime? now}) async {
    final target = resolveId(lineUpId);
    final at = now ?? DateTime.now();
    final written = await _db.transaction(() async {
      final row = await _songRow(target, songId);
      if (row == null) return false;
      final before = {for (final n in decodeNotes(row.notes)) n.id: n};
      final after = {for (final n in notes) n.id: n};
      final changed = {
        for (final id in {...before.keys, ...after.keys})
          if (before[id] != after[id]) id,
      };
      if (changed.isEmpty) return false;
      await _songWhere(target, songId).write(LineUpSongsCompanion(notes: Value(encodeNotes(notes))));
      for (final id in changed) {
        await _queuePrep(target, songId, PrepKind.note(id), at);
      }
      return true;
    });
    if (written) await _flushPrepFor(target);
  }

  /// Replaces one view's section order and cuts for a song in the line-up;
  /// the other view is kept. Saved and sent like [setNotes], with the view
  /// as it was before this device's first unsent change as the base.
  Future<void> setArrangement(
    int lineUpId,
    int songId,
    SongArrangementView view,
    SectionArrangementField field, {
    DateTime? now,
  }) async {
    final target = resolveId(lineUpId);
    final written = await _db.transaction(() async {
      final row = await _songRow(target, songId);
      if (row == null) return false;
      final current = decodeArrangement(row.sectionArrangement) ?? const SectionArrangement();
      await _songWhere(
        target,
        songId,
      ).write(LineUpSongsCompanion(sectionArrangement: Value(encodeArrangement(_withView(current, view, field)))));
      await _queuePrep(target, songId, PrepKind.of(view), now ?? DateTime.now(), base: _viewOf(current, view));
      return true;
    });
    if (written) await _flushPrepFor(target);
  }

  static SectionArrangement _withView(SectionArrangement a, SongArrangementView view, SectionArrangementField field) =>
      switch (view) {
        SongArrangementView.chords => a.copyWith(chords: field),
        SongArrangementView.lyrics => a.copyWith(lyrics: field),
      };

  static SectionArrangementField _viewOf(SectionArrangement a, SongArrangementView view) => switch (view) {
    SongArrangementView.chords => a.chords,
    SongArrangementView.lyrics => a.lyrics,
  };

  Future<LineUpSongRow?> _songRow(int lineUpId, int songId) => (_db.select(
    _db.lineUpSongs,
  )..where((t) => t.lineUpId.equals(lineUpId) & t.songId.equals(songId))).getSingleOrNull();

  UpdateStatement<$LineUpSongsTable, LineUpSongRow> _songWhere(int lineUpId, int songId) =>
      _db.update(_db.lineUpSongs)..where((t) => t.lineUpId.equals(lineUpId) & t.songId.equals(songId));

  /// Queues (or re-times) one change. [base] is kept from the first queueing.
  Future<void> _queuePrep(int lineUpId, int songId, PrepKind kind, DateTime at, {SectionArrangementField? base}) async {
    final existing = await _prepEntry(lineUpId, songId, kind);
    await _db
        .into(_db.lineUpPrepOutbox)
        .insertOnConflictUpdate(
          LineUpPrepOutboxCompanion.insert(
            lineUpId: lineUpId,
            songId: songId,
            kind: kind.key,
            updatedAt: at,
            error: const Value(null),
            base: Value(existing != null ? existing.base : (base == null ? null : jsonEncode(base.toJson()))),
          ),
        );
  }

  Future<LineUpPrepOutboxRow?> _prepEntry(int lineUpId, int songId, PrepKind kind) => (_db.select(
    _db.lineUpPrepOutbox,
  )..where((t) => t.lineUpId.equals(lineUpId) & t.songId.equals(songId) & t.kind.equals(kind.key))).getSingleOrNull();

  Future<List<PrepKind>> _prepKinds(int lineUpId, int songId) async => [
    for (final r in await (_db.select(
      _db.lineUpPrepOutbox,
    )..where((t) => t.lineUpId.equals(lineUpId) & t.songId.equals(songId))).get())
      ?PrepKind.parse(r.kind),
  ];

  Future<void> _flushPrepFor(int lineUpId) async {
    final row = await _row(lineUpId);
    if (row != null) await flushPrep(row.workspaceId);
  }

  bool _flushingPrep = false;
  bool _flushPrepAgain = false;

  /// Sends queued notes and arrangements in the workspace, oldest first.
  /// One waits while its line-up or its entry isn't on the server yet (the
  /// line-up outbox sends those, then calls this). Stops at the first
  /// network failure; a refused one keeps its error and is retried.
  Future<void> flushPrep(int workspaceId) async {
    if (_flushingPrep) {
      _flushPrepAgain = true;
      return;
    }
    _flushingPrep = true;
    try {
      do {
        _flushPrepAgain = false;
        final p = _db.lineUpPrepOutbox;
        final l = _db.lineUps;
        final queued =
            await (_db.select(p).join([innerJoin(l, l.id.equalsExp(p.lineUpId))])
                  ..where(l.workspaceId.equals(workspaceId))
                  ..orderBy([OrderingTerm.asc(p.updatedAt)]))
                .map((r) => r.readTable(p))
                .get();
        for (final entry in queued) {
          if (!await _pushPrep(entry)) return;
        }
      } while (_flushPrepAgain);
    } finally {
      _flushingPrep = false;
    }
  }

  /// `false` when the queue should stop (offline).
  Future<bool> _pushPrep(LineUpPrepOutboxRow entry) async {
    final kind = PrepKind.parse(entry.kind);
    Future<void> drop() =>
        (_db.delete(_db.lineUpPrepOutbox)..where(
              (t) => t.lineUpId.equals(entry.lineUpId) & t.songId.equals(entry.songId) & t.kind.equals(entry.kind),
            ))
            .go();

    if (kind == null) {
      await drop();
      return true;
    }
    if (entry.lineUpId < 0) return true;
    final row = await _songRow(entry.lineUpId, entry.songId);
    if (row == null) {
      // Taken out of the set since: nothing left to send it to.
      await drop();
      return true;
    }
    final pivot = row.lineUpSongId;
    if (pivot == null) return true;

    Future<void> sentIfUnchanged() => _db.transaction(() async {
      final latest = await _prepEntry(entry.lineUpId, entry.songId, kind);
      // Changed again while this was in flight: leave it for the next run.
      if (latest != null && latest.updatedAt == entry.updatedAt) await drop();
    });

    try {
      switch (kind) {
        case PrepNote(:final id):
          final note = decodeNotes(row.notes).where((n) => n.id == id).firstOrNull;
          note == null
              ? await _service.deleteNote(entry.lineUpId, pivot, id)
              : await _service.putNote(entry.lineUpId, pivot, note);
        case PrepAllNotes():
          await _service.setNotes(entry.lineUpId, pivot, decodeNotes(row.notes));
        case PrepView(:final view):
          final a = decodeArrangement(row.sectionArrangement) ?? const SectionArrangement();
          final base = entry.base == null
              ? null
              : SectionArrangementField.fromJson((jsonDecode(entry.base!) as Map).cast<String, dynamic>());
          await _service.setArrangement(entry.lineUpId, pivot, view, _viewOf(a, view), base: base);
      }
      await sentIfUnchanged();
      return true;
    } on NetworkException {
      return false;
    } on ApiConflictException catch (e) {
      // Someone rearranged it first: take theirs, as the web does.
      if (kind case PrepView(:final view) when e.data is Map) {
        final theirs = LineUpSongEntry.fromJson((e.data! as Map).cast<String, dynamic>()).sectionArrangement;
        await _db.transaction(() async {
          final current =
              decodeArrangement((await _songRow(entry.lineUpId, entry.songId))?.sectionArrangement) ??
              const SectionArrangement();
          await _songWhere(entry.lineUpId, entry.songId).write(
            LineUpSongsCompanion(
              sectionArrangement: Value(
                encodeArrangement(_withView(current, view, _viewOf(theirs ?? const SectionArrangement(), view))),
              ),
            ),
          );
          await drop();
        });
        return true;
      }
      await _markPrepError(entry, e.message);
      return true;
    } on ApiException catch (e) {
      if (e is ApiHttpException && e.status == 404) {
        // The song (or the line-up) is gone on the server.
        await drop();
        return true;
      }
      await _markPrepError(entry, e.message);
      return true;
    }
  }

  Future<void> _markPrepError(LineUpPrepOutboxRow entry, String message) =>
      (_db.update(_db.lineUpPrepOutbox)..where(
            (t) => t.lineUpId.equals(entry.lineUpId) & t.songId.equals(entry.songId) & t.kind.equals(entry.kind),
          ))
          .write(LineUpPrepOutboxCompanion(error: Value(message)));

  /// [songs] from the server, with this device's unsent notes and
  /// arrangement views laid over them — those win until they're sent.
  Future<List<_SongWrite>> _withPendingPrep(int lineUpId, List<_SongWrite> songs) async {
    final pending = await (_db.select(_db.lineUpPrepOutbox)..where((t) => t.lineUpId.equals(lineUpId))).get();
    if (pending.isEmpty) return songs;
    final kinds = <int, List<PrepKind>>{};
    for (final p in pending) {
      if (PrepKind.parse(p.kind) case final k?) (kinds[p.songId] ??= []).add(k);
    }
    final local = {for (final r in await _songRows(lineUpId)) r.songId: r};
    return [
      for (final s in songs)
        if (kinds[s.songId] case final k? when local[s.songId] != null) _overlay(s, local[s.songId]!, k) else s,
    ];
  }

  static _SongWrite _overlay(_SongWrite s, LineUpSongRow local, List<PrepKind> kinds) {
    var arrangement = s.sectionArrangement ?? const SectionArrangement();
    final mine = decodeArrangement(local.sectionArrangement) ?? const SectionArrangement();
    for (final k in kinds.whereType<PrepView>()) {
      arrangement = _withView(arrangement, k.view, _viewOf(mine, k.view));
    }
    return (
      songId: s.songId,
      transposition: s.transposition,
      lineUpSongId: s.lineUpSongId,
      notes: overlayNotes(s.notes, decodeNotes(local.notes), kinds),
      sectionArrangement: arrangement,
    );
  }

  /// The server's [server] notes with this device's unsent ones laid over:
  /// a queued note takes its local form (or stays deleted); a queued whole
  /// list (from before per-note saves) wins outright.
  static List<LineUpSongNote> overlayNotes(
    List<LineUpSongNote> server,
    List<LineUpSongNote> local,
    List<PrepKind> kinds,
  ) {
    if (kinds.any((k) => k is PrepAllNotes)) return local;
    final ids = {for (final k in kinds.whereType<PrepNote>()) k.id};
    if (ids.isEmpty) return server;
    final mine = {for (final n in local) n.id: n};
    final out = [
      for (final n in server)
        if (!ids.contains(n.id)) n else ?mine[n.id],
    ];
    final present = {for (final n in out) n.id};
    for (final n in local) {
      if (ids.contains(n.id) && !present.contains(n.id)) out.add(n);
    }
    return out;
  }

  // -- Capo (per user, per line-up song) -----------------------------------

  Stream<Map<int, int>> watchCapos(int lineUpId) => (_db.select(
    _db.lineUpSongCapos,
  )..where((t) => t.lineUpId.equals(lineUpId))).watch().map((rows) => {for (final r in rows) r.lineUpSongId: r.capo});

  /// Mirrors the server's resolved capos, keeping any not yet sent. Quiet
  /// when offline.
  Future<void> refreshCapos(int lineUpId) async {
    if (lineUpId <= 0) return;
    final Map<int, int> remote;
    try {
      remote = await _service.capos(lineUpId);
    } on ApiException {
      return;
    }
    await _db.transaction(() async {
      final dirty = {
        for (final r in await (_db.select(
          _db.lineUpSongCapos,
        )..where((t) => t.lineUpId.equals(lineUpId) & t.dirty.equals(true))).get())
          r.lineUpSongId,
      };
      await _db.batch(
        (b) => b.insertAllOnConflictUpdate(_db.lineUpSongCapos, [
          for (final MapEntry(key: pivot, value: capo) in remote.entries)
            if (!dirty.contains(pivot))
              LineUpSongCaposCompanion.insert(lineUpSongId: Value(pivot), lineUpId: lineUpId, capo: Value(capo)),
        ]),
      );
    });
  }

  /// My capo for one line-up song changed on another of my devices. A
  /// change made here and not yet sent wins.
  Future<void> applyRemoteCapo(int lineUpId, int lineUpSongId, int capo) => _db.transaction(() async {
    final row = await (_db.select(
      _db.lineUpSongCapos,
    )..where((t) => t.lineUpSongId.equals(lineUpSongId))).getSingleOrNull();
    if (row?.dirty ?? false) return;
    await _db
        .into(_db.lineUpSongCapos)
        .insertOnConflictUpdate(
          LineUpSongCaposCompanion.insert(lineUpSongId: Value(lineUpSongId), lineUpId: lineUpId, capo: Value(capo)),
        );
  });

  /// Applies at once; the server catches up now if it can, else on the next
  /// [flushCapos].
  Future<void> setCapo(int lineUpId, int lineUpSongId, int capo) async {
    await _db
        .into(_db.lineUpSongCapos)
        .insertOnConflictUpdate(
          LineUpSongCaposCompanion.insert(
            lineUpSongId: Value(lineUpSongId),
            lineUpId: lineUpId,
            capo: Value(capo),
            dirty: const Value(true),
          ),
        );
    await _pushCapo(lineUpSongId);
  }

  Future<void> flushCapos() async {
    for (final r in await (_db.select(_db.lineUpSongCapos)..where((t) => t.dirty.equals(true))).get()) {
      await _pushCapo(r.lineUpSongId);
    }
  }

  Future<void> _pushCapo(int lineUpSongId) async {
    final query = _db.select(_db.lineUpSongCapos)..where((t) => t.lineUpSongId.equals(lineUpSongId));
    final row = await query.getSingleOrNull();
    if (row == null || !row.dirty) return;
    try {
      await _service.setCapo(row.lineUpId, lineUpSongId, row.capo);
    } on ApiException {
      return; // Stays dirty; retried on the next flush.
    }
    final now = await query.getSingleOrNull();
    if (now != null && now.capo == row.capo) {
      await (_db.update(
        _db.lineUpSongCapos,
      )..where((t) => t.lineUpSongId.equals(lineUpSongId))).write(const LineUpSongCaposCompanion(dirty: Value(false)));
    }
  }

  // -- Delete with undo ----------------------------------------------------

  /// Takes the line-up off this device and returns what's needed to put it
  /// back. Nothing reaches the server until [deleteRemote].
  Future<RemovedLineUp?> removeLocal(int id) => _db.transaction(() async {
    final row = await _row(id);
    if (row == null) return null;
    final songs = await _songRows(id);
    _removing.add(id);
    await _deleteLocal(id);
    return RemovedLineUp(row, songs);
  });

  /// Undo: puts a removed line-up back exactly as it was.
  Future<void> restore(RemovedLineUp removed) async {
    _removing.remove(removed.row.id);
    await _db.transaction(() async {
      await _db.into(_db.lineUps).insertOnConflictUpdate(removed.row);
      await _db.batch((b) => b.insertAllOnConflictUpdate(_db.lineUpSongs, removed.songs));
    });
  }

  /// Sends the delete. On failure the line-up is restored and the error
  /// rethrown; a 404 means it's already gone, which is the goal.
  Future<void> deleteRemote(RemovedLineUp removed) async {
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

  Stream<List<LineUp>> watchAll(int workspaceId) =>
      (_db.select(_db.lineUps)
            ..where((t) => t.workspaceId.equals(workspaceId))
            ..orderBy([(t) => OrderingTerm.desc(t.id)]))
          .watch()
          .map((rows) => rows.map(_fromRow).toList());

  /// The Line-ups screen's query: timing, content and order run in SQLite,
  /// the (small) result is then matched against the search text in Dart so
  /// "October" can find dates.
  Stream<List<LineUp>> watchLibrary(int workspaceId, LineUpListQuery q) {
    final t = _db.lineUps;
    final today = todayIsoLocal();
    final query = _db.select(t)..where((l) => l.workspaceId.equals(workspaceId));
    query.where(
      (l) => switch (q.timing) {
        LineUpTiming.upcoming => l.date.isBiggerOrEqualValue(today),
        LineUpTiming.past => l.date.isSmallerThanValue(today),
        null => const Constant(true),
      },
    );
    query.where(
      (l) => switch (q.content) {
        LineUpContent.hasSongs => l.songsCount.isBiggerThanValue(0),
        LineUpContent.empty => l.songsCount.equals(0),
        null => const Constant(true),
      },
    );
    query.orderBy([(l) => OrderingTerm.desc(l.date), (l) => OrderingTerm.desc(l.id)]);

    final search = q.search;
    return query.watch().map((rows) {
      final all = rows.map(_fromRow);
      return (search.trim().isEmpty ? all : all.where((l) => lineUpMatchesSearch(l, search))).toList();
    });
  }

  /// Worship leaders already used in the workspace, most recent first
  /// (case-insensitive), for the create form's suggestions.
  Stream<List<String>> watchLeaders(int workspaceId) {
    final t = _db.lineUps;
    final latest = t.date.max();
    final query = _db.selectOnly(t)
      ..addColumns([t.worshipLeader, latest])
      ..where(t.workspaceId.equals(workspaceId) & t.worshipLeader.isNotNull() & t.worshipLeader.trim().equals('').not())
      ..groupBy([t.worshipLeader.lower()])
      ..orderBy([OrderingTerm.desc(latest)]);
    return query.watch().map((rows) => [for (final r in rows) r.read(t.worshipLeader)!.trim()]);
  }

  /// Line-up ids waiting on the server, with why the last attempt failed
  /// (null: just waiting).
  Stream<Map<int, String?>> watchOutbox(int workspaceId) =>
      (_db.select(_db.lineUpOutbox)..where((t) => t.workspaceId.equals(workspaceId))).watch().map(
        (rows) => {for (final r in rows) r.lineUpId: r.error},
      );

  /// Saves a new line-up on this device at once and queues it for the
  /// server. Returns its local (negative) id — call [flushOutbox] to push it.
  Future<int> createLocal(int workspaceId, LineUpDetails details, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    final localId = -at.microsecondsSinceEpoch;
    final d = details.normalized();
    await _db.transaction(() async {
      await _db
          .into(_db.lineUps)
          .insert(
            LineUpsCompanion.insert(
              id: Value(localId),
              workspaceId: workspaceId,
              title: d.title,
              date: d.date,
              worshipLeader: Value(d.worshipLeader),
              // Nothing to fetch: it has no songs until they're added here.
              songsLoaded: const Value(true),
            ),
          );
      await _db
          .into(_db.lineUpOutbox)
          .insert(
            LineUpOutboxCompanion.insert(
              lineUpId: Value(localId),
              workspaceId: workspaceId,
              isNew: const Value(true),
              createdAt: at,
              updatedAt: at,
            ),
          );
    });
    return localId;
  }

  /// The line-up as the edit screen opens it, from Drift.
  Future<EditableLineUp?> loadEditable(int id) async {
    final target = resolveId(id);
    final row = await _row(target);
    if (row == null) return null;
    return EditableLineUp(
      id: target,
      details: _detailsOf(row),
      songs: await _draftSongs(target),
      songsKnown: row.songsLoaded || row.songsCount == 0,
    );
  }

  /// Fetches one line-up's songs into Drift. Skipped while this device has
  /// unsent changes to it — those win until they're pushed.
  Future<void> refreshDetail(int id, int workspaceId) async {
    if (id < 0 || await _outboxEntry(id) != null) return;
    final detail = await _service.detail(id);
    await _db.transaction(() async {
      if (await _outboxEntry(id) != null) return;
      await _storeDetail(detail, workspaceId);
    });
  }

  /// Writes an edit to Drift and queues it. [songs] is null when the song
  /// list wasn't touched. Returns the id the line-up now goes by.
  Future<int> save(int id, LineUpDetails details, {List<LineUpDraftSong>? songs, DateTime? now}) {
    final at = now ?? DateTime.now();
    final d = details.normalized();
    return _db.transaction(() async {
      final target = resolveId(id);
      final row = await _row(target);
      if (row == null) throw StateError('Line-up $target is not on this device.');

      final detailsChanged = d != _detailsOf(row);
      List<SetSong>? beforeIds;
      await (_db.update(_db.lineUps)..where((t) => t.id.equals(target))).write(
        LineUpsCompanion(
          title: Value(d.title),
          date: Value(d.date),
          worshipLeader: Value(d.worshipLeader),
          songsCount: songs == null ? const Value.absent() : Value(songs.length),
          songsLoaded: songs == null ? const Value.absent() : const Value(true),
        ),
      );
      if (songs != null) {
        // A song that stays keeps its entry on the server (the PUT matches by
        // song), so it keeps its pivot, notes and arrangement here too.
        final beforeRows = await _songRows(target);
        beforeIds = [for (final r in beforeRows) (songId: r.songId, transposition: r.transposition)];
        final before = {for (final r in beforeRows) r.songId: r};
        await _replaceSongs(target, [
          for (final s in songs)
            (
              songId: s.songId,
              transposition: s.transposition,
              lineUpSongId: before[s.songId]?.lineUpSongId,
              notes: decodeNotes(before[s.songId]?.notes),
              sectionArrangement: decodeArrangement(before[s.songId]?.sectionArrangement),
            ),
        ]);
        final kept = {for (final s in songs) s.songId};
        await _markUsed(kept.difference(before.keys.toSet()), at);
        await (_db.delete(_db.lineUpPrepOutbox)..where((t) => t.lineUpId.equals(target) & t.songId.isNotIn(kept))).go();
      }

      final queued = await _outboxEntry(target);
      final detailsDirty = (queued?.detailsDirty ?? false) || detailsChanged;
      final songsDirty = (queued?.songsDirty ?? false) || songs != null;
      if (queued == null && !detailsDirty && !songsDirty) return target;
      await _db
          .into(_db.lineUpOutbox)
          .insertOnConflictUpdate(
            LineUpOutboxCompanion.insert(
              lineUpId: Value(target),
              workspaceId: row.workspaceId,
              isNew: Value(queued?.isNew ?? false),
              detailsDirty: Value(detailsDirty),
              songsDirty: Value(songsDirty),
              baseSongIds: Value(
                queued?.songsDirty ?? false
                    ? queued!.baseSongIds
                    : songs == null || (queued?.isNew ?? false) || target < 0 || beforeIds == null
                    ? null
                    : encodeSetBase(beforeIds),
              ),
              createdAt: queued?.createdAt ?? at,
              updatedAt: at,
              error: const Value(null),
            ),
          );
      return target;
    });
  }

  /// Puts [songId] at the end of a line-up's set, on this device at once,
  /// and queues the set for the server (call [flushOutbox]). Refused when
  /// the set isn't on this device yet, or already holds the song.
  Future<AddSongResult> addSong(int lineUpId, int songId, {DateTime? now}) => _db.transaction(() async {
    final target = resolveId(lineUpId);
    final row = await _row(target);
    if (row == null || !(row.songsLoaded || row.songsCount == 0)) return AddSongResult.notLoaded;
    final songs = await _songRows(target);
    if (songs.any((s) => s.songId == songId)) return AddSongResult.alreadyIn;
    final baseIds = [for (final s in songs) (songId: s.songId, transposition: s.transposition)];
    await _db
        .into(_db.lineUpSongs)
        .insert(LineUpSongsCompanion.insert(lineUpId: target, position: songs.length, songId: songId));
    await (_db.update(_db.lineUps)..where((t) => t.id.equals(target))).write(
      LineUpsCompanion(songsCount: Value(songs.length + 1), songsLoaded: const Value(true)),
    );
    final at = now ?? DateTime.now();
    await _markUsed({songId}, at);
    await _queueSongs(target, at, baseIds: baseIds);
    return AddSongResult.added;
  });

  /// Ids of the line-ups on this device whose set holds [songId].
  Stream<Set<int>> watchLineUpsWithSong(int songId) {
    final l = _db.lineUpSongs;
    final query = _db.selectOnly(l, distinct: true)
      ..addColumns([l.lineUpId])
      ..where(l.songId.equals(songId));
    return query.watch().map((rows) => {for (final r in rows) r.read(l.lineUpId)!});
  }

  /// Drops a line-up that never reached the server.
  Future<void> discardPending(int localId) => _db.transaction(() => _deleteLocal(localId));

  bool _flushing = false;
  bool _flushAgain = false;

  /// Sends queued line-ups oldest first: POST for new ones, then the song
  /// list (PUT) and details (PATCH) if they changed. Stops at the first
  /// network failure; a line-up the server refuses keeps its error and is
  /// retried on the next flush. Overlapping calls fold into one run.
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
            await (_db.select(_db.lineUpOutbox)
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
    // Entries the server just took now have pivots to send notes to.
    await flushPrep(workspaceId);
  }

  /// `false` when the queue should stop (offline).
  Future<bool> _push(LineUpOutboxRow queued) async {
    var id = queued.lineUpId;
    try {
      if (queued.isNew) {
        final row = await _row(id);
        if (row == null) {
          await _db.transaction(() => _deleteLocal(id));
          return true;
        }
        final created = await _service.create(_detailsOf(row));
        await _adopt(queued, created.id);
        id = created.id;
      }

      final entry = await _outboxEntry(id);
      if (entry == null) return true;

      LineUpDetail? synced;
      if (entry.songsDirty) {
        final songs = await _songRows(id);
        final local = [for (final s in songs) (songId: s.songId, transposition: s.transposition)];
        final base = decodeSetBase(entry.baseSongIds);
        try {
          synced = await _service.syncSongs(
            id,
            local,
            baseSongIds: base == null ? null : [for (final s in base) s.songId],
          );
        } on ApiConflictException catch (e) {
          // Someone changed the set meanwhile: put this device's changes on
          // top of theirs and send that instead.
          if (base == null || e.data is! Map) rethrow;
          final server = LineUpDetail.fromJson((e.data! as Map).cast<String, dynamic>());
          final ordered = [...server.songs]..sort((a, b) => a.order.compareTo(b.order));
          final rebased = rebaseSet(
            server: [for (final s in ordered) (songId: s.song.id, transposition: s.transposition)],
            base: base,
            local: local,
          );
          synced = await _service.syncSongs(id, rebased, baseSongIds: [for (final s in ordered) s.song.id]);
        }
      }
      if (entry.detailsDirty) {
        final row = await _row(id);
        if (row != null) await _service.update(id, _detailsOf(row));
      }

      await _db.transaction(() async {
        final latest = await _outboxEntry(id);
        // Saved again while this was in flight: leave it for the next run.
        if (latest == null || latest.updatedAt != entry.updatedAt) return;
        await (_db.delete(_db.lineUpOutbox)..where((t) => t.lineUpId.equals(id))).go();
        if (synced != null) await _storeDetail(synced, entry.workspaceId, songsOnly: true);
      });
      return true;
    } on NetworkException {
      return false;
    } on ApiException catch (e) {
      if (e is ApiHttpException && e.status == 404 && id > 0) {
        // Deleted on the server meanwhile — nothing left to save it to.
        await _db.transaction(() => _deleteLocal(id));
        return true;
      }
      await (_db.update(
        _db.lineUpOutbox,
      )..where((t) => t.lineUpId.equals(id))).write(LineUpOutboxCompanion(error: Value(e.message)));
      return true;
    }
  }

  /// Moves a just-created line-up from its local id to the server's.
  /// The POST carried the details, so they're no longer dirty — unless they
  /// were saved again while it was in flight.
  Future<void> _adopt(LineUpOutboxRow sent, int serverId) => _db.transaction(() async {
    final localId = sent.lineUpId;
    final row = await _row(localId);
    final latest = await _outboxEntry(localId);
    if (row != null) {
      await _db.into(_db.lineUps).insertOnConflictUpdate(row.copyWith(id: serverId));
      await (_db.update(
        _db.lineUpSongs,
      )..where((t) => t.lineUpId.equals(localId))).write(LineUpSongsCompanion(lineUpId: Value(serverId)));
      await (_db.delete(_db.lineUps)..where((t) => t.id.equals(localId))).go();
      await (_db.update(
        _db.lineUpPrepOutbox,
      )..where((t) => t.lineUpId.equals(localId))).write(LineUpPrepOutboxCompanion(lineUpId: Value(serverId)));
    }
    await (_db.delete(_db.lineUpOutbox)..where((t) => t.lineUpId.equals(localId))).go();
    if (latest != null) {
      final changedInFlight = latest.updatedAt != sent.updatedAt;
      await _db
          .into(_db.lineUpOutbox)
          .insertOnConflictUpdate(
            latest.copyWith(lineUpId: serverId, isNew: false, detailsDirty: changedInFlight && latest.detailsDirty),
          );
    }
    _serverIds[localId] = serverId;
  });

  Future<void> sync(int workspaceId) async {
    final lineUps = await _service.list();
    var stale = const <int>[];
    await _db.transaction(() async {
      // Unsent changes win over the server's copy until they're pushed, and
      // local (negative) ids can't be on the server yet.
      final pending = {
        for (final e in await (_db.select(_db.lineUpOutbox)..where((t) => t.workspaceId.equals(workspaceId))).get())
          e.lineUpId,
      };
      final cached = {
        for (final r in await (_db.select(_db.lineUps)..where((t) => t.workspaceId.equals(workspaceId))).get()) r.id: r,
      };
      pending.addAll(_removing);
      final serverIds = {for (final l in lineUps) l.id};
      for (final row in cached.values) {
        if (row.id >= 0 && !serverIds.contains(row.id) && !pending.contains(row.id)) await _deleteLocal(row.id);
      }
      await _db.batch(
        (b) => b.insertAllOnConflictUpdate(_db.lineUps, [
          for (final l in lineUps)
            if (!pending.contains(l.id))
              LineUpsCompanion.insert(
                id: Value(l.id),
                workspaceId: workspaceId,
                title: l.title,
                date: l.date,
                worshipLeader: Value(l.worshipLeader),
                songsCount: Value(l.songsCount),
                version: Value(l.version),
                updatedAt: Value(l.updatedAt),
                updatedById: Value(l.updatedBy?.id),
                updatedByName: Value(l.updatedBy?.name),
                // Someone else changed its songs: the cached list is stale.
                songsLoaded: cached[l.id]?.songsCount == l.songsCount ? const Value.absent() : const Value(false),
              ),
        ]),
      );
      stale = [
        for (final l in lineUps)
          if (!pending.contains(l.id) &&
              (cached[l.id]?.songsLoaded ?? false) &&
              cached[l.id]?.songsCount == l.songsCount &&
              cached[l.id]?.songsVersion != l.version)
            l.id,
      ];
    });
    // Sets changed on the server since they were fetched (a ping missed
    // while offline): bring them up to date, quietly.
    for (final id in stale) {
      try {
        await refreshDetail(id, workspaceId);
      } on ApiException {
        // The next sync tries again.
      }
    }
  }

  /// The version the line-up's cached set came from (null: not here, or
  /// its songs never fetched).
  Future<int?> localSongsVersion(int id) async => (await _row(id))?.songsVersion;

  /// A teammate deleted the line-up: off this device, unless a delete of
  /// our own is already under way.
  Future<void> applyRemoteDelete(int id) async {
    if (_removing.contains(id)) return;
    await _db.transaction(() => _deleteLocal(id));
  }

  Future<LineUpRow?> _row(int id) => (_db.select(_db.lineUps)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<LineUpOutboxRow?> _outboxEntry(int id) =>
      (_db.select(_db.lineUpOutbox)..where((t) => t.lineUpId.equals(id))).getSingleOrNull();

  Future<List<LineUpSongRow>> _songRows(int id) =>
      (_db.select(_db.lineUpSongs)
            ..where((t) => t.lineUpId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();

  /// The line-up's songs joined to the library for their titles and keys.
  Future<List<LineUpDraftSong>> _draftSongs(int id) async {
    final l = _db.lineUpSongs;
    final s = _db.songs;
    final rows =
        await (_db.select(l).join([innerJoin(s, s.id.equalsExp(l.songId))])
              ..where(l.lineUpId.equals(id))
              ..orderBy([OrderingTerm.asc(l.position)]))
            .get();
    return [
      for (final r in rows)
        LineUpDraftSong(song: SongsRepository.songFromRow(r.readTable(s)), transposition: r.readTable(l).transposition),
    ];
  }

  /// Songs just put in a set here: "Recently used" at once, without waiting
  /// for the next library sync to say so.
  Future<void> _markUsed(Set<int> songIds, DateTime at) async {
    if (songIds.isEmpty) return;
    await (_db.update(_db.songs)..where((t) => t.id.isIn(songIds))).write(SongsCompanion(lastUsedAt: Value(at)));
  }

  Future<void> _replaceSongs(int id, List<_SongWrite> songs) async {
    await (_db.delete(_db.lineUpSongs)..where((t) => t.lineUpId.equals(id))).go();
    await _db.batch(
      (b) => b.insertAll(_db.lineUpSongs, [
        for (final (i, s) in songs.indexed)
          LineUpSongsCompanion.insert(
            lineUpId: id,
            position: i,
            songId: s.songId,
            transposition: Value(s.transposition),
            lineUpSongId: Value(s.lineUpSongId),
            notes: Value(encodeNotes(s.notes)),
            sectionArrangement: Value(encodeArrangement(s.sectionArrangement)),
          ),
      ]),
    );
  }

  /// Writes a server detail. Songs only the line-up knows about are added
  /// to the library; songs already cached are left alone (the songs sync
  /// owns them, and may hold an unsent edit). [songsOnly] keeps the local
  /// title, date and leader — the song PUT answers before the PATCH lands.
  Future<void> _storeDetail(LineUpDetail detail, int workspaceId, {bool songsOnly = false}) async {
    final entries = [...detail.songs]..sort((a, b) => a.order.compareTo(b.order));
    await _db.batch(
      (b) => b.insertAll(_db.songs, [
        for (final e in entries) SongsRepository.songCompanion(e.song, workspaceId),
      ], mode: InsertMode.insertOrIgnore),
    );
    await _replaceSongs(
      detail.id,
      await _withPendingPrep(detail.id, [
        for (final e in entries)
          (
            songId: e.song.id,
            transposition: e.transposition,
            lineUpSongId: e.lineUpSongId,
            notes: e.notes,
            sectionArrangement: e.sectionArrangement,
          ),
      ]),
    );
    if (songsOnly) {
      await (_db.update(_db.lineUps)..where((t) => t.id.equals(detail.id))).write(
        LineUpsCompanion(
          songsCount: Value(entries.length),
          songsLoaded: const Value(true),
          version: Value(detail.version),
          songsVersion: Value(detail.version),
          updatedAt: Value(detail.updatedAt),
          updatedById: Value(detail.updatedBy?.id),
          updatedByName: Value(detail.updatedBy?.name),
        ),
      );
      return;
    }
    await _db
        .into(_db.lineUps)
        .insertOnConflictUpdate(
          LineUpsCompanion.insert(
            id: Value(detail.id),
            workspaceId: workspaceId,
            title: detail.title,
            date: detail.date,
            worshipLeader: Value(detail.worshipLeader),
            songsCount: Value(entries.length),
            songsLoaded: const Value(true),
            version: Value(detail.version),
            songsVersion: Value(detail.version),
            updatedAt: Value(detail.updatedAt),
            updatedById: Value(detail.updatedBy?.id),
            updatedByName: Value(detail.updatedBy?.name),
          ),
        );
  }

  Future<void> _deleteLocal(int id) async {
    await (_db.delete(_db.lineUpSongCapos)..where((t) => t.lineUpId.equals(id))).go();
    await (_db.delete(_db.lineUpOutbox)..where((t) => t.lineUpId.equals(id))).go();
    await (_db.delete(_db.lineUpPrepOutbox)..where((t) => t.lineUpId.equals(id))).go();
    await (_db.delete(_db.lineUpSongs)..where((t) => t.lineUpId.equals(id))).go();
    await (_db.delete(_db.lineUps)..where((t) => t.id.equals(id))).go();
  }

  static LineUpDetails _detailsOf(LineUpRow row) =>
      LineUpDetails(title: row.title, date: row.date, worshipLeader: row.worshipLeader);

  static LineUp _fromRow(LineUpRow row) => LineUp(
    id: row.id,
    title: row.title,
    date: row.date,
    worshipLeader: row.worshipLeader,
    songsCount: row.songsCount,
    version: row.version,
    updatedAt: row.updatedAt,
    updatedBy: SongsRepository.updatedByOf(row.updatedById, row.updatedByName),
  );
}

/// Which of a song's two arrangements a change is for (`field` in the API).
enum SongArrangementView { chords, lyrics }

enum AddSongResult { added, alreadyIn, notLoaded }

typedef SetSong = ({int songId, int transposition});

/// The outbox's `base_song_ids` column: the set (with keys) it started from.
String encodeSetBase(List<SetSong> set) => jsonEncode([
  for (final s in set) {'id': s.songId, 't': s.transposition},
]);

List<SetSong>? decodeSetBase(String? json) {
  if (json == null) return null;
  try {
    return [
      for (final e in jsonDecode(json) as List)
        e is int
            ? (songId: e, transposition: 0)
            : (songId: (e as Map)['id'] as int, transposition: e['t'] as int? ?? 0),
    ];
  } on Object {
    return null;
  }
}

/// This device's set changes ([base] → [local]) applied on top of the set the
/// server has now ([server]): songs removed here stay removed, songs added
/// here go on the end, keys changed here win; the server's order stands
/// otherwise (a reorder from both sides keeps theirs).
List<SetSong> rebaseSet({required List<SetSong> server, required List<SetSong> base, required List<SetSong> local}) {
  final baseIds = {for (final s in base) s.songId};
  final baseKey = {for (final s in base) s.songId: s.transposition};
  final localIds = {for (final s in local) s.songId};
  // Only keys this device actually changed.
  final myKeys = {
    for (final s in local)
      if (baseKey[s.songId] != s.transposition) s.songId: s.transposition,
  };
  final removed = baseIds.difference(localIds);
  final out = [
    for (final s in server)
      if (!removed.contains(s.songId)) (songId: s.songId, transposition: myKeys[s.songId] ?? s.transposition),
  ];
  final present = {for (final s in out) s.songId};
  for (final s in local) {
    if (!baseIds.contains(s.songId) && !present.contains(s.songId)) out.add(s);
  }
  return out;
}

/// What a queued prep change is, as stored in `kind`.
sealed class PrepKind {
  const PrepKind();

  /// One note, by id: sent as an add/edit if it's still here, else a delete.
  const factory PrepKind.note(String id) = PrepNote;

  static PrepKind of(SongArrangementView view) => PrepView(view);

  /// Null for something this version doesn't know.
  static PrepKind? parse(String key) {
    if (key.startsWith('note:')) return PrepNote(key.substring(5));
    if (key == 'notes') return const PrepAllNotes();
    for (final v in SongArrangementView.values) {
      if (v.name == key) return PrepView(v);
    }
    return null;
  }

  String get key;
}

class PrepNote extends PrepKind {
  const PrepNote(this.id);

  final String id;

  @override
  String get key => 'note:$id';
}

/// The whole list, queued before per-note saves.
class PrepAllNotes extends PrepKind {
  const PrepAllNotes();

  @override
  String get key => 'notes';
}

class PrepView extends PrepKind {
  const PrepView(this.view);

  final SongArrangementView view;

  @override
  String get key => view.name;
}

/// One line-up song as written to Drift.
typedef _SongWrite = ({
  int songId,
  int transposition,
  int? lineUpSongId,
  List<LineUpSongNote> notes,
  SectionArrangement? sectionArrangement,
});

/// A line-up taken off this device while its delete can still be undone.
class RemovedLineUp {
  const RemovedLineUp(this.row, this.songs);

  final LineUpRow row;
  final List<LineUpSongRow> songs;
}

@Riverpod(keepAlive: true)
LineUpsService lineUpsService(Ref ref) => LineUpsService(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
LineUpsRepository lineUpsRepository(Ref ref) =>
    LineUpsRepository(ref.watch(appDatabaseProvider), ref.watch(lineUpsServiceProvider));

/// Every cached line-up in the active workspace, newest id first.
@riverpod
Stream<List<LineUp>> workspaceLineUps(Ref ref) {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(lineUpsRepositoryProvider).watchAll(id);
}

/// Pending line-ups (by id) and the server's last complaint about each.
@riverpod
Stream<Map<int, String?>> lineUpOutbox(Ref ref) {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return Stream.value(const {});
  return ref.watch(lineUpsRepositoryProvider).watchOutbox(id);
}

@riverpod
Stream<List<String>> worshipLeaders(Ref ref) {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return Stream.value(const []);
  return ref.watch(lineUpsRepositoryProvider).watchLeaders(id);
}

/// The running performance. Network-only on purpose: a stale "Live now" is
/// worse than none.
///
/// Realtime first: Reverb pushes `session.active` / `session.ended` on the
/// workspace channel, so it flips in about a second. REST stays the source of
/// truth for the initial value and after every reconnect, and a slow poll
/// covers the socket being down.
@riverpod
class ActiveLiveSession extends _$ActiveLiveSession {
  @override
  Future<LiveSession?> build() async {
    final online = ref.watch(isOnlineProvider);
    final workspaceId = ref.watch(activeWorkspaceIdProvider);
    if (!online || workspaceId == null) return null;

    final realtime = ref.watch(realtimeClientProvider);
    final subscription = realtime.listen('private-workspace.$workspaceId', {
      'session.active': (data) {
        final session = data['session'];
        if (session is Map<String, dynamic>) state = AsyncData(LiveSession.fromJson(session));
      },
      'session.ended': (_) => state = const AsyncData(null),
    });
    final reconnected = realtime.reconnected.listen((_) => _refresh());
    final fallback = Timer.periodic(AppConfig.liveSessionFallbackPollInterval, (_) {
      if (!realtime.isConnected) _refresh();
    });
    ref.onDispose(() {
      subscription.cancel();
      reconnected.cancel();
      fallback.cancel();
    });

    return ref.watch(lineUpsServiceProvider).activeLiveSession();
  }

  /// What a live-session call just returned, ahead of the socket's echo.
  void adopt(LiveSession? session) => state = AsyncData(session);

  /// Refetches without flashing a loading state; a failed refetch keeps what
  /// the socket last told us.
  Future<void> _refresh() async {
    try {
      final next = await ref.read(lineUpsServiceProvider).activeLiveSession();
      state = AsyncData(next);
    } on Object {
      // Offline or transient — the next reconnect or poll tries again.
    }
  }
}
