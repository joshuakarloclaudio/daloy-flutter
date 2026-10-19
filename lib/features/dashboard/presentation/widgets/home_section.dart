import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/hairline.dart';
import '../../../../shared/widgets/pressable.dart';

/// A band of Home under a native-style section header: a bold title that,
/// when the band has more to show, is itself the way onward (title + chevron,
/// like an App Store or Music shelf) instead of a separate "View all" link.
///
/// Home's column is [bleed] wider on each side than the page gutter allows,
/// so a [HomeList]'s rows reach into the gutter. Everything else here (the
/// title, cards, empty states) is padded back in.
class HomeSection extends StatelessWidget {
  const HomeSection({super.key, required this.label, required this.child, this.onViewAll});

  /// How far a [HomeList] reaches past the column: a row's own padding, so
  /// its text lines up with the section title.
  static const bleed = DaloySpace.s4;

  final String label;
  final Widget child;

  /// Makes the header tappable and adds the chevron.
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final title = Text(label, style: context.text.titleLarge!.copyWith(fontSize: 19));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: bleed),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 44,
              child: onViewAll == null
                  ? Align(alignment: Alignment.centerLeft, child: title)
                  : Pressable(
                      onPressed: onViewAll,
                      pressedScale: 0.98,
                      semanticLabel: '$label, see all',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(child: title),
                          const SizedBox(width: 2),
                          Icon(TablerIcons.chevron_right, size: 20, color: c.mutedForeground),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: DaloySpace.s1),
        // Skeleton → content (or empty state) cross-fades instead of popping.
        AnimatedSwitcher(
          duration: DaloyMotion.medium,
          switchInCurve: DaloyMotion.ease,
          layoutBuilder: (current, previous) =>
              Stack(alignment: Alignment.topCenter, children: [...previous, ?current]),
          child: child is HomeList
              ? child
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: bleed),
                  child: child,
                ),
        ),
      ],
    );
  }
}

/// A plain list, the way Apple lays out Home-style shelves: no card around
/// it, rows reaching [HomeSection.bleed] into the gutter so their press
/// highlight and their lift (touch and hold) have room around the text, and
/// hairlines across the column, lined up with the text at both ends.
class HomeList extends StatelessWidget {
  const HomeList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        for (final (i, child) in children.indexed) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: HomeSection.bleed),
              child: Hairline(color: c.border.withValues(alpha: 0.7)),
            ),
          child,
        ],
      ],
    );
  }
}
