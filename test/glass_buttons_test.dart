import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shared/widgets/daloy_glass.dart';
import 'package:daloy_flutter/shared/widgets/daloy_list_row.dart';
import 'package:daloy_flutter/shared/widgets/glass_buttons.dart';
import 'package:daloy_flutter/shared/widgets/hairline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(
  theme: DaloyTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('icon and text buttons frost once, run the action, speak the label', (tester) async {
    final semantics = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(_app(GlassIconButton(icon: TablerIcons.x, label: 'Close', onPressed: () => taps++)));
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    await tester.tap(find.byType(GlassIconButton));
    expect(taps, 1);

    await tester.pumpWidget(_app(GlassTextButton(label: 'Add', onPressed: () => taps++, prominent: true)));
    expect(find.byType(DaloyGlass), findsOneWidget);
    await tester.tap(find.text('Add'));
    expect(taps, 2);
    semantics.dispose();
  });

  testWidgets('Hairline is half a pixel and insets to the text', (tester) async {
    await tester.pumpWidget(_app(const SizedBox(width: 200, child: Hairline(indent: 60))));
    final rect = tester.getRect(find.descendant(of: find.byType(Hairline), matching: find.byType(ColoredBox)));
    expect(rect.height, 0.5);
    expect(rect.width, 140);
  });

  testWidgets('DaloyListRow taps, and a null onTap disables it', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(DaloyListRow(title: const Text('Row'), onTap: () => taps++)));
    await tester.tap(find.text('Row'));
    expect(taps, 1);
    await tester.pumpWidget(_app(const DaloyListRow(title: Text('Row'))));
    await tester.tap(find.text('Row'));
    expect(taps, 1);
  });
}
