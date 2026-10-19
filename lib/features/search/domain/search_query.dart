import 'search_text.dart';

/// The chips under the search field.
enum SearchScope {
  all('All'),
  songs('Songs'),
  lyrics('Lyrics'),
  lineUps('Line-ups');

  const SearchScope(this.label);

  final String label;
}

/// What was typed, read for musicians: `key:G` / `key:F#m` keeps songs in
/// that key, `120bpm` / `bpm:120` keeps songs within [bpmSlack] of the tempo,
/// `bpm:110-130` within a range. The rest is the free text.
class SearchQuery {
  const SearchQuery({this.text = '', this.key, this.bpm, this.scope = SearchScope.all});

  /// Either side of a single `120bpm`: close enough to swap into a set.
  static const bpmSlack = 5;

  final String text;
  final String? key;
  final ({int min, int max})? bpm;
  final SearchScope scope;

  static final _keyToken = RegExp(r'^[kK][eE][yY]:([a-gA-G])([#b♯♭]?)(m|min|minor)?$');
  static final _bpmToken = RegExp(r'^(?:bpm:(\d{2,3})(?:-(\d{2,3}))?|(\d{2,3})bpm)$', caseSensitive: false);

  factory SearchQuery.parse(String input, {SearchScope scope = SearchScope.all}) {
    String? key;
    ({int min, int max})? bpm;
    final rest = <String>[];
    for (final part in input.trim().split(RegExp(r'\s+'))) {
      if (part.isEmpty) continue;
      if (_keyToken.firstMatch(part) case final m?) {
        final accidental = switch (m[2]) {
          '♯' => '#',
          '♭' || 'b' => 'b',
          final a => a ?? '',
        };
        key = '${m[1]!.toUpperCase()}$accidental${m[3] != null ? 'm' : ''}';
      } else if (_bpmToken.firstMatch(part) case final m?) {
        if (m[3] != null || m[2] == null) {
          final at = int.parse(m[1] ?? m[3]!);
          bpm = (min: at - bpmSlack, max: at + bpmSlack);
        } else {
          final a = int.parse(m[1]!);
          final b = int.parse(m[2]!);
          bpm = (min: a < b ? a : b, max: a < b ? b : a);
        }
      } else {
        rest.add(part);
      }
    }
    return SearchQuery(text: rest.join(' '), key: key, bpm: bpm, scope: scope);
  }

  /// The free text's folded words.
  List<String> get terms => words(fold(text));

  bool get hasText => terms.isNotEmpty;

  /// A key or tempo filter: songs only.
  bool get hasMusicFilter => key != null || bpm != null;

  bool get isEmpty => !hasText && !hasMusicFilter;

  bool get wantsSongs => scope == SearchScope.all || scope == SearchScope.songs;

  /// One letter would match nearly every chart.
  bool get wantsLyrics =>
      (scope == SearchScope.all || scope == SearchScope.lyrics) && fold(text).replaceAll(' ', '').length >= 2;

  bool get wantsLineUps => !hasMusicFilter && (scope == SearchScope.all || scope == SearchScope.lineUps);

  bool get wantsActions => !hasMusicFilter && scope == SearchScope.all;

  /// Discover results: free text, and not when you've asked for
  /// line-ups or lyrics only.
  bool get wantsNetwork => hasText && (scope == SearchScope.all || scope == SearchScope.songs) && text.length >= 2;

  /// Whether [songKey] / [songBpm] pass the music filters.
  bool keepsSong(String? songKey, int? songBpm) {
    if (key != null && (songKey == null || songKey.toLowerCase() != key!.toLowerCase())) return false;
    if (bpm != null && (songBpm == null || songBpm < bpm!.min || songBpm > bpm!.max)) return false;
    return true;
  }

  /// "Key of G" / "115–125 BPM" for the token chips.
  String? get keyLabel => key == null ? null : 'Key of $key';
  String? get bpmLabel => bpm == null ? null : '${bpm!.min}–${bpm!.max} BPM';

  @override
  bool operator ==(Object other) =>
      other is SearchQuery && other.text == text && other.key == key && other.bpm == bpm && other.scope == scope;

  @override
  int get hashCode => Object.hash(text, key, bpm, scope);
}

/// [input] with its `key:` / tempo tokens taken out — tapping a token chip's ×.
String removeSearchToken(String input, {bool key = false, bool bpm = false}) => input
    .trim()
    .split(RegExp(r'\s+'))
    .where((part) => !(key && SearchQuery._keyToken.hasMatch(part)) && !(bpm && SearchQuery._bpmToken.hasMatch(part)))
    .join(' ');
