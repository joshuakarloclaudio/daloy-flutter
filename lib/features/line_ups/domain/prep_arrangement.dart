/// Preparing a song's sections for one line-up: the list the Prepare screen
/// shows (kept sections in play order, then the cut ones), and the stored
/// arrangement each edit writes. Port of `use-line-up-prepare-page.ts`.
/// Pure Dart.
library;

import 'package:flutter/foundation.dart';

import '../../songs/chart/chart_sections.dart';
import 'line_up.dart';

/// One section as Prepare lists it.
@immutable
class PrepSection {
  const PrepSection({required this.originalIndex, required this.block, required this.removed});

  /// Its place in the song as written — what the arrangement stores.
  final int originalIndex;
  final ChartSection block;

  /// Left out of this line-up.
  final bool removed;

  @override
  bool operator ==(Object other) =>
      other is PrepSection && other.originalIndex == originalIndex && other.block == block && other.removed == removed;

  @override
  int get hashCode => Object.hash(originalIndex, block, removed);
}

/// The order Prepare lists a song's [blockCount] sections in: the stored
/// order, then the cut ones, then any the song grew since (as written).
/// Indices that no longer exist are dropped.
List<int> prepDisplayOrder(int blockCount, SectionArrangementField? field) {
  if (field == null || field.isEmpty) return List.generate(blockCount, (i) => i);
  final seen = <int>{};
  final display = <int>[];
  for (final i in [...field.order, ...field.removed]) {
    if (i < 0 || i >= blockCount || !seen.add(i)) continue;
    display.add(i);
  }
  for (var i = 0; i < blockCount; i++) {
    if (seen.add(i)) display.add(i);
  }
  return display;
}

/// A song's sections for Prepare, from its [blocks] and stored [field].
List<PrepSection> prepSections(List<ChartSection> blocks, SectionArrangementField? field) {
  final removed = {...?field?.removed};
  return [
    for (final i in prepDisplayOrder(blocks.length, field))
      PrepSection(originalIndex: i, block: blocks[i], removed: removed.contains(i)),
  ];
}

SectionArrangementField _fieldOf(List<int> display, Set<int> removed) => SectionArrangementField(
  order: [
    for (final i in display)
      if (!removed.contains(i)) i,
  ],
  removed: [
    for (final i in display)
      if (removed.contains(i)) i,
  ],
);

/// The arrangement after moving the section at list place [from] to [to]
/// (indices as `onReorderItem` gives them: [to] counts after the removal).
SectionArrangementField movedSection(List<PrepSection> sections, int from, int to) {
  final display = [for (final s in sections) s.originalIndex];
  display.insert(to, display.removeAt(from));
  return _fieldOf(display, {
    for (final s in sections)
      if (s.removed) s.originalIndex,
  });
}

/// The arrangement after cutting [originalIndex] — or bringing it back.
SectionArrangementField toggledSection(List<PrepSection> sections, int originalIndex) {
  final removed = {
    for (final s in sections)
      if (s.removed) s.originalIndex,
  };
  if (!removed.remove(originalIndex)) removed.add(originalIndex);
  return _fieldOf([for (final s in sections) s.originalIndex], removed);
}

/// Whether [sections] differ from the song as written.
bool isRearranged(List<PrepSection> sections) {
  for (final (i, s) in sections.indexed) {
    if (s.removed || s.originalIndex != i) return true;
  }
  return false;
}

/// A short name for a section in the play-order strip ("V1", "C", "Br").
String sectionShortLabel(ChartSection section, int place) {
  final label = section.label.trim();
  if (label.isEmpty) return '${place + 1}';
  final words = label.split(RegExp(r'\s+'));
  final number = words.length > 1 && RegExp(r'^\d+$').hasMatch(words.last) ? words.removeLast() : '';
  final written = words.join(' ');
  final short = switch (written.toLowerCase()) {
    'verse' => 'V',
    'chorus' => 'C',
    'pre-chorus' || 'prechorus' || 'pre chorus' => 'PC',
    'bridge' => 'B',
    'intro' => 'In',
    'outro' => 'Out',
    'tag' => 'Tag',
    'interlude' => 'Int',
    'instrumental' => 'Inst',
    'ending' => 'End',
    'refrain' => 'R',
    'start' => 'S',
    _ => written.length <= 4 ? written : written.substring(0, 3),
  };
  return '$short$number';
}

/// A section's first line, to tell it apart in a list.
String sectionPreview(ChartSection section) =>
    linePreview(section.lines.firstWhere((l) => l.trim().isNotEmpty, orElse: () => ''));

/// A chart line as plain text: the words without their chords, or the
/// chords when the line has nothing else.
String linePreview(String line) {
  final words = line.replaceAll(RegExp(r'\[[^\]]*\]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (words.isNotEmpty && RegExp(r'[A-Za-z]{2,}').hasMatch(words)) return words;
  return line.replaceAll(RegExp(r'[\[\]]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
}
