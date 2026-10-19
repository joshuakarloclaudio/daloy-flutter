/// A chart flattened into the bars it is played as — what the Practice
/// clock walks. Port of the web's `lib/bars.ts` (`barBeatMap`,
/// `songBarTimeline`) and `lib/time-signatures.ts`, so a chart counts the
/// same on every platform. Pure Dart: no Flutter, no I/O.
library;

import 'package:flutter/foundation.dart';

import '../../perform/domain/perform_sections.dart';
import '../../songs/chart/chart_parser.dart';

/// Beats per bar to click on — beat 1 of this count is accented. 4 when the
/// song has no (readable) time signature.
int beatsPerBar(String? timeSignature) {
  final match = RegExp(r'^(\d{1,2})/(\d{1,2})$').firstMatch(timeSignature?.trim() ?? '');
  final beats = int.tryParse(match?[1] ?? '');
  return beats != null && beats > 0 ? beats : 4;
}

final _separatorAtom = RegExp(r'^[./_-]+$');

/// Whether an atom is only a beat placeholder (`.`, `--`, `/`, `_`).
bool isSeparatorAtom(List<Segment> atom) =>
    atom.length == 1 && atom.first.kind == SegmentKind.text && _separatorAtom.hasMatch(atom.first.value);

/// A bar's own rhythm, read from its separators: for each beat, the index of
/// the atom sounding on it. A separator extends the chord before it, so
/// `| C - G - |` in 4/4 is C for two beats, then G for two.
///
/// The length is the bar's own beat count, which can be short of
/// [beatsPerBar] (`| A . |` in 4/4 is a two-beat bar). Null — "no rhythm
/// written" — when there are no separators, an atom carries no chord, or the
/// beats add up to more than a bar; the whole bar is then one event.
List<int>? barBeatMap(List<List<Segment>> atoms, int beatsPerBar) {
  final map = <int>[];
  var hasSeparator = false;
  var current = -1;

  for (var i = 0; i < atoms.length; i++) {
    final atom = atoms[i];
    if (isSeparatorAtom(atom)) {
      hasSeparator = true;
      // A bar that opens with a separator has no chord to extend.
      final target = current == -1 ? i : current;
      for (var b = 0; b < atom.first.value.length; b++) {
        map.add(target);
      }
      continue;
    }
    if (!atom.any((s) => s.kind == SegmentKind.chord)) return null;
    current = i;
    map.add(i);
  }

  if (!hasSeparator || map.isEmpty || map.length > beatsPerBar) return null;
  return map;
}

/// One bar of playing time, pointing back at where it is written.
@immutable
class BarStep {
  const BarStep({
    required this.sectionId,
    required this.line,
    required this.bar,
    required this.chords,
    required this.beatCount,
    this.beatMap,
  });

  final String sectionId;

  /// Line within the section's own lines (headers excluded).
  final int line;

  /// Bar within that line — or chord, on a bare chord line.
  final int bar;

  /// What sounds, with `%` and empty bars resolved to the bar before.
  final List<String> chords;

  /// Beats this bar takes: the song's count unless the bar wrote a shorter
  /// rhythm. `%` and empty bars carry the last one, as [chords] do.
  final int beatCount;

  /// The bar's own rhythm (see [barBeatMap]), or null to light the whole bar.
  final List<int>? beatMap;

  /// The atom sounding on [beat], or null for the whole bar.
  int? atomAt(int beat) {
    final map = beatMap;
    if (map == null || beat < 0 || beat >= map.length) return null;
    return map[beat];
  }

  @override
  bool operator ==(Object other) =>
      other is BarStep &&
      other.sectionId == sectionId &&
      other.line == line &&
      other.bar == bar &&
      other.beatCount == beatCount &&
      listEquals(other.chords, chords) &&
      listEquals(other.beatMap, beatMap);

  @override
  int get hashCode =>
      Object.hash(sectionId, line, bar, beatCount, Object.hashAll(chords), Object.hashAll(beatMap ?? []));

  @override
  String toString() => 'BarStep($sectionId L$line B$bar ${chords.join(' ')} /$beatCount)';
}

typedef _Unit = ({List<String> chords, List<int>? beatMap, int beatCount});

/// The bars a line contributes, or null for lyrics, notes and headers.
({List<_Unit> units, int repeat})? _unitsFor(String line, int beatsPerBar) {
  switch (classifyLine(line)) {
    case BarChartLine(:final bars, :final repeat):
      return (
        units: [
          for (final bar in bars)
            () {
              final map = barBeatMap(bar.atoms, beatsPerBar);
              return (
                chords: [
                  for (final atom in bar.atoms)
                    for (final s in atom)
                      if (s.kind == SegmentKind.chord) s.value,
                ],
                beatMap: map,
                beatCount: map?.length ?? beatsPerBar,
              );
            }(),
        ],
        repeat: repeat,
      );
    // A bare chord line counts a bar per chord — how charts typed before
    // barlines read, and what lets the clock work on them.
    case ChordsLine(:final chords, :final repeat) when chords.isNotEmpty:
      return (
        units: [
          for (final c in chords) (chords: [c], beatMap: null, beatCount: beatsPerBar),
        ],
        repeat: repeat,
      );
    default:
      return null;
  }
}

/// The song flattened into the bars it is played as, every repeat expanded,
/// section after section in the order given. Step N is the Nth bar played.
List<BarStep> songBarTimeline(List<PerformSection> sections, int beatsPerBar) {
  // `%` and empty bars sound as whatever was last written — across lines
  // and on across sections.
  var chords = const <String>[];
  var beatCount = beatsPerBar;
  final steps = <BarStep>[];

  for (final section in sections) {
    final parsed = [for (final line in section.lines) _unitsFor(line, beatsPerBar)];
    for (var cycle = 0; cycle < (section.repeat < 1 ? 1 : section.repeat); cycle++) {
      for (final (index, line) in parsed.indexed) {
        if (line == null) continue;
        for (var pass = 0; pass < line.repeat; pass++) {
          for (final (bar, unit) in line.units.indexed) {
            if (unit.chords.isNotEmpty) {
              chords = unit.chords;
              beatCount = unit.beatCount;
            }
            steps.add(
              BarStep(
                sectionId: section.id,
                line: index,
                bar: bar,
                chords: chords,
                beatCount: beatCount,
                beatMap: unit.beatMap,
              ),
            );
          }
        }
      }
    }
  }
  return steps;
}

/// Where each section's bars start in a timeline. Sections play as one run,
/// so the first step is enough to seek to one.
Map<String, ({int start, int count})> sectionRuns(List<BarStep> steps) {
  final runs = <String, ({int start, int count})>{};
  for (final (i, step) in steps.indexed) {
    final run = runs[step.sectionId];
    runs[step.sectionId] = run == null ? (start: i, count: 1) : (start: run.start, count: run.count + 1);
  }
  return runs;
}
