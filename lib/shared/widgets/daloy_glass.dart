import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';

/// The fallback rendering of Liquid Glass: frosted blur, a tint of the page
/// colour, a bright top sheen, a hairline edge and a soft shadow, so chrome
/// reads as floating. `docs/flutter-ios-components.md` §3 is the recipe.
///
/// Glass only floats: bars, buttons over content, menus, toasts, partial
/// sheets. Content stays flat, and glass is never nested or put in a list.
/// One [BackdropFilter] per instance.
class DaloyGlass extends StatelessWidget {
  const DaloyGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(DaloyRadii.xl)),
    this.circle = false,
    this.tintAlpha,
    this.tint,
    this.shadow = true,
    this.sheen = true,
    this.hairline = true,
    this.border,
    this.flat = false,
  });

  /// Bars, toasts and chrome buttons: fully rounded ends.
  const DaloyGlass.capsule({
    super.key,
    required this.child,
    this.tintAlpha,
    this.tint,
    this.shadow = true,
    this.sheen = true,
    this.hairline = true,
    this.border,
    this.flat = false,
  }) : borderRadius = const BorderRadius.all(Radius.circular(DaloyRadii.full)),
       circle = false;

  /// Icon buttons and the primary action.
  const DaloyGlass.circle({
    super.key,
    required this.child,
    this.tintAlpha,
    this.tint,
    this.shadow = true,
    this.sheen = true,
    this.hairline = true,
    this.border,
    this.flat = false,
  }) : borderRadius = null,
       circle = true;

  /// Menus and alerts: [radius] 14 for menus, 28 for alerts.
  DaloyGlass.panel({
    super.key,
    required this.child,
    double radius = 14,
    double? tintAlpha,
    this.tint,
    this.shadow = true,
    this.sheen = true,
    this.hairline = true,
    this.border,
    this.flat = false,
  }) : borderRadius = BorderRadius.all(Radius.circular(radius)),
       tintAlpha = tintAlpha ?? _denseAlpha,
       circle = false;

  /// Partial-height sheets, inset from the screen edges. Radius matches the
  /// device corners.
  const DaloyGlass.sheet({
    super.key,
    required this.child,
    double? tintAlpha,
    this.tint,
    this.shadow = true,
    this.sheen = true,
    this.hairline = true,
    this.border,
    this.flat = false,
  }) : borderRadius = const BorderRadius.all(Radius.circular(34)),
       tintAlpha = tintAlpha ?? _denseAlpha,
       circle = false;

  /// Menus, alerts and sheets hold rows of text, so they frost more than
  /// bars and buttons do.
  static const _denseAlpha = 0.62;

  /// Behind the tint: the blur, with the colour turned up so what's under
  /// the glass shows through bright, not greyed.
  static final _backdrop = ImageFilter.compose(
    outer: const ColorFilter.matrix(_saturate),
    inner: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
  );

  /// Saturation 1.6, weighted by luminance (Rec. 709).
  static const _saturate = <double>[
    1.4725, -0.4290, -0.0434, 0, 0, //
    -0.1275, 1.1710, -0.0434, 0, 0, //
    -0.1275, -0.4290, 1.5566, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  final Widget child;

  /// Ignored when [circle].
  final BorderRadius? borderRadius;
  final bool circle;

  /// Overrides the tint's opacity (Perform needs more behind a chart).
  final double? tintAlpha;

  /// Replaces the page-colour tint, e.g. the teal of the primary action.
  final Color? tint;
  final bool shadow;
  final bool sheen;

  /// The bright edge. Off for bars that draw their own border.
  final bool hairline;

  /// Replaces the hairline, e.g. a bottom rule on a top bar.
  final Border? border;

  /// E-ink and other panels where blur and translucency smear: no blur, a
  /// solid fill.
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = circle ? BoxShape.circle : BoxShape.rectangle;
    final radius = circle ? null : borderRadius;
    final edge =
        border ?? (hairline ? Border.all(color: Colors.white.withValues(alpha: dark ? 0.08 : 0.6), width: 0.75) : null);

    // Two layers: a decoration's gradient replaces its colour, so the tint and
    // the sheen can't share one.
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: radius,
        color: flat
            ? (tint ?? c.background)
            : (tint ?? (dark ? c.card : c.background)).withValues(alpha: tintAlpha ?? (dark ? 0.55 : 0.5)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: radius,
          border: edge,
          gradient: flat || !sheen
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: dark ? 0.05 : 0.2),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
        ),
        child: child,
      ),
    );

    Widget frosted = flat ? surface : BackdropFilter(filter: _backdrop, child: surface);
    frosted = circle ? ClipOval(child: frosted) : ClipRRect(borderRadius: radius ?? BorderRadius.zero, child: frosted);

    if (!shadow || flat) return frosted;
    return CustomPaint(
      painter: _OuterShadow(
        circle: circle,
        radius: radius,
        shadows: [
          // A wide, soft lift and a tight contact line that edges the glass on
          // a page of the same colour.
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.4 : 0.1),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.3 : 0.07),
            blurRadius: 2,
            offset: const Offset(0, 0.5),
          ),
        ],
      ),
      child: frosted,
    );
  }
}

/// The shadow outside the shape only: under translucent glass a full shadow
/// shows through and greys it.
class _OuterShadow extends CustomPainter {
  _OuterShadow({required this.circle, required this.radius, required this.shadows});

  final bool circle;
  final BorderRadius? radius;
  final List<BoxShadow> shadows;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final corner = math.min(radius?.topLeft.x ?? 0, size.shortestSide / 2);
    final shape = circle
        ? (Path()..addOval(rect))
        : (Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(corner))));

    canvas
      ..save()
      ..clipPath(Path.combine(PathOperation.difference, Path()..addRect(rect.inflate(80)), shape));
    for (final s in shadows) {
      canvas.drawPath(shape.shift(s.offset), s.toPaint());
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OuterShadow old) =>
      old.circle != circle || old.radius != radius || !listEquals(old.shadows, shadows);
}
