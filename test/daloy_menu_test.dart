import 'dart:io';

import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shared/widgets/daloy_menu.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind, kSecondaryMouseButton;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child, {ThemeData? theme}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? DaloyTheme.light(),
      home: Scaffold(
        body: Align(alignment: Alignment.topRight, child: child),
      ),
    ),
  );
}

List<DaloyMenuItem> _items(List<String> log) => [
  DaloyMenuItem(icon: Icons.edit, label: 'Edit', onSelected: () => log.add('edit')),
  DaloyMenuItem.divider,
  DaloyMenuItem(icon: Icons.delete, label: 'Delete', destructive: true, onSelected: () => log.add('delete')),
];

void main() {
  group('DaloyMenuButton', () {
    testWidgets('opens a pull-down; a pick runs once, after the menu has closed', (tester) async {
      final log = <String>[];
      await _pump(tester, DaloyMenuButton(tooltip: 'More', items: _items(log)));

      await tester.tap(find.byType(DaloyMenuButton));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pump(const Duration(milliseconds: 30));
      expect(log, isEmpty, reason: 'still animating out');
      await tester.pumpAndSettle();
      expect(log, ['edit']);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('the menu sits under the button, right-aligned, on screen', (tester) async {
      await _pump(tester, DaloyMenuButton(tooltip: 'More', items: _items([])));
      final button = tester.getRect(find.byType(DaloyMenuButton));
      await tester.tap(find.byType(DaloyMenuButton));
      await tester.pumpAndSettle();

      final panel = tester.getRect(find.ancestor(of: find.text('Edit'), matching: find.byType(Material)).first);
      expect(panel.top, greaterThanOrEqualTo(button.bottom));
      expect(panel.right, lessThanOrEqualTo(390));
      expect(panel.left, greaterThanOrEqualTo(0));
    });

    testWidgets('under a notch, the menu still hangs just below the button', (tester) async {
      tester.view.padding = const FakeViewPadding(top: 59);
      addTearDown(tester.view.resetPadding);
      await _pump(
        tester,
        Padding(
          padding: const EdgeInsets.only(top: 64),
          child: DaloyMenuButton(tooltip: 'More', items: _items([])),
        ),
      );
      final button = tester.getRect(find.byType(DaloyMenuButton));
      await tester.tap(find.byType(DaloyMenuButton));
      await tester.pumpAndSettle();

      final panel = tester.getRect(find.ancestor(of: find.text('Edit'), matching: find.byType(Material)).first);
      expect(panel.top - button.bottom, 8, reason: 'the safe-area inset is not added to the gap');
    });

    testWidgets('tapping outside dismisses without running anything', (tester) async {
      final log = <String>[];
      await _pump(tester, DaloyMenuButton(tooltip: 'More', items: _items(log)));
      await tester.tap(find.byType(DaloyMenuButton));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(20, 700));
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsNothing);
      expect(log, isEmpty);
    });

    testWidgets('dark mode, with a destructive row, lays out', (tester) async {
      await _pump(
        tester,
        DaloyMenuButton(tooltip: 'More', items: _items([])),
        theme: DaloyTheme.dark(),
      );
      await tester.tap(find.byType(DaloyMenuButton));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('showDaloyChoiceMenu', () {
    Future<void> pumpTrigger(WidgetTester tester, void Function(Future<String?> result) onResult) => _pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => onResult(
            showDaloyChoiceMenu<String>(
              context,
              title: 'Sort by',
              options: const [('title', 'Title'), ('key', 'Key'), ('recent', 'Recently added')],
              current: 'key',
            ),
          ),
          child: const Text('Sort'),
        ),
      ),
    );

    testWidgets('marks the current option and resolves to the pick once closed', (tester) async {
      late Future<String?> result;
      await pumpTrigger(tester, (r) => result = r);
      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      expect(find.text('Sort by'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing, reason: 'Tabler check, not Material');
      await tester.tap(find.text('Recently added'));
      await tester.pumpAndSettle();
      expect(await result, 'recent');
    });

    testWidgets('dismissing resolves to null', (tester) async {
      late Future<String?> result;
      await pumpTrigger(tester, (r) => result = r);
      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(20, 700));
      await tester.pumpAndSettle();
      expect(await result, isNull);
    });
  });

  group('DaloyContextMenu', () {
    testWidgets('touch and hold lifts the row and opens its actions; a pick runs once', (tester) async {
      final log = <String>[];
      await _pump(
        tester,
        DaloyContextMenu(
          items: () => _items(log),
          child: const SizedBox(width: 300, height: 60, child: Center(child: Text('Oceans'))),
        ),
      );

      final hold = await tester.startGesture(tester.getCenter(find.text('Oceans')));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await hold.up();
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(log, ['delete']);
    });

    testWidgets('a stretching list row lifts at its own size, with the menu on screen', (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      // Shaped like the real rows: a Row with an Expanded column, in a Stack,
      // in a scrolling list. Laid out loosely it would fill the screen.
      await tester.pumpWidget(
        MaterialApp(
          theme: DaloyTheme.light(),
          home: Scaffold(
            body: ListView(
              children: [
                const SizedBox(height: 200),
                DaloyContextMenu(
                  items: () => _items([]),
                  child: Stack(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [Text('Oceans'), Text('Hillsong')],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Positioned(right: 0, top: 0, bottom: 0, child: Icon(Icons.chevron_right)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      final inList = tester.getSize(find.byType(DaloyContextMenu));

      final hold = await tester.startGesture(tester.getCenter(find.text('Oceans')));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await hold.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final lifted = tester.getRect(find.text('Oceans').last);
      expect(lifted.height, lessThan(inList.height), reason: 'the row at its own size, not the screen');
      final menu = tester.getRect(find.text('Edit'));
      expect(menu.top, greaterThanOrEqualTo(0));
      expect(menu.bottom, lessThanOrEqualTo(844));
      expect(menu.left, greaterThanOrEqualTo(0));
      expect(menu.right, lessThanOrEqualTo(390));
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('a fixed-extent list row (songs, line-ups) lifts at its own size too', (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: DaloyTheme.light(),
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverFixedExtentList.builder(
                  itemExtent: 72,
                  itemCount: 5,
                  itemBuilder: (_, i) => DaloyContextMenu(
                    items: () => _items([]),
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(children: [Expanded(child: Text('Song $i'))]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final hold = await tester.startGesture(tester.getCenter(find.text('Song 2')));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      await hold.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Stack).last).height, lessThan(100), reason: 'the row, not the screen');
      final menu = tester.getRect(find.text('Edit'));
      expect(menu.top, greaterThanOrEqualTo(0));
      expect(menu.bottom, lessThanOrEqualTo(844));
    });

    testWidgets('lifting and dropping a row never overflows, frame by frame', (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1
        ..padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.reset);
      final errors = <FlutterErrorDetails>[];
      final previous = FlutterError.onError;
      FlutterError.onError = errors.add;
      addTearDown(() => FlutterError.onError = previous);

      await tester.pumpWidget(
        MaterialApp(
          theme: DaloyTheme.light(),
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverFixedExtentList.builder(
                  itemExtent: 72,
                  itemCount: 11,
                  itemBuilder: (_, i) => DaloyContextMenu(
                    items: () => _items([]),
                    // Content exactly as tall as the extent, like the song
                    // rows: any rect a hair shorter overflows it.
                    child: const ColoredBox(
                      color: Colors.white,
                      child: Column(
                        children: [
                          SizedBox(height: 36, child: Text('Oceans')),
                          SizedBox(height: 36, child: Text('Hillsong · 4/4')),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // The last full row, where there is no room to grow downwards.
      final row = find.byType(DaloyContextMenu).at(10);
      final hold = await tester.startGesture(tester.getCenter(row));
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 25));
      }
      await hold.up();
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);

      await tester.tapAt(const Offset(195, 120));
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsNothing);
      expect(errors.map((e) => e.exceptionAsString()), isEmpty);
    }, timeout: const Timeout(Duration(seconds: 30)));

    testWidgets('a right click opens the same actions at the pointer, without lifting', (tester) async {
      final log = <String>[];
      await _pump(
        tester,
        DaloyContextMenu(
          items: () => _items(log),
          child: const SizedBox(width: 300, height: 60, child: Center(child: Text('Oceans'))),
        ),
      );

      final at = tester.getCenter(find.text('Oceans'));
      await tester.tapAt(at, buttons: kSecondaryMouseButton, kind: PointerDeviceKind.mouse);
      await tester.pumpAndSettle();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Oceans'), findsOneWidget, reason: 'no lifted copy');
      final panel = tester.getRect(find.ancestor(of: find.text('Edit'), matching: find.byType(Material)).first);
      expect(panel.top, closeTo(at.dy + 8, 1), reason: 'hangs from the pointer');

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(log, ['delete']);
    });

    testWidgets('a plain tap on the row still reaches the row', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        DaloyContextMenu(
          items: () => _items([]),
          child: GestureDetector(
            onTap: () => taps++,
            child: const SizedBox(width: 300, height: 60, child: Center(child: Text('Oceans'))),
          ),
        ),
      );
      await tester.tap(find.text('Oceans'));
      expect(taps, 1);
      expect(find.text('Edit'), findsNothing);
    });

    testWidgets('every action is also a custom semantics action', (tester) async {
      final semantics = tester.ensureSemantics();
      final log = <String>[];
      await _pump(
        tester,
        DaloyContextMenu(
          items: () => _items(log),
          child: const SizedBox(width: 300, height: 60, child: Center(child: Text('Oceans'))),
        ),
      );
      final data = tester.getSemantics(find.text('Oceans')).getSemanticsData();
      expect(data.customSemanticsActionIds, isNotNull);
      expect(data.customSemanticsActionIds!.length, 2, reason: 'Edit and Delete; the divider is dropped');
      semantics.dispose();
    });
  });

  test('no action sheets or choice sheets are left', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (file.readAsStringSync().contains(RegExp(r'\bshowActionSheet\b|\bshowChoiceSheet\b'))) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty, reason: 'Use DaloyMenuButton, DaloyContextMenu or showDaloyChoiceMenu');
  });
}
