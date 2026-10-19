import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/network/api_client.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/search/application/search_controller.dart';
import 'package:daloy_flutter/features/search/domain/search_results.dart';
import 'package:daloy_flutter/features/search/presentation/search_view.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:daloy_flutter/features/songs/domain/display_prefs.dart';
import 'package:daloy_flutter/features/songs/domain/song.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _results = SearchResults(
  songs: [Song(id: 1, title: 'Way Maker', artist: 'Sinach', key: 'E')],
  lyrics: [
    LyricHit(
      song: Song(id: 2, title: 'Goodness of God', key: 'Ab'),
      line: 3,
      text: 'All my life You have been faithful',
      view: SongViewMode.lyrics,
    ),
  ],
  lineUps: [LineUp(id: 9, title: 'Sunday Service', date: '2026-10-18', songsCount: 4)],
  destinations: [SearchDestination.profile],
);

Future<GoRouter> _pump(WidgetTester tester, {List<String> recent = const []}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: SafeArea(child: SearchView())),
      ),
      GoRoute(
        path: '/songs/:id',
        builder: (_, state) => Scaffold(body: Text('opened ${state.uri}')),
      ),
      GoRoute(
        path: '/line-ups/:id',
        builder: (_, state) => Scaffold(body: Text('opened ${state.uri}')),
      ),
    ],
  );
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        songsRepositoryProvider.overrideWithValue(SongsRepository(db, SongsService(ApiClient(Dio())))),
        activeWorkspaceIdProvider.overrideWith((ref) => 1),
        isOnlineProvider.overrideWithValue(false),
        searchResultsProvider.overrideWith((ref) {
          final q = ref.watch(searchPageControllerProvider.select((s) => s.query));
          return Stream.value(q.isEmpty ? SearchResults.empty : _results);
        }),
        recentSearchesProvider.overrideWith((ref) => Stream.value(recent)),
        recentlyOpenedSongsProvider.overrideWith((ref) => Stream.value(const [Song(id: 5, title: 'Oceans')])),
      ],
      child: MaterialApp.router(theme: DaloyTheme.light(), routerConfig: router),
    ),
  );
  await tester.pump();
  return router;
}

void main() {
  testWidgets('before typing: recent searches, recently opened, and the token tip', (tester) async {
    await _pump(tester, recent: ['way maker']);
    expect(find.text('Recent searches'), findsOneWidget);
    expect(find.text('way maker'), findsOneWidget);
    expect(find.text('Recently opened'), findsOneWidget);
    expect(find.text('Oceans'), findsOneWidget);
    expect(find.textContaining('key:G', findRichText: true), findsOneWidget);
  });

  testWidgets('typing shows grouped results; a lyric hit opens the song at its line', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), 'faithful');
    await tester.pump(SearchPageController.debounce);
    await tester.pump();

    // "Songs" and "Line-ups" are scope chips as well as group labels.
    expect(find.text('Songs'), findsNWidgets(2));
    expect(find.text('Line-ups'), findsNWidgets(2));
    expect(find.text('In lyrics'), findsOneWidget);
    expect(find.text('Go to'), findsOneWidget);
    expect(find.textContaining('have been faithful', findRichText: true), findsOneWidget);

    await tester.tap(find.text('Goodness of God'));
    await tester.pumpAndSettle();
    expect(find.text('opened /songs/2?line=3&view=lyrics'), findsOneWidget);
  });

  testWidgets('a key token shows as a chip; tapping it takes the token out', (tester) async {
    await _pump(tester);
    await tester.enterText(find.byType(TextField), 'hosanna key:G');
    await tester.pump(SearchPageController.debounce);
    await tester.pump();
    expect(find.text('Key of G'), findsOneWidget);

    await tester.tap(find.text('Key of G'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'hosanna');
    expect(find.text('Key of G'), findsNothing);
  });
}
