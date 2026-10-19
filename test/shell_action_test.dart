import 'dart:io';

import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shell/floating_tab_bar.dart';
import 'package:daloy_flutter/shell/primary_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';

const _inline = SizedBox(
  key: Key('inline'),
  width: 200,
  height: 40,
  child: Center(child: Text('Library | Discover')),
);

PrimaryAction _action(List<Rect> taps, {String label = 'New song', Widget? inline}) =>
    PrimaryAction(label: label, icon: TablerIcons.plus, onPressed: taps.add, inline: inline);

/// The bar over a scrollable tab, as the shell lays it out.
Widget _scope({PrimaryAction? action, int index = 1, ThemeData? theme, ScrollController? controller}) => MaterialApp(
  theme: theme ?? DaloyTheme.light(),
  home: Scaffold(
    body: FloatingTabBarScope(
      currentIndex: index,
      visible: true,
      onSelect: (_) {},
      onReselect: (_) {},
      accessory: const SizedBox.shrink(),
      action: action,
      child: ListView.builder(
        controller: controller,
        itemCount: 80,
        itemBuilder: (_, i) => SizedBox(height: 56, child: Text('Row $i')),
      ),
    ),
  ),
);

void _size(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Finder get _capsule => find.byKey(const Key('tab-capsule'));

/// Full size: the labelled capsule. Folded: the same four tabs, icons only.
void _expectOpen(WidgetTester tester) {
  expect(tester.getSize(_capsule).height, FloatingGlassTabBar.height);
  expect(_labelOpacity(tester, 'Songs'), 1);
}

void _expectFolded(WidgetTester tester) {
  expect(tester.getSize(_capsule).height, FloatingGlassTabBar.foldedHeight);
  expect(_labelOpacity(tester, 'Songs'), 0, reason: 'icons only');
}

double _labelOpacity(WidgetTester tester, String label) =>
    tester.widget<Opacity>(find.ancestor(of: find.text(label), matching: find.byType(Opacity)).first).opacity;

void main() {
  group('the open bar', () {
    testWidgets('four tabs, and no search tab in the bar', (tester) async {
      await tester.pumpWidget(_scope());
      for (final label in ['Home', 'Songs', 'Line-ups', 'You']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(find.text('Search'), findsNothing);
    });

    testWidgets('the + sits detached at the bar\'s trailing end, and runs the action with its rect', (tester) async {
      _size(tester);
      final taps = <Rect>[];
      await tester.pumpWidget(_scope(action: _action(taps)));
      await tester.pumpAndSettle();

      final plus = tester.getRect(find.bySemanticsLabel('New song').hitTestable().first);
      expect(plus.right, lessThanOrEqualTo(390 - 20 + 0.5));
      expect(plus.width, FloatingGlassTabBar.height);

      await tester.tapAt(plus.center);
      expect(taps, hasLength(1));
      expect(taps.single.size, const Size(FloatingGlassTabBar.height, FloatingGlassTabBar.height));
    });

    testWidgets('with no action (You) there is no +, and the capsule runs full width', (tester) async {
      _size(tester);
      await tester.pumpWidget(_scope(action: _action([])));
      await tester.pumpAndSettle();
      final withPlus = tester.getRect(find.text('You')).right;
      await tester.pumpWidget(_scope());
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('New song'), findsNothing);
      expect(tester.getRect(find.text('You')).right, greaterThan(withPlus));
    });

    testWidgets('the tab\'s inline control rides above the bar, and the list clears both', (tester) async {
      _size(tester);
      await tester.pumpWidget(_scope(action: _action([], inline: _inline)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('inline')), findsOneWidget);
      final inline = tester.getRect(find.byKey(const Key('inline')));
      final tabs = tester.getRect(find.text('Songs'));
      expect(inline.bottom, lessThan(tabs.top), reason: 'above the tabs');
    });

    testWidgets('renders in dark mode', (tester) async {
      await tester.pumpWidget(
        _scope(
          action: _action([], inline: _inline),
          theme: DaloyTheme.dark(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('folding on scroll, like Photos', () {
    testWidgets('scrolling down folds it: the same four tabs as icons, and a smaller +', (tester) async {
      _size(tester);
      await tester.pumpWidget(_scope(action: _action([])));
      await tester.pumpAndSettle();
      _expectOpen(tester);
      final openPlus = tester.getSize(find.bySemanticsLabel('New song').hitTestable().first);
      final openWidth = tester.getSize(_capsule).width;

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      _expectFolded(tester);
      for (final label in ['Home', 'Songs', 'Line-ups', 'You']) {
        expect(find.bySemanticsLabel(label), findsOneWidget, reason: '$label is still there');
      }
      final plus = tester.getSize(find.bySemanticsLabel('New song').hitTestable().first);
      expect(plus.width, FloatingGlassTabBar.foldedHeight);
      expect(plus.width, lessThan(openPlus.width));
      expect(tester.getRect(_capsule).left, lessThanOrEqualTo(20 + 1), reason: 'hugs the leading edge');
      expect(tester.getSize(_capsule).width, lessThan(openWidth), reason: 'shrinks to its icons');
    });

    testWidgets('it folds the same on a tab with no inline control, and on one with no +', (tester) async {
      _size(tester);
      await tester.pumpWidget(_scope());
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      _expectFolded(tester);
      expect(find.bySemanticsLabel('New song'), findsNothing);
    });

    testWidgets('scrolling back up opens it', (tester) async {
      _size(tester);
      await tester.pumpWidget(_scope(action: _action([])));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      _expectFolded(tester);

      await tester.drag(find.byType(ListView), const Offset(0, 120));
      await tester.pumpAndSettle();
      _expectOpen(tester);
    });

    testWidgets('with an inline control, folded is the tab\'s icon, the control centred beside it, and the +', (
      tester,
    ) async {
      _size(tester);
      await tester.pumpWidget(_scope(action: _action([], inline: _inline)));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('folded')), findsOneWidget);
      expect(_capsule, findsNothing);
      expect(find.text('Home'), findsNothing, reason: 'one icon, not the four tabs');

      final circle = tester.getRect(find.bySemanticsLabel(RegExp('show the tab bar')).first);
      final inline = tester.getRect(find.byKey(const Key('inline')));
      final plus = tester.getRect(find.bySemanticsLabel('New song').hitTestable().first);
      expect(circle.left, lessThanOrEqualTo(20 + 1), reason: 'at the leading edge');
      expect(circle.width, FloatingGlassTabBar.foldedHeight);
      expect(inline.left, greaterThan(circle.right));
      expect(inline.right, lessThan(plus.left));
      expect(inline.center.dy, closeTo(plus.center.dy, 1), reason: 'in the bar\'s own row');
      expect(inline.center.dx, closeTo(390 / 2, 2), reason: 'centred on the row');
    });

    testWidgets('tapping the folded circle opens all four tabs again', (tester) async {
      _size(tester);
      await tester.pumpWidget(_scope(action: _action([], inline: _inline)));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel(RegExp('show the tab bar')).first);
      await tester.pumpAndSettle();
      _expectOpen(tester);
      for (final label in ['Home', 'Songs', 'Line-ups', 'You']) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('a small scroll, or a bounce at the top, does not fold it', (tester) async {
      _size(tester);
      await tester.pumpWidget(_scope(action: _action([])));
      await tester.drag(find.byType(ListView), const Offset(0, -20));
      await tester.pumpAndSettle();
      _expectOpen(tester);

      await tester.drag(find.byType(ListView), const Offset(0, 200)); // overscroll at the top
      await tester.pumpAndSettle();
      _expectOpen(tester);
    });

    testWidgets('a horizontal shelf inside the screen does not fold it', (tester) async {
      _size(tester);
      await tester.pumpWidget(
        MaterialApp(
          theme: DaloyTheme.light(),
          home: Scaffold(
            body: FloatingTabBarScope(
              currentIndex: 0,
              visible: true,
              onSelect: (_) {},
              onReselect: (_) {},
              accessory: const SizedBox.shrink(),
              child: ListView(
                children: [
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      key: const Key('shelf'),
                      scrollDirection: Axis.horizontal,
                      itemCount: 30,
                      itemBuilder: (_, i) => SizedBox(width: 100, child: Text('S$i')),
                    ),
                  ),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.drag(find.byKey(const Key('shelf')), const Offset(-300, 0));
      await tester.pumpAndSettle();
      _expectOpen(tester);
    });

    testWidgets('switching tab opens it again', (tester) async {
      _size(tester);
      Widget app(int index) => MaterialApp(
        theme: DaloyTheme.light(),
        home: Scaffold(
          body: FloatingTabBarScope(
            currentIndex: index,
            visible: true,
            onSelect: (_) {},
            onReselect: (_) {},
            accessory: const SizedBox.shrink(),
            child: ListView.builder(itemCount: 80, itemBuilder: (_, i) => SizedBox(height: 56, child: Text('Row $i'))),
          ),
        ),
      );
      await tester.pumpWidget(app(1));
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      _expectFolded(tester);

      await tester.pumpWidget(app(2));
      await tester.pumpAndSettle();
      _expectOpen(tester);
    });

    testWidgets('folded, in dark mode, lays out', (tester) async {
      _size(tester);
      await tester.pumpWidget(
        _scope(
          action: _action([], inline: _inline),
          theme: DaloyTheme.dark(),
        ),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('registering a tab\'s action', () {
    Widget app(ProviderContainer container, {required Widget child}) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: child),
    );

    testWidgets('a screen declares it, a rebuild with a new closure keeps it, leaving removes it', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      var calls = 0;
      Widget screen(void Function(Rect) onPressed) => RegisterPrimaryAction(
        branch: 1,
        label: 'New song',
        icon: TablerIcons.plus,
        onPressed: onPressed,
        child: const SizedBox(),
      );

      await tester.pumpWidget(app(container, child: screen((_) => calls = 1)));
      await tester.pump();
      final first = container.read(primaryActionsProvider)[1]!;
      expect(first.label, 'New song');

      await tester.pumpWidget(app(container, child: screen((_) => calls = 2)));
      await tester.pump();
      expect(container.read(primaryActionsProvider)[1], same(first), reason: 'same button, so no bar rebuild');
      first.onPressed(Rect.zero);
      expect(calls, 2, reason: 'but it runs the newest closure');

      await tester.pumpWidget(app(container, child: const SizedBox()));
      await tester.pump();
      expect(container.read(primaryActionsProvider), isEmpty);
    });

    testWidgets('each tab keeps its own, and the inline control travels with it', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        app(
          container,
          child: Column(
            children: [
              RegisterPrimaryAction(
                branch: 1,
                label: 'New song',
                icon: TablerIcons.plus,
                onPressed: (_) {},
                inline: _inline,
                child: const SizedBox(),
              ),
              RegisterPrimaryAction(
                branch: 2,
                label: 'New line-up',
                icon: TablerIcons.plus,
                onPressed: (_) {},
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      final actions = container.read(primaryActionsProvider);
      expect(actions[1]!.label, 'New song');
      expect(actions[1]!.inline, isNotNull);
      expect(actions[2]!.label, 'New line-up');
      expect(actions[2]!.inline, isNull);
      expect(actions[3], isNull, reason: 'You has no create action');
    });
  });

  test('no native tab bar, and no Search tab, is left', () {
    final bar = File('lib/shell/floating_tab_bar.dart').readAsStringSync();
    expect(bar, isNot(contains("'Search'")));
    expect(bar, isNot(contains('MethodChannel')));
    expect(File('lib/core/router/app_router.dart').readAsStringSync(), contains('parentNavigatorKey: _rootKey'));
  });
}
