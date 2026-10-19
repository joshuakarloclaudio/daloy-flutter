import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import 'daloy_glass.dart';
import 'pressable.dart';

const _hit = 44.0;
const _visual = 36.0;

/// A round chrome button over content (top bars, Perform, the player): a
/// frosted 36pt circle in a 44pt hit target. [prominent] tints it with the
/// accent.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.prominent = false,
  });

  final IconData icon;

  /// Spoken label; the button itself is icon-only.
  final String label;
  final VoidCallback? onPressed;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      pressedScale: 0.92,
      child: SizedBox.square(
        dimension: _hit,
        child: Center(
          child: SizedBox.square(
            dimension: _visual,
            child: DaloyGlass.circle(
              tint: prominent ? c.primary : null,
              tintAlpha: prominent ? 0.9 : null,
              child: Icon(icon, color: prominent ? c.primaryForeground : c.foreground, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

/// A capsule chrome button with a text label, for a verb ("Add", "Share").
/// Frosted like [GlassIconButton].
class GlassTextButton extends StatelessWidget {
  const GlassTextButton({super.key, required this.label, required this.onPressed, this.prominent = false});

  final String label;
  final VoidCallback? onPressed;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      pressedScale: 0.96,
      child: SizedBox(
        height: _hit,
        child: Center(
          child: SizedBox(
            height: _visual,
            child: DaloyGlass.capsule(
              tint: prominent ? c.primary : null,
              tintAlpha: prominent ? 0.9 : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    label,
                    style: context.text.labelLarge!.copyWith(
                      color: prominent ? c.primaryForeground : c.foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
