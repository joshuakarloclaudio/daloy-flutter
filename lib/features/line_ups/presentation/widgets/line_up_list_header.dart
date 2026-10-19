import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../shared/widgets/daloy_menu.dart';
import '../../../../shared/widgets/filter_pill.dart';
import '../../../../shared/widgets/list_header.dart';
import '../../domain/line_up_list_query.dart';

/// Search + chips for the Line-ups screen.
class LineUpListHeader extends StatelessWidget {
  const LineUpListHeader({
    super.key,
    required this.searchController,
    required this.query,
    required this.onSearchChanged,
    required this.onSortChanged,
    required this.onTimingToggled,
    required this.onContentToggled,
    required this.onClear,
  });

  final TextEditingController searchController;
  final LineUpListQuery query;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<LineUpSort> onSortChanged;
  final ValueChanged<LineUpTiming> onTimingToggled;
  final ValueChanged<LineUpContent> onContentToggled;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListHeader(
      searchController: searchController,
      onSearchChanged: onSearchChanged,
      searchHint: 'Search line-ups',
      chips: [
        Builder(
          builder: (pillContext) => FilterPill(
            label: query.sort.label,
            icon: TablerIcons.arrows_sort,
            onTap: () async {
              final sort = await showDaloyChoiceMenu(
                pillContext,
                title: 'Order earlier line-ups',
                options: [for (final s in LineUpSort.values) (s, s.label)],
                current: query.sort,
              );
              if (sort != null) onSortChanged(sort);
            },
          ),
        ),
        for (final timing in LineUpTiming.values)
          FilterPill(label: timing.label, active: query.timing == timing, onTap: () => onTimingToggled(timing)),
        for (final content in LineUpContent.values)
          FilterPill(label: content.label, active: query.content == content, onTap: () => onContentToggled(content)),
        if (query.hasFilters) FilterPill(label: 'Clear', icon: TablerIcons.x, onTap: onClear, quiet: true),
      ],
    );
  }
}
