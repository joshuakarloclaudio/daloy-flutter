/// Typing into the chart from a hardware keyboard, or any source of single
/// characters: chords auto-wrap in `[…]` when a delimiter ends them, and keys
/// pressed with the cursor on a chord edit that chord. Port of the typing half
/// of the web's `lib/chords.ts` and the number-entry hooks in `lib/nashville.ts`.
library;

import '../chart/chart_parser.dart';
import '../chart/chord_math.dart';
import '../chart/nashville.dart';
import 'chart_edit.dart';
import 'nashville_paste.dart';

/// How raw typed text becomes a stored `[…]` token.
class TypedTokenInput {
  const TypedTokenInput({required this.pendingWord, required this.format, this.lineGuard});

  /// Matches the unbracketed word immediately before the cursor (group 1).
  final RegExp pendingWord;

  /// Raw typed text → stored token, or null when it isn't a chord.
  final String? Function(String raw) format;

  /// Optional veto given the line text before the pending word. Notations
  /// whose tokens collide with prose use it to require the rest of the line
  /// to already read as chords.
  final bool Function(String lineBeforeWord)? lineGuard;
}

/// Which characters can replace a chord's root, and what they resolve to.
class ChordRootResolver {
  const ChordRootResolver({required this.matches, required this.resolve});

  final bool Function(String char) matches;

  /// The replacement root, or null to refuse.
  final String? Function(String char, String currentRoot) resolve;
}

/// The unbracketed word must start at a boundary, or the match floats to the
/// last note letter in any word and `hold` becomes `hol[D]`.
final pendingChordWord = RegExp(r'(?:^|[\s\-|%\[\]])([A-Ga-g][^\s\-|%\[\]]*)$');

/// The same boundary rule for degrees, or `x4` splits into `x[F]`.
final pendingDegreeWord = RegExp(r'(?:^|[\s\-|\[\]])([b#]{0,2}[1-7][^\s\-|\[\]]*)$');

final letterTokenInput = TypedTokenInput(pendingWord: pendingChordWord, format: formatTypedChordToken);

final letterRootResolver = ChordRootResolver(
  matches: (c) => RegExp(r'^[A-Ga-g]$').hasMatch(c),
  // Typing a letter swaps the letter and keeps whatever accidental was there.
  resolve: (c, current) => c.toUpperCase() + current.substring(1),
);

/// Whether a typed degree on this line should be treated as a chord. Degrees
/// collide with prose (`hold 2`, `Verse 2`, `x4`), so the rest of the line has
/// to already read as chords.
bool isNashvilleInputLine(String lineBeforeWord) {
  if (plainSectionPattern.hasMatch(lineBeforeWord)) return false;
  final bare = lineBeforeWord.replaceAll(RegExp(r'\[[^\]]*\]'), ' ');
  return bareTokens(bare).every((t) => t == '/' || isNashvilleToken(t));
}

TypedTokenInput nashvilleTokenInput(String? musicalKey) => TypedTokenInput(
  pendingWord: pendingDegreeWord,
  format: (raw) => formatTypedNashvilleToken(raw, musicalKey),
  lineGuard: isNashvilleInputLine,
);

ChordRootResolver nashvilleRootResolver(String? musicalKey) => ChordRootResolver(
  matches: (c) => RegExp(r'^[1-7]$').hasMatch(c),
  resolve: (c, _) => nashvilleToChord(c, musicalKey),
);

// -- Auto-bracketing --------------------------------------------------------

bool isPhysicalInputDelimiter(String c) => c == '\n' || c == ' ' || c == '\t' || c == '-' || c == '|' || c == '%';

/// Chord typing is only auto-wrapped outside standalone section labels.
bool isLineEligibleForAutoBracket(String line) => !plainSectionPattern.hasMatch(line);

typedef PendingWord = ({int start, int end, String raw});

/// The unbracketed chord text immediately before column [col] of [line].
PendingWord? extractPendingChordWord(String line, int col, RegExp pendingWord) {
  final before = line.substring(0, col);
  if (before.lastIndexOf('[') > before.lastIndexOf(']')) return null;
  final raw = pendingWord.firstMatch(before)?.group(1);
  if (raw == null || raw.isEmpty) return null;
  return (start: before.length - raw.length, end: col, raw: raw);
}

/// Inserts one typed character, first wrapping the chord word before the
/// cursor in brackets when [text] is a delimiter ending it.
Edited applyPhysicalTextInsert(String content, int cursor, String text, TypedTokenInput input) {
  final normalized = normalizeNewlines(text);
  if (normalized.length != 1) return insertAt(content, cursor, normalized);

  final char = normalized;
  var pos = cursor;
  var doc = content;

  final (:line, :col) = cursorLineCol(doc, pos);
  final lineStartPos = lineStartOffset(doc, line);
  final lines = doc.split('\n');
  var text0 = lines[line];
  var colInLine = col;

  if (isLineEligibleForAutoBracket(text0) && isPhysicalInputDelimiter(char)) {
    final pending = extractPendingChordWord(text0, colInLine, input.pendingWord);
    final allowed = pending != null && (input.lineGuard?.call(text0.substring(0, pending.start)) ?? true);
    if (pending != null && allowed) {
      final formatted = input.format(pending.raw);
      if (formatted != null) {
        text0 = text0.substring(0, pending.start) + formatted + text0.substring(pending.end);
        colInLine = pending.start + formatted.length;
        lines[line] = text0;
        doc = lines.join('\n');
        pos = lineStartPos + colInLine;
      }
    }
  }
  return (content: doc.substring(0, pos) + char + doc.substring(pos), cursor: pos + char.length);
}

// -- Editing a chord under the cursor ------------------------------------------

bool _atQualityEdge(String content, int cursor, ChordToken t) =>
    cursor == t.end - 1 || (cursor == t.end && t.end == content.length);

Edited _replaceInner(String content, ChordToken t, String inner) {
  final token = '[$inner]';
  return (content: content.substring(0, t.start) + token + content.substring(t.end), cursor: t.start + token.length);
}

/// Single keys that apply a quality when a chord is under the cursor.
String? resolvePhysicalModifierKey(String key) => const {'m': 'm', 'M': '', '7': '7', '6': '6', '9': '9'}[key];

/// Typing on a chord's opening bracket replaces its root.
Edited? tryReplaceChordRootAtCursor(String content, int cursor, String char, ChordRootResolver resolver) {
  if (!resolver.matches(char)) return null;
  final token = findChordTokenAtCursor(content, cursor);
  if (token == null || cursor != token.start) return null;
  final parsed = parseChordInner(token.inner);
  if (parsed == null) return null;
  final root = resolver.resolve(char, parsed.root);
  if (root == null) return null;
  final inner = formatChordInner((root: root, quality: parsed.quality, bass: parsed.bass));
  return parseChordInner(inner) == null ? null : _replaceInner(content, token, inner);
}

final _qualityChar = RegExp(r'^[a-zA-Z0-9#b+]$');

/// Typing at a chord's end adds to its quality.
Edited? tryAppendQualityCharToChordAtCursor(String content, int cursor, String char) {
  if (!_qualityChar.hasMatch(char)) return null;
  final token = findChordTokenAtCursor(content, cursor);
  if (token == null || !_atQualityEdge(content, cursor, token)) return null;
  final parsed = parseChordInner(token.inner);
  if (parsed == null) return null;
  final inner = formatChordInner((root: parsed.root, quality: parsed.quality + char, bass: parsed.bass));
  return parseChordInner(inner) == null ? null : _replaceInner(content, token, inner);
}

/// Edit an existing `[…]` token from the keyboard: a modifier key, root
/// replacement at the opening bracket, or a quality character at its end.
Edited? applyPhysicalChordEditKey(String content, int cursor, String key, ChordRootResolver resolver) {
  final modifier = resolvePhysicalModifierKey(key);
  if (modifier != null) {
    final r = applyModifierToTokenAtCursor(content, cursor, modifier);
    if (r != null) return r;
  }
  return tryReplaceChordRootAtCursor(content, cursor, key, resolver) ??
      tryAppendQualityCharToChordAtCursor(content, cursor, key);
}

/// Whether a printable key is chord inline-editing (and so mustn't also be
/// inserted as text, even when the edit itself was refused).
bool isPhysicalChordEditKey(String content, int cursor, String key, ChordRootResolver resolver) {
  final token = findChordTokenAtCursor(content, cursor);
  if (token == null) return false;
  if (_atQualityEdge(content, cursor, token)) {
    return resolvePhysicalModifierKey(key) != null || _qualityChar.hasMatch(key);
  }
  if (cursor == token.start) return resolver.matches(key);
  return false;
}
