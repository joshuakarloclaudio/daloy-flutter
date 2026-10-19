import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/formatters.dart';
import 'line_up.dart';

/// Web: `LineUpSortOrder`. Applies to *Earlier*; Coming up is always soonest first.
enum LineUpSort {
  newestFirst('Newest first'),
  oldestFirst('Oldest first');

  const LineUpSort(this.label);
  final String label;
}

/// Web: `LineUpTimingFilter`.
enum LineUpTiming {
  upcoming('Coming up'),
  past('Earlier');

  const LineUpTiming(this.label);
  final String label;
}

/// Web: `LineUpContentFilter`.
enum LineUpContent {
  hasSongs('Has songs'),
  empty('Empty');

  const LineUpContent(this.label);
  final String label;
}

@immutable
class LineUpListQuery {
  const LineUpListQuery({this.search = '', this.sort = LineUpSort.newestFirst, this.timing, this.content});

  final String search;
  final LineUpSort sort;
  final LineUpTiming? timing;
  final LineUpContent? content;

  bool get hasFilters => timing != null || content != null;
  bool get isDefault => search.trim().isEmpty && !hasFilters;

  LineUpListQuery copyWith({String? search, LineUpSort? sort}) =>
      LineUpListQuery(search: search ?? this.search, sort: sort ?? this.sort, timing: timing, content: content);

  /// Nullable fields need to be settable *to* null, so they get their own method.
  LineUpListQuery withFilters({LineUpTiming? timing, LineUpContent? content}) =>
      LineUpListQuery(search: search, sort: sort, timing: timing, content: content);

  @override
  bool operator ==(Object other) =>
      other is LineUpListQuery &&
      other.search == search &&
      other.sort == sort &&
      other.timing == timing &&
      other.content == content;

  @override
  int get hashCode => Object.hash(search, sort, timing, content);
}

/// Web: `matchesLineUpSearch` — title, leader, ISO date, or the date as written
/// ("Oct 15, 2026" / "October").
bool lineUpMatchesSearch(LineUp lineUp, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  final date = DateTime.parse('${lineUp.date}T12:00:00');
  return lineUp.title.toLowerCase().contains(q) ||
      (lineUp.leader?.toLowerCase().contains(q) ?? false) ||
      lineUp.date.contains(q) ||
      formatLineUpDate(lineUp.date).toLowerCase().contains(q) ||
      DateFormat.MMMM().format(date).toLowerCase().contains(q);
}

class LineUpSection {
  const LineUpSection({required this.id, required this.label, required this.lineUps});

  final String id;
  final String label;
  final List<LineUp> lineUps;
}

/// Agenda sections: *Coming up* (today onward, soonest first), then one
/// section per month of earlier line-ups in [sort] order.
List<LineUpSection> groupLineUps(List<LineUp> lineUps, {required String today, required LineUpSort sort}) {
  int byDate(LineUp a, LineUp b) {
    final c = a.date.compareTo(b.date);
    return c != 0 ? c : a.id.compareTo(b.id);
  }

  final upcoming = lineUps.where((l) => l.date.compareTo(today) >= 0).toList()..sort(byDate);
  final past = lineUps.where((l) => l.date.compareTo(today) < 0).toList()..sort(byDate);
  if (sort == LineUpSort.newestFirst) {
    final reversed = past.reversed.toList();
    past
      ..clear()
      ..addAll(reversed);
  }

  final sections = <LineUpSection>[
    if (upcoming.isNotEmpty) LineUpSection(id: 'upcoming', label: 'Coming up', lineUps: upcoming),
  ];
  final months = <String, List<LineUp>>{};
  for (final l in past) {
    months.putIfAbsent(l.date.substring(0, 7), () => []).add(l);
  }
  for (final entry in months.entries) {
    final label = DateFormat.yMMMM().format(DateTime.parse('${entry.key}-01T12:00:00'));
    sections.add(LineUpSection(id: entry.key, label: label, lineUps: entry.value));
  }
  return sections;
}
