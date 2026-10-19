import 'dart:io';

import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shared/widgets/daloy_glass.dart';
import 'package:daloy_flutter/shared/widgets/daloy_top_bar.dart';
import 'package:daloy_flutter/shared/widgets/primary_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, {VoidCallback? onPressed, ThemeData? theme}) => tester.pumpWidget(
  MaterialApp(
    theme: theme ?? DaloyTheme.light(),
    home: Scaffold(
      appBar: DaloyTopBar(
        title: 'Songs',
        actions: [PrimaryActionButton(icon: TablerIcons.plus, label: 'New song', onPressed: onPressed ?? () {})],
      ),
    ),
  ),
);

void main() {
  for (final (name, theme) in [('light', DaloyTheme.light()), ('dark', DaloyTheme.dark())]) {
    testWidgets('a frosted teal circle in the top bar\'s trailing slot ($name)', (tester) async {
      await _pump(tester, theme: theme);

      expect(tester.getSize(find.byType(DaloyGlass)), const Size(36, 36));
      final bar = tester.getRect(find.byType(DaloyTopBar));
      final button = tester.getRect(find.byType(PrimaryActionButton));
      expect(button.top, greaterThanOrEqualTo(bar.top));
      expect(button.bottom, lessThanOrEqualTo(bar.bottom));
      expect(button.right, lessThanOrEqualTo(bar.right), reason: 'at the trailing edge');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('tapping runs the action; the label is spoken', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await _pump(tester, onPressed: () => taps++);
    expect(find.bySemanticsLabel('New song'), findsOneWidget);
    await tester.tap(find.byType(PrimaryActionButton));
    expect(taps, 1);
    semantics.dispose();
  });

  test('no screen places a floating action button', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (file.readAsStringSync().contains(RegExp(r'\bfloatingActionButton:|\bFloatingActionButton\b'))) {
        offenders.add(file.path);
      }
    }
    expect(offenders, isEmpty, reason: 'Put the create action in DaloyTopBar.actions as a PrimaryActionButton');
  });
}
