import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/songs/chart/nashville.dart';
import 'package:daloy_flutter/features/songs/editor/editor_line.dart';
import 'package:daloy_flutter/features/songs/presentation/editor/chart_editor_screen.dart';
import 'package:daloy_flutter/features/songs/presentation/editor/chart_editor_view.dart';
import 'package:daloy_flutter/features/songs/presentation/editor/chord_keyboard.dart';
import 'package:daloy_flutter/features/songs/presentation/widgets/chord_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the editor over a button and records what Done returns.
Future<List<String?>> _open(
  WidgetTester tester, {
  String content = '',
  String? key = 'G',
  ChordNotation notation = ChordNotation.letters,
  Size size = const Size(390, 844),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final result = <String?>[];
  await tester.pumpWidget(
    MaterialApp(
      theme: DaloyTheme.light(),
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async =>
              result.add(await showChartEditor(context, content: content, musicalKey: key, notation: notation)),
          child: const Text('Go'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Go'));
  await tester.pumpAndSettle();
  return result;
}

Future<void> _press(WidgetTester tester, Finder f) async {
  await tester.tap(f);
  await tester.pump(const Duration(milliseconds: 50));
}

/// Holds [key] until its popup opens, slides to the cell labelled [cell]
/// (or off the grid when null) and lifts.
Future<void> _holdAndPick(WidgetTester tester, Finder key, {String? cell, bool lift = true}) async {
  final gesture = await tester.startGesture(tester.getCenter(key));
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(); // the overlay builds on the next frame
  if (cell != null) {
    await gesture.moveTo(tester.getCenter(find.text(cell)));
  } else {
    await gesture.moveTo(const Offset(2, 2)); // far off the grid
  }
  await tester.pump();
  if (lift) await gesture.up();
  await tester.pump();
}

Future<void> _mockClipboard(WidgetTester tester, String? text) async {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'Clipboard.getData') return text == null ? null : {'text': text};
    return null;
  });
  addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
}

/// Opens the chord-key settings, picks [option] and closes the sheet again.
Future<void> _setting(WidgetTester tester, String option) async {
  await tester.tap(find.bySemanticsLabel(RegExp('^Chord keys:')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option));
  await tester.pumpAndSettle();
  Navigator.of(tester.element(find.text(option))).pop(); // a page sheet has no barrier to tap
  await tester.pumpAndSettle();
}

Future<void> _done(WidgetTester tester) async {
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
}

/// Types [chars] the way a physical keyboard reports them.
Future<void> _type(WidgetTester tester, String chars) async {
  const keys = {
    'g': LogicalKeyboardKey.keyG,
    'd': LogicalKeyboardKey.keyD,
    'e': LogicalKeyboardKey.keyE,
    'm': LogicalKeyboardKey.keyM,
    'h': LogicalKeyboardKey.keyH,
    'o': LogicalKeyboardKey.keyO,
    'l': LogicalKeyboardKey.keyL,
    ' ': LogicalKeyboardKey.space,
  };
  for (final ch in chars.split('')) {
    final key = keys[ch.toLowerCase()]!;
    await tester.sendKeyDownEvent(key, character: ch);
    await tester.sendKeyUpEvent(key);
  }
  await tester.pump();
}

Future<void> _chord(WidgetTester tester, LogicalKeyboardKey mod, LogicalKeyboardKey key, {bool shift = false}) async {
  await tester.sendKeyDownEvent(mod);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyDownEvent(key);
  await tester.sendKeyUpEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(mod);
  await tester.pump();
}

void main() {
  group('hardware keyboard', () {
    testWidgets('typing writes the chart, wrapping each chord when a delimiter ends it', (tester) async {
      final result = await _open(tester);
      await _type(tester, 'G D em ');
      await _done(tester);
      expect(result, ['[G] [D] [Em] ']);
    });

    testWidgets('prose is left alone', (tester) async {
      final result = await _open(tester);
      await _type(tester, 'hold ');
      await _done(tester);
      expect(result, ['hold ']);
    });

    testWidgets('arrows, backspace and enter edit like a text field', (tester) async {
      final result = await _open(tester, content: 'ab');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await _done(tester);
      expect(result, ['\nb']);
    });

    testWidgets('⌘Z undoes and ⌘⇧Z redoes', (tester) async {
      final result = await _open(tester);
      await _press(tester, find.bySemanticsLabel('Insert D'));
      await _chord(tester, LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.keyZ);
      await _chord(tester, LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.keyZ, shift: true);
      await _done(tester);
      expect(result, ['[D]']);
    });

    testWidgets('⌘Z on its own really undoes', (tester) async {
      final result = await _open(tester);
      await _press(tester, find.bySemanticsLabel('Insert D'));
      await _chord(tester, LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.keyZ);
      await _done(tester);
      expect(result, ['']);
    });

    testWidgets('⌘Enter is Done', (tester) async {
      final result = await _open(tester);
      await _press(tester, find.bySemanticsLabel('Insert D'));
      await _chord(tester, LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(result, ['[D]']);
    });

    testWidgets('Escape asks before throwing edits away', (tester) async {
      final result = await _open(tester);
      await _press(tester, find.bySemanticsLabel('Insert D'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();
      expect(result, isEmpty);
    });
  });

  group('free-type mode (system keyboard)', () {
    testWidgets('swaps the chord keys for a text field holding the chart, and back', (tester) async {
      final result = await _open(tester, content: '[G]');
      expect(find.byType(ChordKeyboard), findsOneWidget);
      await tester.tap(find.byTooltip('Switch to the system keyboard'));
      await tester.pumpAndSettle();
      expect(find.byType(ChordKeyboard), findsNothing);
      expect(find.widgetWithText(TextField, '[G]'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '[G] [C]\nVerse:');
      await tester.tap(find.byTooltip('Switch to the chord keyboard'));
      await tester.pumpAndSettle();
      expect(find.byType(ChordKeyboard), findsOneWidget);
      expect(find.textContaining('VERSE'), findsOneWidget); // drawn in the chart, as a section label

      await tester.tap(find.byTooltip('Undo')); // the typed text is one undo step
      await tester.pump();
      await _done(tester);
      expect(result, ['[G]']);
    });

    testWidgets('Done saves what was typed', (tester) async {
      final result = await _open(tester);
      await tester.tap(find.byTooltip('Switch to the system keyboard'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Intro:\n[C][Em]');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(result, ['Intro:\n[C][Em]']);
    });

    testWidgets('leaving with typed text asks first', (tester) async {
      final result = await _open(tester);
      await tester.tap(find.byTooltip('Switch to the system keyboard'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '[G]');
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();
      expect(result, [null]);
    });
  });

  group('layout', () {
    testWidgets('numbers mode says what is saved', (tester) async {
      await _open(tester, key: 'C', notation: ChordNotation.numbers);
      expect(find.textContaining('Saved as chords in the key of'), findsOneWidget);
    });

    testWidgets('a wide screen puts the keyboard beside the chart, its keys stretched', (tester) async {
      await _open(tester, content: 'Amazing grace', size: const Size(1180, 820));
      final keyboard = tester.getRect(find.byType(ChordKeyboard));
      final chart = tester.getRect(find.text('Amazing grace'));
      expect(keyboard.left, greaterThan(chart.right)); // side by side
      expect(keyboard.width, lessThanOrEqualTo(460));
      expect(keyboard.bottom, closeTo(820, 40)); // docked to the bottom
      expect(keyboard.height, greaterThan(360)); // taller than a phone's
      expect(tester.takeException(), isNull);
    });

    testWidgets('a phone keeps the keyboard under the chart', (tester) async {
      await _open(tester, content: 'Amazing grace');
      expect(
        tester.getRect(find.byType(ChordKeyboard)).top,
        greaterThan(tester.getRect(find.text('Amazing grace')).bottom),
      );
    });
  });

  group('long-press popups', () {
    testWidgets('hold a chord, slide to a quality, lift: one gesture inserts it', (tester) async {
      final result = await _open(tester); // key of G
      await _holdAndPick(tester, find.bySemanticsLabel('Insert D'), cell: 'Dsus4');
      await _done(tester);
      expect(result, ['[Dsus4]']);
    });

    testWidgets('lifting without sliding takes the first cell — the diatonic quality', (tester) async {
      final result = await _open(tester);
      final gesture = await tester.startGesture(tester.getCenter(find.bySemanticsLabel('Insert Em')));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(find.text('Em7'), findsOneWidget); // the popup is open
      await gesture.up();
      await tester.pump();
      await _done(tester);
      expect(result, ['[Em]']);
    });

    testWidgets('sliding off the grid cancels', (tester) async {
      final result = await _open(tester);
      await _holdAndPick(tester, find.bySemanticsLabel('Insert D'));
      expect(find.text('Dsus4'), findsNothing); // closed again
      await _done(tester);
      expect(result, ['']);
    });

    testWidgets('a quick tap still inserts and never opens the popup', (tester) async {
      final result = await _open(tester);
      await _press(tester, find.bySemanticsLabel('Insert D'));
      expect(find.text('Dsus4'), findsNothing);
      await _done(tester);
      expect(result, ['[D]']);
    });

    testWidgets('the same hold works on the twelve roots', (tester) async {
      final result = await _open(tester, key: 'C');
      await _setting(tester, 'All 12 roots');
      await _holdAndPick(tester, find.bySemanticsLabel('Insert A'), cell: 'Am7');
      await _done(tester);
      expect(result, ['[Am7]']);
    });

    testWidgets('in numbers the cells read as numbers, the chart still gets letters', (tester) async {
      final result = await _open(tester, key: 'C', notation: ChordNotation.numbers);
      await _holdAndPick(tester, find.bySemanticsLabel('Insert Am'), cell: '6m7');
      await _done(tester);
      expect(result, ['[Am7]']);
    });

    testWidgets('hold / for the bass notes that suit the chord at the cursor', (tester) async {
      final result = await _open(tester, content: '[G]');
      await _holdAndPick(tester, find.bySemanticsLabel('Insert slash. Hold for bass notes'), cell: '/B');
      await _done(tester);
      expect(result, ['[G]/[B]']);
    });

    testWidgets('a tap on / still inserts a slash', (tester) async {
      final result = await _open(tester);
      await _press(tester, find.bySemanticsLabel('Insert slash. Hold for bass notes'));
      await _done(tester);
      expect(result, ['/']);
    });
  });

  group('pasting', () {
    testWidgets('plain chords get brackets without asking', (tester) async {
      await _mockClipboard(tester, 'G D\nEm C');
      final result = await _open(tester);
      await _press(tester, find.descendant(of: find.byType(ChordKeyboard), matching: find.bySemanticsLabel('Edit')));
      await _press(tester, find.bySemanticsLabel('Paste'));
      await tester.pumpAndSettle();
      expect(find.text('This looks like a number chart'), findsNothing);
      await _done(tester);
      expect(result, ['[G] [D]\n[Em] [C]']);
    });

    testWidgets('a number chart asks, and "Paste as chords" converts it in the key', (tester) async {
      await _mockClipboard(tester, '1 4 5 6m');
      final result = await _open(tester); // key of G
      await _press(tester, find.descendant(of: find.byType(ChordKeyboard), matching: find.bySemanticsLabel('Edit')));
      await _press(tester, find.bySemanticsLabel('Paste'));
      await tester.pumpAndSettle();
      expect(find.text('This looks like a number chart'), findsOneWidget);
      expect(find.text('G   C   D   Em'), findsOneWidget); // the preview
      await tester.tap(find.text('Paste as chords'));
      await tester.pumpAndSettle();
      await _done(tester);
      expect(result, ['[G] [C] [D] [Em]']);
    });

    testWidgets('"Paste as-is" keeps the numbers', (tester) async {
      await _mockClipboard(tester, '1 4 5');
      final result = await _open(tester);
      await _press(tester, find.descendant(of: find.byType(ChordKeyboard), matching: find.bySemanticsLabel('Edit')));
      await _press(tester, find.bySemanticsLabel('Paste'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Paste as-is'));
      await tester.pumpAndSettle();
      await _done(tester);
      expect(result, ['1 4 5']);
    });

    testWidgets('without a key the prompt says to set one, and only offers as-is', (tester) async {
      await _mockClipboard(tester, '1 4 5');
      final result = await _open(tester, key: null);
      await _press(tester, find.descendant(of: find.byType(ChordKeyboard), matching: find.bySemanticsLabel('Edit')));
      await _press(tester, find.bySemanticsLabel('Paste'));
      await tester.pumpAndSettle();
      expect(find.textContaining("Set the song's key first"), findsOneWidget);
      expect(find.text('Paste as chords'), findsNothing);
      await tester.tap(find.text('Paste as-is'));
      await tester.pumpAndSettle();
      await _done(tester);
      expect(result, ['1 4 5']);
    });
  });

  testWidgets('the help sheet opens from the app bar', (tester) async {
    await _open(tester);
    await tester.tap(find.byTooltip('Help'));
    await tester.pumpAndSettle();
    expect(find.text('Chord notation'), findsOneWidget);
    expect(find.text('Basic chords'), findsOneWidget);
  });

  testWidgets('the Key layout has a second row of borrowed chords that insert like any chord', (tester) async {
    final result = await _open(tester); // key of G
    await _press(tester, find.bySemanticsLabel('Insert F')); // ♭VII
    await _press(tester, find.bySemanticsLabel('Insert Cm')); // iv
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, ['[F][Cm]']);
  });

  testWidgets('the keyboard keeps one height across tabs and the Key / All layouts', (tester) async {
    await _open(tester);
    double height() => tester.getSize(find.byType(ChordKeyboard)).height;
    final chords = height();
    await _setting(tester, 'All 12 roots');
    expect(height(), chords);
    await _press(tester, find.bySemanticsLabel('Sections'));
    expect(height(), chords);
    await _press(tester, find.bySemanticsLabel('Edit'));
    expect(height(), chords);
  });

  testWidgets('keys are comfortably large', (tester) async {
    await _open(tester);
    // Key layout: chords and the borrowed row are the same height as All's naturals, no taller.
    expect(tester.getSize(find.bySemanticsLabel('Insert Em')).height, 52);
    expect(tester.getSize(find.bySemanticsLabel('Backspace')).height, greaterThanOrEqualTo(44));
    await _setting(tester, 'All 12 roots');
    expect(tester.getSize(find.bySemanticsLabel('Insert C')).height, 52);
    expect(tester.getSize(find.bySemanticsLabel('Insert C')).width, greaterThanOrEqualTo(44));
  });

  testWidgets('fits a small phone without overflowing', (tester) async {
    await _open(tester, size: const Size(360, 640));
    for (final tab in ['Sections', 'Edit', 'Chords']) {
      await _press(tester, find.descendant(of: find.byType(ChordKeyboard), matching: find.bySemanticsLabel(tab)));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('a key in the song key inserts its chord and Done returns the chart', (tester) async {
    final result = await _open(tester);
    expect(find.text('Em'), findsOneWidget); // the diatonic row
    await _press(tester, find.bySemanticsLabel('Insert Em'));
    await _press(tester, find.bySemanticsLabel('Insert C'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, ['[Em][C]']);
  });

  testWidgets('a modifier shapes the chord, and with a chord at the cursor it edits that chord', (tester) async {
    final result = await _open(tester);
    await _press(tester, find.bySemanticsLabel('m')); // the row scrolls; 'm' is in view
    await _press(tester, find.bySemanticsLabel('Insert D'));
    await _press(tester, find.bySemanticsLabel('Insert C'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, ['[Dm][C]']);
  });

  testWidgets('123 types numbers as letters in the key', (tester) async {
    final result = await _open(tester, key: 'C');
    await _setting(tester, 'Numbers (123)');
    expect(find.text('6m'), findsOneWidget); // the diatonic row now reads in numbers
    await _press(tester, find.bySemanticsLabel('Insert Am'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, ['[Am]']);
  });

  testWidgets('without a key, 123 is off and the twelve roots show', (tester) async {
    final result = await _open(tester, key: null);
    expect(find.text('Set a song key to use its chords or type numbers.'), findsOneWidget);
    await _press(tester, find.bySemanticsLabel('Insert F'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, ['[F]']);
  });

  testWidgets('undo and redo walk the edits', (tester) async {
    final result = await _open(tester);
    await _press(tester, find.bySemanticsLabel('Insert D'));
    await _press(tester, find.bySemanticsLabel('Insert C'));
    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();
    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();
    await tester.tap(find.byTooltip('Redo'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, ['[D]']);
  });

  testWidgets('sections and repeats come from the Sections tab', (tester) async {
    final result = await _open(tester);
    await _press(tester, find.bySemanticsLabel('Sections'));
    await _press(tester, find.text('Chorus'));
    await _press(tester, find.bySemanticsLabel('Insert repeat marker x2'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, ['Chorus:\nx2']);
  });

  testWidgets('tapping the chart moves the caret, and the next chord lands there', (tester) async {
    final result = await _open(tester, content: 'Amazing grace');
    // Tap near the start of the line, then insert.
    final line = find.text('Amazing grace');
    final topLeft = tester.getTopLeft(line);
    await tester.tapAt(topLeft + const Offset(1, 8));
    await tester.pump();
    await _press(tester, find.bySemanticsLabel('Insert G'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result.single, startsWith('[G]'));
    expect(result.single, endsWith('Amazing grace'));
  });

  testWidgets('leaving with edits asks first, and discarding returns nothing', (tester) async {
    final result = await _open(tester);
    await _press(tester, find.bySemanticsLabel('Insert D'));
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(result, [null]);
  });

  testWidgets('Clear all needs a second tap', (tester) async {
    final result = await _open(tester, content: '[G]');
    await _press(tester, find.bySemanticsLabel('Edit'));
    await _press(tester, find.bySemanticsLabel('Clear all'));
    expect(find.text('Tap again to clear all'), findsOneWidget);
    await _press(tester, find.bySemanticsLabel('Tap again to clear all'));
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(result, ['']);
  });

  group('shared formatting', () {
    testWidgets('the editor draws structure with the chart\'s own widgets, one placeholder per source character', (
      tester,
    ) async {
      const content = 'Chorus: x2\n| [G] [D] | % | x2\n[Am7]Grace';
      await _open(tester, content: content, key: 'C', notation: ChordNotation.numbers);
      final editor = find.byType(ChartEditorView);
      expect(find.descendant(of: editor, matching: find.byType(RepeatBadge)), findsOneWidget); // rounded ×2
      expect(find.descendant(of: editor, matching: find.byType(BarDivider)), findsNWidgets(3));
      expect(find.descendant(of: editor, matching: find.text('⁄⁄')), findsOneWidget);

      final drawn = tester
          .widgetList<RichText>(find.descendant(of: editor, matching: find.byType(RichText)))
          .map((t) => t.text.toPlainText(includeSemanticsLabels: false))
          .where((t) => t.contains('CHORUS') || t.contains('￼') || t.contains('Grace'))
          .toList();
      final expected = [
        for (final l in content.split('\n'))
          EditorLine.parse(l, notation: ChordNotation.numbers, musicalKey: 'C').drawnText,
      ];
      expect(drawn.length, 3);
      for (var i = 0; i < 3; i++) {
        expect(drawn[i].length, expected[i].length, reason: 'line $i keeps its drawn length');
      }
      expect(drawn[0], startsWith('CHORUS'));
      expect(drawn[2], '6m7Grace');
    });

    testWidgets('tapping a chord between barlines puts the caret after it', (tester) async {
      final result = await _open(tester, content: '| [G] [D] |');
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.byType(ChartEditorView), matching: find.byType(RichText)).first,
      );
      final drawn = EditorLine.parse('| [G] [D] |').drawnText;
      final end = drawn.indexOf('D') + 1;
      final at = paragraph.getOffsetForCaret(TextPosition(offset: end), Rect.zero);
      await tester.tapAt(paragraph.localToGlobal(at + const Offset(-2, 8)));
      await tester.pump();
      await _press(tester, find.bySemanticsLabel('Insert C'));
      await _done(tester);
      expect(result, ['| [G] [D][C] |']);
    });

    testWidgets('free-type colours the source but keeps the text as typed', (tester) async {
      await _open(tester, content: 'Verse:\n[G]Hi | x2');
      await tester.tap(find.byTooltip('Switch to the system keyboard'));
      await tester.pumpAndSettle();
      final field = tester.widget<EditableText>(find.byType(EditableText));
      final span = field.controller.buildTextSpan(
        context: tester.element(find.byType(EditableText)),
        withComposing: false,
      );
      expect(span.toPlainText(), 'Verse:\n[G]Hi | x2');
    });
  });

  group('matches the Perform / Practice chart', () {
    /// Left edges of the barline rules [chart] draws, relative to the first.
    List<double> dividers(WidgetTester tester, Finder within) {
      final xs = tester
          .widgetList<BarDivider>(find.descendant(of: within, matching: find.byType(BarDivider)))
          .map((w) => tester.getTopLeft(find.byWidget(w)).dx)
          .toList();
      return [for (final x in xs) x - xs.first];
    }

    for (final line in [
      '| [G] [D] | [Em] [C] |',
      '|[G] [D]|[Em]|',
      '|   [G]    [D]   |',
      '| [G][D] | % | [C] |',
      '| [G] | | [D] |',
      '| [G] . . [D] | [C] |',
    ]) {
      testWidgets('barline spacing on `$line`', (tester) async {
        tester.view
          ..physicalSize = const Size(1000, 800)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          MaterialApp(
            theme: DaloyTheme.light(),
            home: Scaffold(
              body: ChordSheet(content: line, transposition: 0, zoom: 100, musicalKey: 'G'),
            ),
          ),
        );
        final perform = dividers(tester, find.byType(ChordSheet));

        await _open(tester, content: line, size: const Size(1000, 800));
        final editor = dividers(tester, find.byType(ChartEditorView));
        expect(editor.length, perform.length);
        for (var i = 0; i < editor.length; i++) {
          expect(editor[i], closeTo(perform[i], 0.5), reason: 'barline $i');
        }
      });
    }
  });
}
