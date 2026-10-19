import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The colours generated artwork is drawn in. Every palette stays inside the
/// teal family so the one-accent rule holds; [today] (Today Emerald) is kept
/// for the line-up happening today, and [past] for what's gone quiet.
@immutable
class FlowPalette {
  const FlowPalette(this.light, this.mid, this.deep);

  final Color light;
  final Color mid;
  final Color deep;

  static const family = [
    FlowPalette(Color(0xFF14B8A6), Color(0xFF0F766E), Color(0xFF042F2E)), // teal
    FlowPalette(Color(0xFF2DD4BF), Color(0xFF0E7490), Color(0xFF083344)), // sea
    FlowPalette(Color(0xFF34D399), Color(0xFF0D9488), Color(0xFF134E4A)), // jade
    FlowPalette(Color(0xFF5EEAD4), Color(0xFF115E59), Color(0xFF0B1F1E)), // ink
  ];

  static const today = FlowPalette(Color(0xFF6EE7B7), Color(0xFF059669), Color(0xFF022C22));
  static const past = FlowPalette(Color(0xFFA1A1AA), Color(0xFF52525B), Color(0xFF18181B));

  /// Stable per [seed], so a thing's artwork never changes between visits.
  factory FlowPalette.seeded(int seed) => family[seed.abs() % family.length];
}

/// Daloy's generated artwork: a palette gradient lit from one corner,
/// crossed by slow "flow" lines (daloy: flow) seeded per item, with [child]
/// (its type) laid over it. Line-up covers, song tiles and the profile
/// avatar are all drawn with it, so everything that has an identity shares
/// one look.
///
/// Small tiles in lists stay still; pass [animate] for a hero-sized piece.
/// [glow] makes the coloured shadow breathe (today's line-up).
class FlowArtwork extends StatefulWidget {
  const FlowArtwork({
    super.key,
    required this.seed,
    required this.palette,
    required this.width,
    double? height,
    double? radius,
    this.animate = false,
    this.shadow = false,
    this.glow = false,
    this.circle = false,
    this.child,
  }) : height = height ?? width,
       radius = radius ?? width * 0.152;

  final int seed;
  final FlowPalette palette;
  final double width;
  final double height;
  final double radius;
  final bool animate;
  final bool shadow;
  final bool glow;
  final bool circle;
  final Widget? child;

  @override
  State<FlowArtwork> createState() => _FlowArtworkState();
}

class _FlowArtworkState extends State<FlowArtwork> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  bool get _moving => widget.animate || widget.glow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(FlowArtwork old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = _moving && !MediaQuery.disableAnimationsOf(context);
    if (run) {
      final controller = _controller ??= AnimationController(vsync: this, duration: const Duration(seconds: 14));
      if (!controller.isAnimating) controller.repeat();
    } else {
      _controller?.stop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final shape = widget.circle
        ? const CircleBorder()
        : RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.radius));
    final scale = math.min(widget.width, widget.height) / 184;
    final controller = _controller;

    Widget lines = CustomPaint(
      painter: _FlowPainter(seed: widget.seed, phase: 0, color: p.light, scale: scale),
    );
    if (widget.animate && controller != null) {
      lines = AnimatedBuilder(
        animation: controller,
        builder: (context, _) => CustomPaint(
          painter: _FlowPainter(seed: widget.seed, phase: controller.value, color: p.light, scale: scale),
        ),
      );
    }

    final art = ClipPath(
      clipper: ShapeBorderClipper(shape: shape),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [p.mid, p.deep]),
              ),
            ),
            // A soft light source in the upper corner.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.7, -0.8),
                  radius: 1.1,
                  colors: [p.light.withValues(alpha: 0.55), p.light.withValues(alpha: 0)],
                ),
              ),
            ),
            RepaintBoundary(child: lines),
            ?widget.child,
            // Hairline inner edge, so the artwork reads as an object on dark grounds.
            DecoratedBox(
              decoration: ShapeDecoration(
                shape: widget.circle
                    ? CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.12)))
                    : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(widget.radius),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                      ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.shadow) return art;

    BoxDecoration shadow(double glow) => BoxDecoration(
      borderRadius: widget.circle ? null : BorderRadius.circular(widget.radius),
      shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
      boxShadow: [
        BoxShadow(
          color: p.mid.withValues(alpha: 0.28 + 0.2 * glow),
          blurRadius: 40 * scale + 12 * glow,
          offset: Offset(0, 18 * scale),
          spreadRadius: -12 * scale,
        ),
      ],
    );

    if (!widget.glow || controller == null) return DecoratedBox(decoration: shadow(0), child: art);
    // Today breathes; the rest just cast a coloured shadow.
    return AnimatedBuilder(
      animation: controller,
      child: art,
      builder: (context, child) =>
          DecoratedBox(decoration: shadow(0.5 + 0.5 * math.sin(controller.value * 2 * math.pi * 7)), child: child),
    );
  }
}

/// Gentle sine bands drifting across the artwork. Seeded, so each item has
/// its own shape.
class _FlowPainter extends CustomPainter {
  _FlowPainter({required this.seed, required this.phase, required this.color, required this.scale, this.intensity = 1});

  final int seed;

  /// 0…1, one full drift cycle.
  final double phase;
  final Color color;

  /// Artwork size relative to a 184px cover; thins the strokes on small tiles.
  final double scale;

  /// Scales every line's opacity.
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final tilt = (random.nextDouble() - 0.5) * 0.5;
    const lines = 7;
    final step = math.max(1.0, size.width / 90);
    final weight = scale.clamp(0.6, 1.0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < lines; i++) {
      final t = i / (lines - 1);
      final baseY = size.height * (0.42 + 0.5 * t);
      final amplitude = size.height * (0.03 + 0.05 * random.nextDouble());
      final waves = 1.0 + random.nextDouble() * 0.8;
      final offset = random.nextDouble() * math.pi * 2 + phase * math.pi * 2 * (i.isEven ? 1 : -1);

      final path = Path();
      for (var x = 0.0; x <= size.width + step; x += step) {
        final u = x / size.width;
        final y = baseY + amplitude * math.sin(u * waves * math.pi * 2 + offset) + tilt * (x - size.width / 2);
        x == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      paint
        ..strokeWidth = (1 + (1 - t) * 0.6) * weight
        ..color = color.withValues(alpha: (0.10 + 0.18 * (1 - t)) * intensity);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_FlowPainter old) =>
      old.phase != phase || old.seed != seed || old.color != color || old.scale != scale || old.intensity != intensity;
}

/// Just the flow lines, still, on a transparent ground — the brand motif
/// where there's no artwork to carry it (the sign-in screens).
class FlowLines extends StatelessWidget {
  const FlowLines({super.key, required this.seed, required this.color, this.intensity = 1});

  final int seed;
  final Color color;
  final double intensity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(
        painter: _FlowPainter(seed: seed, phase: 0, color: color, scale: 1, intensity: intensity),
        size: Size.infinite,
      ),
    ),
  );
}

/// The artwork's colour washed down the top of a page, behind a floating
/// top bar — the page takes on the colour of what it's about.
class ArtworkWash extends StatelessWidget {
  const ArtworkWash({super.key, required this.palette, required this.background});

  final FlowPalette palette;

  /// The page colour the wash fades into.
  final Color background;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette.mid.withValues(alpha: dark ? 0.38 : 0.2),
              palette.light.withValues(alpha: dark ? 0.08 : 0.06),
              background.withValues(alpha: 0),
            ],
            stops: const [0, 0.6, 1],
          ),
        ),
      ),
    );
  }
}
