import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';

/// Quiet placeholder for a band with nothing in it yet: a soft muted
/// surface with an icon, one line of guidance and an optional action.
class EmptySection extends StatelessWidget {
  const EmptySection({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tile = compact ? 36.0 : 40.0;
    return Container(
      decoration: BoxDecoration(color: c.muted.withValues(alpha: 0.5), borderRadius: DaloyRadii.all(DaloyRadii.xl)),
      padding: EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: compact ? DaloySpace.s3_5 : DaloySpace.s4),
      child: Row(
        crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            width: tile,
            height: tile,
            decoration: BoxDecoration(color: c.background, borderRadius: DaloyRadii.all(DaloyRadii.lg)),
            child: Icon(icon, size: 20, color: c.mutedForeground),
          ),
          const SizedBox(width: DaloySpace.s3_5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(description, style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
                if (action != null) ...[const SizedBox(height: DaloySpace.s2), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
