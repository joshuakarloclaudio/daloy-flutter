import 'package:flutter/foundation.dart';

/// How Discover orders its songs (`NetworkSortOrder` on the web).
enum DiscoverSort {
  recent('recently_shared', 'Recently shared'),
  popular('most_added', 'Most added'),
  az('a_to_z', 'A–Z');

  const DiscoverSort(this.api, this.label);

  final String api;
  final String label;
}

/// Whose songs: everyone's, other teams' (browse), or ours ("Shared by us").
enum DiscoverScope {
  all('all'),
  others('others'),
  own('own');

  const DiscoverScope(this.api);

  final String api;
}

/// A tempo band, matched against a song's BPM.
enum DiscoverTempo {
  slow('Slow', 'Under 80', null, 79),
  mid('Mid', '80–110', 80, 110),
  upbeat('Upbeat', '110–140', 111, 140),
  fast('Fast', 'Over 140', 141, null);

  const DiscoverTempo(this.label, this.range, this.min, this.max);

  final String label;
  final String range;
  final int? min;
  final int? max;
}

/// Everything Discover can ask of the API. Value-equal so a change reloads
/// the list and nothing else does.
@immutable
class DiscoverQuery {
  const DiscoverQuery({
    this.search = '',
    this.sort = DiscoverSort.recent,
    this.key,
    this.tempo,
    this.scope = DiscoverScope.others,
  });

  final String search;
  final DiscoverSort sort;
  final String? key;
  final DiscoverTempo? tempo;
  final DiscoverScope scope;

  bool get hasFilters => key != null || tempo != null;
  bool get isDefault => search.trim().isEmpty && !hasFilters && sort == DiscoverSort.recent;

  DiscoverQuery copyWith({String? search, DiscoverSort? sort, DiscoverScope? scope}) => DiscoverQuery(
    search: search ?? this.search,
    sort: sort ?? this.sort,
    key: key,
    tempo: tempo,
    scope: scope ?? this.scope,
  );

  /// Nullable filters need to be settable *to* null.
  DiscoverQuery withFilters({String? key, DiscoverTempo? tempo}) =>
      DiscoverQuery(search: search, sort: sort, key: key, tempo: tempo, scope: scope);

  @override
  bool operator ==(Object other) =>
      other is DiscoverQuery &&
      other.search == search &&
      other.sort == sort &&
      other.key == key &&
      other.tempo == tempo &&
      other.scope == scope;

  @override
  int get hashCode => Object.hash(search, sort, key, tempo, scope);
}
