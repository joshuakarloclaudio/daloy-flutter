import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';

/// Pulsing placeholder block (`animate-pulse bg-muted`). Wrap a group of
/// [SkeletonBox]es in one [SkeletonPulse] so they breathe together.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
    lowerBound: 0.5,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _controller, child: widget.child);
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, required this.height, this.radius = DaloyRadii.md, this.widthFactor});

  final double? width;
  final double height;
  final double radius;

  /// Fraction of the available width, like `w-3/5`.
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: context.colors.muted, borderRadius: DaloyRadii.all(radius)),
    );
    return widthFactor == null
        ? box
        : FractionallySizedBox(widthFactor: widthFactor, alignment: Alignment.centerLeft, child: box);
  }
}
