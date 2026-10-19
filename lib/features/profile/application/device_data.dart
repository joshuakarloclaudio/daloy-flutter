import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/app_database.dart';
import '../../auth/application/session_controller.dart';
import '../../line_ups/data/line_ups_repository.dart';
import '../../songs/data/song_detail_repository.dart';
import '../../songs/data/songs_repository.dart';
import '../../sync/workspace_sync_controller.dart';

part 'device_data.g.dart';

/// Where the database's bytes go. [other] holds the workspace list,
/// preferences and the file's free pages.
class StorageBreakdown {
  const StorageBreakdown({this.songs = 0, this.lineUps = 0, this.search = 0, this.other = 0});

  final int songs;
  final int lineUps;
  final int search;
  final int other;

  int get total => songs + lineUps + search + other;
}

/// What this device holds, across every workspace it has opened.
class DeviceData {
  const DeviceData({
    required this.songs,
    required this.lineUps,
    required this.workspaces,
    required this.pendingChanges,
    required this.storage,
  });

  final int songs;
  final int lineUps;

  /// Workspaces with songs or line-ups here.
  final int workspaces;
  final int pendingChanges;
  final StorageBreakdown storage;
}

/// [DeviceData], read again shortly after any write settles, so the numbers
/// climb while a workspace downloads.
@riverpod
Stream<DeviceData> deviceData(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final controller = StreamController<DeviceData>();
  Timer? timer;

  Future<void> read() async {
    final data = await _readDeviceData(db);
    if (!controller.isClosed) controller.add(data);
  }

  final sub = db.tableUpdates().listen((_) {
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 300), () => unawaited(read()));
  });
  unawaited(read());
  ref.onDispose(() {
    timer?.cancel();
    unawaited(sub.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
}

Future<DeviceData> _readDeviceData(AppDatabase db) async {
  final counts = await db
      .customSelect(
        'SELECT (SELECT COUNT(*) FROM songs) AS songs, (SELECT COUNT(*) FROM line_ups) AS line_ups,'
        ' (SELECT COUNT(*) FROM (SELECT workspace_id FROM songs UNION SELECT workspace_id FROM line_ups)) AS workspaces',
      )
      .getSingle();
  return DeviceData(
    songs: counts.read<int>('songs'),
    lineUps: counts.read<int>('line_ups'),
    workspaces: counts.read<int>('workspaces'),
    pendingChanges: await db.pendingChangeCount(),
    storage: await _storage(db),
  );
}

/// Bytes per kind of table, from SQLite's `dbstat` (indexes count toward
/// their table). Falls back to the file's size alone if `dbstat` is missing.
Future<StorageBreakdown> _storage(AppDatabase db) async {
  final total =
      (await db
              .customSelect('SELECT page_count * page_size AS bytes FROM pragma_page_count(), pragma_page_size()')
              .getSingle())
          .read<int>('bytes');
  final List<({String name, int bytes})> tables;
  try {
    final rows = await db
        .customSelect(
          'SELECT m.tbl_name AS name, SUM(s.pgsize) AS bytes FROM dbstat s '
          'JOIN sqlite_master m ON m.name = s.name GROUP BY m.tbl_name',
        )
        .get();
    tables = [for (final r in rows) (name: r.read<String>('name'), bytes: r.read<int>('bytes'))];
  } on Object {
    return StorageBreakdown(other: total);
  }
  var songs = 0, lineUps = 0, search = 0;
  for (final (:name, :bytes) in tables) {
    // The FTS index's shadow tables are all `song_search_*`.
    if (name.startsWith(SearchIndexSchema.table) || name == 'recent_searches') {
      search += bytes;
    } else if (name.startsWith('line_up')) {
      lineUps += bytes;
    } else if (name.startsWith('song') || name == 'recent_song_accesses') {
      songs += bytes;
    }
  }
  final other = total - songs - lineUps - search;
  return StorageBreakdown(songs: songs, lineUps: lineUps, search: search, other: other < 0 ? 0 : other);
}

enum ClearPhase { idle, sending, clearing }

enum ClearOutcome {
  cleared,

  /// Nothing to download the workspace again with, so nothing was cleared.
  offline,

  /// Changes made here wouldn't go; clearing would have lost them.
  unsynced,
}

/// Clearing the downloaded library. Changes made here go to the server
/// first, and the active workspace downloads again straight after.
@riverpod
class DeviceDataClear extends _$DeviceDataClear {
  @override
  ClearPhase build() => ClearPhase.idle;

  /// With [ClearOutcome.unsynced], `pending` is how many changes stayed.
  Future<({ClearOutcome outcome, int pending})> clear() async {
    if (!ref.read(isOnlineProvider)) return (outcome: ClearOutcome.offline, pending: 0);
    final db = ref.read(appDatabaseProvider);
    final songs = ref.read(songsRepositoryProvider);
    final songDetail = ref.read(songDetailRepositoryProvider);
    final lineUps = ref.read(lineUpsRepositoryProvider);
    final workspaceId = ref.read(activeWorkspaceIdProvider);

    state = ClearPhase.sending;
    try {
      // In the sync's order: songs before the line-ups that point at them.
      for (final id in {...await db.pendingWorkspaceIds(), ?workspaceId}) {
        await _attempt(() => songs.flushOutbox(id));
        await _attempt(() => songDetail.flush(id));
        await _attempt(() => lineUps.flushOutbox(id));
      }
      await _attempt(lineUps.flushCapos);

      final pending = await db.pendingChangeCount();
      if (pending > 0) return (outcome: ClearOutcome.unsynced, pending: pending);

      state = ClearPhase.clearing;
      await db.clearLibrary();
      if (ref.mounted) unawaited(ref.read(workspaceSyncProvider.notifier).refresh());
      return (outcome: ClearOutcome.cleared, pending: 0);
    } finally {
      if (ref.mounted) state = ClearPhase.idle;
    }
  }

  /// A refusal stays in its outbox, and the count afterwards says so.
  Future<void> _attempt(Future<void> Function() flush) async {
    try {
      await flush();
    } on ApiException {
      // Counted below.
    }
  }
}
