/// Nashville Number System display transform — port of the render half of the
/// web's `lib/nashville.ts`. Numbers are never stored: `content` always holds
/// letter chords, and this derives numbers from `content` + the song's key.
library;

import 'chord_math.dart';

enum ChordNotation {
  letters,
  numbers;

  static ChordNotation parse(String? value) => value == 'numbers' ? numbers : letters;
}

const _letters = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
const _letterPitch = [0, 2, 4, 5, 7, 9, 11];
const _majorDegreePitch = [0, 2, 4, 5, 7, 9, 11];

typedef _Tonic = ({String tonic, int letterIndex, int pitchClass});

/// A chord split into the pieces a renderer styles apart.
typedef NashvilleParts = ({String degree, String quality, String? bass});

int _accidentalOffset(String accidental) {
  var offset = 0;
  for (final char in accidental.split('')) {
    if (char == '#') offset++;
    if (char == 'b') offset--;
  }
  return offset;
}

int _wrapDelta(int delta) {
  if (delta > 6) return delta - 12;
  if (delta < -6) return delta + 12;
  return delta;
}

String? _spell(int letterIndex, int pitchClass) {
  final delta = _wrapDelta((((pitchClass - _letterPitch[letterIndex]) % 12) + 12) % 12);
  if (delta.abs() > 2) return null;
  final accidental = delta == 0 ? '' : (delta > 0 ? '#' * delta : 'b' * -delta);
  return _letters[letterIndex] + accidental;
}

({int letterIndex, int pitchClass})? _parseNote(String note) {
  final match = RegExp(r'^([A-G])([b#]{0,2})$').firstMatch(note.trim());
  if (match == null) return null;
  final letterIndex = _letters.indexOf(match[1]!);
  final pitch = (((_letterPitch[letterIndex] + _accidentalOffset(match[2]!)) % 12) + 12) % 12;
  return (letterIndex: letterIndex, pitchClass: pitch);
}

/// The major tonic a key's numbers count from. "Am" is numbered against C.
_Tonic? _tonicInfo(String? musicalKey) {
  if (musicalKey == null || musicalKey.isEmpty) return null;
  final match = RegExp(r'^([A-G])([b#]{0,2})(.*)$').firstMatch(musicalKey.trim());
  if (match == null) return null;
  final suffix = match[3]!.trim();
  final isMinor = RegExp(r'^(m|min|minor)$', caseSensitive: false).hasMatch(suffix) && suffix != 'M';
  final isMajor = suffix.isEmpty || suffix == 'M' || RegExp(r'^(maj|major)$', caseSensitive: false).hasMatch(suffix);
  if (!isMinor && !isMajor) return null;
  final parsed = _parseNote(match[1]! + match[2]!);
  if (parsed == null) return null;
  final letterIndex = isMinor ? (parsed.letterIndex + 2) % 7 : parsed.letterIndex;
  final pitchClass = isMinor ? (parsed.pitchClass + 3) % 12 : parsed.pitchClass;
  final tonic = _spell(letterIndex, pitchClass);
  if (tonic == null) return null;
  return (tonic: tonic, letterIndex: letterIndex, pitchClass: pitchClass);
}

bool canUseNumbers(String? musicalKey) => _tonicInfo(musicalKey) != null;

/// "G" → "1 = G"; "Am" → "1 = C".
String? numberingLabel(String? musicalKey) {
  final tonic = _tonicInfo(musicalKey);
  return tonic == null ? null : '1 = ${tonic.tonic}';
}

String? _rootToDegree(String root, _Tonic tonic) {
  final parsed = _parseNote(root);
  if (parsed == null) return null;
  final degree = ((parsed.letterIndex - tonic.letterIndex + 7) % 7) + 1;
  final expected = _majorDegreePitch[degree - 1];
  final actual = (((parsed.pitchClass - tonic.pitchClass) % 12) + 12) % 12;
  final delta = _wrapDelta(actual - expected);
  if (delta.abs() > 2) return null;
  final prefix = delta == 0 ? '' : (delta > 0 ? '#' * delta : 'b' * -delta);
  return '$prefix$degree';
}

// Longest spelling first, or `min7b5` would match the `min` rule.
const _qualitySymbols = [
  ('min7b5', 'ø7'),
  ('m7b5', 'ø7'),
  ('min7-5', 'ø7'),
  ('m7-5', 'ø7'),
  ('dim', '°'),
  ('aug', '+'),
  ('maj', 'Δ'),
  ('min', 'm'),
  ('M', 'Δ'),
];

String _nashvilleQuality(String quality) {
  if (quality.isEmpty || quality == 'M' || quality == 'maj') return '';
  if (quality == 'min' || quality == '-') return 'm';
  for (final (from, to) in _qualitySymbols) {
    if (quality.startsWith(from)) return to + quality.substring(from.length);
  }
  return quality;
}

/// The symbol run at the head of a quality (`Δ` in `Δ7`).
final qualitySymbolPattern = RegExp(r'^[°ø+Δ]+');

/// Null when the key is unusable or the chord unparseable — callers fall back
/// to the letter chord for that one token.
NashvilleParts? chordToNashvilleParts(String chord, String? musicalKey) {
  final tonic = _tonicInfo(musicalKey);
  if (tonic == null) return null;
  final parsed = parseChordInner(chord);
  if (parsed == null) return null;
  final degree = _rootToDegree(parsed.root, tonic);
  if (degree == null) return null;
  String? bass;
  if (parsed.bass != null) {
    // Never emit a half-converted "1/B".
    bass = _rootToDegree(parsed.bass!, tonic);
    if (bass == null) return null;
  }
  return (degree: degree, quality: _nashvilleQuality(parsed.quality), bass: bass);
}

/// What the chart prints for one chord token. Numbers are key-invariant, so
/// transposition only ever applies to letters.
String displayChord(String token, ChordNotation notation, String? musicalKey, int transposition) {
  if (notation == ChordNotation.numbers) {
    final parts = chordToNashvilleParts(token, musicalKey);
    if (parts != null) return '${parts.degree}${parts.quality}${parts.bass == null ? '' : '/${parts.bass}'}';
  }
  return transposeChord(token, transposition);
}

// -- Number entry (the editor's input half; web `nashvilleToChord`, diatonic) --

String? _degreeToRoot(String degreeToken, _Tonic tonic) {
  final match = RegExp(r'^([b#]{0,2})([1-7])$').firstMatch(degreeToken);
  if (match == null) return null;
  final degree = int.parse(match[2]!);
  final letterIndex = (tonic.letterIndex + degree - 1) % 7;
  final pitchClass =
      (((tonic.pitchClass + _majorDegreePitch[degree - 1] + _accidentalOffset(match[1]!)) % 12) + 12) % 12;
  return _spell(letterIndex, pitchClass);
}

// The inverse of the display table, plus spellings pasted from other tools.
const _symbolQualities = [
  ('ø7', 'm7b5'),
  ('ø', 'm7b5'),
  ('°', 'dim'),
  ('Δ', 'maj'),
  ('+', 'aug'),
  ('min', 'm'),
  ('-', 'm'),
];

String _letterQuality(String quality) {
  if (quality.isEmpty) return '';
  // A lone triangle is a major *seventh*, not a major triad.
  if (quality == 'Δ') return 'maj7';
  if (quality == '-' || quality == 'min') return 'm';
  for (final (from, to) in _symbolQualities) {
    if (quality.startsWith(from)) return to + quality.substring(from.length);
  }
  return quality;
}

/// Nashville number → letter chord: `"1"`, `"6m"`, `"b7"`, `"#4maj7"`, `"1/3"`.
/// Null when the key is unusable or the token isn't valid.
String? nashvilleToChord(String token, String? musicalKey) {
  final tonic = _tonicInfo(musicalKey);
  if (tonic == null) return null;
  final trimmed = token.trim();
  if (trimmed.isEmpty) return null;

  final slash = trimmed.indexOf('/');
  final main = slash == -1 ? trimmed : trimmed.substring(0, slash);
  final bassToken = slash == -1 ? null : trimmed.substring(slash + 1);

  final match = RegExp(r'^([b#]{0,2}[1-7])(.*)$').firstMatch(main);
  if (match == null) return null;
  final root = _degreeToRoot(match[1]!, tonic);
  if (root == null) return null;
  final quality = _letterQuality(match[2]!);
  if (bassToken == null) return root + quality;

  // The bass side must be a bare degree — no quality.
  final bass = _degreeToRoot(bassToken, tonic);
  return bass == null ? null : '$root$quality/$bass';
}

/// One chip on the diatonic row.
class DiatonicChord {
  const DiatonicChord({
    required this.chord,
    required this.root,
    required this.quality,
    required this.degree,
    required this.numberLabel,
  });

  /// Bracket-ready letter chord, e.g. `F#m`.
  final String chord;
  final String root;

  /// `""`, `m` or `dim`.
  final String quality;

  /// Relative-major degree, 1–7.
  final int degree;

  /// What 123 mode would print: `6m`, `7°`.
  final String numberLabel;
}

const _diatonicQuality = ['', 'm', 'm', '', '', 'm', 'dim'];

/// The seven diatonic triads of a key in playing order. Minor keys rotate to
/// open on their own tonic while the number labels stay against the relative
/// major. Null when the key is unusable (fall back to chromatic).
List<DiatonicChord>? diatonicChords(String? musicalKey) {
  final tonic = _tonicInfo(musicalKey);
  if (tonic == null) return null;
  final chords = <DiatonicChord>[];
  for (var degree = 1; degree <= 7; degree++) {
    final root = _degreeToRoot('$degree', tonic);
    if (root == null) return null;
    final quality = _diatonicQuality[degree - 1];
    chords.add(
      DiatonicChord(
        chord: root + quality,
        root: root,
        quality: quality,
        degree: degree,
        numberLabel: '$degree${_nashvilleQuality(quality)}',
      ),
    );
  }
  final isMinor = _isMinorKey(musicalKey);
  // Degree 6 is the minor tonic, so rotating by 5 puts it first.
  return isMinor ? [...chords.skip(5), ...chords.take(5)] : chords;
}

bool _isMinorKey(String? musicalKey) {
  final match = RegExp(r'^([A-G])([b#]{0,2})(.*)$').firstMatch((musicalKey ?? '').trim());
  if (match == null) return false;
  final suffix = match[3]!.trim();
  return RegExp(r'^(m|min|minor)$', caseSensitive: false).hasMatch(suffix) && suffix != 'M';
}

/// Relative-major degree of a letter root, only for the scale's naturals.
int? degreeOfRoot(String root, String? musicalKey) {
  final tonic = _tonicInfo(musicalKey);
  if (tonic == null) return null;
  final token = _rootToDegree(root, tonic);
  if (token == null) return null;
  return RegExp(r'^[1-7]$').hasMatch(token) ? int.parse(token) : null;
}

/// Diatonic bass candidates for a slash chord: the third, then the fifth of
/// [root], then the rest of the scale. Null when the key is unusable.
List<String>? diatonicBassOptions(String? root, String? musicalKey) {
  final chords = diatonicChords(musicalKey);
  if (chords == null) return null;
  final allRoots = [for (final c in chords) c.root];
  if (root == null) return allRoots;

  final byDegree = {for (final c in chords) c.degree: c.root};
  final rootDegree = degreeOfRoot(root, musicalKey);
  final ordered = <String>[];
  if (rootDegree != null) {
    final third = byDegree[((rootDegree - 1 + 2) % 7) + 1];
    final fifth = byDegree[((rootDegree - 1 + 4) % 7) + 1];
    if (third != null) ordered.add(third);
    if (fifth != null && fifth != third) ordered.add(fifth);
  }
  for (final candidate in allRoots) {
    if (candidate == root || ordered.contains(candidate)) continue;
    ordered.add(candidate);
  }
  return ordered;
}

/// The chords worship songs borrow most that aren't in the key — the second
/// row under the diatonic chips. Measured from the number system's tonic (the
/// relative major for a minor key), then spelled in letters. Null when the
/// key is unusable.
///
/// Major keys: ♭VII, ♭III, ♭VI, iv, and the major II, III, VI (secondary
/// dominants). Minor keys: the major V and V7, IV and I, plus ♭II.
List<DiatonicChord>? borrowedChords(String? musicalKey) {
  final tonic = _tonicInfo(musicalKey);
  if (tonic == null) return null;
  // (degree token, quality, number label) — tokens count from the number tonic.
  final spec = _isMinorKey(musicalKey)
      ? const [('3', ''), ('3', '7'), ('2', ''), ('6', ''), ('b7', '')]
      : const [('b7', ''), ('b3', ''), ('b6', ''), ('4', 'm'), ('2', ''), ('3', ''), ('6', '')];
  final out = <DiatonicChord>[];
  for (final (token, quality) in spec) {
    final root = _degreeToRoot(token, tonic);
    if (root == null) return null;
    out.add(
      DiatonicChord(
        chord: root + quality,
        root: root,
        quality: quality,
        degree: int.parse(token.replaceAll(RegExp(r'[b#]'), '')),
        numberLabel: '$token${_nashvilleQuality(quality)}',
      ),
    );
  }
  return out;
}
