import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shared/widgets/daloy_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app() => MaterialApp(
  theme: DaloyTheme.light(),
  home: Scaffold(
    appBar: const DaloyTopBar(title: 'Line-ups', largeTitle: true),
    body: CustomScrollView(
      slivers: [
        const SliverLargeTitle('Line-ups'),
        SliverList.builder(itemCount: 40, itemBuilder: (_, i) => SizedBox(height: 60, child: Text('Row $i'))),
      ],
    ),
  ),
);

double _inlineOpacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.descendant(of: find.byType(DaloyTopBar), matching: find.byType(AnimatedOpacity)))
    .opacity;

void main() {
  testWidgets('the inline title waits until the large one has scrolled under the bar', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.text('Line-ups'), findsNWidgets(2));
    expect(_inlineOpacity(tester), 0);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -20));
    await tester.pump();
    expect(_inlineOpacity(tester), 0, reason: 'still on screen');

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -80));
    await tester.pump();
    expect(_inlineOpacity(tester), 1);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await tester.pump();
    expect(_inlineOpacity(tester), 0, reason: 'back at the top');
  });
}
