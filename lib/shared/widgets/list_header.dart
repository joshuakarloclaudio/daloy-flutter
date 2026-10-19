import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import 'list_search_field.dart';

/// Search field over a horizontal strip of [FilterPill]s — the top of a list
/// screen. It scrolls away with the content (like a native search bar); the
/// pinned section headers are what stay.
class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchHint,
    required this.chips,
  });

  /// Fixed so screens can compute exact scroll offsets.
  static const height = 112.0;
  static const _chipHeight = 36.0;

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;

  /// Pills in order; spacing is added between them.
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    final gutter = DaloySpace.gutter(context);
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: DaloySpace.s2),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: ListSearchField(controller: searchController, onChanged: onSearchChanged, hint: searchHint),
          ),
          const SizedBox(height: DaloySpace.s2_5),
          SizedBox(
            height: _chipHeight,
            child: ListView.separated(
              // Survives the strip being rebuilt (e.g. when results go empty).
              key: const PageStorageKey('list-filter-chips'),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: gutter),
              itemCount: chips.length,
              separatorBuilder: (_, _) => const SizedBox(width: DaloySpace.s2),
              itemBuilder: (_, i) => chips[i],
            ),
          ),
          const SizedBox(height: DaloySpace.s3),
        ],
      ),
    );
  }
}
