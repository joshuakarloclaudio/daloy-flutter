/// Chord and lyric sheets as A4 PDFs, built on the device (the web builds
/// them in the browser with jsPDF). Same layout as the web's `export.ts`:
/// title, a grey key line, then the chart; a line-up adds a cover line and
/// numbers each song.
library;

import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../songs/chart/nashville.dart';
import '../domain/export_sheet.dart';

/// The PDF's typefaces: static DM Sans cuts.
class PdfFonts {
  const PdfFonts({required this.regular, required this.bold});

  final pw.Font regular;
  final pw.Font bold;

  static PdfFonts? _cached;

  static Future<PdfFonts> load() async => _cached ??= PdfFonts(
    regular: pw.Font.ttf(await rootBundle.load('assets/fonts/pdf/DMSans-Regular.ttf')),
    bold: pw.Font.ttf(await rootBundle.load('assets/fonts/pdf/DMSans-Bold.ttf')),
  );
}

const _text = PdfColor.fromInt(0xFF111111);
const _chord = PdfColor.fromInt(0xFF2563EB);
const _muted = PdfColor.fromInt(0xFF888888);
const _rule = PdfColor.fromInt(0xFFE2E8F0);

/// Space under a chart line, so baselines sit about the web's 7mm apart.
const _lineGap = 5.0;

/// Chords ([chords]) or lyrics for every song in [set], as PDF bytes.
Future<Uint8List> buildSheetPdf(
  ExportSet set, {
  required bool chords,
  required PdfFonts fonts,
  ChordNotation notation = ChordNotation.letters,
}) {
  final doc = pw.Document(title: set.title, creator: 'Daloy', author: 'Daloy');
  final theme = pw.ThemeData.withFont(
    base: fonts.regular,
    bold: fonts.bold,
    italic: fonts.regular,
    boldItalic: fonts.bold,
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(20 * PdfPageFormat.mm),
      theme: theme,
      footer: (context) => context.pagesCount < 2
          ? pw.SizedBox()
          : pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                '${set.title} · ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: _muted),
              ),
            ),
      build: (_) => [
        if (set.isLineUp) ..._cover(set),
        for (final (i, song) in set.songs.indexed) ..._song(set, song, i, chords: chords, notation: notation),
      ],
    ),
  );
  return doc.save();
}

List<pw.Widget> _cover(ExportSet set) => [
  pw.Text(
    set.title,
    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _text),
  ),
  if (set.subtitle case final sub? when sub.isNotEmpty)
    pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Text(sub, style: const pw.TextStyle(fontSize: 10, color: _muted)),
    ),
  pw.SizedBox(height: 24),
];

List<pw.Widget> _song(
  ExportSet set,
  ExportSong song,
  int index, {
  required bool chords,
  required ChordNotation notation,
}) {
  final lines = chords ? chordLinesFor(song, notation, pdfSafe: true) : lyricLinesFor(song);
  final subtitle = chords ? set.chordsSubtitle(song, notation) : set.lyricsSubtitle(song);

  final heading = <pw.Widget>[
    if (index > 0) ...[
      pw.SizedBox(height: 28),
      pw.Divider(color: _rule, thickness: 0.8, height: 1),
      pw.SizedBox(height: 16),
    ],
    if (set.isLineUp)
      pw.Text(
        'SONG ${index + 1}',
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _muted, letterSpacing: 0.6),
      ),
    pw.Text(
      song.song.title,
      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _text),
    ),
    if (subtitle.isNotEmpty)
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 3),
        child: pw.Text(subtitle, style: const pw.TextStyle(fontSize: 10, color: _muted)),
      ),
    pw.SizedBox(height: 12),
  ];

  if (lines.isEmpty) {
    final empty = chords
        ? (set.isLineUp ? 'No chords for this song.' : 'No chords added yet.')
        : (set.isLineUp ? 'No lyrics for this song.' : 'No lyrics added yet.');
    return [
      _keep([...heading, pw.Text(empty, style: const pw.TextStyle(fontSize: 10, color: _muted))]),
    ];
  }

  // The title stays with the chart's first lines, and a header with the
  // line under it, so neither is left alone at the foot of a page.
  final chunks = _chunks(lines);
  return [
    _keep([...heading, ...chunks.first]),
    for (final chunk in chunks.skip(1)) chunk.length == 1 ? chunk.single : _keep(chunk),
  ];
}

/// Lines grouped so a header never ends a page: each header travels with
/// the line after it, and the first group takes the opening three lines.
List<List<pw.Widget>> _chunks(List<PrintLine> lines) {
  final chunks = <List<pw.Widget>>[];
  var i = 0;
  final first = <pw.Widget>[];
  while (i < lines.length && first.length < 3) {
    first.add(_line(lines[i]));
    i++;
  }
  chunks.add(first);
  while (i < lines.length) {
    final line = lines[i];
    if (line is PrintHeader && i + 1 < lines.length) {
      chunks.add([_line(line), _line(lines[i + 1])]);
      i += 2;
    } else {
      chunks.add([_line(line)]);
      i++;
    }
  }
  return chunks;
}

/// Widgets that move to the next page together rather than split.
pw.Widget _keep(List<pw.Widget> children) => pw.Inseparable(
  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children),
);

pw.Widget _line(PrintLine line) {
  final chordStyle = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _chord);
  return switch (line) {
    PrintGap() => pw.SizedBox(height: 2 * PdfPageFormat.mm),
    PrintHeader(:final text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 4 * PdfPageFormat.mm, bottom: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _muted, letterSpacing: 0.8),
      ),
    ),
    PrintChords(:final text) => _row(pw.Text(text, style: chordStyle)),
    PrintText(:final text) => _row(pw.Text(text, style: const pw.TextStyle(fontSize: 11, color: _text))),
    PrintChordLyric(:final words) => _chordLyricRow(words, chordStyle),
    PrintMixed(:final runs) => _row(
      pw.RichText(
        text: pw.TextSpan(
          style: const pw.TextStyle(fontSize: 11, color: _text),
          children: [
            for (final r in runs)
              switch (r.kind) {
                PrintRunKind.chord => pw.TextSpan(text: '${r.text} ', style: chordStyle),
                PrintRunKind.section => pw.TextSpan(
                  text: r.text,
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _muted),
                ),
                PrintRunKind.text => pw.TextSpan(text: r.text),
              },
          ],
        ),
      ),
    ),
  };
}

/// Chords on a row above the words they land on — the sheet's layout on
/// paper. Wraps between words.
pw.Widget _chordLyricRow(List<List<PrintColumn>> words, pw.TextStyle chordStyle) {
  const textStyle = pw.TextStyle(fontSize: 11, color: _text);
  final chord = chordStyle.copyWith(fontSize: 10);
  return _row(
    pw.Wrap(
      crossAxisAlignment: pw.WrapCrossAlignment.end,
      children: [
        for (final word in words)
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              for (final c in word)
                if (c.section case final section?)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 4),
                    child: pw.Text(
                      section.toUpperCase(),
                      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _muted),
                    ),
                  )
                else
                  pw.Column(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(right: 3),
                        child: pw.Text(c.chord ?? ' ', style: chord),
                      ),
                      // Non-breaking, so a word's trailing space keeps its width.
                      pw.Text(c.text.isEmpty ? ' ' : c.text.replaceAll(' ', '\u00A0'), style: textStyle),
                    ],
                  ),
            ],
          ),
      ],
    ),
  );
}

pw.Widget _row(pw.Widget child) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: _lineGap),
  child: child,
);
