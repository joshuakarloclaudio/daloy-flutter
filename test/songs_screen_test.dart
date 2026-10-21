import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/songs/application/song_list_controller.dart';
import 'package:daloy_flutter/features/songs/domain/song.dart';
import 'package:daloy_flutter/features/songs/presentation/song_detail_screen.dart';
import 'package:daloy_flutter/features/songs/presentation/songs_screen.dart';
import 'package:daloy_flutter/features/songs/presentation/widgets/alphabet_rail.dart';
import 'package:daloy_flutter/features/sync/workspace_sync_controller.dart';
import 'package:daloy_flutter/shared/widgets/split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

class _IdleSync extends WorkspaceSync {
  @override
  WorkspaceSyncState build() => WorkspaceSyncState(status: SyncStatus.done, lastSyncedAt: DateTime(2026));
}

void main() {
  testWidgets('a long alphabetical library builds lazily, pins letters and jumps from the rail', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final letters = List.generate(26, (i) => String.fromCharCode(65 + i));
    final songs = [
      for (final l in letters)
        for (var n = 0; n < 40; n++) Song(id: letters.indexOf(l) * 100 + n, title: '$l song $n', key: 'G'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          librarySongsProvider.overrideWith((ref) => Stream.value(songs)),
          activeWorkspaceIdProvider.overrideWith((ref) => 1),
          workspaceSyncProvider.overrideWith(_IdleSync.new),
          isOnlineProvider.overrideWithValue(true),
        ],
        child: MaterialApp(theme: DaloyTheme.light(), home: const SongsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // 1,040 songs, but only the visible rows exist.
    expect(find.text('A song 0'), findsOneWidget);
    expect(find.textContaining(' song ').evaluate().length, lessThan(20));
    expect(find.byType(AlphabetRail), findsOneWidget);

    // Drag on the rail to "M".
    final rail = tester.getRect(find.byType(AlphabetRail));
    final itemHeight = (rail.height / railLetters.length).clamp(0.0, 17.0);
    final top = rail.center.dy - itemHeight * railLetters.length / 2;
    await tester.tapAt(Offset(rail.center.dx, top + itemHeight * railLetters.indexOf('M') + itemHeight / 2));
    await tester.pumpAndSettle();

    expect(find.text('M song 0'), findsOneWidget);
    expect(find.text('A song 0'), findsNothing);
    // The pinned header for M sits under the app bar.
    expect(find.text('M'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rows with emoji and bullets fit their fixed extent', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final songs = [
      const Song(id: 1, title: '🙏 Praise • Worship ✨', artist: '• Hillsong 🎶', key: 'G'),
      const Song(id: 2, title: 'Plain title', artist: 'Plain artist'),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          librarySongsProvider.overrideWith((ref) => Stream.value(songs)),
          activeWorkspaceIdProvider.overrideWith((ref) => 1),
          workspaceSyncProvider.overrideWith(_IdleSync.new),
          isOnlineProvider.overrideWithValue(true),
        ],
        child: MaterialApp(theme: DaloyTheme.light(), home: const SongsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('🙏 Praise • Worship ✨'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing keeps focus when the results drop below the rail threshold', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final songs = [for (var i = 0; i < 40; i++) Song(id: i, title: '${String.fromCharCode(65 + i % 26)} song $i')];
    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          librarySongsProvider.overrideWith((ref) {
            final q = ref.watch(songListControllerProvider);
            final hits = songs.where((s) => s.title.toLowerCase().contains(q.search.toLowerCase())).toList();
            return Stream.value(hits);
          }),
          activeWorkspaceIdProvider.overrideWith((ref) => 1),
          workspaceSyncProvider.overrideWith(_IdleSync.new),
          isOnlineProvider.overrideWithValue(true),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            container = ProviderScope.containerOf(context);
            return MaterialApp(theme: DaloyTheme.light(), home: const SongsScreen());
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlphabetRail), findsOneWidget);

    await tester.tap(find.byType(TextField));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'song 3');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(container.read(songListControllerProvider).search, 'song 3');
    expect(find.byType(AlphabetRail), findsNothing);
    final field = tester.widget<EditableText>(find.byType(EditableText));
    expect(field.focusNode.hasFocus, isTrue);
  });

  testWidgets('a tablet in landscape opens a song beside the list; portrait still pushes', (tester) async {
    tester.view
      ..physicalSize = const Size(1194, 834)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final songs = [
      for (var n = 0; n < 30; n++) Song(id: n + 1, title: 'Song ${n.toString().padLeft(2, '0')}', key: 'G'),
    ];
    // The pane builds the real song screen, which needs the app's storage.
    final container = await createTestContainer(
      FakeApiAdapter({}),
      overrides: [
        librarySongsProvider.overrideWith((ref) => Stream.value(songs)),
        activeWorkspaceIdProvider.overrideWith((ref) => 1),
        workspaceSyncProvider.overrideWith(_IdleSync.new),
        isOnlineProvider.overrideWithValue(true),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: DaloyTheme.light(), home: const SongsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SplitView), findsOneWidget);
    expect(find.text('Choose a song'), findsOneWidget);
    await tester.tap(find.text('Song 03'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Choose a song'), findsNothing);
    expect(find.byType(SongDetailScreen), findsOneWidget);
    // In the pane: no back button.
    expect(find.bySemanticsLabel('Back'), findsNothing);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(834, 1194);
    await tester.pumpAndSettle();
    expect(find.byType(SplitView), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
