import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/core/utils/formatters.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/application/line_up_list_controller.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/line_ups/domain/live_session.dart';
import 'package:daloy_flutter/features/line_ups/presentation/line_up_detail_screen.dart';
import 'package:daloy_flutter/features/line_ups/presentation/line_ups_screen.dart';
import 'package:daloy_flutter/features/sync/workspace_sync_controller.dart';
import 'package:daloy_flutter/shared/widgets/split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

class _NoLiveSession extends ActiveLiveSession {
  @override
  Future<LiveSession?> build() async => null;
}

class _IdleSync extends WorkspaceSync {
  @override
  WorkspaceSyncState build() => WorkspaceSyncState(status: SyncStatus.done, lastSyncedAt: DateTime(2026));
}

Future<void> _pump(WidgetTester tester, List<LineUp> lineUps) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        libraryLineUpsProvider.overrideWith((ref) => Stream.value(lineUps)),
        activeWorkspaceIdProvider.overrideWith((ref) => 1),
        workspaceSyncProvider.overrideWith(_IdleSync.new),
        isOnlineProvider.overrideWithValue(true),
        activeLiveSessionProvider.overrideWith(_NoLiveSession.new),
      ],
      child: MaterialApp(theme: DaloyTheme.light(), home: const LineUpsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows Coming up and month sections with today/tomorrow chips, no overflow', (tester) async {
    final now = DateTime.now();
    String day(int o) => isoDate(DateTime(now.year, now.month, now.day + o, 12));
    await _pump(tester, [
      LineUp(id: 1, title: '🙏 Sunday • Service', date: day(0), worshipLeader: '• Ana 🎶', songsCount: 4),
      LineUp(id: 2, title: 'Tomorrow set', date: day(1), songsCount: 0),
      LineUp(id: 3, title: 'Old one', date: day(-60), songsCount: 2),
    ]);

    // The filter pill and the section header.
    expect(find.text('Coming up'), findsNWidgets(2));
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('TOMORROW'), findsOneWidget);
    expect(find.text('🙏 Sunday • Service'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long agenda builds lazily', (tester) async {
    final lineUps = [for (var i = 0; i < 500; i++) LineUp(id: i, title: 'Set $i', date: '2020-01-01', songsCount: 1)];
    await _pump(tester, lineUps);
    expect(find.textContaining('Set ').evaluate().length, lessThan(20));
  });

  testWidgets('typing keeps focus while the list shrinks to nothing', (tester) async {
    late ProviderContainer container;
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final all = [for (var i = 0; i < 30; i++) LineUp(id: i, title: 'Set $i', date: '2020-01-01')];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryLineUpsProvider.overrideWith((ref) {
            final q = ref.watch(lineUpListControllerProvider);
            return Stream.value([
              for (final l in all)
                if (l.title.toLowerCase().contains(q.search.toLowerCase())) l,
            ]);
          }),
          activeWorkspaceIdProvider.overrideWith((ref) => 1),
          workspaceSyncProvider.overrideWith(_IdleSync.new),
          isOnlineProvider.overrideWithValue(true),
          activeLiveSessionProvider.overrideWith(_NoLiveSession.new),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(theme: DaloyTheme.light(), home: const LineUpsScreen());
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(container.read(lineUpListControllerProvider).search, 'zzz');
    expect(find.text('No line-ups match'), findsOneWidget);
    expect(tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus, isTrue);
  });

  testWidgets('a tablet in landscape opens a line-up beside the list, in one column', (tester) async {
    tester.view
      ..physicalSize = const Size(1366, 1024)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final today = todayIsoLocal();
    final lineUps = [for (var n = 1; n <= 6; n++) LineUp(id: n, title: 'Service $n', date: today, songsCount: 0)];
    // The pane builds the real line-up screen, which needs the app's storage.
    final container = await createTestContainer(
      FakeApiAdapter({}),
      overrides: [
        libraryLineUpsProvider.overrideWith((ref) => Stream.value(lineUps)),
        activeWorkspaceIdProvider.overrideWith((ref) => 1),
        workspaceSyncProvider.overrideWith(_IdleSync.new),
        isOnlineProvider.overrideWithValue(true),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: DaloyTheme.light(), home: const LineUpsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose a line-up'), findsOneWidget);
    await tester.tap(find.text('Service 2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(LineUpDetailScreen), findsOneWidget);
    expect(find.byType(SplitView), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
