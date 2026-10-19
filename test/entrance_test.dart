import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/shared/widgets/staggered_entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _opacity(WidgetTester tester, String text) =>
    tester.widget<Opacity>(find.ancestor(of: find.text(text), matching: find.byType(Opacity)).first).opacity;

bool _animated(WidgetTester tester, String text) =>
    find.ancestor(of: find.text(text), matching: find.byType(Opacity)).evaluate().isNotEmpty;

Widget _app(Widget child, {bool reduceMotion = false}) => MaterialApp(
  theme: DaloyTheme.light(),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('entrances play in index order, then settle fully shown', (tester) async {
    await tester.pumpWidget(
      _app(
        const Column(
          children: [
            Entrance(index: 0, child: Text('first')),
            Entrance(index: 4, child: Text('fifth')),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 150));
    expect(_opacity(tester, 'first'), greaterThan(_opacity(tester, 'fifth')));

    await tester.pumpAndSettle();
    expect(_opacity(tester, 'first'), 1);
    expect(_opacity(tester, 'fifth'), 1);
  });

  testWidgets('rows built after the opening moments of a scope just appear', (tester) async {
    var later = false;
    late StateSetter set;
    await tester.pumpWidget(
      _app(
        EntranceScope(
          child: StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return Column(
                children: [
                  const Entrance(index: 0, child: Text('opening')),
                  if (later) const Entrance(index: 0, child: Text('scrolled to')),
                ],
              );
            },
          ),
        ),
      ),
    );
    expect(_animated(tester, 'opening'), isTrue);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));

    set(() => later = true);
    await tester.pump();
    expect(_animated(tester, 'scrolled to'), isFalse);
  });

  testWidgets('a scope that is not ready yet holds its clock until it is', (tester) async {
    Widget scope({required bool ready}) => _app(
      EntranceScope(
        ready: ready,
        child: ready ? const Entrance(index: 0, child: Text('row')) : const SizedBox(),
      ),
    );
    await tester.pumpWidget(scope(ready: false));
    await tester.pump(const Duration(seconds: 2));

    await tester.pumpWidget(scope(ready: true));
    expect(_animated(tester, 'row'), isTrue);
  });

  testWidgets('reduced motion skips entrances', (tester) async {
    await tester.pumpWidget(_app(const Entrance(index: 0, child: Text('row')), reduceMotion: true));
    expect(_animated(tester, 'row'), isFalse);
  });
}
