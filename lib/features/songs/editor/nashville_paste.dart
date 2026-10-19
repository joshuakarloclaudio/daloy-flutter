/// Pasting a number chart: spotting one and converting it to letter chords in
/// the song's key. Port of the paste half of the web's `lib/nashville.ts`.
/// Classification is per line, never per token — `1`, `4` and `7` turn up in
/// lyrics, bar counts and musician notes, and converting one that merely
/// looks like a degree would mangle a real chart.
library;

import '../chart/chart_parser.dart';
import '../chart/chord_math.dart';
import '../chart/nashville.dart';
import 'chart_edit.dart';

final _nashvilleToken = RegExp(r'^[b#]{0,2}[1-7](m|maj|min|sus|aug|dim|add|M|[0-9]|[#b+°øΔ-])*(\/[b#]{0,2}[1-7])?$');
final _bracketInner = RegExp(r'\[([^\]]+)\]');
final _pasteSplit = RegExp(r'(\s+|[-|%])');

bool isNashvilleToken(String text) => _nashvilleToken.hasMatch(text.trim());

bool _isStructural(String part) =>
    RegExp(r'^\s+$').hasMatch(part) || part == '-' || part == '|' || part == '%' || parseRepeatToken(part) != null;

List<String> bareTokens(String line) => [
  for (final p in _splitKeep(line))
    if (p.isNotEmpty && !_isStructural(p)) p,
];

/// `line.split(re)` keeping the separators, like JS's split with a capture group.
List<String> _splitKeep(String line) {
  final out = <String>[];
  var last = 0;
  for (final m in _pasteSplit.allMatches(line)) {
    out.add(line.substring(last, m.start));
    out.add(m[0]!);
    last = m.end;
  }
  out.add(line.substring(last));
  return out;
}

/// True when the line reads as a Nashville chord line.
bool isNashvilleChordLine(String line) {
  if (plainSectionPattern.hasMatch(line)) return false;

  // Already-bracketed content (a chart copied out of Daloy in numbers mode):
  // brackets are an explicit chord marker, so one is enough.
  final bracketed = [for (final m in _bracketInner.allMatches(line)) m[1]!];
  if (bracketed.isNotEmpty) return bracketed.every(isNashvilleToken);

  final tokens = bareTokens(line);
  if (tokens.length < 2) return false;
  // A line mixing "G" and "4" isn't a number chart — leave it alone.
  if (tokens.any(isChordToken)) return false;
  return tokens.every(isNashvilleToken);
}

/// How many lines of [text] classify as Nashville. Drives the paste prompt.
int countNashvilleLines(String text) => normalizeLines(text).where(isNashvilleChordLine).length;

List<String> normalizeLines(String text) => text.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');

/// `6m` in C → `[Am]`; `1/3` in G → `[G]/[B]`. Null when invalid.
String? formatTypedNashvilleToken(String raw, String? musicalKey) {
  final t = raw.trim();
  if (t.isEmpty || !isNashvilleToken(t)) return null;
  final slash = t.indexOf('/');
  if (slash == -1) {
    final chord = nashvilleToChord(t, musicalKey);
    return chord == null ? null : '[$chord]';
  }
  final main = nashvilleToChord(t.substring(0, slash), musicalKey);
  final bass = nashvilleToChord(t.substring(slash + 1), musicalKey);
  return main == null || bass == null ? null : '[$main]/[$bass]';
}

String _convertLine(String line, String? musicalKey) {
  if (!isNashvilleChordLine(line)) return line;
  if (_bracketInner.hasMatch(line)) {
    return line.replaceAllMapped(_bracketInner, (m) => formatTypedNashvilleToken(m[1]!, musicalKey) ?? m[0]!);
  }
  return _splitKeep(line)
      .map((p) => p.isEmpty || _isStructural(p) ? p : formatTypedNashvilleToken(p, musicalKey) ?? p)
      .join();
}

/// Converts the lines that classify as Nashville to bracketed letter chords
/// and leaves every other line byte-identical. Null when the key can't be
/// numbered.
String? normalizePastedNashvilleContent(String text, String? musicalKey) {
  if (!canUseNumbers(musicalKey)) return null;
  return normalizeLines(text).map((l) => _convertLine(l, musicalKey)).join('\n');
}

/// The first number-chart line of [text], spaced out for the prompt's preview.
String? firstNashvilleLine(String text) {
  for (final line in normalizeLines(text)) {
    if (isNashvilleChordLine(line)) return line.trim().replaceAll(RegExp(r'\s+'), '   ');
  }
  return null;
}

/// A bracketed chart line as plain letters, for the prompt's preview.
String lettersOf(String bracketed) => bracketed.replaceAllMapped(_bracketInner, (m) => m[1]!);

/// Pastes [text] into a chart: bare letter chords are bracketed; number
/// charts are converted first when [asChords].
String prepareChordPaste(String text, {required bool asChords, required String? musicalKey}) {
  var t = text;
  if (asChords) t = normalizePastedNashvilleContent(t, musicalKey) ?? t;
  // Number conversion leaves other lines alone, so the letter pass still runs
  // over the result — a chart that mixes number lines with bare letters needs both.
  return normalizePastedChordContent(t);
}
