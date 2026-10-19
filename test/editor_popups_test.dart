import 'dart:ui';

import 'package:daloy_flutter/features/songs/editor/nashville_paste.dart';
import 'package:daloy_flutter/features/songs/editor/popup_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('popup geometry', () {
    const screen = Size(390, 844);

    test('sits above the key, centred, in a grid of at most three columns', () {
      final l = layoutPopup(const Rect.fromLTWH(150, 600, 50, 50), 6, screen);
      expect((l.cols, l.rows, l.cells.length), (3, 2, 6));
      expect(l.below, isFalse);
      expect(l.rect.bottom, lessThan(600));
      expect(l.rect.center.dx, closeTo(175, 0.5));
    });

    test('is pulled back inside the screen edges', () {
      final left = layoutPopup(const Rect.fromLTWH(0, 600, 50, 50), 6, screen);
      expect(left.rect.left, 8);
      final right = layoutPopup(const Rect.fromLTWH(340, 600, 50, 50), 6, screen);
      expect(right.rect.right, 390 - 8);
    });

    test('drops below the key when there is no headroom', () {
      final l = layoutPopup(const Rect.fromLTWH(150, 20, 50, 50), 6, screen);
      expect(l.below, isTrue);
      expect(l.rect.top, greaterThan(70));
    });

    test('hit-testing picks the cell under the finger and misses off the grid', () {
      final l = layoutPopup(const Rect.fromLTWH(150, 600, 50, 50), 6, screen);
      for (var i = 0; i < l.cells.length; i++) {
        expect(hitTestPopup(l, l.cells[i].center), i);
      }
      expect(hitTestPopup(l, const Offset(5, 5)), -1);
      // A gap between cells resolves to a neighbour, never a dead zone.
      final gap = Offset(l.cells[0].right + popupGap / 2, l.cells[0].center.dy);
      expect(hitTestPopup(l, gap), isIn([0, 1]));
    });

    test('a short last row is a miss under its empty tail', () {
      final l = layoutPopup(const Rect.fromLTWH(150, 600, 50, 50), 4, screen); // 3 + 1
      expect(hitTestPopup(l, Offset(l.cells[3].center.dx + popupCellWidth + popupGap, l.cells[3].center.dy)), -1);
    });
  });

  group('number-chart paste', () {
    test('spots number lines, not lyrics or letter lines', () {
      expect(isNashvilleChordLine('1 4 5 6m'), isTrue);
      expect(isNashvilleChordLine('| 1 | 4 | x2'), isTrue);
      expect(isNashvilleChordLine('[1] [4]'), isTrue);
      expect(isNashvilleChordLine('Verse 2'), isFalse);
      expect(isNashvilleChordLine('hold 2 bars'), isFalse);
      expect(isNashvilleChordLine('G 4'), isFalse); // mixed
      expect(isNashvilleChordLine('4'), isFalse); // one bare token isn't a chart
      expect(isNashvilleChordLine('Chorus:'), isFalse);
      expect(countNashvilleLines('1 4 5\nAmazing grace\n6m 5 4'), 2);
    });

    test('converts to bracketed letter chords in the key and leaves other lines alone', () {
      expect(
        normalizePastedNashvilleContent('1 4 5 6m\nAmazing grace\n1/3 5', 'G'),
        '[G] [C] [D] [Em]\nAmazing grace\n[G]/[B] [D]',
      );
      expect(normalizePastedNashvilleContent('1 4', null), isNull);
    });

    test('a key-less paste keeps its numbers; the prepared paste runs the letter pass too', () {
      expect(prepareChordPaste('1 4', asChords: true, musicalKey: null), '1 4');
      expect(prepareChordPaste('1 4\nG D', asChords: true, musicalKey: 'C'), '[C] [F]\n[G] [D]');
      expect(prepareChordPaste('1 4', asChords: false, musicalKey: 'C'), '1 4');
    });

    test('formats single tokens', () {
      expect(formatTypedNashvilleToken('6m', 'C'), '[Am]');
      expect(formatTypedNashvilleToken('x', 'C'), isNull);
      expect(firstNashvilleLine('hi\n1  4   5'), '1   4   5');
      expect(lettersOf('[G] [C]'), 'G C');
    });
  });
}
