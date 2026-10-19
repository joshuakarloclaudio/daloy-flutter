import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:daloy_flutter/features/export/data/pdf_export.dart';
import 'package:daloy_flutter/features/export/data/pptx_export.dart';
import 'package:daloy_flutter/features/export/domain/export_sheet.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/songs/chart/nashville.dart';
import 'package:daloy_flutter/features/songs/domain/song.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

const _chart = '''
Verse 1:
| [G] | [C] | x2
[G]Amazing [C]grace

Chorus: x2
| [Em] | [D] |''';

const _lyrics = '''
Verse 1:
Amazing grace, how sweet the sound
That saved a wretch like me

Chorus: x2
My chains are gone''';

const _song = Song(id: 7, title: 'Amazing Grace!', artist: 'John Newton', key: 'G', content: _chart, lyrics: _lyrics);

String _text(PrintLine line) => switch (line) {
  PrintGap() => '',
  PrintHeader(:final text) || PrintChords(:final text) || PrintText(:final text) => text,
  PrintMixed(:final runs) => runs.map((r) => r.kind == PrintRunKind.chord ? '<${r.text}>' : r.text).join(),
  PrintChordLyric(:final words) => chordLyricText(words, (chord) => '<$chord>'),
};

PdfFonts _fonts() {
  pw.Font font(String name) =>
      pw.Font.ttf(ByteData.sublistView(File('assets/fonts/pdf/DMSans-$name.ttf').readAsBytesSync()));
  return PdfFonts(regular: font('Regular'), bold: font('Bold'));
}

void main() {
  group('chord sheet lines', () {
    test('prints headers, barlines and inline chords in letters, shifted by the key change', () {
      final lines = chordSheetLines(_chart, notation: ChordNotation.letters, musicalKey: 'G', transposition: 2);
      expect(lines.map(_text).toList(), [
        'VERSE 1',
        '| A | D | ×2',
        '<A>Amazing <D>grace',
        '',
        'CHORUS ×2',
        '| F#m | E |',
      ]);
    });

    test('numbers ignore the transposition; a keyless song falls back to letters', () {
      final numbers = chordSheetLines(_chart, notation: ChordNotation.numbers, musicalKey: 'G', transposition: 5);
      expect(_text(numbers[1]), '| 1 | 4 | ×2');

      final keyless = chordSheetLines(_chart, notation: ChordNotation.numbers, musicalKey: null, transposition: 0);
      expect(_text(keyless[1]), '| G | C | ×2');
    });

    test('a PDF spells Δ out, which its font cannot draw', () {
      final lines = chordSheetLines(
        '| [Cmaj7] |',
        notation: ChordNotation.numbers,
        musicalKey: 'C',
        transposition: 0,
        pdfSafe: true,
      );
      expect(_text(lines.single), isNot(contains('Δ')));
      expect(_text(lines.single), contains('maj'));
    });
  });

  test('lyric lines keep headers and words only', () {
    final lines = lyricSheetLines('Chorus:\n[G]My chains are [C]gone\n');
    expect(lines.map(_text).toList(), ['CHORUS', 'My chains are gone', '']);
  });

  test('a line-up arrangement reorders and cuts sections, headers kept', () {
    const field = SectionArrangementField(order: [1], removed: [0]);
    final arranged = arrangedText(_lyrics, 'song-7', field);
    expect(arranged, 'Chorus: x2\nMy chains are gone');
    expect(arrangedText(_lyrics, 'song-7', null), _lyrics);
  });

  group('export set', () {
    test('the key line names the sounding key, the numbering, and a capo', () {
      final set = ExportSet.song(const ExportSong(song: _song, transposition: 2, capo: 2));
      final s = set.songs.single;
      expect(set.chordsSubtitle(s, ChordNotation.letters), 'John Newton · Key of A · Capo 2');
      expect(set.chordsSubtitle(s, ChordNotation.numbers), 'John Newton · Key of A · 1 = A');
      // The chord shapes come back down by the capo.
      expect(_text(chordLinesFor(s, ChordNotation.letters)[1]), '| G | C | ×2');
    });

    test('file names are safe and say what is inside', () {
      final set = ExportSet.song(const ExportSong(song: _song));
      expect(set.fileName(ExportFormat.chordsPdf), 'amazing-grace-chords.pdf');
      expect(set.fileName(ExportFormat.chordsPdf, notation: ChordNotation.numbers), 'amazing-grace-numbers.pdf');
      expect(set.fileName(ExportFormat.lyricsPptx), 'amazing-grace-lyrics.pptx');
      expect(safeFileName('“?!”'), 'daloy');
    });

    test('a line-up set numbers its songs in plain text', () {
      final set = ExportSet.lineUp(const LineUp(id: 1, title: 'Sunday', date: '2026-10-18', worshipLeader: 'Ana'), [
        const ExportSong(song: _song, transposition: 2),
        const ExportSong(song: Song(id: 8, title: 'Empty')),
      ]);
      final text = exportText(set, chords: true);
      expect(
        text,
        startsWith('Sunday\nOct 18, 2026 · Ana\n\n1. Amazing Grace!\nJohn Newton · Key A\n\nVERSE 1\n| A | D | ×2\n'),
      );
      expect(text, contains('[A]Amazing [D]grace'));
      expect(text, contains('2. Empty\n\n(No chords yet.)'));
    });
  });

  test('builds chord and lyric PDFs offline', () async {
    final set = ExportSet.lineUp(const LineUp(id: 1, title: 'Sunday', date: '2026-10-18'), [
      for (var i = 0; i < 6; i++) ExportSong(song: _song.copyWith(id: i + 1)),
    ]);
    for (final chords in [true, false]) {
      final bytes = await buildSheetPdf(set, chords: chords, fonts: _fonts(), notation: ChordNotation.numbers);
      expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
    }
  });

  test('builds a PPTX package: a title slide plus one slide per lyric section', () {
    final set = ExportSet.song(const ExportSong(song: _song));
    final zip = ZipDecoder().decodeBytes(buildLyricsPptx(set));
    final names = zip.files.map((f) => f.name).toSet();
    expect(
      names,
      containsAll([
        '[Content_Types].xml',
        'ppt/presentation.xml',
        'ppt/slideMasters/slideMaster1.xml',
        'ppt/slideLayouts/slideLayout1.xml',
        'ppt/theme/theme1.xml',
        'ppt/slides/slide3.xml',
      ]),
    );
    expect(names, isNot(contains('ppt/slides/slide4.xml')));

    String part(String name) => utf8.decode(zip.findFile(name)!.content as List<int>);
    expect(part('ppt/slides/slide1.xml'), contains('Amazing Grace!'));
    expect(part('ppt/slides/slide1.xml'), contains('John Newton  ·  Key of G'));
    expect(part('ppt/slides/slide2.xml'), contains('VERSE 1'));
    expect(part('ppt/slides/slide2.xml'), contains('That saved a wretch like me'));
    expect(part('ppt/presentation.xml'), contains('r:id="rId12"'));
  });

  test('PPTX text is escaped for XML', () {
    const song = Song(id: 1, title: 'Rock & <Roll>', lyrics: 'A "quote" & more');
    final zip = ZipDecoder().decodeBytes(buildLyricsPptx(ExportSet.song(const ExportSong(song: song))));
    final slide = utf8.decode(zip.findFile('ppt/slides/slide1.xml')!.content as List<int>);
    expect(slide, contains('Rock &amp; &lt;Roll&gt;'));
  });
}
