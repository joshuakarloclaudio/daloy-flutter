/// Chord-chart text → drawable lines. Port of the web's `lib/chords.ts`
/// (`parseLine`, `sectionHeader`) and `lib/bars.ts` (barlines), so a chart
/// reads the same on every platform. Pure Dart: no Flutter, no I/O.
///
/// Charts are plain text with chords in brackets: `[G]Amazing [C]grace`,
/// `Verse:`, `[Chorus] x2`, and barline rows like `| C G | Am % | 2/4 D | x2`.
library;

import 'chord_math.dart';

enum SegmentKind { chord, section, bar, simile, repeat, meter, text }

class Segment {
  const Segment(this.kind, this.value, {this.count});

  final SegmentKind kind;
  final String value;

  /// Play count, for [SegmentKind.repeat] (`x2`) and sections written
  /// `Chorus: x2`; beats, for [SegmentKind.meter] (`2/4` is 2).
  final int? count;

  bool get isBlankText => kind == SegmentKind.text && value.trim().isEmpty;

  @override
  String toString() => '$kind($value${count == null ? '' : ' x$count'})';
}

final _repeatToken = RegExp(r'^(?:[xX](\d{1,2})|(\d{1,2})[xX])$');

/// `x2` / `2x`, or null when `text` isn't a repeat marker.
int? parseRepeatToken(String text) {
  final match = _repeatToken.firstMatch(text.trim());
  if (match == null) return null;
  final count = int.tryParse(match[1] ?? match[2] ?? '');
  return count != null && count >= 1 ? count : null;
}

final _meterToken = RegExp(r'^(\d{1,2})/(1|2|4|8|16)$');

/// Beats in a bar-level time signature (`2/4` → 2), or null when `text`
/// isn't one. Only means anything inside a barline row: `| 2/4 [Em] [F#m] |`
/// is a two-beat bar in a 4/4 song.
int? parseMeterToken(String text) {
  final match = _meterToken.firstMatch(text.trim());
  final beats = int.tryParse(match?[1] ?? '');
  return beats != null && beats >= 1 && beats <= 32 ? beats : null;
}

// "Intro:", "Pre-Chorus:", "Bridge 1:", optionally "Chorus: x2".
final plainSectionPattern = RegExp(r'^([A-Za-z][A-Za-z0-9 \-]*):[ \t]*(?:[xX](\d{1,2})|(\d{1,2})[xX])?[ \t]*$');
final _bracketToken = RegExp(r'\[([^\]]+)\]|([^\[]+)');
final _structurePiece = RegExp(r'\s+|[|%]|[^\s|%]+');
final _inertPiece = RegExp(r'^[./_-]+$');

/// Splits a bare run of text into structural tokens, or null the moment it
/// meets something that isn't structure — that veto keeps a `|` inside a
/// lyric from being read as a barline.
List<Segment>? _splitStructure(String text) {
  final pieces = <Segment>[];
  for (final match in _structurePiece.allMatches(text)) {
    final part = match[0]!;
    if (part.trim().isEmpty || _inertPiece.hasMatch(part)) {
      pieces.add(Segment(SegmentKind.text, part));
    } else if (part == '|') {
      pieces.add(Segment(SegmentKind.bar, part));
    } else if (part == '%') {
      pieces.add(Segment(SegmentKind.simile, part));
    } else if (parseRepeatToken(part) case final count?) {
      pieces.add(Segment(SegmentKind.repeat, part, count: count));
    } else if (parseMeterToken(part) case final beats?) {
      pieces.add(Segment(SegmentKind.meter, part, count: beats));
    } else {
      return null;
    }
  }
  return pieces;
}

/// Re-reads a tokenized line as chord structure (barlines, `%`, `x2`), or
/// null when it isn't one. Classification is per line, never per token.
List<Segment>? _structureChordLine(List<Segment> segments) {
  final out = <Segment>[];
  var hasChord = false;
  var hasStructure = false;
  for (final seg in segments) {
    if (seg.kind == SegmentKind.chord) {
      hasChord = true;
      out.add(seg);
      continue;
    }
    // An inline [Section] label means this is a header line, not a chord line.
    if (seg.kind != SegmentKind.text) return null;
    final pieces = _splitStructure(seg.value);
    if (pieces == null) return null;
    for (final piece in pieces) {
      if (piece.kind != SegmentKind.text) hasStructure = true;
      out.add(piece);
    }
  }
  if (!hasStructure) return null;
  final hasBar = out.any((s) => s.kind == SegmentKind.bar);
  if (!hasChord && !hasBar) return null;
  // A time signature belongs to a bar; with no barline it is just text.
  if (!hasBar && out.any((s) => s.kind == SegmentKind.meter)) return null;
  return out;
}

/// `[Chorus] x2` — a bracketed header carrying a repeat marker.
List<Segment>? _structureSectionLine(List<Segment> segments) {
  if (segments.isEmpty || segments.first.kind != SegmentKind.section) return null;
  final out = [segments.first];
  var hasRepeat = false;
  for (final seg in segments.skip(1)) {
    if (seg.kind != SegmentKind.text) return null;
    final pieces = _splitStructure(seg.value);
    if (pieces == null) return null;
    for (final piece in pieces) {
      if (piece.kind == SegmentKind.repeat) {
        if (hasRepeat) return null;
        hasRepeat = true;
      } else if (piece.kind != SegmentKind.text || piece.value.trim().isNotEmpty) {
        return null;
      }
      out.add(piece);
    }
  }
  return hasRepeat ? out : null;
}

List<Segment> parseLine(String line) {
  final plain = plainSectionPattern.firstMatch(line);
  if (plain != null && plain[1] != null) {
    final repeat = int.tryParse(plain[2] ?? plain[3] ?? '');
    return [Segment(SegmentKind.section, plain[1]!, count: repeat != null && repeat >= 1 ? repeat : null)];
  }

  final segments = <Segment>[];
  for (final match in _bracketToken.allMatches(line)) {
    final inner = match[1];
    if (inner != null) {
      segments.add(Segment(isChordToken(inner) ? SegmentKind.chord : SegmentKind.section, inner));
    } else if (match[2] != null) {
      segments.add(Segment(SegmentKind.text, match[2]!));
    }
  }
  return _structureSectionLine(segments) ?? _structureChordLine(segments) ?? segments;
}

bool isChordOnlyLine(List<Segment> segments) => segments.every(
  (s) => switch (s.kind) {
    SegmentKind.chord || SegmentKind.bar || SegmentKind.simile || SegmentKind.repeat || SegmentKind.meter => true,
    SegmentKind.text => s.value.trim().isEmpty,
    SegmentKind.section => false,
  },
);

/// Dashes, underscores, dots, slashes and tildes some teams type between
/// chords to say "hold this" (`[C]-[G]--[Am]`, `[F]_[G]`). Not lyrics.
final _chordSeparatorText = RegExp(r'^[\s\-_./~\u2013\u2014]*$');

/// Whether a line is lyrics with inline chords, to be drawn chords-over-words.
/// A line whose only text is chord separators is not: it reads left to right
/// as written, so a chord never lands on top of a dash. Port of the web's
/// `isChordLyricLine`.
bool isChordLyricLine(List<Segment> segments) =>
    segments.any((s) => s.kind == SegmentKind.chord) &&
    segments.any((s) => s.kind == SegmentKind.text && !_chordSeparatorText.hasMatch(s.value));

typedef SectionHeader = ({String label, int repeat});

/// The header a line declares (`Chorus: x2` or `[Chorus] x2`), or null.
SectionHeader? sectionHeader(List<Segment> segments) {
  if (segments.isEmpty || segments.first.kind != SegmentKind.section) return null;
  final rest = segments.skip(1);
  final trailingOk = rest.every((s) => s.kind == SegmentKind.repeat || s.isBlankText);
  if (!trailingOk) return null;
  final marker = rest.where((s) => s.kind == SegmentKind.repeat).firstOrNull;
  return (label: segments.first.value, repeat: marker?.count ?? segments.first.count ?? 1);
}

/// One column of a chords-over-lyrics line: [chord] (or none) over the
/// [text] it lands on, or an inline `[Section]` label.
class ChordLyricUnit {
  const ChordLyricUnit.lyric(this.chord, this.text) : section = null;
  const ChordLyricUnit.section(String this.section) : chord = null, text = '';

  final String? chord;
  final String text;
  final String? section;

  @override
  String toString() => section != null ? 'section($section)' : '[${chord ?? ''}]$text';
}

final _lyricPiece = RegExp(r'\s+|\S+\s*');
final _trailingSpace = RegExp(r'\s$');

/// A lyric line with inline chords, regrouped for drawing each chord above
/// the text it lands on. Each inner list is one word, trailing whitespace
/// included: a line wraps only between words, so a mid-word chord
/// (`A[G]mazing`) never splits its word across rows. A slash chord written
/// `[G]/[B]` comes back as one unit with [ChordLyricUnit.chord] `G/B`. Port
/// of the web's `chordLyricWords`.
List<List<ChordLyricUnit>> chordLyricWords(List<Segment> segments) {
  final words = <List<ChordLyricUnit>>[];
  var word = <ChordLyricUnit>[];
  String? pending;

  void flushWord() {
    if (word.isNotEmpty) words.add(word);
    word = [];
  }

  // A chord with no text of its own (`[G][C]`, or one ending the line).
  void flushChord() {
    if (pending == null) return;
    word.add(ChordLyricUnit.lyric(pending, ''));
    pending = null;
  }

  for (var i = 0; i < segments.length; i++) {
    final seg = segments[i];
    switch (seg.kind) {
      case SegmentKind.chord:
        flushChord();
        pending = seg.value;
        // `[G]/[B]` is one slash chord over the text after it, not G over "/".
        if (i + 2 < segments.length && segments[i + 1].value == '/' && segments[i + 2].kind == SegmentKind.chord) {
          pending = '${seg.value}/${segments[i + 2].value}';
          i += 2;
        }
      case SegmentKind.section:
        flushChord();
        flushWord();
        words.add([ChordLyricUnit.section(seg.value)]);
      default:
        for (final match in _lyricPiece.allMatches(seg.value)) {
          final piece = match[0]!;
          word.add(ChordLyricUnit.lyric(pending, piece));
          pending = null;
          if (_trailingSpace.hasMatch(piece)) flushWord();
        }
    }
  }
  flushChord();
  flushWord();
  return words;
}

/// One bar: what is written between two barlines.
class BarCell {
  const BarCell(this.atoms, {required this.simile, this.meter});

  /// Chord/placeholder groups; whitespace is the only thing that splits one,
  /// so a slash chord `G/B` stays a single unbreakable unit.
  final List<List<Segment>> atoms;

  /// Written as `%`: sounds as the bar before it.
  final bool simile;

  /// The bar's own time signature (`| 2/4 [Em] [F#m] |`), or null to play
  /// at the song's. Its [Segment.count] is the bar's beats.
  final Segment? meter;
}

List<List<Segment>> _atoms(List<Segment> segments) {
  final atoms = <List<Segment>>[];
  var atom = <Segment>[];
  void flush() {
    if (atom.isNotEmpty) atoms.add(atom);
    atom = [];
  }

  for (final seg in segments) {
    if (seg.isBlankText) {
      flush();
    } else {
      atom.add(seg);
    }
  }
  flush();
  return atoms;
}

List<Segment> _trimBlankEdges(List<Segment> segments) {
  var start = 0;
  var end = segments.length;
  while (start < end && segments[start].isBlankText) {
    start++;
  }
  while (end > start && segments[end - 1].isBlankText) {
    end--;
  }
  return segments.sublist(start, end);
}

/// Bars of a `| C G | Am % |` line, or null when the line has no barline.
/// `| C | G |` and `C | G` read the same: the outer barlines are punctuation.
({List<BarCell> bars, int repeat})? _barLine(List<Segment> segments) {
  if (!segments.any((s) => s.kind == SegmentKind.bar)) return null;
  final bars = <BarCell>[];
  var pending = <Segment>[];
  var simile = false;
  Segment? meter;
  var opened = false;
  var repeat = 1;

  void closeBar() {
    final content = _trimBlankEdges(pending);
    // Before the first `|` there is nothing to close unless something was
    // written there — that is what makes the leading barline optional.
    if (opened || content.isNotEmpty || simile) {
      bars.add(BarCell(_atoms(content), simile: simile, meter: meter));
      meter = null;
    }
    // `2/4 | [Em] [F#m] |` — a time signature before the first barline
    // stays with the bar it opens.
    pending = [];
    simile = false;
  }

  for (final seg in segments) {
    switch (seg.kind) {
      case SegmentKind.bar:
        closeBar();
        opened = true;
      case SegmentKind.simile:
        simile = true;
      case SegmentKind.repeat:
        repeat = seg.count ?? 1;
      case SegmentKind.meter:
        meter = seg;
      case _:
        pending.add(seg);
    }
  }
  final tail = _trimBlankEdges(pending);
  if (tail.isNotEmpty || simile || meter != null) bars.add(BarCell(_atoms(tail), simile: simile, meter: meter));
  return bars.isEmpty ? null : (bars: bars, repeat: repeat);
}

/// Whether an atom is only a `.`-run — drawn as a centred dot per character
/// rather than as text (`/`, `-`, `_` draw as themselves).
bool isDotSeparatorAtom(List<Segment> atom) =>
    atom.length == 1 && atom.first.kind == SegmentKind.text && RegExp(r'^\.+$').hasMatch(atom.first.value);

/// A line, classified for drawing.
sealed class ChartLine {
  const ChartLine();
}

class BlankLine extends ChartLine {
  const BlankLine();
}

class SectionLine extends ChartLine {
  const SectionLine(this.label, this.repeat);
  final String label;
  final int repeat;
}

class BarChartLine extends ChartLine {
  const BarChartLine(this.bars, this.repeat);
  final List<BarCell> bars;
  final int repeat;
}

/// A row of bare chords with no lyrics or barlines.
class ChordsLine extends ChartLine {
  const ChordsLine(this.chords, this.repeat);
  final List<String> chords;
  final int repeat;
}

/// Lyrics, optionally with inline chords.
class TextLine extends ChartLine {
  const TextLine(this.segments);
  final List<Segment> segments;
}

ChartLine classifyLine(String line) {
  final segments = parseLine(line);
  if (segments.isEmpty ||
      (segments.length == 1 && segments.first.kind == SegmentKind.text && segments.first.value.isEmpty)) {
    return const BlankLine();
  }
  if (sectionHeader(segments) case final header?) return SectionLine(header.label, header.repeat);
  if (_barLine(segments) case final barLine?) return BarChartLine(barLine.bars, barLine.repeat);
  if (isChordOnlyLine(segments)) {
    final marker = segments.where((s) => s.kind == SegmentKind.repeat).firstOrNull;
    return ChordsLine([
      for (final s in segments)
        if (s.kind == SegmentKind.chord) s.value,
    ], marker?.count ?? 1);
  }
  return TextLine(segments);
}

String normalizeNewlines(String text) => text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

/// Every line of a chart, classified.
List<ChartLine> parseChart(String content) => [
  for (final line in normalizeNewlines(content).split('\n')) classifyLine(line),
];
