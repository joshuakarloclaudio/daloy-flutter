/// What an export prints, before it becomes a PDF, slides or text: a song or
/// a line-up's set, each chart turned into printable lines. Port of the
/// line handling in the web's `lib/export.ts`. Pure Dart: the PDF, PPTX and
/// text writers all read from here, so the three outputs agree.
library;

import 'package:flutter/foundation.dart';

import '../../../core/utils/formatters.dart';
import '../../line_ups/domain/line_up.dart';
import '../../perform/domain/perform_sections.dart';
import '../../songs/chart/chart_parser.dart';
import '../../songs/chart/chordpro.dart';
import '../../songs/chart/chord_math.dart';
import '../../songs/chart/nashville.dart';
import '../../songs/domain/song.dart';

enum ExportFormat { chordsPdf, lyricsPdf, lyricsPptx, chordPro, chordProCopy }

/// One song as it's exported.
@immutable
class ExportSong {
  const ExportSong({required this.song, this.transposition = 0, this.capo = 0, this.arrangement});

  final Song song;

  /// Semitones from the written key to the key it's played in.
  final int transposition;

  /// Only a single song carries the device's capo: a line-up's sheet goes to
  /// the whole band, so it prints sounding chords.
  final int capo;

  /// The line-up's section order and cuts; null prints the song as written.
  final SectionArrangement? arrangement;

  String? get writtenKey => _blank(song.key);

  /// The key the band hears — a capo never changes it.
  String? get soundingKey => writtenKey == null ? null : transposeKey(writtenKey!, transposition);

  /// What the chord shapes shift by: the key change, less what the capo gives back.
  int get chartTransposition => transposition - capo;

  /// Numbers need a key, so a keyless song falls back to letters on its own.
  ChordNotation notationFor(ChordNotation wanted) =>
      wanted == ChordNotation.numbers && canUseNumbers(writtenKey) ? ChordNotation.numbers : ChordNotation.letters;

  String? get chords => _blank(song.content) == null ? null : song.content;
  String? get lyrics => _blank(song.lyrics) == null ? null : song.lyrics;
}

/// A song, or a line-up's set, to export.
@immutable
class ExportSet {
  const ExportSet({required this.title, required this.songs, this.subtitle, this.isLineUp = false});

  factory ExportSet.song(ExportSong song) => ExportSet(title: song.song.title, songs: [song]);

  factory ExportSet.lineUp(LineUp lineUp, List<ExportSong> songs) => ExportSet(
    title: lineUp.title,
    subtitle: [formatLineUpDate(lineUp.date), ?lineUp.leader].join(' · '),
    songs: songs,
    isLineUp: true,
  );

  final String title;

  /// The line-up's date and leader.
  final String? subtitle;
  final List<ExportSong> songs;
  final bool isLineUp;

  /// Whether any song here can be written in numbers.
  bool get canShowNumbers => songs.any((s) => canUseNumbers(s.writtenKey));

  /// The line under a song's title on a chord sheet. A printed chart without
  /// its key can't be read, so the sounding key is always there, and in
  /// numbers what degree 1 is.
  String chordsSubtitle(ExportSong s, ChordNotation wanted) {
    final numbers = s.notationFor(wanted) == ChordNotation.numbers;
    final key = s.soundingKey;
    return [
      ?_blank(s.song.artist),
      if (key != null) isLineUp ? 'Key $key' : 'Key of $key',
      if (numbers) ?numberingLabel(key),
      if (!numbers && s.capo > 0) 'Capo ${s.capo}',
    ].join(' · ');
  }

  String lyricsSubtitle(ExportSong s) => _blank(s.song.artist) ?? '';

  /// `amazing-grace-chords.pdf`.
  String fileName(ExportFormat format, {ChordNotation notation = ChordNotation.letters}) {
    final suffix = switch (format) {
      ExportFormat.chordsPdf => notation == ChordNotation.numbers && canShowNumbers ? 'numbers' : 'chords',
      ExportFormat.lyricsPdf || ExportFormat.lyricsPptx => 'lyrics',
      ExportFormat.chordPro || ExportFormat.chordProCopy => null,
    };
    final ext = switch (format) {
      ExportFormat.lyricsPptx => 'pptx',
      ExportFormat.chordPro || ExportFormat.chordProCopy => 'cho',
      _ => 'pdf',
    };
    return suffix == null ? '${safeFileName(title)}.$ext' : '${safeFileName(title)}-$suffix.$ext';
  }
}

/// A title as a file name: letters, digits and dashes, at most 60 long.
String safeFileName(String name) {
  final cleaned = name.replaceAll(RegExp(r'[^\w\s-]'), '').trim().replaceAll(RegExp(r'\s+'), '-').toLowerCase();
  final short = cleaned.length > 60 ? cleaned.substring(0, 60) : cleaned;
  return short.isEmpty ? 'daloy' : short;
}

// ---------------------------------------------------------------------------
// Printable lines
// ---------------------------------------------------------------------------

/// A chart line as it's printed.
@immutable
sealed class PrintLine {
  const PrintLine();
}

/// A blank line in the chart: a little space.
class PrintGap extends PrintLine {
  const PrintGap();
}

/// `CHORUS ×2`.
class PrintHeader extends PrintLine {
  const PrintHeader(this.text);
  final String text;
}

/// A row of chords, or a barline row `| C | G | Am | F | ×2`. Barlines are
/// structure, so they print as written.
class PrintChords extends PrintLine {
  const PrintChords(this.text);
  final String text;
}

/// Words with chords inline.
class PrintMixed extends PrintLine {
  const PrintMixed(this.runs);
  final List<PrintRun> runs;
}

/// Words with their chords on a row above: one entry per word, each a run of
/// chord-over-text columns (see `chordLyricWords`). [PrintColumn.chord] is
/// already written in the export's notation.
class PrintChordLyric extends PrintLine {
  const PrintChordLyric(this.words);
  final List<List<PrintColumn>> words;
}

@immutable
class PrintColumn {
  const PrintColumn({this.chord, this.text = '', this.section});
  final String? chord;
  final String text;

  /// An inline `[Chorus]` label in place of a chord and text.
  final String? section;
}

class PrintText extends PrintLine {
  const PrintText(this.text);
  final String text;
}

enum PrintRunKind { chord, section, text }

@immutable
class PrintRun {
  const PrintRun(this.kind, this.text);
  final PrintRunKind kind;
  final String text;
}

String _headerText(String label, int repeat) {
  final upper = label.toUpperCase();
  return repeat > 1 ? '$upper ×$repeat' : upper;
}

/// A chord chart, ready to print. [pdfSafe] spells `Δ` as `maj`, which the
/// PDF font can't draw.
List<PrintLine> chordSheetLines(
  String content, {
  required ChordNotation notation,
  required String? musicalKey,
  required int transposition,
  bool pdfSafe = false,
}) {
  final effective = notation == ChordNotation.numbers && canUseNumbers(musicalKey)
      ? ChordNotation.numbers
      : ChordNotation.letters;
  String chord(String token) {
    final shown = displayChord(token, effective, musicalKey, transposition);
    return pdfSafe ? shown.replaceAll('Δ', 'maj') : shown;
  }

  String atomText(List<Segment> atom) => atom.map((s) => s.kind == SegmentKind.chord ? chord(s.value) : s.value).join();

  return [
    for (final line in parseChart(content))
      switch (line) {
        BlankLine() => const PrintGap(),
        SectionLine(:final label, :final repeat) => PrintHeader(_headerText(label, repeat)),
        BarChartLine(:final bars, :final repeat) => PrintChords(_barRow(bars, repeat, atomText)),
        ChordsLine(:final chords, :final repeat) => PrintChords(
          [chords.map(chord).join('   '), if (repeat > 1) '×$repeat'].join('   '),
        ),
        TextLine(:final segments) when isChordLyricLine(segments) => PrintChordLyric([
          for (final word in chordLyricWords(segments))
            [
              for (final unit in word)
                PrintColumn(
                  // A slash chord comes as `G/B`; each half is written on its own.
                  chord: unit.chord?.split('/').map(chord).join('/'),
                  text: unit.text,
                  section: unit.section,
                ),
            ],
        ]),
        TextLine(:final segments) => PrintMixed([
          for (final s in segments)
            switch (s.kind) {
              SegmentKind.chord => PrintRun(PrintRunKind.chord, chord(s.value)),
              SegmentKind.section => PrintRun(PrintRunKind.section, s.value),
              _ => PrintRun(PrintRunKind.text, s.value),
            },
        ]),
      },
  ];
}

String _barRow(List<BarCell> bars, int repeat, String Function(List<Segment>) atomText) {
  final cells = [
    for (final bar in bars) [?bar.meter?.value, if (bar.simile) '%', ...bar.atoms.map(atomText)].join('  '),
  ];
  final body = '| ${cells.join(' | ')} |';
  return repeat > 1 ? '$body ×$repeat' : body;
}

/// Lyrics, ready to print: headers and words, nothing else.
List<PrintLine> lyricSheetLines(String lyrics) => [
  for (final line in normalizeNewlines(lyrics).split('\n')) _lyricLine(line),
];

PrintLine _lyricLine(String line) {
  final segments = parseLine(line);
  if (segments.isEmpty ||
      (segments.length == 1 && segments.first.kind == SegmentKind.text && segments.first.value.isEmpty)) {
    return const PrintGap();
  }
  if (sectionHeader(segments) case final header?) return PrintHeader(_headerText(header.label, header.repeat));
  return PrintText(lyricText(segments));
}

/// A lyric line's words, without chords or markers.
String lyricText(List<Segment> segments) =>
    segments.where((s) => s.kind == SegmentKind.text).map((s) => s.value).join().trimRight();

/// [content] with the line-up's [field] applied: sections reordered and
/// cut, each led by its header again. Untouched when there's no arrangement.
String arrangedText(String content, String songKey, SectionArrangementField? field) {
  if (field == null || field.isEmpty) return content;
  final sections = applyArrangement(groupBySections(content, songKey), field);
  return sections
      .map((s) {
        if (s.label.isEmpty) return s.body;
        final header = s.repeat > 1 ? '${s.label}: x${s.repeat}' : '${s.label}:';
        return '$header\n${s.body}';
      })
      .join('\n\n');
}

/// A song's chart lines for this export, arranged for the line-up.
List<PrintLine> chordLinesFor(ExportSong s, ChordNotation wanted, {bool pdfSafe = false}) {
  final chords = s.chords;
  if (chords == null) return const [];
  return chordSheetLines(
    arrangedText(chords, 'song-${s.song.id}', s.arrangement?.chords),
    notation: wanted,
    musicalKey: s.writtenKey,
    transposition: s.chartTransposition,
    pdfSafe: pdfSafe,
  );
}

List<PrintLine> lyricLinesFor(ExportSong s) {
  final lyrics = s.lyrics;
  if (lyrics == null) return const [];
  return lyricSheetLines(arrangedText(lyrics, 'song-${s.song.id}', s.arrangement?.lyrics));
}

/// The lyrics' sections in play order, each as its lines of words — one
/// slide each.
List<({String label, List<String> lines})> lyricSlides(ExportSong s) {
  final lyrics = s.lyrics;
  if (lyrics == null) return const [];
  return [
    for (final section in applyArrangement(groupBySections(lyrics, 'song-${s.song.id}'), s.arrangement?.lyrics))
      if ([
            for (final line in section.lines)
              if (lyricText(parseLine(line)).trim() case final words when words.isNotEmpty) words,
          ]
          case final lines when lines.isNotEmpty)
        (label: section.label, lines: lines),
  ];
}

// ---------------------------------------------------------------------------
// Plain text
// ---------------------------------------------------------------------------

/// The sheet as plain text, for a message or another app: chords as they
/// print (inline chords in brackets), lyrics as words.
String exportText(ExportSet set, {required bool chords, ChordNotation notation = ChordNotation.letters}) {
  final out = StringBuffer();
  void line([String text = '']) => out.writeln(text);

  if (set.isLineUp) {
    line(set.title);
    if (set.subtitle case final sub? when sub.isNotEmpty) line(sub);
    line();
  }

  for (final (i, s) in set.songs.indexed) {
    if (i > 0) {
      line();
      line();
    }
    final title = set.isLineUp ? '${i + 1}. ${s.song.title}' : s.song.title;
    line(title);
    final sub = chords ? set.chordsSubtitle(s, notation) : set.lyricsSubtitle(s);
    if (sub.isNotEmpty) line(sub);
    line();

    final lines = chords ? chordLinesFor(s, notation) : lyricLinesFor(s);
    if (lines.isEmpty) line(chords ? '(No chords yet.)' : '(No lyrics yet.)');
    for (final l in lines) {
      line(switch (l) {
        PrintGap() => '',
        PrintHeader(:final text) || PrintChords(:final text) || PrintText(:final text) => text,
        PrintMixed(:final runs) => runs.map((r) => r.kind == PrintRunKind.chord ? '[${r.text}]' : r.text).join(),
        PrintChordLyric(:final words) => chordLyricText(words, (chord) => '[$chord]'),
      });
    }
  }
  return '${_collapseBlankRuns(out.toString()).trimRight()}\n';
}

/// A chords-over-lyrics line back on one line, each chord as [chord] writes it.
String chordLyricText(List<List<PrintColumn>> words, String Function(String chord) chord) => [
  for (final word in words)
    for (final c in word) c.section != null ? '[${c.section}] ' : '${c.chord == null ? '' : chord(c.chord!)}${c.text}',
].join().trimRight();

// ---------------------------------------------------------------------------
// ChordPro
// ---------------------------------------------------------------------------

/// The set as one ChordPro file: each song in the key it's played in, with
/// the line-up's section order, chords as the capo shapes.
String chordProText(ExportSet set) => toChordPro([
  for (final s in set.songs)
    ChordProExportSong(
      title: s.song.title,
      artist: s.song.artist,
      key: s.writtenKey,
      bpm: s.song.bpm,
      timeSignature: s.song.timeSignature,
      content: s.chords == null ? null : arrangedText(s.chords!, 'song-${s.song.id}', s.arrangement?.chords),
      lyrics: s.lyrics == null ? null : arrangedText(s.lyrics!, 'song-${s.song.id}', s.arrangement?.lyrics),
      transposition: s.transposition,
      capo: s.capo,
    ),
]);

/// No more than two blank lines in a row.
String _collapseBlankRuns(String text) => text.replaceAll(RegExp(r'\n{4,}'), '\n\n\n');

String? _blank(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
