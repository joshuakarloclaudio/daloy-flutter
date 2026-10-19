import 'dart:async';

import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shared/widgets/daloy_menu.dart';
import 'package:daloy_flutter/shell/floating_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget tab(NavigatorObserver observer, {Key? key}) => MaterialApp(
    home: Navigator(
      key: key,
      observers: [observer],
      pages: const [MaterialPage<void>(child: Scaffold(body: Text('tab')))],
      onDidRemovePage: (_) {},
    ),
  );

  testWidgets('a sheet over a tab covers the shell until it closes', (tester) async {
    final observer = ShellCover.observer();
    await tester.pumpWidget(tab(observer));
    expect(ShellCover.covered.value, 0);

    final context = tester.element(find.text('tab'));
    unawaited(showModalBottomSheet<void>(context: context, builder: (_) => const Text('sheet')));
    await tester.pumpAndSettle();
    expect(ShellCover.covered.value, 1);

    Navigator.of(tester.element(find.text('sheet'))).pop();
    await tester.pumpAndSettle();
    expect(ShellCover.covered.value, 0);
  });

  testWidgets('a rebuilt tab navigator does not leave the shell covered', (tester) async {
    final observer = ShellCover.observer();
    await tester.pumpWidget(tab(observer, key: GlobalKey()));
    // go_router swaps the navigator out without popping its page.
    await tester.pumpWidget(tab(observer, key: GlobalKey()));
    await tester.pumpWidget(tab(observer, key: GlobalKey()));
    expect(ShellCover.covered.value, 0);
  });

  group('a menu opened over the tab', () {
    Widget themedTab(NavigatorObserver observer) => MaterialApp(
      theme: DaloyTheme.light(),
      home: Navigator(
        observers: [observer],
        pages: const [MaterialPage<void>(child: Scaffold(body: Text('tab')))],
        onDidRemovePage: (_) {},
      ),
    );

    final items = [DaloyMenuItem(icon: Icons.add, label: 'New song', onSelected: () {})];

    testWidgets('does not hide the tab bar: you pressed it a moment ago', (tester) async {
      final observer = ShellCover.observer();
      await tester.pumpWidget(themedTab(observer));
      final context = tester.element(find.text('tab'));

      unawaited(showDaloyMenu(context, items: items, anchor: const Rect.fromLTWH(300, 700, 56, 56)));
      await tester.pumpAndSettle();
      expect(find.text('New song'), findsOneWidget);
      expect(ShellCover.covered.value, 0, reason: 'a menu is not a place');

      await tester.tapAt(const Offset(20, 100));
      await tester.pumpAndSettle();
      expect(ShellCover.covered.value, 0);
    });

    testWidgets('but a page opened from it still does', (tester) async {
      final observer = ShellCover.observer();
      await tester.pumpWidget(themedTab(observer));
      final context = tester.element(find.text('tab'));

      unawaited(showDaloyMenu(context, items: items, anchor: const Rect.fromLTWH(300, 700, 56, 56)));
      await tester.pumpAndSettle();
      unawaited(
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('page')))),
      );
      await tester.pumpAndSettle();
      expect(ShellCover.covered.value, 1);
    });
  });
}
