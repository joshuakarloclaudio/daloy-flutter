import 'package:daloy_flutter/features/songs/chart/nashville.dart';
import 'package:daloy_flutter/features/songs/editor/chart_editor_core.dart';
import 'package:daloy_flutter/features/songs/editor/nashville_paste.dart';
import 'package:daloy_flutter/features/songs/editor/physical_input.dart';
import 'package:flutter_test/flutter_test.dart';

String typeSpace(String line) => applyPhysicalTextInsert(line, line.length, ' ', letterTokenInput).content;

ChartEditorCore editor(String content, {String? key = 'G', ChordNotation notation = ChordNotation.letters}) =>
    ChartEditorCore(content: content, musicalKey: key, notation: notation);

void main() {
  group('the pending word', () {
    test('only matches a word that starts at a boundary', () {
      // Without the anchor the match slides to the last A–G anywhere, and `hold` ends at `d`.
      expect(extractPendingChordWord('hold', 4, pendingChordWord), isNull);
      expect(extractPendingChordWord('grace', 5, pendingChordWord)?.raw, 'grace');
      expect(extractPendingChordWord('G', 1, pendingChordWord)?.raw, 'G');
      expect(extractPendingChordWord('C G', 3, pendingChordWord)?.raw, 'G');
      expect(extractPendingChordWord('[C]G', 4, pendingChordWord)?.raw, 'G');
    });

    test('is not picked out of an open bracket', () {
      expect(extractPendingChordWord('[Am', 3, pendingChordWord), isNull);
    });
  });

  group('letter entry never picks a chord out of a word', () {
    test('leaves prose alone', () {
      expect(typeSpace('hold'), 'hold ');
      expect(typeSpace('hold 2 bars'), 'hold 2 bars ');
      expect(typeSpace('grace'), 'grace ');
      expect(typeSpace('capo'), 'capo ');
    });

    test('still brackets real chords', () {
      expect(typeSpace('G'), '[G] ');
      expect(typeSpace('Am7'), '[Am7] ');
      expect(typeSpace('G C D'), 'G C [D] ');
      expect(typeSpace('[C] G'), '[C] [G] ');
    });

    test('a section label is never wrapped', () {
      expect(typeSpace('Chorus:'), 'Chorus: ');
    });

    test('any delimiter closes a chord, a slash chord keeps its bass bracketed', () {
      for (final d in ['\n', '-', '|', '%', ' ']) {
        expect(applyPhysicalTextInsert('G', 1, d, letterTokenInput).content, '[G]$d');
      }
      expect(typeSpace('G/B'), '[G]/[B] ');
    });
  });

  group('number entry', () {
    final input = nashvilleTokenInput('G');

    test('brackets degrees as letters in the key, on a line of chords only', () {
      expect(applyPhysicalTextInsert('1 4', 3, ' ', input).content, '1 [C] ');
      expect(applyPhysicalTextInsert('6m', 2, ' ', input).content, '[Em] ');
      expect(applyPhysicalTextInsert('1/3', 3, ' ', input).content, '[G]/[B] ');
    });

    test('never touches prose: Verse 2, hold 2, x4', () {
      expect(applyPhysicalTextInsert('hold 2', 6, ' ', input).content, 'hold 2 ');
      expect(applyPhysicalTextInsert('Verse 2', 7, ' ', input).content, 'Verse 2 ');
      expect(applyPhysicalTextInsert('1 4 5 x4', 8, ' ', input).content, '1 4 5 x4 ');
    });

    test('the input-line rule', () {
      expect(isNashvilleInputLine(''), isTrue);
      expect(isNashvilleInputLine('1 4 '), isTrue);
      expect(isNashvilleInputLine('[C] '), isTrue);
      expect(isNashvilleInputLine('[G]/[B]  6m  '), isTrue);
      expect(isNashvilleInputLine('hold '), isFalse);
      expect(isNashvilleInputLine('Amazing grace '), isFalse);
      expect(isNashvilleInputLine('Verse:'), isFalse);
    });
  });

  group('typing on a chord edits it', () {
    test('a modifier key changes the quality', () {
      final e = editor('[G]');
      e.typeChar('m');
      expect(e.content, '[Gm]');
      e.typeChar('7');
      expect(e.content, '[Gm7]');
    });

    test('a letter at the opening bracket swaps the root and keeps the accidental', () {
      final e = editor('[F#m]');
      e.moveToStart();
      e.typeChar('a');
      expect(e.content, '[A#m]');
    });

    test('a degree at the opening bracket swaps the root in numbers', () {
      final e = editor('[G]', notation: ChordNotation.numbers);
      e.moveToStart();
      e.typeChar('4');
      expect(e.content, '[C]');
    });

    test('a quality character is appended at the chord end', () {
      final e = editor('[G]');
      e.typeChar('s');
      e.typeChar('u');
      e.typeChar('s');
      expect(e.content, '[Gsus]');
    });

    test('at the opening bracket only a root letter edits; any other key is text before the chord', () {
      final e = editor('[G]');
      e.moveToStart();
      e.typeChar('x');
      expect(e.content, 'x[G]');
    });
  });

  group('typing through the core', () {
    test('a chord line typed whole, with Enter closing the last chord', () {
      final e = editor('');
      for (final ch in 'G D Em C'.split('')) {
        e.typeChar(ch);
      }
      e.typeNewline();
      expect(e.content, 'G D Em [C]\n'.replaceFirst('G D Em ', '[G] [D] [Em] '));
    });

    test('undo walks back one character at a time', () {
      final e = editor('');
      e.typeChar('G');
      e.typeChar(' ');
      expect(e.content, '[G] ');
      e.undo();
      expect(e.content, 'G');
    });
  });

  test('mixed paste: number lines convert, letter lines bracket', () {
    final pasted = ['Verse:', '1 4 5 6m', 'G C D Em', 'Amazing grace'].join('\n');
    expect(
      prepareChordPaste(pasted, asChords: true, musicalKey: 'C'),
      'Verse:\n[C] [F] [G] [Am]\n[G] [C] [D] [Em]\nAmazing grace',
    );
  });
}
