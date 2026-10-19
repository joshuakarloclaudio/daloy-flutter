import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/daloy_theme.dart';
import 'pressable.dart';

/// A filter / sort pill in a list header's chip strip. Outlined when idle,
/// teal-washed when [active]; [quiet] is a plain text action ("Clear").
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.trailingIcon = false,
    this.active = false,
    this.quiet = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool trailingIcon;
  final bool active;

  /// Plain text action ("Clear") rather than a toggle.
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = active ? c.primaryInk : (quiet ? c.mutedForeground : c.foreground);
    final glyph = icon == null ? null : Icon(icon, size: 15, color: active ? c.primaryInk : c.mutedForeground);
    return Pressable(
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      pressedScale: 0.96,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3_5),
        decoration: BoxDecoration(
          color: active ? c.primary.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(color: active ? c.primary.withValues(alpha: 0.35) : c.border),
          borderRadius: DaloyRadii.all(DaloyRadii.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (glyph != null && !trailingIcon) ...[glyph, const SizedBox(width: DaloySpace.s1_5)],
            Text(label, style: context.text.labelLarge!.copyWith(color: fg)),
            if (glyph != null && trailingIcon) ...[const SizedBox(width: DaloySpace.s1), glyph],
          ],
        ),
      ),
    );
  }
}
