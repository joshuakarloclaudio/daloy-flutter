import '../chart/chart_parser.dart';
import '../chart/chord_math.dart';
import '../chart/nashville.dart';
import 'chart_edit.dart';
import 'chart_edit.dart' as ed;
import 'editor_history.dart';
import 'physical_input.dart';

/// The chord editor's brain: the document, the cursor, the armed modifier and
/// the undo history, driven by what the keyboard keys do (the web's
/// `ChordEditor` handlers). No Flutter — [onChanged] tells a listener to
/// rebuild. Chords are always stored as letters; numbers are an input method.
class ChartEditorCore {
  ChartEditorCore({
    required String content,
    required this.musicalKey,
    ChordNotation notation = ChordNotation.letters,
    this.onChanged,
  }) : _notation = notation, // ignore: prefer_initializing_formals
       _content = normalizeNewlines(content),
       _history = EditorHistory(EditorSnapshot(normalizeNewlines(content), normalizeNewlines(content).length)) {
    _cursor = _content.length;
  }

  final String? musicalKey;
  final void Function()? onChanged;
  final EditorHistory _history;

  String _content;
  int _cursor = 0;
  String _pendingModifier = '';
  ChordNotation _notation;
  bool _useFlats = false;

  bool get useFlats => _useFlats;
  set useFlats(bool value) {
    _useFlats = value;
    onChanged?.call();
  }

  String get content => _content;
  int get cursor => _cursor;
  bool get canUndo => _history.canUndo;
  bool get canRedo => _history.canRedo;

  /// Numbers need a usable key; without one the editor stays in letters.
  bool get numbersAvailable => canUseNumbers(musicalKey);
  ChordNotation get notation => numbersAvailable ? _notation : ChordNotation.letters;
  set notation(ChordNotation value) {
    _notation = value;
    onChanged?.call();
  }

  /// The diatonic chips for this key, or null (chromatic keyboard).
  late final List<DiatonicChord>? diatonic = diatonicChords(musicalKey);

  /// Common borrowed chords for the key's second row.
  late final List<DiatonicChord>? borrowed = borrowedChords(musicalKey);

  /// The modifier shown as selected: the chord under the cursor's quality,
  /// else whatever is armed for the next chord.
  String get selectedModifier {
    final token = findChordTokenAtCursor(_content, _cursor);
    if (token != null) {
      final parsed = parseChordInner(token.inner);
      if (parsed != null) return qualityToModifier(parsed.quality);
    }
    return _pendingModifier;
  }

  void _apply(Edited e) {
    _content = e.content;
    _cursor = e.cursor;
    _history.commit(EditorSnapshot(_content, _cursor));
    onChanged?.call();
  }

  void _restore(EditorSnapshot? s) {
    if (s == null) return;
    _content = s.content;
    _cursor = s.cursor;
    onChanged?.call();
  }

  void undo() => _restore(_history.undo());
  void redo() => _restore(_history.redo());

  void insertText(String text) => _apply(insertAt(_content, _cursor, text));

  void deleteBack() {
    final e = ed.deleteBack(_content, _cursor);
    if (e != null) _apply(e);
  }

  void deleteForward() {
    final e = ed.deleteForward(_content, _cursor);
    if (e != null) _apply(e);
  }

  /// Takes the text from the system keyboard's field (free-type mode) back
  /// as one undoable edit, with the cursor where that field's was.
  void setContent(String text, int cursor) {
    final normalized = normalizeNewlines(text);
    _apply((content: normalized, cursor: cursor.clamp(0, normalized.length)));
  }

  /// Replaces everything (the "clear" key and a paste into an empty chart).
  void replaceAll(String text) => _apply((content: normalizeNewlines(text), cursor: normalizeNewlines(text).length));

  void _insertLetterChord(String letterRoot, String quality) {
    insertText('[$letterRoot$quality]');
    _pendingModifier = '';
  }

  /// A root key. In numbers mode [root] is `"1"`/`"b3"`; the conversion
  /// happens here only. The armed quality is appended after converting, so
  /// `2` + `m` in C is `[Dm]`. Refuses silently rather than write a broken token.
  void insertChord(String root) {
    final letter = notation == ChordNotation.numbers ? nashvilleToChord(root, musicalKey) : root;
    if (letter == null) return;
    _insertLetterChord(letter, _pendingModifier);
  }

  /// A diatonic key carries its quality, but an armed modifier *replaces* it.
  void insertDiatonicChord(String letterRoot, String quality) =>
      _insertLetterChord(letterRoot, _pendingModifier.isNotEmpty ? _pendingModifier : quality);

  /// A quality picked in the long-press popup is explicit and always wins.
  void insertChordWithQuality(String letterRoot, String quality) => _insertLetterChord(letterRoot, quality);

  /// With a chord at the cursor the modifier edits it; otherwise it arms (or
  /// disarms, tapped again) for the next chord.
  void selectModifier(String modifier) {
    if (findChordTokenAtCursor(_content, _cursor) != null) {
      final e = applyModifierToTokenAtCursor(_content, _cursor, modifier);
      if (e != null) _apply(e);
      _pendingModifier = '';
      return;
    }
    _pendingModifier = _pendingModifier == modifier ? '' : modifier;
    onChanged?.call();
  }

  void insertSectionName(String name) => _apply(insertSection(_content, _cursor, name));

  void insertRepeat(int count) => _apply(insertRepeatMarker(_content, _cursor, count));

  void insertMeter(String signature) => _apply(insertMeterMarker(_content, _cursor, signature));

  /// A bass note from the long-press popup — always a bare letter root.
  void insertBassNote(String letterRoot) => insertText('/[$letterRoot]');

  /// The letter root of the chord at the cursor, or null.
  String? get chordRootAtCursor {
    final token = findChordTokenAtCursor(_content, _cursor);
    return token == null ? null : parseChordInner(token.inner)?.root;
  }

  // -- Typing (hardware keyboard) ---------------------------------------------

  TypedTokenInput get _tokenInput =>
      notation == ChordNotation.numbers ? nashvilleTokenInput(musicalKey) : letterTokenInput;

  ChordRootResolver get _rootResolver =>
      notation == ChordNotation.numbers ? nashvilleRootResolver(musicalKey) : letterRootResolver;

  /// One typed character. With the cursor on a chord it edits that chord
  /// (`m`, `7`, a root letter at the opening bracket…); otherwise it's text,
  /// and a chord word before a delimiter is wrapped in brackets.
  void typeChar(String char) {
    final edited = applyPhysicalChordEditKey(_content, _cursor, char, _rootResolver);
    if (edited != null) {
      _apply(edited);
      return;
    }
    // A refused chord edit is still not text.
    if (isPhysicalChordEditKey(_content, _cursor, char, _rootResolver)) return;
    _apply(applyPhysicalTextInsert(_content, _cursor, char, _tokenInput));
  }

  void typeNewline() => _apply(applyPhysicalTextInsert(_content, _cursor, '\n', _tokenInput));

  // -- Cursor ----------------------------------------------------------------

  void _moveTo(int pos) {
    _cursor = pos.clamp(0, _content.length);
    onChanged?.call();
  }

  void moveLeft() => _moveTo(moveCursorThroughToken(_content, _cursor, Direction.left));
  void moveRight() => _moveTo(moveCursorThroughToken(_content, _cursor, Direction.right));
  void moveUp() => _moveTo(moveCursorUp(_content, _cursor));
  void moveDown() => _moveTo(moveCursorDown(_content, _cursor));
  void moveToLineStart() => _moveTo(lineStart(_content, _cursor));
  void moveToLineEnd() => _moveTo(lineEnd(_content, _cursor));
  void moveToStart() => _moveTo(0);
  void moveToEnd() => _moveTo(_content.length);

  /// A tap on the rendered chart: column [col] of [line], never inside a chord.
  void tapAt(int line, int col) {
    final lines = _content.split('\n');
    final text = line < lines.length ? lines[line] : '';
    _moveTo(lineStartOffset(_content, line) + snapCursorColInLine(text, col));
  }

  // -- Paste -------------------------------------------------------------------

  /// Inserts pasted text at the cursor with bare chords wrapped in brackets.
  void paste(String text) => insertText(normalizePastedChordContent(text));
}
