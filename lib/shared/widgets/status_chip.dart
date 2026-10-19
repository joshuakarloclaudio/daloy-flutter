import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';

/// Uppercase status label — "LIVE NOW", "TODAY", "TOMORROW", "EMPTY".
/// A tinted wash, never a solid fill.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.background,
    this.pulse = false,
    this.dense = false,
    this.leading,
  });

  /// "Empty" / neutral badge.
  factory StatusChip.muted(BuildContext context, String label) =>
      StatusChip(label: label, color: context.colors.mutedForeground, background: context.colors.muted, dense: true);

  final String label;
  final Color color;
  final Color? background;

  /// Leading ping dot, for things happening right now.
  final bool pulse;

  /// Small rounded-rect badge instead of a pill.
  final bool dense;

  /// A small icon (or spinner) before the label.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: dense
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 3)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.14),
        borderRadius: DaloyRadii.all(dense ? DaloyRadii.sm : DaloyRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulse) ...[PulseDot(color: color), const SizedBox(width: DaloySpace.s1_5)],
          if (leading != null) ...[leading!, const SizedBox(width: DaloySpace.s1)],
          Text(
            label.toUpperCase(),
            style: context.text.labelSmall!.copyWith(color: color, letterSpacing: dense ? 0.8 : null),
          ),
        ],
      ),
    );
  }
}

/// The "live" dot with an expanding ping ring (`animate-ping`). Respects the
/// OS reduce-motion setting.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.color, this.size = 7});

  final Color color;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: DaloyMotion.pulse);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox.square(
      dimension: s,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = Curves.easeOut.transform(_controller.value);
              return Transform.scale(
                scale: 1 + t * 1.4,
                child: Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.6 * (1 - t)),
                  ),
                ),
              );
            },
          ),
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
          ),
        ],
      ),
    );
  }
}
