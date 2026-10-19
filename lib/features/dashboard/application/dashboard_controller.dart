import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/application/session_controller.dart';
import '../../line_ups/data/line_ups_repository.dart';
import '../../line_ups/domain/line_up.dart';
import '../../line_ups/domain/live_session.dart';
import '../../songs/data/songs_repository.dart';
import '../../songs/domain/song.dart';
import '../../sync/workspace_sync_controller.dart';
import '../../workspaces/data/workspaces_repository.dart';

part 'dashboard_controller.freezed.dart';
part 'dashboard_controller.g.dart';

const _recentLimit = 5;

@freezed
abstract class DashboardState with _$DashboardState {
  const DashboardState._();

  const factory DashboardState({
    int? workspaceId,
    String? workspaceName,
    String? userName,
    @Default(true) bool isOnline,
    @Default(false) bool showSkeletons,
    @Default(false) bool isSyncing,
    LiveSession? liveSession,
    LineUp? liveSessionLineUp,
    @Default(false) bool isLiveSessionLoading,
    LineUp? featuredLineUp,
    @Default([]) List<LineUp> recentLineUps,
    @Default([]) List<Song> recentSongs,
    @Default([]) List<Song> jumpBackInSongs,
  }) = _DashboardState;

  // `this.isOnline` / `this.recentSongs`: freezed fields live on the mixin,
  // so the bare names resolve to the same-named top-level providers.
  String get displayName => userName == null ? 'there' : firstName(userName!);

  bool get showLiveSection => this.isOnline && (isLiveSessionLoading || liveSession != null);

  String get subtitle {
    if (liveSession != null && this.isOnline) return "A performance is live — join when you're ready.";
    if (featuredLineUp case final featured?) {
      return switch (lineUpDayChip(featured.date)) {
        DayChip.today => '“${featured.title}” is happening today.',
        DayChip.tomorrow => '“${featured.title}” is tomorrow.',
        null => 'Next up on ${formatLineUpDate(featured.date)}.',
      };
    }
    if (!showSkeletons && (this.recentSongs.isNotEmpty || recentLineUps.isNotEmpty)) {
      return "Here's what's recent in your library.";
    }
    return 'Plan songs and line-ups so your team is ready to perform.';
  }
}

/// All of Home's state and actions — the twin of `use-dashboard-page.ts`.
/// Everything is read from Drift (works offline) except the live session,
/// which is polled from the network.
@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardState build() {
    final session = ref.watch(sessionControllerProvider).value;
    final workspaceId = session?.workspaceId;
    final isOnline = ref.watch(isOnlineProvider);
    final sync = ref.watch(workspaceSyncProvider);
    final lineUps = ref.watch(workspaceLineUpsProvider);
    final recentSongs = ref.watch(recentSongsProvider);
    final jumpBackIn = ref.watch(recentlyOpenedSongsProvider);
    final workspace = ref.watch(activeWorkspaceProvider).value;
    final live = ref.watch(activeLiveSessionProvider);

    final liveSession = isOnline ? live.value : null;
    final allLineUps = lineUps.value ?? const <LineUp>[];

    // Earliest upcoming set; hidden while that same set is live (it's
    // already the card above).
    final today = todayIsoLocal();
    final upcoming = allLineUps.where((l) => l.date.compareTo(today) >= 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date) != 0 ? a.date.compareTo(b.date) : a.id - b.id);
    final next = upcoming.firstOrNull;
    final featured = next != null && liveSession?.lineUpId == next.id ? null : next;

    final dataReady = lineUps.hasValue && recentSongs.hasValue;

    return DashboardState(
      workspaceId: workspaceId,
      workspaceName: workspace?.name,
      userName: session?.user.name,
      isOnline: isOnline,
      isSyncing: sync.isSyncing,
      showSkeletons: workspaceId != null && (!dataReady || sync.isInitialSync),
      liveSession: liveSession,
      liveSessionLineUp: liveSession == null ? null : allLineUps.where((l) => l.id == liveSession.lineUpId).firstOrNull,
      isLiveSessionLoading: isOnline && workspaceId != null && live.isLoading && !live.hasValue,
      featuredLineUp: featured,
      recentLineUps: allLineUps.where((l) => l.id != next?.id).take(_recentLimit).toList(),
      recentSongs: recentSongs.value ?? const [],
      jumpBackInSongs: jumpBackIn.value ?? const [],
    );
  }

  Future<void> refresh() async {
    ref.invalidate(activeLiveSessionProvider);
    await ref.read(workspaceSyncProvider.notifier).refresh();
  }

  Future<void> recordSongOpened(Song song) async {
    final workspaceId = state.workspaceId;
    if (workspaceId == null) return;
    await ref.read(songsRepositoryProvider).recordOpened(song.id, workspaceId);
  }
}
