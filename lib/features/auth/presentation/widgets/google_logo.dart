import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The four-colour Google "G", drawn so the app needs no SVG dependency.
/// Brand colours are fixed by Google's guidelines, so they skip the theme.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: const CustomPaint(painter: _GoogleLogoPainter()),
  );
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.22;
    final radius = (size.width - stroke) / 2;
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: center, radius: radius);

    double rad(double degrees) => degrees * math.pi / 180;
    void arc(Color color, double start, double sweep) => canvas.drawArc(
      rect,
      rad(start),
      rad(sweep),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // Clockwise from 3 o'clock; the gap between red and blue is the G's mouth.
    arc(_blue, 0, 40);
    arc(_green, 40, 100);
    arc(_yellow, 140, 75);
    arc(_red, 215, 100);

    canvas.drawRect(
      Rect.fromLTRB(center.dx, center.dy - stroke / 2, center.dx + radius + stroke / 2, center.dy + stroke / 2),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
