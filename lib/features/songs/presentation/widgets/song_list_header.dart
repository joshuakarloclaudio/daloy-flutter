import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../shared/widgets/daloy_menu.dart';
import '../../../../shared/widgets/filter_pill.dart';
import '../../../../shared/widgets/list_header.dart';
import '../../domain/song_list_query.dart';
import 'song_list_sheets.dart';

/// The search field and filter chips above the list. Scrolls away with the
/// content (like a native search bar); the letter headers are what pin.
class SongListHeader extends StatelessWidget {
  const SongListHeader({
    super.key,
    required this.searchController,
    required this.query,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onKeyChanged,
    required this.onContentToggled,
    required this.onClear,
  });

  static const height = ListHeader.height;

  final TextEditingController searchController;
  final SongListQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SongSort> onSortChanged;
  final ValueChanged<String?> onKeyChanged;
  final ValueChanged<SongContentFilter> onContentToggled;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListHeader(
      searchController: searchController,
      onSearchChanged: onSearchChanged,
      searchHint: 'Search songs',
      chips: [
        Builder(
          builder: (pillContext) => FilterPill(
            label: query.sort.label,
            icon: TablerIcons.arrows_sort,
            onTap: () async {
              final sort = await showDaloyChoiceMenu(
                pillContext,
                title: 'Sort by',
                options: [for (final s in SongSort.values) (s, s.label)],
                current: query.sort,
              );
              if (sort != null) onSortChanged(sort);
            },
          ),
        ),
        Builder(
          builder: (pillContext) => FilterPill(
            label: query.key == null ? 'Key' : 'Key: ${query.key}',
            icon: TablerIcons.chevron_down,
            trailingIcon: true,
            active: query.key != null,
            onTap: () async {
              final result = await showKeySheet(context, query.key, anchor: anchorOf(pillContext));
              if (result != null) onKeyChanged(result.key);
            },
          ),
        ),
        for (final filter in SongContentFilter.values)
          FilterPill(label: filter.label, active: query.content == filter, onTap: () => onContentToggled(filter)),
        if (query.hasFilters) FilterPill(label: 'Clear', icon: TablerIcons.x, onTap: onClear, quiet: true),
      ],
    );
  }
}
