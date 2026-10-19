import 'dart:io';

import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shared/widgets/daloy_glass.dart';
import 'package:daloy_flutter/shared/widgets/daloy_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A Scaffold under the same bottom padding the shell gives tab screens
/// (tab bar + accessory), with the messenger handed out.
Future<ScaffoldMessengerState> _pump(WidgetTester tester, {ThemeData? theme, double bottom = 120}) async {
  late ScaffoldMessengerState messenger;
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: theme ?? DaloyTheme.light(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(padding: EdgeInsets.only(bottom: bottom)),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Builder(
              builder: (context) {
                messenger = ScaffoldMessenger.of(context);
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      ),
    ),
  );
  return messenger;
}

void main() {
  testWidgets('floats a glass capsule above the tab bar', (tester) async {
    final messenger = await _pump(tester);
    showDaloyToast(messenger, 'Chart copied.');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Chart copied.'), findsOneWidget);
    expect(find.byType(DaloyGlass), findsOneWidget);
    final rect = tester.getRect(find.byType(DaloyGlass));
    expect(rect.bottom, lessThanOrEqualTo(800 - 120), reason: 'clears the tab bar');
    expect(rect.width, lessThanOrEqualTo(400 * 0.9));
    expect((rect.center.dx - 200).abs(), lessThan(1), reason: 'centred');
  });

  testWidgets('lasts 3s, or 5s with an action', (tester) async {
    final messenger = await _pump(tester);

    showDaloyToast(messenger, 'Plain.');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Plain.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Plain.'), findsNothing);

    showDaloyToast(messenger, 'With undo.', actionLabel: 'Undo', onAction: () {});
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('With undo.'), findsOneWidget, reason: 'still up at 3.5s');
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('With undo.'), findsNothing);
  });

  testWidgets('the action runs once and dismisses the toast', (tester) async {
    final messenger = await _pump(tester);
    var undone = 0;
    showDaloyToast(messenger, 'Deleted.', actionLabel: 'Undo', onAction: () => undone++);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(undone, 1);
    expect(find.text('Deleted.'), findsNothing);
  });

  testWidgets('a newer toast replaces the one showing', (tester) async {
    final messenger = await _pump(tester);
    showDaloyToast(messenger, 'First.');
    await tester.pump(const Duration(milliseconds: 500));
    showDaloyToast(messenger, 'Second.');
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('First.'), findsNothing);
    expect(find.text('Second.'), findsOneWidget);
  });

  testWidgets('a null messenger does nothing', (tester) async {
    await _pump(tester);
    showDaloyToast(null, 'Nobody home.');
    await tester.pump();
    expect(find.text('Nobody home.'), findsNothing);
  });

  testWidgets('renders in dark mode', (tester) async {
    final messenger = await _pump(tester, theme: DaloyTheme.dark());
    showDaloyToast(messenger, 'Dark.', actionLabel: 'Undo', onAction: () {});
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Dark.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('toasts are the only SnackBars in the app', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') || file.path.endsWith('daloy_toast.dart')) continue;
      if (file.readAsStringSync().contains(RegExp(r'\bSnackBar(Action)?\b|showSnackBar'))) offenders.add(file.path);
    }
    expect(offenders, isEmpty, reason: 'Use showDaloyToast instead');
  });
}
