import 'package:daloy_flutter/core/router/routes.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/search/presentation/search_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('the magnifier pushes the search page over the tab, and back returns to it', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Center(child: TopBarSearchButton())),
        ),
        GoRoute(
          path: Routes.search,
          builder: (context, _) => Scaffold(
            body: Column(
              children: [
                const Text('search page'),
                // Another tap from here must not stack a second page.
                const TopBarSearchButton(),
                TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(theme: DaloyTheme.light(), routerConfig: router),
      ),
    );

    await tester.tap(find.byType(TopBarSearchButton));
    await tester.pumpAndSettle();
    expect(find.text('search page'), findsOneWidget);
    expect(router.state.matchedLocation, Routes.search);

    await tester.tap(find.byType(TopBarSearchButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('search page'), findsNothing, reason: 'one page, so one Cancel gets back to the tab');
    expect(find.byType(TopBarSearchButton), findsOneWidget);
  });
}
