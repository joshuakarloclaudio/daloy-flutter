/// Text-and-cursor editing of a chord chart — port of the editing half of the
/// web's `lib/chords.ts`. Pure Dart. A chart is plain text where a chord is a
/// `[…]` token; the cursor is a UTF-16 offset that never rests inside one.
library;

import '../chart/chart_parser.dart';
import '../chart/chord_math.dart';

/// An edited document and where the cursor ended up.
typedef Edited = ({String content, int cursor});

typedef ChordToken = ({int start, int end, String inner});

final _token = RegExp(r'\[([^\]]+)\]');

/// The `[…]` token under the cursor: inside the brackets, on `[`, or flush
/// after a final `]` at the end of the document.
ChordToken? findChordTokenAtCursor(String content, int cursor) {
  for (final m in _token.allMatches(content)) {
    final start = m.start;
    final end = m.end;
    if (cursor > start && cursor < end) return (start: start, end: end, inner: m[1]!);
    if (cursor == start) return (start: start, end: end, inner: m[1]!);
    if (cursor == end && end == content.length) return (start: start, end: end, inner: m[1]!);
  }
  return null;
}

/// Snaps a column so it never sits inside a `[…]` token — to the nearer edge.
int snapCursorColInLine(String line, int col) {
  final clamped = col.clamp(0, line.length);
  for (final m in _token.allMatches(line)) {
    if (clamped > m.start && clamped < m.end) {
      return clamped - m.start <= m.end - clamped ? m.start : m.end;
    }
  }
  return clamped;
}

enum Direction { left, right }

/// Arrow-key step that treats each `[…]` token as one step.
int moveCursorThroughToken(String content, int cursor, Direction direction) {
  for (final m in _token.allMatches(content)) {
    if (direction == Direction.right) {
      if (cursor >= m.start && cursor < m.end) return m.end;
    } else if (cursor > m.start && cursor <= m.end) {
      return m.start;
    }
  }
  return direction == Direction.right ? (cursor + 1).clamp(0, content.length) : (cursor - 1).clamp(0, content.length);
}

typedef LineCol = ({int line, int col});

LineCol cursorLineCol(String content, int cursor) {
  final parts = content.substring(0, cursor).split('\n');
  return (line: parts.length - 1, col: parts.last.length);
}

int lineStartOffset(String content, int line) {
  var offset = 0;
  final lines = content.split('\n');
  for (var i = 0; i < line && i < lines.length; i++) {
    offset += lines[i].length + 1;
  }
  return offset;
}

int moveCursorUp(String content, int cursor) {
  final (:line, :col) = cursorLineCol(content, cursor);
  if (line == 0) return 0;
  final lines = content.split('\n');
  final prev = lines[line - 1];
  return lineStartOffset(content, line - 1) + snapCursorColInLine(prev, col < prev.length ? col : prev.length);
}

int moveCursorDown(String content, int cursor) {
  final (:line, :col) = cursorLineCol(content, cursor);
  final lines = content.split('\n');
  if (line >= lines.length - 1) return content.length;
  final next = lines[line + 1];
  return lineStartOffset(content, line + 1) + snapCursorColInLine(next, col < next.length ? col : next.length);
}

int lineStart(String content, int cursor) {
  final nl = content.substring(0, cursor).lastIndexOf('\n');
  return nl == -1 ? 0 : nl + 1;
}

int lineEnd(String content, int cursor) {
  final nl = content.indexOf('\n', cursor);
  return nl == -1 ? content.length : nl;
}

// -- Qualities -----------------------------------------------------------

const _qualityAliases = {'': '', 'M': '', 'maj': '', 'min': 'm'};

/// The chord keyboard's modifier row (and what each is called in a quality).
const chordModifiers = [
  'm',
  '7',
  'maj7',
  'm7',
  'sus2',
  'sus4',
  'dim',
  'dim7',
  'm7b5',
  'aug',
  '6',
  '9',
  'add9',
  'm9',
  '11',
  '13',
];

/// Maps a chord quality to the modifier value used by the chord keyboard;
/// anything the keyboard doesn't know reads as plain (`''`).
String qualityToModifier(String quality) {
  final normalized = _qualityAliases[quality] ?? quality;
  return normalized.isEmpty || chordModifiers.contains(normalized) ? normalized : '';
}

final _combine = <String, Map<String, String>>{
  '': {for (final m in chordModifiers) m: m},
  'm': {'7': 'm7', '9': 'm9'},
  // Half-diminished is a minor seventh with a flat fifth, so both routes combine.
  'm7': {'m7b5': 'm7b5'},
  'dim': {'7': 'dim7'},
};

/// Applies a modifier to a quality — combines when it can, else replaces.
String applyModifierToQuality(String currentQuality, String modifier) {
  final current = qualityToModifier(currentQuality);
  if (current == modifier) return current;
  return _combine[current]?[modifier] ?? modifier;
}

String formatChordInner(ParsedChord c) =>
    '${c.root}${c.quality}${c.bass == null || c.bass!.isEmpty ? '' : '/${c.bass}'}';

Edited _replaceInner(String content, ChordToken t, String inner) {
  final token = '[$inner]';
  return (content: content.substring(0, t.start) + token + content.substring(t.end), cursor: t.start + token.length);
}

/// Applies a modifier-key value to the chord at the cursor, or null if none.
Edited? applyModifierToTokenAtCursor(String content, int cursor, String modifier) {
  final token = findChordTokenAtCursor(content, cursor);
  if (token == null) return null;
  final parsed = parseChordInner(token.inner);
  if (parsed == null) return null;
  final quality = applyModifierToQuality(parsed.quality, modifier);
  return _replaceInner(content, token, formatChordInner((root: parsed.root, quality: quality, bass: parsed.bass)));
}

/// Backspace on a chord's quality drops its last character instead of the
/// whole chord. Null when the cursor isn't at a chord's quality edge.
Edited? trimChordQualityAtCursor(String content, int cursor) {
  final token = findChordTokenAtCursor(content, cursor);
  if (token == null) return null;
  final atEdge = cursor == token.end - 1 || (cursor == token.end && token.end == content.length);
  if (!atEdge) return null;
  final parsed = parseChordInner(token.inner);
  if (parsed == null || parsed.quality.isEmpty) return null;
  final quality = parsed.quality.substring(0, parsed.quality.length - 1);
  return _replaceInner(content, token, formatChordInner((root: parsed.root, quality: quality, bass: parsed.bass)));
}

// -- Insert / delete ------------------------------------------------------

Edited insertAt(String content, int cursor, String text) {
  final normalized = normalizeNewlines(text);
  return (
    content: content.substring(0, cursor) + normalized + content.substring(cursor),
    cursor: cursor + normalized.length,
  );
}

/// Backspace: a chord quality loses a character, a whole `[chord]` goes in one
/// press, anything else loses one character.
Edited? deleteBack(String content, int cursor) {
  if (cursor == 0) return null;
  final trimmed = trimChordQualityAtCursor(content, cursor);
  if (trimmed != null) return trimmed;
  final before = content.substring(0, cursor);
  final token = RegExp(r'\[[^\]]+\]$').firstMatch(before);
  final len = token == null ? 1 : token[0]!.length;
  return (content: content.substring(0, cursor - len) + content.substring(cursor), cursor: cursor - len);
}

Edited? deleteForward(String content, int cursor) {
  if (cursor >= content.length) return null;
  return (content: content.substring(0, cursor) + content.substring(cursor + 1), cursor: cursor);
}

/// A section label on its own line: `Verse 1:\n`.
Edited insertSection(String content, int cursor, String name) {
  final atLineStart = cursor == 0 || content[cursor - 1] == '\n';
  return insertAt(content, cursor, '${atLineStart ? '' : '\n'}$name:\n');
}

/// A repeat marker (`x2`), space-separated from what precedes it.
Edited insertRepeatMarker(String content, int cursor, int count) {
  final before = cursor > 0 ? content[cursor - 1] : null;
  final needsSpace = before != null && before != '\n' && before != ' ';
  return insertAt(content, cursor, '${needsSpace ? ' ' : ''}x$count');
}

// -- Paste ----------------------------------------------------------------

final _bassNote = RegExp(r'^[A-Ga-g][b#]?$');

String _upperFirst(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Raw typed chord text → stored `[…]` notation, or null when it isn't one.
String? formatTypedChordToken(String raw) {
  if (raw.isEmpty) return null;
  final slash = raw.indexOf('/');
  if (slash == -1) {
    final c = _upperFirst(raw);
    return isChordToken(c) ? '[$c]' : null;
  }
  final main = _upperFirst(raw.substring(0, slash));
  final bass = _upperFirst(raw.substring(slash + 1));
  if (!isChordToken(main) || !_bassNote.hasMatch(bass)) return null;
  return '[$main]/[$bass]';
}

final _pasteSplit = RegExp(r'(\s+|[-|%])');

bool _isStructuralPastePart(String part) =>
    RegExp(r'^\s+$').hasMatch(part) || part == '-' || part == '|' || part == '%' || parseRepeatToken(part) != null;

/// Wraps bare chord tokens in pasted text (already-bracketed text is left be).
String normalizePastedChordLine(String line) {
  if (plainSectionPattern.hasMatch(line)) return line;
  final out = StringBuffer();
  var last = 0;
  for (final m in _pasteSplit.allMatches(line)) {
    out.write(_pastePart(line.substring(last, m.start)));
    out.write(m[0]);
    last = m.end;
  }
  out.write(_pastePart(line.substring(last)));
  return out.toString();
}

String _pastePart(String part) {
  if (part.isEmpty || _isStructuralPastePart(part)) return part;
  return formatTypedChordToken(part) ?? part;
}

String normalizePastedChordContent(String text) =>
    normalizeNewlines(text).split('\n').map(normalizePastedChordLine).join('\n');
