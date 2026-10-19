/// Text helpers behind Search: accent folding, word splitting, typo-tolerant
/// matching, and the chart → plain text step the lyrics index is built from.
/// Pure Dart: no Flutter, no I/O.
library;

import 'dart:math' as math;

import '../../songs/chart/chart_parser.dart';

const _folds = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ā': 'a', 'ă': 'a', 'ą': 'a', //
  'ç': 'c', 'ć': 'c', 'č': 'c', 'ď': 'd', 'đ': 'd',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ė': 'e', 'ę': 'e', 'ě': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'į': 'i', 'ı': 'i',
  'ł': 'l', 'ñ': 'n', 'ń': 'n', 'ň': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'ō': 'o', 'ő': 'o',
  'ř': 'r', 'ś': 's', 'š': 's', 'ş': 's', 'ș': 's', 'ß': 's', 'ť': 't', 'ț': 't',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u', 'ů': 'u', 'ű': 'u', 'ų': 'u',
  'ý': 'y', 'ÿ': 'y', 'ź': 'z', 'ż': 'z', 'ž': 'z',
  '’': "'", '‘': "'",
};

/// Lower-cased with accents dropped, one character for one, so an index
/// into the folded text is an index into the original.
String fold(String text) {
  final out = StringBuffer();
  for (final rune in text.runes) {
    final ch = String.fromCharCode(rune);
    final lower = ch.toLowerCase();
    // A few characters lower-case to two ('İ'); keep those as they are.
    final one = lower.length == ch.length ? lower : ch;
    out.write(_folds[one] ?? one);
  }
  return out.toString();
}

final _word = RegExp(r"[\p{L}\p{N}']+", unicode: true);

/// The words in already-[fold]ed text, apostrophes kept ("don't").
List<String> words(String folded) => [for (final m in _word.allMatches(folded)) m[0]!.replaceAll("'", '')];

/// Word spans in already-[fold]ed text, for highlighting.
Iterable<({int start, int end, String word})> wordSpans(String folded) =>
    _word.allMatches(folded).map((m) => (start: m.start, end: m.end, word: m[0]!.replaceAll("'", '')));

/// How a typed [term] meets a [word] (both folded), or null when it doesn't:
/// 0 = the word starts with it, 1 = within a typo or two of its start.
int? termMeetsWord(String term, String word) {
  if (word.startsWith(term)) return 0;
  // A typo in one or two letters is noise; from four up it's worth forgiving.
  // Numbers are exact: 2025 is not a typo for 2026.
  if (term.length < 4 || term.contains(RegExp(r'\d'))) return null;
  final budget = term.length >= 7 ? 2 : 1;
  // Compare against the word's start the length of the term (±1), so "amazng"
  // still meets "amazing" and "graec" meets "grace".
  for (var len = term.length - 1; len <= term.length + 1; len++) {
    if (len < 1 || len > word.length) continue;
    if (_distance(term, word.substring(0, len), budget) <= budget) return 1;
  }
  return null;
}

/// Damerau–Levenshtein (optimal string alignment), giving up past [cap].
int _distance(String a, String b, int cap) {
  if ((a.length - b.length).abs() > cap) return cap + 1;
  var prev2 = List<int>.filled(b.length + 1, 0);
  var prev = List<int>.generate(b.length + 1, (j) => j);
  var cur = List<int>.filled(b.length + 1, 0);
  for (var i = 1; i <= a.length; i++) {
    cur[0] = i;
    var rowMin = cur[0];
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      var v = math.min(math.min(prev[j] + 1, cur[j - 1] + 1), prev[j - 1] + cost);
      if (i > 1 && j > 1 && a.codeUnitAt(i - 1) == b.codeUnitAt(j - 2) && a.codeUnitAt(i - 2) == b.codeUnitAt(j - 1)) {
        v = math.min(v, prev2[j - 2] + 1);
      }
      cur[j] = v;
      rowMin = math.min(rowMin, v);
    }
    if (rowMin > cap) return cap + 1;
    final t = prev2;
    prev2 = prev;
    prev = cur;
    cur = t;
  }
  return prev[b.length];
}

/// How well [terms] (folded words) match [text]: lower is better, null is no
/// match. Every term has to meet some word.
///  * 0 — the text starts with the whole query
///  * 1 — every term starts a word
///  * 2 — the text contains the query, mid-word
///  * 3 — every term meets a word, allowing typos
double? matchScore(String text, String query, List<String> terms) {
  if (terms.isEmpty) return null;
  final folded = fold(text);
  final q = fold(query.trim());
  if (folded.startsWith(q)) return 0;
  final textWords = words(folded);
  var typos = false;
  for (final term in terms) {
    int? best;
    for (final w in textWords) {
      final meet = termMeetsWord(term, w);
      if (meet != null && (best == null || meet < best)) best = meet;
      if (best == 0) break;
    }
    if (best == null) return folded.contains(q) ? 2 : null;
    if (best == 1) typos = true;
  }
  // A real substring beats a guess at a typo.
  if (typos && folded.contains(q)) return 2;
  return typos ? 3 : 1;
}

/// A chart's words without its chords, section labels or bar rows — one
/// output line per input line, so line numbers still match the chart.
String chartPlainText(String content) =>
    [for (final line in normalizeNewlines(content).split('\n')) chartLinePlainText(line)].join('\n');

/// One chart line's words: text segments only. `A[G]mazing` → `Amazing`.
String chartLinePlainText(String line) {
  final parsed = classifyLine(line);
  if (parsed is! TextLine) return '';
  return parsed.segments.where((s) => s.kind == SegmentKind.text).map((s) => s.value).join().trim();
}

/// Lyrics' words without `[Section]` labels, line for line.
String lyricsPlainText(String lyrics) => [
  for (final line in normalizeNewlines(lyrics).split('\n'))
    parseLine(line).where((s) => s.kind == SegmentKind.text).map((s) => s.value).join().trim(),
].join('\n');

/// The line of [plain] (from [chartPlainText] / [lyricsPlainText]) that best
/// matches [terms]: the most terms meeting its words, the first such line on
/// a tie. Null when no line meets any.
({int line, int hits, String text})? bestLine(String plain, List<String> terms) {
  ({int line, int hits, String text})? best;
  final lines = plain.split('\n');
  for (var i = 0; i < lines.length; i++) {
    final text = lines[i];
    if (text.isEmpty) continue;
    final lineWords = words(fold(text));
    var hits = 0;
    for (final term in terms) {
      if (lineWords.any((w) => termMeetsWord(term, w) != null)) hits++;
    }
    if (hits > 0 && (best == null || hits > best.hits)) best = (line: i, hits: hits, text: text);
    if (best != null && best.hits == terms.length) break;
  }
  return best;
}

/// Character ranges in [text] where a word meets one of [terms], for drawing
/// the match in bold: the typed part of a word it starts, or the whole word
/// when it only matched allowing a typo.
List<({int start, int end})> highlightRanges(String text, List<String> terms) {
  if (terms.isEmpty) return const [];
  final out = <({int start, int end})>[];
  for (final span in wordSpans(fold(text))) {
    var prefix = 0;
    var typo = false;
    for (final t in terms) {
      final meet = termMeetsWord(t, span.word);
      if (meet == 0) prefix = math.max(prefix, t.length);
      if (meet == 1) typo = true;
    }
    if (prefix > 0) {
      out.add((start: span.start, end: math.min(span.start + prefix, span.end)));
    } else if (typo) {
      out.add((start: span.start, end: span.end));
    }
  }
  return out;
}
