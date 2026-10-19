import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/connectivity/online_status.dart';
import '../../core/network/api_exception.dart';
import '../../core/storage/app_database.dart';
import '../auth/application/session_controller.dart';
import '../line_ups/data/line_ups_repository.dart';
import '../songs/data/song_detail_repository.dart';
import '../songs/data/songs_repository.dart';
import '../workspaces/data/workspaces_repository.dart';

part 'workspace_sync_controller.freezed.dart';
part 'workspace_sync_controller.g.dart';

enum SyncStatus { idle, syncing, done, error }

@freezed
abstract class WorkspaceSyncState with _$WorkspaceSyncState {
  const WorkspaceSyncState._();

  const factory WorkspaceSyncState({
    @Default(SyncStatus.idle) SyncStatus status,
    DateTime? lastSyncedAt,
    String? errorMessage,
  }) = _WorkspaceSyncState;

  bool get isSyncing => status == SyncStatus.syncing;

  /// First sync for this workspace on this device — nothing cached to show.
  bool get isInitialSync => isSyncing && lastSyncedAt == null;
}

/// Pulls the active workspace's library into Drift: on sign-in, on workspace
/// switch, on reconnect, and on pull-to-refresh. Screens never wait on it —
/// they watch Drift and update when the write lands.
@Riverpod(keepAlive: true)
class WorkspaceSync extends _$WorkspaceSync {
  bool _running = false;

  @override
  WorkspaceSyncState build() {
    final workspaceId = ref.watch(activeWorkspaceIdProvider);
    final online = ref.watch(isOnlineProvider);
    if (workspaceId == null) return const WorkspaceSyncState();

    if (online) Future.microtask(refresh);
    return const WorkspaceSyncState(status: SyncStatus.syncing);
  }

  Future<void> refresh() async {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId == null || _running) return;
    _running = true;

    final db = ref.read(appDatabaseProvider);
    try {
      final lastSyncedAt = await db.lastSyncedAt(workspaceId);
      state = state.copyWith(status: SyncStatus.syncing, lastSyncedAt: lastSyncedAt, errorMessage: null);

      // Push first so a song made offline is on the server before the pull.
      await ref.read(songsRepositoryProvider).flushOutbox(workspaceId);
      await ref.read(songDetailRepositoryProvider).flush(workspaceId);
      // After songs, so a line-up never points at a song the server lacks.
      await ref.read(lineUpsRepositoryProvider).flushOutbox(workspaceId);

      await Future.wait([
        ref.read(workspacesRepositoryProvider).sync(),
        ref.read(songsRepositoryProvider).sync(workspaceId),
        ref.read(lineUpsRepositoryProvider).sync(workspaceId),
      ]);

      final now = DateTime.now();
      await db.markSynced(workspaceId, now);
      if (ref.mounted) state = WorkspaceSyncState(status: SyncStatus.done, lastSyncedAt: now);
    } on ApiException catch (error) {
      if (ref.mounted) state = state.copyWith(status: SyncStatus.error, errorMessage: error.message);
    } finally {
      _running = false;
    }
  }
}
