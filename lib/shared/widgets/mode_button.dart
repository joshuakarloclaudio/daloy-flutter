import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import 'pressable.dart';

/// One of the big ways into a thing (Perform, Practice): 52px, rounded,
/// [filled] for the main one — emerald when it's [today], with a coloured
/// lift. Unfilled ones sit on Quiet Mist.
class ModeButton extends StatelessWidget {
  const ModeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.today = false,
    this.dimmed = false,
    this.height = 52,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;
  final bool today;

  /// Looks unavailable but still answers a tap (with why).
  final bool dimmed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fill = today ? c.today : c.primary;
    final bg = filled ? fill : c.muted;
    final fg = filled ? (today ? Colors.white : c.primaryForeground) : c.foreground;

    return Opacity(
      opacity: dimmed ? 0.45 : 1,
      child: Pressable(
        onPressed: onPressed,
        semanticLabel: label,
        pressedScale: 0.96,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: DaloyRadii.all(16),
            boxShadow: filled && !dimmed
                ? [
                    BoxShadow(
                      color: fill.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      spreadRadius: -6,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 19, color: fg),
              const SizedBox(width: DaloySpace.s2),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium!.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The quieter ways in, under the [ModeButton]s: a teal glyph and a label,
/// no surface.
class QuietAction extends StatelessWidget {
  const QuietAction({super.key, required this.icon, required this.label, required this.onPressed, this.dimmed = false});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = dimmed ? c.mutedForeground.withValues(alpha: 0.6) : c.foreground;
    return Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      child: SizedBox(
        height: ControlSize.lg.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: dimmed ? fg : c.primaryInk),
            const SizedBox(width: DaloySpace.s1_5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge!.copyWith(color: fg, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small all-caps section label ("SETLIST", "KEY & CAPO") that heads a
/// part of a detail screen.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label.toUpperCase(),
          style: context.text.labelSmall!.copyWith(color: context.colors.mutedForeground),
        ),
      ),
      ?trailing,
    ],
  );
}
