import 'package:daloy_flutter/features/songs/chart/nashville.dart';
import 'package:daloy_flutter/features/songs/editor/chart_edit.dart';
import 'package:daloy_flutter/features/songs/editor/chart_editor_core.dart';
import 'package:daloy_flutter/features/songs/editor/editor_history.dart';
import 'package:daloy_flutter/features/songs/editor/quality_menu.dart';
import 'package:flutter_test/flutter_test.dart';

ChartEditorCore editor(String content, {String? key = 'G', ChordNotation notation = ChordNotation.letters}) =>
    ChartEditorCore(content: content, musicalKey: key, notation: notation);

void main() {
  group('tokens and cursor', () {
    test('finds the chord under the cursor, and flush after one at the end', () {
      const doc = 'a [G] b [Am7]';
      expect(findChordTokenAtCursor(doc, 4)?.inner, 'G'); // inside
      expect(findChordTokenAtCursor(doc, 2)?.inner, 'G'); // on [
      expect(findChordTokenAtCursor(doc, doc.length)?.inner, 'Am7'); // trailing edge
      expect(findChordTokenAtCursor(doc, 6), isNull); // after ] mid-line
    });

    test('snaps out of a chord to the nearer edge', () {
      expect(snapCursorColInLine('x[Cmaj7]y', 3), 1);
      expect(snapCursorColInLine('x[Cmaj7]y', 7), 8);
      expect(snapCursorColInLine('abc', 99), 3);
    });

    test('arrows step over a whole chord', () {
      const doc = '[G]ab';
      expect(moveCursorThroughToken(doc, 0, Direction.right), 3);
      expect(moveCursorThroughToken(doc, 3, Direction.left), 0);
      expect(moveCursorThroughToken(doc, 4, Direction.left), 3);
    });

    test('up and down keep the column and never land inside a chord', () {
      const doc = 'abcdef\n[Cmaj7]x\nxy';
      expect(moveCursorDown(doc, 3), 7); // col 3 is inside the chord → its start
      expect(moveCursorUp(doc, 17), 7); // col 1 is inside the chord → its start
      expect(moveCursorUp(doc, 2), 0);
      expect(moveCursorDown(doc, doc.length), doc.length);
    });
  });

  group('qualities', () {
    test('combine when they can, replace otherwise', () {
      expect(applyModifierToQuality('', 'm'), 'm');
      expect(applyModifierToQuality('m', '7'), 'm7');
      expect(applyModifierToQuality('dim', '7'), 'dim7');
      expect(applyModifierToQuality('m7', 'm7b5'), 'm7b5');
      expect(applyModifierToQuality('7', 'sus4'), 'sus4');
      expect(applyModifierToQuality('m', 'm'), 'm');
    });

    test('a modifier edits the chord at the cursor', () {
      final e = applyModifierToTokenAtCursor('[G/B]', 1, 'sus4')!;
      expect(e.content, '[Gsus4/B]');
      expect(e.cursor, e.content.length);
      expect(applyModifierToTokenAtCursor('abc', 1, 'm'), isNull);
    });

    test('unknown qualities read as plain', () {
      expect(qualityToModifier('maj'), '');
      expect(qualityToModifier('min'), 'm');
      expect(qualityToModifier('weird'), '');
    });
  });

  group('delete', () {
    test('backspace trims a chord quality one character at a time', () {
      final e = ChartEditorCore(content: '[Gsus4]', musicalKey: 'G');
      e.deleteBack();
      expect(e.content, '[Gsus]');
      e.deleteBack();
      e.deleteBack();
      e.deleteBack();
      expect(e.content, '[G]');
    });

    test('backspace removes a whole chord when it has no quality, else one character', () {
      final e = ChartEditorCore(content: 'ab [G]', musicalKey: 'G');
      e.deleteBack();
      expect(e.content, 'ab ');
      e.deleteBack();
      expect(e.content, 'ab');
    });
  });

  group('keyboard', () {
    test('a root key inserts a chord; an armed modifier is added then cleared', () {
      final e = editor('');
      e.selectModifier('m7');
      expect(e.selectedModifier, 'm7');
      e.insertChord('A');
      expect(e.content, '[Am7]');
      expect(e.selectedModifier, 'm7'); // the chord now under the cursor
      e.insertChord('D');
      expect(e.content, '[Am7][D]');
    });

    test('tapping the armed modifier again disarms it', () {
      final e = editor('');
      e.selectModifier('7');
      e.selectModifier('7');
      e.insertChord('G');
      expect(e.content, '[G]');
    });

    test('a modifier with the cursor on a chord edits that chord', () {
      final e = editor('[G]');
      e.selectModifier('7');
      expect(e.content, '[G7]');
    });

    test('numbers become letters in the song key, quality appended after', () {
      final e = editor('', key: 'C', notation: ChordNotation.numbers);
      e.selectModifier('m');
      e.insertChord('2');
      e.insertChord('b7');
      expect(e.content, '[Dm][Bb]');
    });

    test('numbers need a key; without one the editor stays in letters and refuses', () {
      final e = editor('', key: null, notation: ChordNotation.numbers);
      expect(e.numbersAvailable, isFalse);
      expect(e.notation, ChordNotation.letters);
      e.insertChord('C');
      expect(e.content, '[C]');
    });

    test('a diatonic key uses its own quality unless a modifier is armed', () {
      final e = editor('');
      e.insertDiatonicChord('E', 'm');
      e.insertText(' '); // off the chord, so the modifier arms instead of editing it
      e.selectModifier('sus4');
      e.insertDiatonicChord('D', '');
      expect(e.content, '[Em] [Dsus4]');
    });

    test('a popup quality always wins', () {
      final e = editor('');
      e.selectModifier('m');
      e.insertChordWithQuality('G', 'maj7');
      expect(e.content, '[Gmaj7]');
    });

    test('sections and repeats land on their own line / spaced', () {
      final e = editor('[G]');
      e.insertSectionName('Chorus');
      expect(e.content, '[G]\nChorus:\n');
      e.insertText('[C]');
      e.insertRepeat(2);
      expect(e.content, '[G]\nChorus:\n[C] x2');
    });

    test('a bar time signature is spaced, and brings a barline when the line has none', () {
      final e = editor('| [G] |');
      e.insertMeter('2/4');
      expect(e.content, '| [G] | 2/4 ');
      final f = editor('');
      f.insertMeter('3/4');
      expect(f.content, '| 3/4 ');
    });

    test('a bass note follows the chord as its own token', () {
      final e = editor('[G]');
      e.insertBassNote('B');
      expect(e.content, '[G]/[B]');
    });

    test('a tap places the cursor, never inside a chord', () {
      final e = editor('Verse:\nx[Cmaj7]y');
      e.tapAt(1, 3);
      expect(e.cursor, 7 + 1);
      e.tapAt(1, 0);
      expect(e.cursor, 7);
    });
  });

  group('history', () {
    test('undo and redo walk the edits; a new edit clears redo', () {
      final e = editor('');
      e.insertChord('G');
      e.insertChord('C');
      e.undo();
      expect(e.content, '[G]');
      e.redo();
      expect(e.content, '[G][C]');
      e.undo();
      e.insertChord('D');
      expect(e.canRedo, isFalse);
      expect(e.content, '[G][D]');
    });

    test('history is capped', () {
      final h = EditorHistory(const EditorSnapshot('', 0));
      for (var i = 1; i <= 150; i++) {
        h.commit(EditorSnapshot('x' * i, i));
      }
      var steps = 0;
      while (h.undo() != null) {
        steps++;
      }
      expect(steps, EditorHistory.maxHistory);
    });
  });

  group('paste', () {
    test('bare chords are bracketed; structure and lyrics are left alone', () {
      expect(normalizePastedChordLine('G  C/E | Am7 - D x2'), '[G]  [C]/[E] | [Am7] - [D] x2');
      expect(normalizePastedChordLine('Chorus:'), 'Chorus:');
      expect(normalizePastedChordLine('[G] already'), '[G] already');
    });

    test('paste inserts at the cursor', () {
      final e = editor('Verse:\n');
      e.paste('G D\nEm C');
      expect(e.content, 'Verse:\n[G] [D]\n[Em] [C]');
    });
  });

  group('diatonic and the popup menu', () {
    test('a major key lists its seven triads', () {
      expect([for (final c in diatonicChords('G')!) c.chord], ['G', 'Am', 'Bm', 'C', 'D', 'Em', 'F#dim']);
      expect(diatonicChords('G')![5].numberLabel, '6m');
    });

    test('a minor key opens on its own tonic', () {
      expect([for (final c in diatonicChords('Am')!) c.chord], ['Am', 'Bdim', 'C', 'Dm', 'Em', 'F', 'G']);
    });

    test('borrowed chords are the common outsiders, in letters and numbers', () {
      expect([for (final c in borrowedChords('G')!) c.chord], ['F', 'Bb', 'Eb', 'Cm', 'A', 'B', 'E']);
      expect([for (final c in borrowedChords('G')!) c.numberLabel], ['b7', 'b3', 'b6', '4m', '2', '3', '6']);
      expect([for (final c in borrowedChords('Am')!) c.chord], ['E', 'E7', 'D', 'A', 'Bb']);
      expect(borrowedChords(null), isNull);
    });

    test('an unusable key has no diatonic row', () {
      expect(diatonicChords(null), isNull);
      expect(diatonicChords('H'), isNull);
    });

    test('bass options lead with the third and fifth', () {
      expect(diatonicBassOptions('C', 'C')!.take(2), ['E', 'G']);
      expect(diatonicBassOptions('G', 'C')!.take(2), ['B', 'D']);
    });

    test('the quality menu starts with the diatonic quality, six at most', () {
      expect(qualityMenuForRoot('A', 'G').first, 'm');
      expect(qualityMenuForRoot('G', 'G').first, '');
      for (final root in ['C', 'D', 'E', 'F', 'G', 'A', 'B', 'Eb']) {
        expect(qualityMenuForRoot(root, 'C').length, lessThanOrEqualTo(6));
      }
      expect(qualityMenuForRoot('Eb', 'C'), ['', 'm', '7', 'maj7', 'm7', 'sus4']);
    });

    test('number tokens resolve in the key', () {
      expect(nashvilleToChord('6m', 'C'), 'Am');
      expect(nashvilleToChord('1/3', 'C'), 'C/E');
      expect(nashvilleToChord('b7', 'G'), 'F');
      expect(nashvilleToChord('4', null), isNull);
      expect(nashvilleToChord('8', 'C'), isNull);
    });
  });
}
