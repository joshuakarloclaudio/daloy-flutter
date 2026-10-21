import 'dart:ui' show AppExitResponse;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../utils/platform.dart';

part 'app_database.g.dart';

/// The offline library — the Drift twin of the web's Dexie `db.ts`.
///
/// Screens read only from here (via `watch` streams), and sync controllers
/// write API results into it, so every screen works offline and updates
/// itself when a sync lands. Row classes end in `Row` to stay clear of the
/// freezed domain models they map to.

@DataClassName('SongRow')
@TableIndex(name: 'songs_workspace', columns: {#workspaceId})
class Songs extends Table {
  IntColumn get id => integer()();
  IntColumn get workspaceId => integer()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  TextColumn get key => text().nullable()();
  IntColumn get transposition => integer().nullable()();
  IntColumn get bpm => integer().nullable()();
  TextColumn get timeSignature => text().nullable()();
  TextColumn get content => text().nullable()();
  TextColumn get lyrics => text().nullable()();
  TextColumn get youtubeUrl => text().nullable()();
  TextColumn get spotifyUrl => text().nullable()();
  TextColumn get appleMusicUrl => text().nullable()();
  TextColumn get otherUrl => text().nullable()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();

  /// When it was last added to a line-up — the "Recently used" sort.
  DateTimeColumn get lastUsedAt => dateTime().nullable()();

  /// The server's version of this copy; a realtime ping with a higher one
  /// means it's out of date.
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// The server's last shared change: when, and who ([updatedById] and
  /// [updatedByName] both null when it doesn't know).
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get updatedById => integer().nullable()();
  TextColumn get updatedByName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Songs created on this device that the server hasn't confirmed yet. The
/// song itself sits in [Songs] under a negative [localId]; flushing swaps it
/// for the server's row. [error] is the last reason the server refused it.
@DataClassName('SongOutboxRow')
class SongOutbox extends Table {
  IntColumn get localId => integer()();
  IntColumn get workspaceId => integer()();
  TextColumn get error => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}

/// Songs changed on this device and not yet accepted by the server. The new
/// values already sit in [Songs]; flushing sends just the changed fields,
/// each with the value it started from, then drops the entry — unless it
/// changed again in flight.
@DataClassName('SongEditRow')
class SongEdits extends Table {
  IntColumn get songId => integer()();
  IntColumn get workspaceId => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Why the server last refused it (null: just waiting).
  TextColumn get error => text().nullable()();

  /// JSON `{api_field: value}`: each changed field as the server had it when
  /// this device first changed it. Null on rows queued before schema 10
  /// (they send the whole song, as they used to).
  TextColumn get base => text().nullable()();

  /// JSON `{api_field: value}`: fields the server refused because someone
  /// else changed them first — their value. Not sent until settled.
  TextColumn get conflicts => text().nullable()();

  @override
  Set<Column> get primaryKey => {songId};
}

/// This user's capo per song — a personal setting, so it is never part of
/// [Songs]. [dirty] marks a value the server hasn't confirmed yet.
@DataClassName('SongCapoRow')
class SongCapos extends Table {
  IntColumn get songId => integer()();
  IntColumn get capo => integer().withDefault(const Constant(0))();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {songId};
}

/// Upcoming line-ups a song is in, as last fetched. Replaced per song.
@DataClassName('SongUpcomingLineUpRow')
class SongUpcomingLineUps extends Table {
  IntColumn get songId => integer()();
  IntColumn get lineUpId => integer()();
  TextColumn get title => text()();

  /// `YYYY-MM-DD`.
  TextColumn get date => text()();

  @override
  Set<Column> get primaryKey => {songId, lineUpId};
}

/// How this device draws a chart. One row (id 1). [chordNotation] is null
/// until the user picks one, so the account's setting applies until then.
@DataClassName('DisplayPrefsRow')
class DisplayPrefs extends Table {
  IntColumn get id => integer()();

  /// `chords` | `lyrics`.
  TextColumn get viewMode => text().withDefault(const Constant('chords'))();

  /// Percent of the base size, 75–200.
  IntColumn get zoom => integer().withDefault(const Constant(100))();

  /// `letters` | `numbers`.
  TextColumn get chordNotation => text().nullable()();

  /// Perform's theme on this device (`PerformTheme.name`); null: follow the app.
  TextColumn get performTheme => text().nullable()();

  /// Perform hides its chrome after a few idle seconds.
  BoolColumn get performAutoHide => boolean().withDefault(const Constant(true))();

  /// Perform shows the team's notes in the chart.
  BoolColumn get performNotes => boolean().withDefault(const Constant(true))();

  /// In a live session, a follower who scrolled away goes back to the team
  /// after a few idle seconds.
  BoolColumn get liveAutoReturn => boolean().withDefault(const Constant(true))();

  /// Practice: the metronome clicks (off: the clock still runs, silently).
  BoolColumn get practiceClick => boolean().withDefault(const Constant(true))();

  /// Practice: a haptic tick on every beat, heavier on 1.
  BoolColumn get practiceHaptics => boolean().withDefault(const Constant(false))();

  /// Practice: the playing bar pulses on the beat.
  BoolColumn get practiceFlash => boolean().withDefault(const Constant(true))();

  /// Practice: bars counted in before Play starts (0: straight in).
  IntColumn get practiceCountIn => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('LineUpRow')
@TableIndex(name: 'line_ups_workspace', columns: {#workspaceId})
class LineUps extends Table {
  IntColumn get id => integer()();
  IntColumn get workspaceId => integer()();
  TextColumn get title => text()();

  /// `YYYY-MM-DD`, compared as text like the web does.
  TextColumn get date => text()();
  TextColumn get worshipLeader => text().nullable()();
  IntColumn get songsCount => integer().withDefault(const Constant(0))();

  /// The server's version (details, set, keys, notes, arrangement).
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// The [version] the cached songs came from; older: refetch the set.
  IntColumn get songsVersion => integer().nullable()();

  /// Whether [LineUpSongs] holds this line-up's songs. The list endpoint
  /// carries only a count, so songs arrive with the detail (or a local edit).
  BoolColumn get songsLoaded => boolean().withDefault(const Constant(false))();

  /// The server's last shared change: when, and who ([updatedById] and
  /// [updatedByName] both null when it doesn't know).
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get updatedById => integer().nullable()();
  TextColumn get updatedByName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A line-up's songs in order, as last fetched or as edited here. Titles and
/// keys come from [Songs] by [songId].
@DataClassName('LineUpSongRow')
class LineUpSongs extends Table {
  IntColumn get lineUpId => integer()();
  IntColumn get position => integer()();
  IntColumn get songId => integer()();
  IntColumn get transposition => integer().withDefault(const Constant(0))();

  /// The server's pivot id; null until the server has seen this entry.
  IntColumn get lineUpSongId => integer().nullable()();

  /// Team notes as the server's JSON list (`[{id, line, text}]`); null: none.
  TextColumn get notes => text().nullable()();

  /// The server's `section_arrangement` JSON; null: play as written.
  TextColumn get sectionArrangement => text().nullable()();

  @override
  Set<Column> get primaryKey => {lineUpId, position};
}

/// This user's capo for one song in one line-up. The server resolves it to
/// the line-up override or the song's default, so a row here is the answer.
/// [dirty]: changed here, not yet sent.
@DataClassName('LineUpSongCapoRow')
class LineUpSongCapos extends Table {
  IntColumn get lineUpSongId => integer()();
  IntColumn get lineUpId => integer()();
  IntColumn get capo => integer().withDefault(const Constant(0))();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {lineUpSongId};
}

/// Line-ups created or edited on this device that the server hasn't accepted
/// yet. The wanted state already sits in [LineUps] / [LineUpSongs]; flushing
/// sends it. A new line-up lives under a negative [lineUpId] until its POST
/// lands. [updatedAt] tells a save made mid-flush from the one that was sent.
@DataClassName('LineUpOutboxRow')
class LineUpOutbox extends Table {
  IntColumn get lineUpId => integer()();
  IntColumn get workspaceId => integer()();
  BoolColumn get isNew => boolean().withDefault(const Constant(false))();
  BoolColumn get detailsDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get songsDirty => boolean().withDefault(const Constant(false))();

  /// JSON list of the set's song ids as the server had them when [songsDirty]
  /// was first set — the set PUT's `base_song_ids`.
  TextColumn get baseSongIds => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Why the server last refused it (null: just waiting).
  TextColumn get error => text().nullable()();

  @override
  Set<Column> get primaryKey => {lineUpId};
}

/// Team notes and section arrangements changed on this device that the
/// server hasn't taken yet: one row per line-up song and [kind]. The wanted
/// value already sits in [LineUpSongs]; flushing sends it. Keyed by song, not
/// position or pivot: a song is in a line-up once, a reorder moves its
/// position, and the pivot isn't known until the server has seen the entry.
@DataClassName('LineUpPrepOutboxRow')
class LineUpPrepOutbox extends Table {
  IntColumn get lineUpId => integer()();
  IntColumn get songId => integer()();

  /// `note:<id>` (one note, added/edited or deleted), `notes` (the whole
  /// list, from before schema 10), or an arrangement view: `chords` / `lyrics`.
  TextColumn get kind => text()();
  DateTimeColumn get updatedAt => dateTime()();

  /// For an arrangement: JSON `{order, removed}` as the server had the view
  /// when this device first changed it — the PATCH's `base`.
  TextColumn get base => text().nullable()();

  /// Why the server last refused it (null: just waiting).
  TextColumn get error => text().nullable()();

  @override
  Set<Column> get primaryKey => {lineUpId, songId, kind};
}

@DataClassName('WorkspaceRow')
class Workspaces extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get role => text()();
  BoolColumn get isMember => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Device-local "Jump back in" history. Never synced.
@DataClassName('RecentSongAccessRow')
class RecentSongAccesses extends Table {
  IntColumn get songId => integer()();
  IntColumn get workspaceId => integer()();
  DateTimeColumn get lastAccessedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {songId};
}

/// Searches run on this device, newest first. Never synced.
@DataClassName('RecentSearchRow')
class RecentSearches extends Table {
  IntColumn get workspaceId => integer()();
  TextColumn get query => text()();
  DateTimeColumn get searchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {workspaceId, query};
}

/// Songs whose text changed since the search index last saw them. Filled by
/// triggers on [Songs] (see [SearchIndexSchema]), drained by `SearchIndex`,
/// which strips the chords in Dart and rewrites the FTS rows — so a song
/// save never waits on (or fails because of) the index.
@DataClassName('SongSearchQueueRow')
class SongSearchQueue extends Table {
  IntColumn get songId => integer()();

  @override
  Set<Column> get primaryKey => {songId};
}

/// When each workspace last finished a full sync.
@DataClassName('SyncMetaRow')
class SyncMetas extends Table {
  IntColumn get workspaceId => integer()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {workspaceId};
}

/// Analytics events waiting to be uploaded (the web's `analyticsEvents`).
/// Keyed by user and kept through sign-out, so a `logout` recorded offline
/// still goes up the next time that person signs in.
@DataClassName('AnalyticsQueueRow')
class AnalyticsQueue extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer()();
  TextColumn get name => text()();
  TextColumn get screen => text().nullable()();
  IntColumn get workspaceId => integer().nullable()();
  TextColumn get sessionId => text()();

  /// JSON object of flat values, or null.
  TextColumn get properties => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Songs,
    SongOutbox,
    SongEdits,
    SongCapos,
    SongUpcomingLineUps,
    DisplayPrefs,
    LineUps,
    LineUpSongs,
    LineUpSongCapos,
    LineUpOutbox,
    LineUpPrepOutbox,
    Workspaces,
    RecentSongAccesses,
    SyncMetas,
    RecentSearches,
    SongSearchQueue,
    AnalyticsQueue,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'daloy'));

  @override
  int get schemaVersion => 15;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await SearchIndexSchema.create(this);
    },
    // Bump schemaVersion and add steps here.
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(songOutbox);
      if (from < 3) {
        await m.createTable(songEdits);
        await m.createTable(songCapos);
        await m.createTable(songUpcomingLineUps);
        await m.createTable(displayPrefs);
      }
      if (from < 4) {
        await m.addColumn(lineUps, lineUps.songsLoaded);
        await m.createTable(lineUpSongs);
        await m.createTable(lineUpOutbox);
      }
      if (from < 5) {
        // A table made by the step above already has the column.
        if (from == 4) await m.addColumn(lineUpSongs, lineUpSongs.notes);
        await m.createTable(lineUpSongCapos);
      }
      if (from < 6) {
        if (from >= 4) await m.addColumn(lineUpSongs, lineUpSongs.sectionArrangement);
        if (from >= 3) {
          await m.addColumn(displayPrefs, displayPrefs.performTheme);
          await m.addColumn(displayPrefs, displayPrefs.performAutoHide);
          await m.addColumn(displayPrefs, displayPrefs.performNotes);
        }
      }
      if (from < 7 && from >= 3) await m.addColumn(displayPrefs, displayPrefs.liveAutoReturn);
      if (from < 8 && from >= 3) {
        await m.addColumn(displayPrefs, displayPrefs.practiceClick);
        await m.addColumn(displayPrefs, displayPrefs.practiceHaptics);
        await m.addColumn(displayPrefs, displayPrefs.practiceFlash);
      }
      if (from < 9) await m.createTable(lineUpPrepOutbox);
      if (from < 10) {
        await m.addColumn(songs, songs.version);
        if (from >= 3) {
          await m.addColumn(songEdits, songEdits.base);
          await m.addColumn(songEdits, songEdits.conflicts);
        }
        await m.addColumn(lineUps, lineUps.version);
        await m.addColumn(lineUps, lineUps.songsVersion);
        if (from >= 4) await m.addColumn(lineUpOutbox, lineUpOutbox.baseSongIds);
        if (from >= 9) await m.addColumn(lineUpPrepOutbox, lineUpPrepOutbox.base);
      }
      if (from < 11) {
        await m.createTable(recentSearches);
        await m.createTable(songSearchQueue);
        await SearchIndexSchema.create(this);
        // Every song already here goes through the indexer once.
        await customStatement('INSERT OR IGNORE INTO song_search_queue (song_id) SELECT id FROM songs');
      }
      if (from < 12) await m.createTable(analyticsQueue);
      if (from < 13) await m.addColumn(songs, songs.lastUsedAt);
      if (from < 14 && from >= 3) await m.addColumn(displayPrefs, displayPrefs.practiceCountIn);
      if (from < 15) {
        await m.addColumn(songs, songs.updatedAt);
        await m.addColumn(songs, songs.updatedById);
        await m.addColumn(songs, songs.updatedByName);
        await m.addColumn(lineUps, lineUps.updatedAt);
        await m.addColumn(lineUps, lineUps.updatedById);
        await m.addColumn(lineUps, lineUps.updatedByName);
      }
    },
  );

  Future<DateTime?> lastSyncedAt(int workspaceId) async {
    final row = await (select(syncMetas)..where((t) => t.workspaceId.equals(workspaceId))).getSingleOrNull();
    return row?.lastSyncedAt;
  }

  Future<void> markSynced(int workspaceId, DateTime at) =>
      into(syncMetas)
          .insertOnConflictUpdate(SyncMetasCompanion.insert(workspaceId: Value(workspaceId), lastSyncedAt: Value(at)));

  /// Wipes everything — on sign-out, so the next account starts clean. The
  /// analytics queue stays: its rows carry their user and wait for them.
  Future<void> clearAll() => transaction(() async {
    for (final table in allTables) {
      if (table == analyticsQueue) continue;
      await delete(table).go();
    }
    // Emptying songs queued each one for the indexer; the index goes too.
    await delete(songSearchQueue).go();
    await customStatement('DELETE FROM ${SearchIndexSchema.table}');
  });

  /// Changes made on this device that the server hasn't taken yet, in every
  /// workspace: what signing out or clearing would lose.
  Future<int> pendingChangeCount() async {
    final row = await customSelect(
      'SELECT (SELECT COUNT(*) FROM song_outbox) + (SELECT COUNT(*) FROM song_edits)'
      ' + (SELECT COUNT(*) FROM line_up_outbox) + (SELECT COUNT(*) FROM line_up_prep_outbox)'
      ' + (SELECT COUNT(*) FROM song_capos WHERE dirty) + (SELECT COUNT(*) FROM line_up_song_capos WHERE dirty) AS n',
    ).getSingle();
    return row.read<int>('n');
  }

  /// Workspaces with something in an outbox. Capos aren't kept per workspace;
  /// their flushes send all of them.
  Future<Set<int>> pendingWorkspaceIds() async {
    final rows = await customSelect(
      'SELECT workspace_id FROM song_outbox UNION SELECT workspace_id FROM song_edits'
      ' UNION SELECT workspace_id FROM line_up_outbox'
      ' UNION SELECT l.workspace_id FROM line_up_prep_outbox p JOIN line_ups l ON l.id = p.line_up_id',
    ).get();
    return {for (final row in rows) row.read<int>('workspace_id')};
  }

  /// Wipes the downloaded library of every workspace, keeping who's signed
  /// in: the workspace list, how this device draws a chart, and the
  /// analytics queue stay. Callers flush the outboxes first — this drops
  /// them. Without a sync time, the next sync is a first sync again.
  Future<void> clearLibrary() async {
    final keep = <TableInfo>{workspaces, displayPrefs, analyticsQueue};
    await transaction(() async {
      for (final table in allTables) {
        if (keep.contains(table)) continue;
        await delete(table).go();
      }
      await delete(songSearchQueue).go();
      await customStatement('DELETE FROM ${SearchIndexSchema.table}');
    });
    // Hand the freed pages back to the OS, so the space shows as free.
    await customStatement('VACUUM');
  }
}

/// The full-text index behind Search, outside Drift's table list because
/// Drift doesn't model FTS5 tables in Dart. One row per song, `rowid` = the
/// song id. `chords` is the chart with the chords taken out, so "amazing"
/// finds `A[G]mazing`; `remove_diacritics` lets "jesus" find "Jesús".
abstract final class SearchIndexSchema {
  static const table = 'song_search';

  static Future<void> create(GeneratedDatabase db) async {
    await db.customStatement(
      'CREATE VIRTUAL TABLE IF NOT EXISTS $table USING fts5('
      'workspace_id UNINDEXED, title, artist, chords, lyrics, '
      "tokenize = 'unicode61 remove_diacritics 2')",
    );
    // Not `INSERT OR IGNORE`: inside a trigger, the outer statement's
    // conflict clause wins, so a Drift upsert would turn a re-queue into a
    // failed song save. Checking first can't conflict at all.
    String queue(String row) =>
        'INSERT INTO song_search_queue (song_id) SELECT $row.id '
        'WHERE NOT EXISTS (SELECT 1 FROM song_search_queue WHERE song_id = $row.id);';
    await db.customStatement(
      'CREATE TRIGGER IF NOT EXISTS songs_search_insert AFTER INSERT ON songs BEGIN ${queue('new')} END',
    );
    await db.customStatement(
      'CREATE TRIGGER IF NOT EXISTS songs_search_update '
      'AFTER UPDATE OF title, artist, content, lyrics, workspace_id ON songs BEGIN ${queue('new')} END',
    );
    await db.customStatement(
      'CREATE TRIGGER IF NOT EXISTS songs_search_delete AFTER DELETE ON songs BEGIN ${queue('old')} END',
    );
  }
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  // Quitting a desktop app shuts Dart down, and SQLite's statement
  // finalizers then crash on the database isolate (EXC_BAD_ACCESS in
  // sqlite3_finalize on the Mac). Closing first leaves them nothing to
  // finalize. Phones are killed instead.
  if (isDesktop) {
    final exit = AppLifecycleListener(
      onExitRequested: () async {
        await db.close();
        return AppExitResponse.exit;
      },
    );
    ref.onDispose(exit.dispose);
  }
  return db;
}
