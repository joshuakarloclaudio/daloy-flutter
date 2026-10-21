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

/// A bar's own rhythm: for each beat, the index of the atom sounding on it.
/// The length is the bar's beat count.
///
/// Separators place the chords: one extends the chord before it, so
/// `| C - G - |` in 4/4 is C for two beats, then G for two. The bar is as
/// long as its beats add up to — `| A . |` in 4/4 is a two-beat bar, and
/// `| F#m . Bm . . . |` a six-beat one.
///
/// With no separators, two or more chords split the bar evenly: `| G A |`
/// is two beats each, and `| 2/4 Em F#m |` one each.
///
/// [meter] is the bar's own time signature (see [BarCell.meter]), which
/// fixes its length; separators that don't add up to it are ignored.
///
/// Null — light the whole bar — for a single chord with no separators, an
/// atom that carries no chord, or chords that don't divide the bar evenly.
List<int>? barBeatMap(List<List<Segment>> atoms, int beatsPerBar, {int? meter}) {
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

  if (map.isEmpty) return null;
  if (hasSeparator) return meter == null || map.length == meter ? map : null;

  final beats = meter ?? beatsPerBar;
  if (atoms.length < 2 || beats % atoms.length != 0) return null;
  final each = beats ~/ atoms.length;
  return [for (var i = 0; i < atoms.length; i++) ...List.filled(each, i)];
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
    this.cycle = 0,
    this.pass = 0,
  });

  final String sectionId;

  /// Which time round the section this is (`×2`), and which time round its
  /// line — 0-based. The same written bar plays once per pass.
  final int cycle;
  final int pass;

  /// Line within the section's own lines (headers excluded).
  final int line;

  /// Bar within that line — or chord, on a bare chord line.
  final int bar;

  /// What sounds, with `%` and empty bars resolved to the bar before.
  final List<String> chords;

  /// Beats this bar takes: the song's count unless the bar wrote its own
  /// (a time signature, or separators that add up to more or less). `%` and
  /// empty bars carry the last one, as [chords] do.
  final int beatCount;

  /// The bar's own rhythm (see [barBeatMap]), or null to light the whole bar.
  final List<int>? beatMap;

  /// The atom sounding on [beat], or null for the whole bar.
  int? atomAt(int beat) {
    final map = beatMap;
    if (map == null || beat < 0 || beat >= map.length) return null;
    return map[beat];
  }

  /// The beat [atom] first sounds on; 0 for the whole bar.
  int beatOf(int? atom) {
    final at = atom == null ? -1 : beatMap?.indexOf(atom) ?? -1;
    return at < 0 ? 0 : at;
  }

  /// The beat the chord sounding on [beat] came in on.
  int chordStart(int beat) => beatOf(atomAt(beat));

  @override
  bool operator ==(Object other) =>
      other is BarStep &&
      other.sectionId == sectionId &&
      other.line == line &&
      other.bar == bar &&
      other.beatCount == beatCount &&
      other.cycle == cycle &&
      other.pass == pass &&
      listEquals(other.chords, chords) &&
      listEquals(other.beatMap, beatMap);

  @override
  int get hashCode =>
      Object.hash(sectionId, line, bar, beatCount, cycle, pass, Object.hashAll(chords), Object.hashAll(beatMap ?? []));

  @override
  String toString() => 'BarStep($sectionId L$line B$bar ${chords.join(' ')} /$beatCount)';
}

/// [beatCount] null carries the bar before's. [holds] keeps sounding the
/// last chord written: a bar of only separators (`| . . |`).
typedef _Unit = ({List<String> chords, List<int>? beatMap, int? beatCount, bool holds});

/// The bars a line contributes, or null for lyrics, notes and headers.
({List<_Unit> units, int repeat})? _unitsFor(String line, int beatsPerBar) {
  switch (classifyLine(line)) {
    case BarChartLine(:final bars, :final repeat):
      return (
        units: [
          for (final bar in bars)
            () {
              final meter = bar.meter?.count;
              final map = barBeatMap(bar.atoms, beatsPerBar, meter: meter);
              final chords = [
                for (final atom in bar.atoms)
                  for (final s in atom)
                    if (s.kind == SegmentKind.chord) s.value,
              ];
              if (chords.isEmpty) {
                // `%`, an empty bar, or a bar of beats held over (`| . . |`):
                // it sounds as before, lit whole, for as long as it says.
                final held = !bar.simile && map != null;
                return (chords: chords, beatMap: null, beatCount: meter ?? (held ? map.length : null), holds: held);
              }
              return (chords: chords, beatMap: map, beatCount: meter ?? map?.length ?? beatsPerBar, holds: false);
            }(),
        ],
        repeat: repeat,
      );
    // A bare chord line counts a bar per chord — how charts typed before
    // barlines read, and what lets the clock work on them.
    case ChordsLine(:final chords, :final repeat) when chords.isNotEmpty:
      return (
        units: [
          for (final c in chords) (chords: [c], beatMap: null, beatCount: beatsPerBar, holds: false),
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
            } else if (unit.holds && chords.isNotEmpty) {
              chords = [chords.last];
            }
            beatCount = unit.beatCount ?? beatCount;
            steps.add(
              BarStep(
                sectionId: section.id,
                line: index,
                bar: bar,
                chords: chords,
                beatCount: beatCount,
                beatMap: unit.beatMap,
                cycle: cycle,
                pass: pass,
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

/// The step that plays the written bar [line]/[bar] of [sectionId]. A
/// repeated bar plays more than once; [near] (where the clock is) picks the
/// time round: its section's cycle and, on its own line, its pass — else the
/// first. Null when the bar isn't played (not in the timeline).
int? stepForBar(List<BarStep> steps, {required String sectionId, required int line, required int bar, int? near}) {
  final at = near != null && near >= 0 && near < steps.length ? steps[near] : null;
  final here = at?.sectionId == sectionId ? at : null;
  int? first;
  int? sameCycle;
  for (final (i, step) in steps.indexed) {
    if (step.sectionId != sectionId || step.line != line || step.bar != bar) continue;
    first ??= i;
    if (here == null || step.cycle != here.cycle) continue;
    sameCycle ??= i;
    if (here.line == line && step.pass == here.pass) return i;
  }
  return sameCycle ?? first;
}
