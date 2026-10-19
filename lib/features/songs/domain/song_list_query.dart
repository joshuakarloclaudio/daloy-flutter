import 'package:flutter/foundation.dart';

/// Web: `SongSortOrder` ("az" | "za" | "recent" | "recently_used").
enum SongSort {
  az('A–Z'),
  za('Z–A'),
  recent('Recently added'),
  recentlyUsed('Recently used');

  const SongSort(this.label);
  final String label;

  /// Alphabetical orders get section headers and the index rail.
  bool get isAlphabetical => this == az || this == za;
}

/// Web: `SongContentFilter`.
enum SongContentFilter {
  hasChords('Has chords'),
  hasLyrics('Has lyrics'),
  draft('Drafts');

  const SongContentFilter(this.label);
  final String label;
}

/// Everything the Songs screen can ask of the local library. Value-equal so
/// a provider only re-queries when something really changed.
@immutable
class SongListQuery {
  const SongListQuery({this.search = '', this.sort = SongSort.az, this.key, this.content});

  final String search;
  final SongSort sort;
  final String? key;
  final SongContentFilter? content;

  bool get hasFilters => key != null || content != null;
  bool get isDefault => search.trim().isEmpty && !hasFilters;

  SongListQuery copyWith({String? search, SongSort? sort}) =>
      SongListQuery(search: search ?? this.search, sort: sort ?? this.sort, key: key, content: content);

  /// Nullable fields need to be settable *to* null, so they get their own
  /// method rather than a `copyWith` parameter.
  SongListQuery withFilters({String? key, SongContentFilter? content}) =>
      SongListQuery(search: search, sort: sort, key: key, content: content);

  @override
  bool operator ==(Object other) =>
      other is SongListQuery &&
      other.search == search &&
      other.sort == sort &&
      other.key == key &&
      other.content == content;

  @override
  int get hashCode => Object.hash(search, sort, key, content);
}

/// The letter a title files under in an alphabetical list; `#` for digits,
/// punctuation and anything outside A–Z.
String songSectionLetter(String title) {
  final trimmed = title.trimLeft();
  if (trimmed.isEmpty) return '#';
  final first = trimmed[0].toUpperCase();
  final code = first.codeUnitAt(0);
  return code >= 0x41 && code <= 0x5A ? first : '#';
}

/// The keys offered by the key filter, in the order the web lists them
/// (`SONG_KEYS`).
const songKeys = ['C', 'D', 'E', 'F', 'G', 'A', 'B', 'Bb', 'Eb', 'F#', 'Ab', 'Am', 'Bm', 'Cm', 'Dm', 'Em', 'F#m', 'Gm'];
