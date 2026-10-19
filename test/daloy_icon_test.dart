import 'dart:io';
import 'dart:ui' as ui;

import 'package:daloy_flutter/shared/widgets/daloy_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';

/// Horizontal ink extent of [icon] drawn at 50px, centred in a 100px box.
Future<(int, int)> _inkX(WidgetTester tester, Widget icon) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: Container(
            color: Colors.white,
            width: 100,
            height: 100,
            child: Center(child: icon),
          ),
        ),
      ),
    ),
  );
  late (int, int) extent;
  await tester.runAsync(() async {
    final image = await (key.currentContext!.findRenderObject()! as RenderRepaintBoundary).toImage();
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    var minX = 100, maxX = -1;
    for (var y = 0; y < 100; y++) {
      for (var x = 0; x < 100; x++) {
        if (bytes.getUint8((y * 100 + x) * 4) < 128) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
        }
      }
    }
    extent = (minX, maxX);
  });
  return extent;
}

/// Tests render with the Ahem font unless a real one is loaded.
final _tablerFont = File(
  '${Platform.environment['PUB_CACHE'] ?? '${Platform.environment['HOME']}/.pub-cache'}'
  '/hosted/pub.dev/flutter_tabler_icons-1.43.0/assets/fonts/tabler-icons.ttf',
);

void main() {
  setUpAll(() async {
    final font = _tablerFont;
    if (!font.existsSync()) return;
    final loader = FontLoader('packages/flutter_tabler_icons/tabler-icons')
      ..addFont(Future.value(ByteData.sublistView(await font.readAsBytes())));
    await loader.load();
  });

  testWidgets('glyphs on combining-mark codepoints render centred', (tester) async {
    for (final icon in [TablerIcons.home, TablerIcons.home_filled, TablerIcons.layout_list_filled]) {
      final (left, right) = await _inkX(tester, DaloyIcon(icon, size: 50, color: Colors.black));
      expect(right, greaterThan(left), reason: 'nothing drawn');
      expect((left + right) / 2, closeTo(49.5, 2), reason: 'U+${icon.codePoint.toRadixString(16)}');
    }
  }, skip: !_tablerFont.existsSync());
}
