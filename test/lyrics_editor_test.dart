import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/help/chord_syntax_guide_screen.dart';
import 'package:daloy_flutter/features/songs/editor/lyrics_edit.dart';
import 'package:daloy_flutter/features/songs/presentation/editor/lyrics_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('lyricsSectionLabel', () {
    test('numbers verses by the ones already written', () {
      expect(lyricsSectionLabel('', 'Verse'), 'Verse 1');
      expect(lyricsSectionLabel('Verse 1:\nA\n\n[Verse 2]\nB\n\nChorus:\nC', 'Verse'), 'Verse 3');
      expect(lyricsSectionLabel('Verse:\nA', 'Verse'), 'Verse 2');
    });

    test('leaves other sections plain and ignores words that only mention them', () {
      expect(lyricsSectionLabel('Chorus:\nA', 'Chorus'), 'Chorus');
      expect(lyricsSectionLabel('Verse after verse we sing', 'Verse'), 'Verse 1');
    });
  });

  group('insertLyricsSection', () {
    test('an empty field gets the header and the cursor under it', () {
      final r = insertLyricsSection('', 0, 'Verse');
      expect(r.text, 'Verse 1:\n');
      expect(r.cursor, r.text.length);
    });

    test('mid-line goes after the line, a blank line apart, without splitting it', () {
      const text = 'Amazing grace\nHow sweet';
      final r = insertLyricsSection(text, 4, 'Chorus');
      expect(r.text, 'Amazing grace\n\nChorus:\n\nHow sweet');
      expect(r.text.substring(0, r.cursor), 'Amazing grace\n\nChorus:\n');
    });

    test('at the end of the last line', () {
      const text = 'Amazing grace';
      final r = insertLyricsSection(text, text.length, 'Chorus');
      expect(r.text, 'Amazing grace\n\nChorus:\n');
      expect(r.cursor, r.text.length);
    });

    test('a blank line takes the header, padded from the stanza above', () {
      const text = 'Verse 1:\nAmazing grace\n';
      final r = insertLyricsSection(text, text.length, 'Verse');
      expect(r.text, 'Verse 1:\nAmazing grace\n\nVerse 2:\n');
      expect(r.cursor, r.text.length);
    });

    test('a blank line already a stanza apart needs no padding', () {
      const text = 'Amazing grace\n\n\nNext';
      final r = insertLyricsSection(text, 15, 'Bridge');
      expect(r.text, 'Amazing grace\n\nBridge:\n\nNext');
      expect(r.text.substring(r.cursor), '\nNext');
    });
  });

  Future<void> pumpApp(WidgetTester tester, Widget home, {Size size = const Size(390, 844)}) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: DaloyTheme.light(),
        builder: (context, child) =>
            MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
        home: home,
      ),
    );
    await tester.pumpAndSettle();
  }

  group('LyricsEditorScreen', () {
    testWidgets('a chip inserts a numbered header at the cursor', (tester) async {
      await pumpApp(tester, const LyricsEditorScreen(lyrics: 'Verse 1:\nAmazing grace'));
      final field = tester.widget<TextField>(find.byType(TextField));
      field.controller!.selection = const TextSelection.collapsed(offset: 22);
      await tester.tap(find.text('Verse'));
      await tester.pump();
      expect(field.controller!.text, 'Verse 1:\nAmazing grace\n\nVerse 2:\n');
      expect(field.controller!.selection.baseOffset, field.controller!.text.length);
    });

    testWidgets('a header added below the fold scrolls into view', (tester) async {
      final long = List.generate(60, (i) => 'Line $i').join('\n');
      await pumpApp(tester, LyricsEditorScreen(lyrics: long));
      final field = tester.widget<TextField>(find.byType(TextField));
      final scroll = tester.state<ScrollableState>(
        find.descendant(of: find.byType(TextField), matching: find.byType(Scrollable)),
      );
      expect(scroll.position.pixels, 0);
      field.controller!.selection = TextSelection.collapsed(offset: long.length);
      await tester.tap(find.text('Verse'));
      await tester.pumpAndSettle();
      expect(scroll.position.pixels, scroll.position.maxScrollExtent);
      expect(scroll.position.pixels, greaterThan(0));
    });

    testWidgets('help opens the lyrics notation sheet', (tester) async {
      await pumpApp(tester, const LyricsEditorScreen(lyrics: ''));
      await tester.tap(find.bySemanticsLabel('Help'));
      await tester.pumpAndSettle();
      expect(find.text('Lyrics notation'), findsOneWidget);
    });
  });

  group('ChordSyntaxGuideScreen', () {
    testWidgets('fits a small phone in both languages', (tester) async {
      await pumpApp(tester, const ChordSyntaxGuideScreen(), size: const Size(320, 640));
      expect(tester.takeException(), isNull);
      expect(find.text('Chord syntax guide'), findsOneWidget);

      await tester.tap(find.text('Tagalog'));
      await tester.pumpAndSettle();
      expect(find.text('Gabay sa pagsulat ng chord'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a chip jumps to its section', (tester) async {
      await pumpApp(tester, const ChordSyntaxGuideScreen());
      final cheat = find.text('Cheat sheet');
      expect(cheat, findsNWidgets(2)); // chip + card title
      await tester.tap(cheat.first);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(cheat.last).dy, lessThan(200));
    });
  });
}
