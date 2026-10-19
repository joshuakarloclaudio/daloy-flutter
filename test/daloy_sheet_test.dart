import 'dart:io';

import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shared/widgets/daloy_sheet.dart';
import 'package:daloy_flutter/shared/widgets/pressable.dart';
import 'package:daloy_flutter/shared/widgets/sheet_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _open(
  WidgetTester tester,
  WidgetBuilder builder, {
  ThemeData? theme,
  BoxConstraints? constraints,
  bool toolbar = false,
  bool fit = false,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? DaloyTheme.light(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showDaloySheet<void>(
              context: context,
              constraints: constraints,
              toolbar: toolbar,
              fit: fit,
              builder: builder,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  for (final (name, theme) in [('light', DaloyTheme.light()), ('dark', DaloyTheme.dark())]) {
    testWidgets('opens as a bottom sheet in the card colour, with a grabber ($name)', (tester) async {
      await _open(tester, (_) => const Center(child: Text('Body')), theme: theme);

      expect(find.text('Body'), findsOneWidget);
      final surface = tester.widget<Material>(
        find.descendant(of: find.byType(DaloySheetSurface), matching: find.byType(Material)).first,
      );
      expect(surface.color!.a, 1, reason: 'an opaque card');
      final top = tester.getTopLeft(find.byType(DaloySheetSurface)).dy;
      expect(top, greaterThan(844 * (1 - sheetMaxHeightFactor) - 1), reason: 'the page shows behind, dimmed');
      expect(tester.getSize(find.byType(DaloySheetSurface)).height, closeTo(844 * sheetMaxHeightFactor, 1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('content clears the rounded top edge unless the sheet has its own toolbar', (tester) async {
    Widget body(BuildContext _) => const Align(alignment: Alignment.topLeft, child: Text('Heading'));

    await _open(tester, body);
    final plain = tester.getTopLeft(find.text('Heading')).dy;
    Navigator.of(tester.element(find.text('Heading'))).pop();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());

    await _open(tester, body, toolbar: true);
    final withToolbar = tester.getTopLeft(find.text('Heading')).dy;
    expect(plain - withToolbar, DaloySpace.s3);
  });

  testWidgets('fit makes the sheet only as tall as its content', (tester) async {
    Widget body(BuildContext _) => const Column(mainAxisSize: MainAxisSize.min, children: [SizedBox(height: 200)]);

    await _open(tester, body);
    final full = tester.getTopLeft(find.byType(DaloySheetSurface)).dy;
    Navigator.of(tester.element(find.byType(DaloySheetSurface))).pop();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());

    await _open(tester, body, fit: true);
    final fitted = tester.getTopLeft(find.byType(DaloySheetSurface)).dy;
    expect(fitted, greaterThan(full + 300), reason: 'a 200pt body does not need a full-height sheet');
    expect(844 - fitted, greaterThanOrEqualTo(200 + 20), reason: 'but it all fits');
  });

  testWidgets('fit never runs past the default height for tall content', (tester) async {
    await _open(tester, (_) => const SizedBox(height: 2000), fit: true);
    final top = tester.getTopLeft(find.byType(DaloySheetSurface)).dy;
    expect(top, closeTo(844 * (1 - sheetMaxHeightFactor), 1));
  });

  testWidgets('pads for the device, not for the shell\'s tab bar', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    double? seen;
    await tester.pumpWidget(
      MaterialApp(
        theme: DaloyTheme.light(),
        // What the shell does: inflate the bottom padding for its tab bar.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: const EdgeInsets.only(bottom: 90)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDaloySheet<void>(
                context: context,
                fit: true,
                builder: (sheet) {
                  seen = MediaQuery.paddingOf(sheet).bottom;
                  return const SizedBox(height: 40);
                },
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(seen, 0, reason: 'the tab bar is hidden under a sheet');
  });

  testWidgets('swiping down dismisses', (tester) async {
    await _open(tester, (_) => const SizedBox.expand(child: Center(child: Text('Body'))));
    await tester.fling(find.text('Body'), const Offset(0, 600), 2000);
    await tester.pumpAndSettle();
    expect(find.text('Body'), findsNothing);
  });

  testWidgets('content with ink (ListTile, fields) lays out under a Material', (tester) async {
    await _open(
      tester,
      (_) => Column(
        children: [
          ListTile(title: const Text('Row'), onTap: () {}),
          const TextField(),
        ],
      ),
    );
    expect(find.text('Row'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a width cap holds on a tablet\'s form sheet', (tester) async {
    tester.view
      ..physicalSize = const Size(1024, 768)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: DaloyTheme.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDaloySheet<void>(
                context: context,
                constraints: const BoxConstraints(maxWidth: 560),
                builder: (_) => const SizedBox.expand(key: Key('content')),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const Key('content'))).width, 560);
  });

  group('on a tablet', () {
    Future<void> pumpTablet(WidgetTester tester, {Rect? anchor, bool fit = false}) async {
      tester.view
        ..physicalSize = const Size(1194, 834)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: DaloyTheme.light(),
          home: Scaffold(
            body: Builder(
              builder: (context) => Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () => showDaloySheet<void>(
                    context: context,
                    anchor: anchor,
                    fit: fit,
                    builder: (_) => const SizedBox(key: Key('content'), height: 200),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('a sheet is a centred form sheet with no grabber, and a tap outside closes it', (tester) async {
      await pumpTablet(tester);
      final sheet = tester.getRect(find.byType(DaloySheetSurface));
      expect(sheet.center.dx, closeTo(1194 / 2, 1));
      expect(sheet.width, 560);
      expect(find.byType(BottomSheet), findsNothing);
      // No grabber: the only 36×4 bar would be it.
      expect(
        find.byWidgetPredicate(
          (w) => w is Container && w.constraints == const BoxConstraints.tightFor(width: 36, height: 4),
        ),
        findsNothing,
      );
      await tester.tapAt(const Offset(20, 800));
      await tester.pumpAndSettle();
      expect(find.byType(DaloySheetSurface), findsNothing);
    });

    testWidgets('given its trigger, a sheet opens as a popover just below it', (tester) async {
      const anchor = Rect.fromLTWH(900, 100, 44, 44);
      await pumpTablet(tester, anchor: anchor, fit: true);
      final popover = tester.getRect(find.byType(DaloySheetSurface));
      expect(popover.top, closeTo(anchor.bottom + 8, 1));
      // Lined up with the trigger's trailing side, since it sits on the right.
      expect(popover.right, closeTo(anchor.right, 1));
      expect(popover.width, inInclusiveRange(320, 420));
      expect(tester.takeException(), isNull);
    });
  });

  group('SheetNavBar', () {
    Future<void> pumpBar(
      WidgetTester tester, {
      String actionLabel = 'Save',
      VoidCallback? onAction,
      VoidCallback? onCancel,
      bool pending = false,
      ThemeData? theme,
    }) => tester.pumpWidget(
      MaterialApp(
        theme: theme ?? DaloyTheme.light(),
        home: Scaffold(
          body: SheetNavBar(
            title: 'New song',
            onCancel: onCancel,
            actionLabel: actionLabel,
            onAction: onAction,
            pending: pending,
          ),
        ),
      ),
    );

    testWidgets('Save is a check, Cancel an ✕; both keep their semantic labels', (tester) async {
      final semantics = tester.ensureSemantics();
      var saved = 0, cancelled = 0;
      await pumpBar(tester, onAction: () => saved++, onCancel: () => cancelled++);

      expect(find.text('New song'), findsOneWidget);
      expect(find.text('Save'), findsNothing, reason: 'icon, not text');
      expect(find.bySemanticsLabel('Save'), findsOneWidget);
      expect(find.bySemanticsLabel('Cancel'), findsOneWidget);
      await tester.tap(find.byKey(SheetNavBar.actionKey));
      await tester.tap(find.byKey(SheetNavBar.cancelKey));
      expect((saved, cancelled), (1, 1));
      semantics.dispose();
    });

    testWidgets('a verb stays text', (tester) async {
      await pumpBar(tester, actionLabel: 'Create', onAction: () {});
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('disabled, and pending, do not fire', (tester) async {
      var fired = 0;
      await pumpBar(tester, onAction: null);
      expect(
        tester
            .widget<Pressable>(find.descendant(of: find.byKey(SheetNavBar.actionKey), matching: find.byType(Pressable)))
            .onPressed,
        isNull,
      );

      await pumpBar(tester, onAction: () => fired++, pending: true, theme: DaloyTheme.dark());
      expect(find.byKey(SheetNavBar.actionKey), findsNothing);
      expect(fired, 0);
    });
  });

  test('sheets are presented only through showDaloySheet', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') || file.path.endsWith('daloy_sheet.dart')) continue;
      // Perform's sheets keep their own palette (showPerformSheet).
      if (file.path.endsWith('perform_themed.dart')) continue;
      if (file.readAsStringSync().contains(RegExp(r'\bshowModalBottomSheet\s*[<(]'))) offenders.add(file.path);
    }
    expect(offenders, isEmpty, reason: 'Use showDaloySheet');
  });
}
