import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';

/// A section label that pins under the top bar while its rows scroll
/// (`SliverPersistentHeader(pinned: true)`). Opaque so rows pass cleanly beneath it.
class PinnedSectionHeader extends SliverPersistentHeaderDelegate {
  const PinnedSectionHeader({required this.label, required this.colors, required this.text});

  static const height = 30.0;

  final String label;
  final DaloyColors colors;
  final TextTheme text;

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4),
      decoration: BoxDecoration(
        color: colors.background,
        border: overlapsContent ? Border(bottom: BorderSide(color: colors.border)) : null,
      ),
      child: Text(label, style: text.labelLarge!.copyWith(color: colors.primaryInk)),
    );
  }

  @override
  bool shouldRebuild(PinnedSectionHeader old) => old.label != label || old.colors != colors || old.text != text;
}
