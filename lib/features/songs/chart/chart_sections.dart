/// A chart (or lyrics) cut into sections: headers like `Verse:` or
/// `[Chorus] x2` start one, and a blank line inside one starts an unlabelled
/// stanza. Port of the web's `lib/performance-sections.ts`. Shared by
/// Perform/Practice (which tap, jump and page through sections) and the song
/// editor's previews, so a song reads the same everywhere. Pure Dart.
library;

import 'package:flutter/foundation.dart';

import 'chart_parser.dart';

@immutable
class ChartSection {
  const ChartSection({
    required this.id,
    required this.label,
    required this.startLine,
    required this.lines,
    this.repeat = 1,
  });

  /// Stable for the song's text: built from the section's place as written,
  /// so it survives the line-up reordering sections.
  final String id;

  /// Empty for an unlabelled stanza.
  final String label;

  /// Index of [lines]' first line in the full chart — what notes point at.
  final int startLine;
  final List<String> lines;

  /// Times the section is played, from a header like `Chorus: x2`.
  final int repeat;

  String get body => lines.join('\n');

  @override
  bool operator ==(Object other) =>
      other is ChartSection &&
      other.id == id &&
      other.label == label &&
      other.startLine == startLine &&
      other.repeat == repeat &&
      listEquals(other.lines, lines);

  @override
  int get hashCode => Object.hash(id, label, startLine, repeat, Object.hashAll(lines));
}

/// Splits a chart into sections. [songKey] scopes the ids. Headers (`Verse:`, `[Chorus] x2`) start
/// one; a blank line inside a section starts an unlabelled continuation so
/// long sections page in stanzas. With no headers at all, every stanza is a
/// section.
List<ChartSection> groupBySections(String content, String songKey) {
  final raw = normalizeNewlines(content).split('\n');
  final hasHeaders = raw.any((line) => sectionHeader(parseLine(line)) != null);
  if (!hasHeaders) return _splitByStanzas(raw, songKey);

  final blocks = <ChartSection>[];
  String? label;
  var repeat = 1;
  var start = 0;
  var lines = <String>[];
  var open = false;
  var index = 0;

  void close() {
    if (open && (lines.isNotEmpty || (label ?? '').isNotEmpty)) {
      blocks.add(
        ChartSection(
          id: '$songKey-section-${index - 1}',
          label: label ?? '',
          startLine: start,
          lines: lines,
          repeat: repeat,
        ),
      );
    }
    open = false;
  }

  void begin(String newLabel, int newRepeat, int newStart) {
    label = newLabel;
    repeat = newRepeat;
    start = newStart;
    lines = [];
    open = true;
    index++;
  }

  for (var i = 0; i < raw.length; i++) {
    final line = raw[i];
    final header = sectionHeader(parseLine(line));
    if (header != null) {
      close();
      // Content starts after the header, so startLine lines up with lines[0].
      begin(header.label, header.repeat, i + 1);
      continue;
    }
    if (line.trim().isEmpty) {
      if (open && lines.isNotEmpty) {
        close();
        begin('', 1, i + 1);
      }
      continue;
    }
    if (!open) begin(index == 0 ? 'Start' : '', 1, i);
    lines.add(line);
  }
  close();

  if (blocks.isEmpty && content.trim().isNotEmpty) {
    return [ChartSection(id: '$songKey-section-0', label: 'Song', startLine: 0, lines: raw)];
  }
  return blocks;
}

List<ChartSection> _splitByStanzas(List<String> raw, String songKey) {
  final blocks = <ChartSection>[];
  var lines = <String>[];
  var start = 0;

  void close() {
    if (lines.isEmpty) return;
    blocks.add(ChartSection(id: '$songKey-section-${blocks.length}', label: '', startLine: start, lines: lines));
    lines = [];
  }

  for (var i = 0; i < raw.length; i++) {
    if (raw[i].trim().isEmpty) {
      close();
    } else {
      if (lines.isEmpty) start = i;
      lines.add(raw[i]);
    }
  }
  close();

  if (blocks.isEmpty && raw.any((l) => l.trim().isNotEmpty)) {
    return [ChartSection(id: '$songKey-section-0', label: '', startLine: 0, lines: raw)];
  }
  return blocks;
}
