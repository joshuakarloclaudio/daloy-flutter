/// One source line of a chart as the editor draws it, and the map between
/// source columns and the drawn text. Pure Dart — the widget only paints
/// [EditorLine.pieces] and asks this for caret and tap positions, so the
/// hard part (a chord shown as `Am` or `6m` while its source is `[Am]`) is
/// testable without a screen.
library;

import '../chart/chart_parser.dart';
import '../chart/chord_math.dart';
import '../chart/nashville.dart';
import 'chart_edit.dart';

enum PieceKind {
  /// Lyrics and anything unbracketed: one drawn character per source one.
  text,

  /// `Verse 1:` — drawn like text, styled as a heading.
  heading,

  /// `[G]`: drawn as the chord, never split.
  chord,

  /// `[Chorus]`: a bracketed label that isn't a chord. Never split.
  label,

  /// `|` or `%` on a bar line: drawn like text, styled as structure.
  bar,

  /// `x2` / `2x` on a bar or section line: drawn as written, styled as a badge.
  repeat,

  /// A drawn space between two touching chords (`[G][D]`); no source text.
  pad,
}

class EditorPiece {
  const EditorPiece({
    required this.kind,
    required this.srcStart,
    required this.srcEnd,
    required this.text,
    required this.drawnStart,
  });

  final PieceKind kind;
  final int srcStart;
  final int srcEnd;

  /// What is drawn for this piece.
  final String text;
  final int drawnStart;

  int get drawnEnd => drawnStart + text.length;
  bool get atomic => kind == PieceKind.chord || kind == PieceKind.label || kind == PieceKind.pad;
}

final _pieceRe = RegExp(r'\[([^\]]+)\]|\[|[^\[]+');
final _structurePiece = RegExp(r'\s+|[|%]|[^\s|%]+');

class EditorLine {
  EditorLine._(this.source, this.pieces);

  /// [line] as drawn for [notation] in [musicalKey].
  factory EditorLine.parse(String line, {ChordNotation notation = ChordNotation.letters, String? musicalKey}) {
    final pieces = <EditorPiece>[];
    var drawn = 0;

    void add(PieceKind kind, int start, int end, String text) {
      pieces.add(EditorPiece(kind: kind, srcStart: start, srcEnd: end, text: text, drawnStart: drawn));
      drawn += text.length;
    }

    if (plainSectionPattern.hasMatch(line)) {
      add(PieceKind.heading, 0, line.length, line);
      return EditorLine._(line, pieces);
    }

    final numbers = notation == ChordNotation.numbers && canUseNumbers(musicalKey);

    // Bars, `%` and repeat counts are structure only on a line that reads as
    // one (the same classification the read-only chart uses) — a `|` in a
    // lyric stays text.
    final structured = parseLine(line)
        .any((seg) => seg.kind == SegmentKind.bar || seg.kind == SegmentKind.simile || seg.kind == SegmentKind.repeat);

    void addText(int start, int end) {
      final text = line.substring(start, end);
      if (!structured) return add(PieceKind.text, start, end, text);
      for (final part in _structurePiece.allMatches(text)) {
        final word = part[0]!;
        final kind = word == '|' || word == '%'
            ? PieceKind.bar
            : parseRepeatToken(word) != null
            ? PieceKind.repeat
            : PieceKind.text;
        add(kind, start + part.start, start + part.end, word);
      }
    }

    for (final m in _pieceRe.allMatches(line)) {
      final inner = m[1];
      if (inner == null) {
        addText(m.start, m.end);
      } else if (isChordToken(inner)) {
        if (pieces.isNotEmpty && pieces.last.kind == PieceKind.chord && pieces.last.srcEnd == m.start) {
          add(PieceKind.pad, m.start, m.start, ' ');
        }
        add(
          PieceKind.chord,
          m.start,
          m.end,
          displayChord(inner, numbers ? ChordNotation.numbers : ChordNotation.letters, musicalKey, 0),
        );
      } else {
        add(PieceKind.label, m.start, m.end, inner);
      }
    }
    return EditorLine._(line, pieces);
  }

  final String source;
  final List<EditorPiece> pieces;

  String get drawnText => pieces.map((p) => p.text).join();
  bool get isEmpty => source.isEmpty;

  /// Where in the drawn text the caret at source column [col] sits. [col]
  /// should already be snapped out of chords.
  int drawnOffsetForCol(int col) {
    for (final p in pieces) {
      if (p.kind == PieceKind.pad) continue;
      if (col < p.srcStart || col > p.srcEnd) continue;
      if (p.atomic) return col == p.srcStart ? p.drawnStart : p.drawnEnd;
      return p.drawnStart + (col - p.srcStart);
    }
    return pieces.isEmpty ? 0 : pieces.last.drawnEnd;
  }

  /// The (snapped) source column nearest to drawn offset [offset].
  int colForDrawnOffset(int offset) {
    if (pieces.isEmpty) return 0;
    for (final p in pieces) {
      if (offset < p.drawnStart || offset > p.drawnEnd) continue;
      if (p.kind == PieceKind.pad) return p.srcStart;
      if (p.atomic) {
        // Before the middle → before the chord; after → after it.
        return offset * 2 < p.drawnStart + p.drawnEnd ? p.srcStart : p.srcEnd;
      }
      return snapCursorColInLine(source, p.srcStart + (offset - p.drawnStart));
    }
    return source.length;
  }
}
