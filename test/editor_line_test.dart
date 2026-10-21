import 'package:daloy_flutter/features/songs/chart/nashville.dart';
import 'package:daloy_flutter/features/songs/editor/editor_line.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chords are drawn without brackets and touching chords get a gap', () {
    final line = EditorLine.parse('[G][D] x');
    expect(line.drawnText, 'G D x');
    expect([for (final p in line.pieces) p.kind], [PieceKind.chord, PieceKind.pad, PieceKind.chord, PieceKind.text]);
  });

  test('numbers draw what the chart prints, the source stays letters', () {
    final line = EditorLine.parse('[Am] [G]', notation: ChordNotation.numbers, musicalKey: 'C');
    expect(line.drawnText, '6m 5');
    expect(line.source, '[Am] [G]');
  });

  test('without a usable key numbers fall back to letters', () {
    expect(EditorLine.parse('[Am]', notation: ChordNotation.numbers).drawnText, 'Am');
  });

  test('a section line is one heading; a bracket label is atomic; a stray [ is text', () {
    expect(EditorLine.parse('Verse 1:').pieces.single.kind, PieceKind.heading);
    expect(EditorLine.parse('[Chorus] x2').pieces.first.kind, PieceKind.label);
    expect(EditorLine.parse('a [ b').drawnText, 'a [ b');
  });

  test('a time signature on a bar line is a meter piece; in lyrics it is text', () {
    expect(EditorLine.parse('| 2/4 [Em] |').pieces.map((p) => p.kind), contains(PieceKind.meter));
    expect(EditorLine.parse('Sing 2/4').pieces.map((p) => p.kind), isNot(contains(PieceKind.meter)));
  });

  group('caret mapping', () {
    final line = EditorLine.parse('A[Cmaj7]bc'); // drawn: "ACmaj7bc"

    test('source column → drawn offset', () {
      expect(line.drawnOffsetForCol(0), 0);
      expect(line.drawnOffsetForCol(1), 1); // before the chord
      expect(line.drawnOffsetForCol(8), 6); // after the chord
      expect(line.drawnOffsetForCol(10), 8); // end
    });

    test('drawn offset → source column, never inside a chord', () {
      expect(line.colForDrawnOffset(0), 0);
      expect(line.colForDrawnOffset(2), 1); // nearer the chord's start
      expect(line.colForDrawnOffset(5), 8); // nearer its end
      expect(line.colForDrawnOffset(7), 9); // inside "bc"
      expect(line.colForDrawnOffset(99), 10);
    });

    test('a number-mode chord is atomic at its drawn width', () {
      final n = EditorLine.parse('[Am]x', notation: ChordNotation.numbers, musicalKey: 'C'); // "6mx"
      expect(n.colForDrawnOffset(0), 0);
      expect(n.colForDrawnOffset(1), 4); // dead centre goes after the chord
      expect(n.colForDrawnOffset(2), 4);
      expect(n.drawnOffsetForCol(4), 2);
    });

    test('an empty line maps to zero', () {
      final e = EditorLine.parse('');
      expect((e.drawnOffsetForCol(0), e.colForDrawnOffset(5)), (0, 0));
    });
  });

  group('bars and repeats', () {
    test('a bar line draws its bars and repeat counts as structure', () {
      final line = EditorLine.parse('| [G] [D] | % x2');
      expect(line.drawnText, '| G D | % x2');
      expect([for (final p in line.pieces) p.kind].where((k) => k == PieceKind.bar).length, 3); // | | %
      expect(line.pieces.last.kind, PieceKind.repeat);
    });

    test('a lyric with a | in it stays text', () {
      final line = EditorLine.parse('a | b x2');
      expect(line.pieces.every((p) => p.kind == PieceKind.text), isTrue);
    });

    test('mapping is unchanged: structure is drawn 1:1', () {
      final line = EditorLine.parse('| [G] x2');
      expect(line.drawnOffsetForCol(0), 0);
      expect(line.colForDrawnOffset(line.drawnText.length), '| [G] x2'.length);
      expect(line.colForDrawnOffset(line.drawnText.length - 1), '| [G] x2'.length - 1);
    });
  });
}
