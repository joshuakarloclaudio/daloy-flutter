import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/pressable.dart';

/// `−  label  +` in a flat bordered track (`TransposeStepper`). Used for the
/// key and the capo.
class StepperTrack extends StatelessWidget {
  const StepperTrack({
    super.key,
    required this.label,
    required this.decreaseLabel,
    required this.increaseLabel,
    this.onDecrease,
    this.onIncrease,
  });

  final String label;
  final String decreaseLabel;
  final String increaseLabel;

  /// Null disables that side.
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: ControlSize.md.height,
      decoration: BoxDecoration(
        color: c.muted.withValues(alpha: 0.5),
        border: Border.all(color: c.border),
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
      ),
      child: Row(
        children: [
          _Step(icon: TablerIcons.minus, label: decreaseLabel, onPressed: onDecrease),
          Expanded(
            // The value fades through as it changes, so a tap reads as a step.
            child: AnimatedSwitcher(
              duration: DaloyMotion.fast,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(animation), child: child),
              ),
              child: Text(
                label,
                key: ValueKey(label),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
          ),
          _Step(icon: TablerIcons.plus, label: increaseLabel, onPressed: onIncrease),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      semanticLabel: label,
      pressedScale: 0.9,
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onPressed!();
            },
      child: SizedBox(
        width: 40,
        height: ControlSize.md.height,
        child: Icon(icon, size: 18, color: onPressed == null ? c.mutedForeground.withValues(alpha: 0.4) : c.foreground),
      ),
    );
  }
}
