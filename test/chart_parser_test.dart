import 'package:daloy_flutter/features/songs/chart/chart_parser.dart';
import 'package:daloy_flutter/features/songs/chart/chord_math.dart';
import 'package:daloy_flutter/features/songs/chart/nashville.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('transposition', () {
    test('shifts roots and keeps the quality and spelling', () {
      expect(transposeChord('Am7', 2), 'Bm7');
      expect(transposeChord('Bb', 2), 'C');
      expect(transposeChord('F#m', -1), 'Fm');
      expect(transposeChord('Eb', 1), 'E');
      expect(transposeChord('C', 12), 'C');
      expect(transposeChord('C', -1), 'B');
    });

    test('leaves anything that is not a chord alone', () {
      expect(transposeChord('N.C.', 3), 'N.C.');
      expect(transposeKey('Am', 2), 'Bm');
    });

    test('knows a chord from a section label', () {
      expect(isChordToken('Cmaj7'), isTrue);
      expect(isChordToken('G/B'), isFalse); // slash chords are bracketed as two tokens
      expect(isChordToken('Verse 1'), isFalse);
      expect(isChordToken('Chorus'), isFalse);
    });
  });

  group('Nashville numbers', () {
    test('numbers measure from the written key', () {
      expect(displayChord('G', ChordNotation.numbers, 'G', 5), '1');
      expect(displayChord('Em', ChordNotation.numbers, 'G', 0), '6m');
      expect(displayChord('D/F#', ChordNotation.numbers, 'G', 0), '5/7');
      expect(displayChord('Cmaj7', ChordNotation.numbers, 'G', 0), '4Δ7');
      expect(displayChord('F', ChordNotation.numbers, 'G', 0), 'b7');
    });

    test('a minor key is numbered against its relative major', () {
      expect(numberingLabel('Am'), '1 = C');
      expect(displayChord('Am', ChordNotation.numbers, 'Am', 0), '6m');
    });

    test('letters transpose, and numbers fall back to letters without a key', () {
      expect(displayChord('G', ChordNotation.letters, 'G', 2), 'A');
      expect(displayChord('G', ChordNotation.numbers, null, 2), 'A');
      expect(canUseNumbers('H'), isFalse);
    });
  });

  group('chords over lyrics', () {
    List<List<String>> words(String line) => [
      for (final word in chordLyricWords(parseLine(line))) [for (final unit in word) unit.toString()],
    ];

    test('puts each chord over the word it lands on', () {
      expect(words('[G]Amazing [C]grace'), [
        ['[G]Amazing '],
        ['[C]grace'],
      ]);
    });

    test('keeps a mid-word chord inside its word', () {
      expect(words('A[G]mazing grace'), [
        ['[]A', '[G]mazing '],
        ['[]grace'],
      ]);
    });

    test('stacked and trailing chords get columns of their own', () {
      expect(words('[G][C]Lord [D]'), [
        ['[G]', '[C]Lord '],
        ['[D]'],
      ]);
    });

    test('an inline section label stands alone', () {
      expect(words('[Chorus] [G]Sing'), [
        ['section(Chorus)'],
        ['[] '],
        ['[G]Sing'],
      ]);
    });
  });

  group('lines', () {
    test('lyrics with inline chords', () {
      final line = classifyLine('[G]Amazing [C]grace') as TextLine;
      expect(line.segments.map((s) => (s.kind, s.value)), [
        (SegmentKind.chord, 'G'),
        (SegmentKind.text, 'Amazing '),
        (SegmentKind.chord, 'C'),
        (SegmentKind.text, 'grace'),
      ]);
    });

    test('plain and bracketed section headers, with repeats', () {
      expect(classifyLine('Verse 1:'), isA<SectionLine>().having((l) => l.label, 'label', 'Verse 1'));
      expect(classifyLine('Chorus: x2'), isA<SectionLine>().having((l) => l.repeat, 'repeat', 2));
      expect(classifyLine('[Bridge] 3x'), isA<SectionLine>().having((l) => l.repeat, 'repeat', 3));
      expect(classifyLine('[Intro]'), isA<SectionLine>().having((l) => l.repeat, 'repeat', 1));
    });

    test('blank lines', () {
      expect(classifyLine(''), isA<BlankLine>());
    });

    test('a row of bare chords', () {
      final line = classifyLine('[G]   [D]  [Em]') as ChordsLine;
      expect(line.chords, ['G', 'D', 'Em']);
      expect(line.repeat, 1);
    });

    test('a barline row reads as bars, with the outer barlines optional', () {
      final a = classifyLine('| [C] [G] | [Am] | % | x2') as BarChartLine;
      final b = classifyLine('[C] [G] | [Am] | % | x2') as BarChartLine;
      for (final line in [a, b]) {
        expect(line.bars.length, 3);
        expect(line.repeat, 2);
        expect(line.bars[0].atoms.map((x) => x.map((s) => s.value).join()), ['C', 'G']);
        expect(line.bars[2].simile, isTrue);
        expect(line.bars[2].atoms, isEmpty);
      }
    });

    test('a beat placeholder stays in its own atom, a slash chord stays whole', () {
      final line = classifyLine('| [C] . . [G] | [D]/[B] |') as BarChartLine;
      expect(line.bars[0].atoms.length, 4);
      expect(isDotSeparatorAtom(line.bars[0].atoms[1]), isTrue);
      expect(line.bars[1].atoms.length, 1);
    });

    test("a time signature in a bar is that bar's, and only on a bar line", () {
      final line = classifyLine('| 2/4 [Em] [F#m] | [G] . [A] . |') as BarChartLine;
      expect(line.bars[0].meter?.value, '2/4');
      expect(line.bars[0].meter?.count, 2);
      expect(line.bars[0].atoms.length, 2, reason: 'the signature is not an atom');
      expect(line.bars[1].meter, isNull);

      final before = classifyLine('2/4 | [Em] [F#m] | [G] |') as BarChartLine;
      expect(before.bars.length, 2);
      expect(before.bars[0].meter?.count, 2);

      expect(classifyLine('[G]Sing 2/4 time'), isA<TextLine>());
      expect(classifyLine('2/4 [Em] [F#m]'), isA<TextLine>());
      expect(parseMeterToken('3/5'), isNull);
      expect(parseMeterToken('6/8'), 6);
    });

    test('a pipe or x2 inside lyrics is not structure', () {
      expect(classifyLine('Sing | it out x2 loud'), isA<TextLine>());
      expect(classifyLine('[G]Sing it | [C]loud'), isA<TextLine>());
    });

    test('Windows and old-Mac line endings', () {
      expect(parseChart('Verse:\r\n[G]hi\r[C]yo').length, 3);
    });
  });

  group('isChordLyricLine', () {
    bool lyric(String line) => isChordLyricLine(parseLine(line));

    test('reads chords with hold separators as written, not over the dashes', () {
      expect(lyric('[C]-[G]-[Am]--[F]'), isFalse);
      expect(lyric('[F]_[G]'), isFalse);
      expect(lyric('[C] - [G] -- [Am]'), isFalse);
      expect(lyric('[C]~[G]...[D]'), isFalse);
      expect(lyric('[C]\u2014[G]\u2013[D]'), isFalse);
      expect(lyric('[G]/[B]'), isFalse);
    });

    test('keeps lyric lines chords-over-words', () {
      expect(lyric('[G]Amazing [C]grace'), isTrue);
      expect(lyric('[G]Oh - [C]Lord'), isTrue);
      expect(lyric('A[G]mazing'), isTrue);
    });

    test('is false without chords', () {
      expect(lyric('Amazing grace'), isFalse);
    });
  });
}
