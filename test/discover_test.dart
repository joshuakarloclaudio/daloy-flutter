import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/search/data/network_songs_repository.dart';
import 'package:daloy_flutter/features/search/domain/discover_query.dart';
import 'package:daloy_flutter/features/search/domain/network_song.dart';
import 'package:daloy_flutter/features/search/presentation/discover/discover_screen.dart';
import 'package:daloy_flutter/features/songs/application/song_list_controller.dart';
import 'package:daloy_flutter/features/songs/presentation/songs_screen.dart';
import 'package:daloy_flutter/features/sync/workspace_sync_controller.dart';
import 'package:daloy_flutter/shell/floating_tab_bar.dart';
import 'package:daloy_flutter/shell/primary_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _IdleSync extends WorkspaceSync {
  @override
  WorkspaceSyncState build() => WorkspaceSyncState(status: SyncStatus.done, lastSyncedAt: DateTime(2026));
}

class _FakeNetwork implements NetworkSongsRepository {
  final queries = <DiscoverQuery>[];
  final added = <int>[];

  static const oceans = NetworkSong(
    id: 1,
    title: 'Oceans',
    artist: 'Hillsong',
    key: 'D',
    bpm: 66,
    preview: 'You call me out upon the waters\nThe great unknown',
    workspaceName: 'Grace Church',
    importCount: 3,
    hasMedia: true,
  );
  static const mine = NetworkSong(
    id: 2,
    title: 'Our Song',
    key: 'G',
    workspaceName: 'Home',
    isOwnWorkspace: true,
    importCount: 1,
  );

  @override
  Future<NetworkSongPage> list(DiscoverQuery query, {String? cursor}) async {
    queries.add(query);
    return NetworkSongPage(songs: query.scope == DiscoverScope.own ? [mine] : (query.key == 'A' ? const [] : [oceans]));
  }

  @override
  Future<int> addToLibrary(int id, int workspaceId) async {
    added.add(id);
    return 99;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<_FakeNetwork> pump(WidgetTester tester, {Widget home = const DiscoverScreen()}) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final network = _FakeNetwork();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          networkSongsRepositoryProvider.overrideWithValue(network),
          activeWorkspaceIdProvider.overrideWith((ref) => 1),
          librarySongsProvider.overrideWith((ref) => Stream.value(const [])),
          workspaceSyncProvider.overrideWith(_IdleSync.new),
          isOnlineProvider.overrideWithValue(true),
        ],
        child: MaterialApp.router(
          theme: DaloyTheme.light(),
          routerConfig: GoRouter(
            routes: [GoRoute(path: '/', builder: (_, _) => home)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return network;
  }

  testWidgets('shows other teams\' songs as cards and our own in "Shared by us"', (tester) async {
    await pump(tester);

    expect(find.text('Oceans'), findsOneWidget);
    expect(find.textContaining('You call me out'), findsOneWidget);
    expect(find.text('Grace Church'), findsOneWidget);
    expect(find.text('3 teams'), findsOneWidget);
    expect(find.text('Shared by us'), findsOneWidget);
    expect(find.text('Our Song'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Songs tab switches to Discover and back', (tester) async {
    // Library | Discover lives in the tab bar, so render the tab inside it.
    await pump(
      tester,
      home: Consumer(
        builder: (context, ref, _) => FloatingTabBarScope(
          currentIndex: 1,
          visible: true,
          onSelect: (_) {},
          onReselect: (_) {},
          accessory: const SizedBox.shrink(),
          action: ref.watch(primaryActionsProvider)[1],
          child: const SongsScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Oceans'), findsNothing);

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Oceans'), findsOneWidget);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('Oceans'), findsNothing);
  });

  testWidgets('quick add copies the song and marks it added', (tester) async {
    final network = await pump(tester);

    await tester.tap(find.byTooltip('Add to library'));
    await tester.pumpAndSettle();

    expect(network.added, [1]);
    expect(find.byTooltip('Add to library'), findsNothing);
    expect(find.text('4 teams'), findsOneWidget);
  });

  testWidgets('a key with no matches says so and clears', (tester) async {
    final network = await pump(tester);

    await tester.tap(find.text('Key'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A').last);
    await tester.pumpAndSettle();

    expect(network.queries.last.key, 'A');
    expect(find.text('Nothing found'), findsOneWidget);

    await tester.tap(find.text('Clear search & filters'));
    await tester.pumpAndSettle();
    expect(find.text('Oceans'), findsOneWidget);
  });
}
