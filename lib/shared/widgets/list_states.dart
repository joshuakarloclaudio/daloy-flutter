import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import 'daloy_button.dart';
import 'skeleton.dart';

/// Placeholder rows (tile + two lines) while the first sync fills an empty library.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final gutter = DaloySpace.gutter(context);
    return SkeletonPulse(
      child: Column(
        children: [
          for (var i = 0; i < 9; i++)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter, vertical: DaloySpace.s3),
              child: Row(
                children: [
                  const SkeletonBox(width: 40, height: 40, radius: DaloyRadii.xl),
                  const SizedBox(width: DaloySpace.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(widthFactor: i.isEven ? 0.6 : 0.45, height: 14, radius: DaloyRadii.md),
                        const SizedBox(height: DaloySpace.s2),
                        SkeletonBox(widthFactor: i.isEven ? 0.35 : 0.5, height: 12, radius: DaloyRadii.md),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A soft, bordered panel standing in for content a section doesn't have
/// yet ("No songs yet", "Songs not on this device yet"), with an optional
/// way to fix it.
class InsetPlaceholder extends StatelessWidget {
  const InsetPlaceholder({super.key, required this.icon, required this.title, this.body, this.action});

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s6, vertical: DaloySpace.s8),
      decoration: BoxDecoration(
        color: c.muted.withValues(alpha: 0.35),
        border: Border.all(color: c.border),
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: c.mutedForeground),
          const SizedBox(height: DaloySpace.s3),
          Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
          if (body != null) ...[
            const SizedBox(height: DaloySpace.s1),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
            ),
          ],
          if (action != null) ...[const SizedBox(height: DaloySpace.s4), action!],
        ],
      ),
    );
  }
}

/// Centered message for an empty library or a search/filter with no hits.
class ListEmptyState extends StatelessWidget {
  const ListEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DaloySpace.s8, DaloySpace.s10, DaloySpace.s8, DaloySpace.s6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.xl2)),
            child: Icon(icon, size: 26, color: c.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s4),
          Text(title, style: context.text.titleMedium),
          const SizedBox(height: DaloySpace.s1_5),
          Text(
            description,
            textAlign: TextAlign.center,
            style: context.text.bodyMedium!.copyWith(color: c.mutedForeground, height: 1.4),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: DaloySpace.s4),
            DaloyButton(
              variant: ButtonVariant.link,
              size: ControlSize.sm,
              label: actionLabel!,
              icon: actionIcon,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
