import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/storage/app_database.dart';
import '../../auth/application/session_controller.dart';
import '../../line_ups/domain/line_up.dart';
import '../chart/nashville.dart';
import '../domain/display_prefs.dart';
import '../domain/song.dart';
import '../domain/song_field.dart';
import '../domain/song_fields.dart';
import 'song_sync_activity.dart';
import 'songs_repository.dart';

part 'song_detail_repository.g.dart';

/// Everything the song details screen reads and writes, offline-first: the
/// screen only watches Drift, edits land there at once, and queued ones are
/// pushed when the network allows.
class SongDetailRepository {
  SongDetailRepository(this._db, this._service, [this._reporter]);

  final AppDatabase _db;
  final SongsService _service;
  final SongSyncReporter? _reporter;

  // -- The song ------------------------------------------------------------

  Stream<Song?> watchSong(int id) => (_db.select(_db.songs)..where((t) => t.id.equals(id))).watchSingleOrNull().map(
    (row) => row == null ? null : SongsRepository.songFromRow(row),
  );

  /// The song as it is on this device right now (a one-shot read).
  Future<Song?> loadSong(int id) async {
    final row = await (_db.select(_db.songs)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : SongsRepository.songFromRow(row);
  }

  /// Saves a new transposition on this device and queues it for the server.
  Future<void> setTransposition(int songId, int transposition, {DateTime? now}) =>
      _edit(songId, (s) => s.copyWith(transposition: transposition), now: now);

  /// Saves a tempo and/or time signature on this device and queues them for
  /// the server (Practice's "Save to song").
  Future<void> setTempo(int songId, {int? bpm, String? timeSignature, DateTime? now}) {
    if (bpm == null && timeSignature == null) return Future.value();
    return _edit(
      songId,
      (s) => s.copyWith(bpm: bpm ?? s.bpm, timeSignature: timeSignature ?? s.timeSignature),
      now: now,
    );
  }

  /// Saves a song's YouTube link on this device and queues it for the server
  /// (from the player's queue). Every line-up using the song picks it up
  /// from Drift.
  Future<void> setYoutubeUrl(int songId, String url, {DateTime? now}) =>
      _edit(songId, (s) => s.copyWith(youtubeUrl: url), now: now);

  /// Saves new lyrics on this device and queues them for the server
  /// (Present's section editor, a line-up's quick edit). Every line-up using
  /// the song picks them up. Blank clears them.
  Future<void> setLyrics(int songId, String lyrics, {DateTime? now}) =>
      _edit(songId, (s) => s.copyWith(lyrics: lyrics.trim().isEmpty ? null : lyrics), now: now);

  /// Saves a new chart on this device and queues it for the server (a
  /// line-up's quick edit). Blank clears it.
  Future<void> setChords(int songId, String content, {DateTime? now}) =>
      _edit(songId, (s) => s.copyWith(content: content.trim().isEmpty ? null : content), now: now);

  /// Saves the edit screen's fields on this device and queues the ones that
  /// changed. Never waits on the network.
  Future<void> saveFields(int songId, SongFields fields, {DateTime? now}) => _edit(songId, fields.applyTo, now: now);

  /// Writes [change] over the song on this device and queues the fields it
  /// changed, each with the value it started from (a field already queued
  /// keeps its first). Changing a field in conflict keeps this device's
  /// value: the next send overwrites theirs. A field put back to where it
  /// started has nothing left to send.
  Future<void> _edit(int songId, Song Function(Song before) change, {DateTime? now}) => _db.transaction(() async {
    final row = await (_db.select(_db.songs)..where((t) => t.id.equals(songId))).getSingleOrNull();
    if (row == null) return;
    final before = SongsRepository.songFromRow(row);
    final after = change(before);
    final changed = changedSongFields(before, after);
    if (changed.isEmpty) return;

    await (_db.update(_db.songs)..where((t) => t.id.equals(songId))).write(_fieldsOf(after));

    final existing = await _editRow(songId);
    final legacy = existing != null && existing.base == null;
    final base = SongsRepository.decodeFields(existing?.base);
    final conflicts = SongsRepository.decodeFields(existing?.conflicts);
    for (final f in changed) {
      if (conflicts.containsKey(f.api)) {
        base[f.api] = conflicts.remove(f.api);
      } else {
        base.putIfAbsent(f.api, () => f.read(before));
      }
    }
    base.removeWhere((api, v) => sameSongValue(SongField.byApi(api)?.read(after), v));

    if (!legacy && base.isEmpty && conflicts.isEmpty) {
      await (_db.delete(_db.songEdits)..where((t) => t.songId.equals(songId))).go();
      return;
    }
    await _db
        .into(_db.songEdits)
        .insertOnConflictUpdate(
          SongEditsCompanion.insert(
            songId: Value(songId),
            workspaceId: row.workspaceId,
            updatedAt: now ?? DateTime.now(),
            base: Value(legacy ? null : SongsRepository.encodeFields(base) ?? '{}'),
            conflicts: Value(SongsRepository.encodeFields(conflicts)),
            error: Value(conflicts.isEmpty ? null : existing?.error),
          ),
        );
  });

  Future<SongEditRow?> _editRow(int songId) =>
      (_db.select(_db.songEdits)..where((t) => t.songId.equals(songId))).getSingleOrNull();

  static SongsCompanion _fieldsOf(Song s) => SongsCompanion(
    title: Value(s.title),
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
  );

  /// Fields the server refused because they changed elsewhere first, with
  /// the other side's value. Empty when there are none.
  Stream<Map<SongField, Object?>> watchConflicts(int songId) =>
      (_db.select(_db.songEdits)..where((t) => t.songId.equals(songId))).watchSingleOrNull().map((row) {
        return {
          for (final MapEntry(:key, :value) in SongsRepository.decodeFields(row?.conflicts).entries)
            ?SongField.byApi(key): value,
        };
      });

  /// Settles a conflict for this device's value: theirs becomes the base, so
  /// the next send overwrites it.
  Future<void> keepMine(int songId, SongField field) => _db.transaction(() async {
    final edit = await _editRow(songId);
    if (edit == null) return;
    final conflicts = SongsRepository.decodeFields(edit.conflicts);
    if (!conflicts.containsKey(field.api)) return;
    final base = SongsRepository.decodeFields(edit.base)..[field.api] = conflicts.remove(field.api);
    await (_db.update(_db.songEdits)..where((t) => t.songId.equals(songId))).write(
      SongEditsCompanion(
        base: Value(SongsRepository.encodeFields(base) ?? '{}'),
        conflicts: Value(SongsRepository.encodeFields(conflicts)),
        error: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  });

  /// Settles a conflict for the other side's value.
  Future<void> takeTheirs(int songId, SongField field) => _db.transaction(() async {
    final edit = await _editRow(songId);
    final row = await (_db.select(_db.songs)..where((t) => t.id.equals(songId))).getSingleOrNull();
    if (edit == null || row == null) return;
    final conflicts = SongsRepository.decodeFields(edit.conflicts);
    if (!conflicts.containsKey(field.api)) return;
    final theirs = conflicts.remove(field.api);
    final base = SongsRepository.decodeFields(edit.base)..remove(field.api);
    await (_db.update(
      _db.songs,
    )..where((t) => t.id.equals(songId))).write(_fieldsOf(field.write(SongsRepository.songFromRow(row), theirs)));
    if (base.isEmpty && conflicts.isEmpty) {
      await (_db.delete(_db.songEdits)..where((t) => t.songId.equals(songId))).go();
      return;
    }
    await (_db.update(_db.songEdits)..where((t) => t.songId.equals(songId))).write(
      SongEditsCompanion(
        base: Value(SongsRepository.encodeFields(base) ?? '{}'),
        conflicts: Value(SongsRepository.encodeFields(conflicts)),
        error: Value(conflicts.isEmpty ? null : edit.error),
      ),
    );
  });

  /// Songs with a change the server hasn't seen yet, and why the last
  /// attempt failed (null: just waiting).
  Stream<Map<int, String?>> watchPendingEdits(int workspaceId) => (_db.select(
    _db.songEdits,
  )..where((t) => t.workspaceId.equals(workspaceId))).watch().map((rows) => {for (final r in rows) r.songId: r.error});

  // -- Capo (per user, per song) -------------------------------------------

  Stream<int> watchCapo(int songId) => (_db.select(
    _db.songCapos,
  )..where((t) => t.songId.equals(songId))).watchSingleOrNull().map((row) => row?.capo ?? 0);

  /// Applies at once; the server catches up now if it can, else in [flush].
  Future<void> setCapo(int songId, int capo) async {
    await _db
        .into(_db.songCapos)
        .insertOnConflictUpdate(
          SongCaposCompanion.insert(songId: Value(songId), capo: Value(capo), dirty: const Value(true)),
        );
    await _pushCapo(songId);
  }

  Future<void> _pushCapo(int songId) async {
    final row = await (_db.select(_db.songCapos)..where((t) => t.songId.equals(songId))).getSingleOrNull();
    if (row == null || !row.dirty) return;
    try {
      await _service.setCapo(songId, row.capo);
    } on ApiException {
      return; // Stays dirty; retried on the next flush.
    }
    // Only clean if nobody changed it while the request was out.
    final now = await (_db.select(_db.songCapos)..where((t) => t.songId.equals(songId))).getSingleOrNull();
    if (now != null && now.capo == row.capo) {
      await (_db.update(
        _db.songCapos,
      )..where((t) => t.songId.equals(songId))).write(const SongCaposCompanion(dirty: Value(false)));
    }
  }

  /// Mirrors the account's capo onto this device, unless a local change is
  /// still waiting to be sent. Quiet when offline.
  Future<void> refreshCapo(int songId) async {
    final int remote;
    try {
      remote = await _service.capo(songId);
    } on ApiException {
      return;
    }
    final row = await (_db.select(_db.songCapos)..where((t) => t.songId.equals(songId))).getSingleOrNull();
    if (row?.dirty ?? false) return;
    await _db
        .into(_db.songCapos)
        .insertOnConflictUpdate(SongCaposCompanion.insert(songId: Value(songId), capo: Value(remote)));
  }

  /// My capo changed on another of my devices. A change made here and not
  /// yet sent wins.
  Future<void> applyRemoteCapo(int songId, int capo) => _db.transaction(() async {
    final row = await (_db.select(_db.songCapos)..where((t) => t.songId.equals(songId))).getSingleOrNull();
    if (row?.dirty ?? false) return;
    await _db
        .into(_db.songCapos)
        .insertOnConflictUpdate(SongCaposCompanion.insert(songId: Value(songId), capo: Value(capo)));
  });

  // -- Upcoming line-ups ---------------------------------------------------

  Stream<List<LineUp>> watchUpcomingLineUps(int songId) =>
      (_db.select(_db.songUpcomingLineUps)
            ..where((t) => t.songId.equals(songId))
            ..orderBy([(t) => OrderingTerm.asc(t.date), (t) => OrderingTerm.asc(t.lineUpId)]))
          .watch()
          .map((rows) => [for (final r in rows) LineUp(id: r.lineUpId, title: r.title, date: r.date)]);

  /// Quiet when offline: the last list stays.
  Future<void> refreshUpcomingLineUps(int songId) async {
    final List<LineUp> lineUps;
    try {
      lineUps = await _service.upcomingLineUps(songId);
    } on ApiException {
      return;
    }
    await _db.transaction(() async {
      await (_db.delete(_db.songUpcomingLineUps)..where((t) => t.songId.equals(songId))).go();
      await _db.batch(
        (b) => b.insertAll(_db.songUpcomingLineUps, [
          for (final l in lineUps)
            SongUpcomingLineUpsCompanion.insert(songId: songId, lineUpId: l.id, title: l.title, date: l.date),
        ]),
      );
    });
  }

  // -- Pushing queued changes ----------------------------------------------

  bool _flushing = false;

  /// Sends queued transposition edits, then dirty capos. Stops at the first
  /// network failure; a refusal keeps its error and is retried next time.
  Future<void> flush(int workspaceId) async {
    if (_flushing) return;
    _flushing = true;
    try {
      final edits =
          await (_db.select(_db.songEdits)
                ..where((t) => t.workspaceId.equals(workspaceId))
                ..orderBy([(t) => OrderingTerm.asc(t.updatedAt)]))
              .get();
      for (final edit in edits) {
        if (!await _pushEdit(edit)) return;
      }
      for (final capo in await (_db.select(_db.songCapos)..where((t) => t.dirty.equals(true))).get()) {
        await _pushCapo(capo.songId);
      }
    } finally {
      _flushing = false;
    }
  }

  /// `false` when the queue should stop (offline). Sends the queued fields
  /// with their bases; fields in conflict wait for the user.
  Future<bool> _pushEdit(SongEditRow edit) async {
    final row = await (_db.select(_db.songs)..where((t) => t.id.equals(edit.songId))).getSingleOrNull();
    // Deleted, or never reached the server: nothing to send.
    if (row == null || row.id < 0) {
      await (_db.delete(_db.songEdits)..where((t) => t.songId.equals(edit.songId))).go();
      return true;
    }
    final song = SongsRepository.songFromRow(row);
    final legacy = edit.base == null;
    final base = SongsRepository.decodeFields(edit.base);
    final waiting = SongsRepository.decodeFields(edit.conflicts);
    final fields = [
      for (final f in legacy ? SongField.values : base.keys.map(SongField.byApi).nonNulls)
        if (!waiting.containsKey(f.api)) f,
    ];
    if (fields.isEmpty) return true;

    final sent = {for (final f in fields) f.api: f.read(song)};
    var synced = false;
    _reporter?.sending(edit.songId);
    try {
      final server = await _service.change(edit.songId, sent, {
        if (!legacy)
          for (final f in fields) f.api: base[f.api],
      });
      synced = await _settle(edit, fields, sent, server, const {});
      return true;
    } on ApiConflictException catch (e) {
      final data = e.data;
      if (data is! Map || data['song'] is! Map) {
        await _markError(edit.songId, e.message);
        return true;
      }
      final server = Song.fromJson((data['song'] as Map).cast<String, dynamic>());
      final refused = {for (final name in (data['conflicts'] as List? ?? const [])) ?SongField.byApi('$name')};
      await _settle(edit, fields, sent, server, refused);
      return true;
    } on NetworkException {
      return false;
    } on ApiException catch (e) {
      await _markError(edit.songId, e.message);
      return true;
    } finally {
      _reporter?.finished(edit.songId, synced: synced);
    }
  }

  /// After a send: sent fields are done (or, if edited again in flight,
  /// re-based on the server's value); [refused] ones become conflicts. The
  /// server's copy is written, keeping what's still pending here. True when
  /// nothing is left to send.
  ///
  /// "Edited again" compares against [values], what went out, not the
  /// server's reply: the server may normalize a value (Laravel trims
  /// strings), and that must not read as a newer local edit or the field is
  /// re-sent forever.
  Future<bool> _settle(
    SongEditRow sent,
    List<SongField> fields,
    Map<String, Object?> values,
    Song server,
    Set<SongField> refused,
  ) => _db.transaction(() async {
    final current = await _editRow(sent.songId);
    final row = await (_db.select(_db.songs)..where((t) => t.id.equals(sent.songId))).getSingleOrNull();
    if (row == null) return true;
    final local = SongsRepository.songFromRow(row);
    final base = SongsRepository.decodeFields(current?.base);
    final conflicts = SongsRepository.decodeFields(current?.conflicts);

    for (final f in fields) {
      if (refused.contains(f)) {
        base.remove(f.api);
        conflicts[f.api] = f.read(server);
      } else if (sameSongValue(f.read(local), values[f.api])) {
        base.remove(f.api);
      } else {
        // Edited again while the request was out: what it changes from now.
        base[f.api] = f.read(server);
      }
    }

    var merged = server;
    for (final api in [...base.keys, ...conflicts.keys]) {
      if (SongField.byApi(api) case final f?) merged = f.write(merged, f.read(local));
    }
    await _db.into(_db.songs).insertOnConflictUpdate(SongsRepository.songCompanion(merged, row.workspaceId));

    if (base.isEmpty && conflicts.isEmpty) {
      await (_db.delete(_db.songEdits)..where((t) => t.songId.equals(sent.songId))).go();
      return true;
    }
    await _db
        .into(_db.songEdits)
        .insertOnConflictUpdate(
          SongEditsCompanion.insert(
            songId: Value(sent.songId),
            workspaceId: row.workspaceId,
            updatedAt: current?.updatedAt ?? sent.updatedAt,
            base: Value(SongsRepository.encodeFields(base) ?? '{}'),
            conflicts: Value(SongsRepository.encodeFields(conflicts)),
            error: Value(conflicts.isEmpty ? null : 'Changed on another device'),
          ),
        );
    return false;
  });

  Future<void> _markError(int songId, String message) => (_db.update(
    _db.songEdits,
  )..where((t) => t.songId.equals(songId))).write(SongEditsCompanion(error: Value(message)));

  // -- Display preferences -------------------------------------------------

  Stream<ChartPrefs> watchPrefs() =>
      (_db.select(_db.displayPrefs)..where((t) => t.id.equals(1))).watchSingleOrNull().map(
        (row) => row == null
            ? const ChartPrefs()
            : ChartPrefs(
                viewMode: SongViewMode.parse(row.viewMode),
                zoom: ChartPrefs.clampZoom(row.zoom),
                notation: row.chordNotation == null ? null : ChordNotation.parse(row.chordNotation),
              ),
      );

  Future<void> _writePrefs(DisplayPrefsCompanion change) async {
    final updated = await (_db.update(_db.displayPrefs)..where((t) => t.id.equals(1))).write(change);
    if (updated == 0) await _db.into(_db.displayPrefs).insert(change.copyWith(id: const Value(1)));
  }

  Future<void> setViewMode(SongViewMode mode) => _writePrefs(DisplayPrefsCompanion(viewMode: Value(mode.name)));

  Future<void> setZoom(int zoom) => _writePrefs(DisplayPrefsCompanion(zoom: Value(ChartPrefs.clampZoom(zoom))));

  Future<void> setNotation(ChordNotation notation) =>
      _writePrefs(DisplayPrefsCompanion(chordNotation: Value(notation.name)));
}

@Riverpod(keepAlive: true)
SongDetailRepository songDetailRepository(Ref ref) => SongDetailRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(songsRepositoryProvider).service,
  ref.watch(songSyncActivityProvider.notifier),
);

@riverpod
Stream<Song?> songById(Ref ref, int id) => ref.watch(songDetailRepositoryProvider).watchSong(id);

@riverpod
Stream<int> songCapo(Ref ref, int songId) => ref.watch(songDetailRepositoryProvider).watchCapo(songId);

@riverpod
Stream<List<LineUp>> songUpcomingLineUps(Ref ref, int songId) =>
    ref.watch(songDetailRepositoryProvider).watchUpcomingLineUps(songId);

@riverpod
Stream<ChartPrefs> chartPrefs(Ref ref) => ref.watch(songDetailRepositoryProvider).watchPrefs();

@riverpod
Stream<Map<int, String?>> pendingSongEdits(Ref ref) {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return Stream.value(const {});
  return ref.watch(songDetailRepositoryProvider).watchPendingEdits(id);
}

/// Fields of this song the server refused (changed elsewhere first): theirs.
@riverpod
Stream<Map<SongField, Object?>> songConflicts(Ref ref, int songId) =>
    ref.watch(songDetailRepositoryProvider).watchConflicts(songId);
