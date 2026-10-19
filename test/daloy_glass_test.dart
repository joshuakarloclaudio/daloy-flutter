import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shared/widgets/daloy_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? DaloyTheme.light(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final (name, theme) in [('light', DaloyTheme.light()), ('dark', DaloyTheme.dark())]) {
    testWidgets('every variant frosts exactly once ($name)', (tester) async {
      for (final glass in [
        const DaloyGlass.capsule(child: SizedBox(width: 120, height: 40)),
        const DaloyGlass.circle(child: SizedBox.square(dimension: 40)),
        DaloyGlass.panel(child: const SizedBox(width: 120, height: 40)),
        DaloyGlass.panel(radius: 28, child: const SizedBox(width: 120, height: 40)),
        const DaloyGlass.sheet(child: SizedBox(width: 120, height: 40)),
      ]) {
        await tester.pumpWidget(_app(glass, theme: theme));
        expect(find.byType(BackdropFilter), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('flat drops the blur for a solid fill (e-ink)', (tester) async {
    await tester.pumpWidget(_app(const DaloyGlass.capsule(flat: true, child: SizedBox(width: 120, height: 40))));
    expect(find.byType(BackdropFilter), findsNothing);
  });
}
