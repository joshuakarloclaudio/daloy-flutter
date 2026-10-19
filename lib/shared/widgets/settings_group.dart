import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/daloy_theme.dart';
import 'hairline.dart';

/// One flat bordered surface holding a few rows, hairlines inset past the
/// leading tile.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
        side: BorderSide(color: c.border),
      ),
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) Hairline(indent: DaloySpace.s4 + 32 + DaloySpace.s3, color: c.border.withValues(alpha: 0.7)),
            child,
          ],
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.leading,
    required this.title,
    this.onTap,
    this.subtitle,
    this.trailing,
    this.destructive = false,
    this.chevron = true,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool destructive;

  /// The disclosure arrow; off for rows that hold a switch of their own.
  final bool chevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return InkWell(
      onTap: onTap,
      splashFactory: isIOS ? NoSplash.splashFactory : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s2_5),
          child: Row(
            children: [
              leading,
              const SizedBox(width: DaloySpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleMedium!.copyWith(color: destructive ? c.destructive : null),
                    ),
                    if (subtitle != null)
                      Text(subtitle!, style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: DaloySpace.s2), trailing!],
              if (!destructive && chevron) ...[
                const SizedBox(width: DaloySpace.s1),
                Icon(TablerIcons.chevron_right, size: 18, color: c.mutedForeground.withValues(alpha: 0.6)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsGlyph extends StatelessWidget {
  const SettingsGlyph(this.icon, {super.key, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = color ?? c.primaryInk;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: tint.withValues(alpha: 0.1), borderRadius: DaloyRadii.all(DaloyRadii.md)),
      child: Icon(icon, size: 17, color: tint),
    );
  }
}
