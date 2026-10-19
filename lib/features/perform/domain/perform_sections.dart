/// Perform's side of a song's sections: the line-up's arrangement, notes per
/// section, chip names. The split itself is shared (`chart_sections.dart`).
/// Port of the web's `lib/section-arrangement.ts`. Pure Dart.
library;

import '../../line_ups/domain/line_up.dart';
import '../../songs/chart/chart_sections.dart';

export '../../songs/chart/chart_sections.dart';

/// Perform's name for a [ChartSection].
typedef PerformSection = ChartSection;

/// Reorders and cuts sections per a line-up's stored arrangement. Sections
/// in neither list (the song grew since) are appended in written order; if
/// nothing valid is left, the song plays as written — never an empty chart.
List<PerformSection> applyArrangement(List<PerformSection> blocks, SectionArrangementField? field) {
  if (field == null || field.isEmpty) return blocks;

  final removed = field.removed.toSet();
  final emitted = <int>{};
  final result = <PerformSection>[];

  for (final i in field.order) {
    if (i < 0 || i >= blocks.length || removed.contains(i) || !emitted.add(i)) continue;
    result.add(blocks[i]);
  }
  for (var i = 0; i < blocks.length; i++) {
    if (emitted.contains(i) || removed.contains(i)) continue;
    result.add(blocks[i]);
  }
  return result.isEmpty ? blocks : result;
}

/// Notes that belong to a section, inclusive at the end: a note added after
/// a section's last line lands on the gap line between sections.
List<LineUpSongNote> notesForSection(List<LineUpSongNote> notes, PerformSection section) {
  final end = section.startLine + section.lines.length;
  return [
    for (final n in notes)
      if (n.line >= section.startLine && n.line <= end) n,
  ];
}

/// The name a chip shows: the label, or the section's place in the song.
String sectionChipLabel(PerformSection section, int index) => section.label.isEmpty ? '${index + 1}' : section.label;
