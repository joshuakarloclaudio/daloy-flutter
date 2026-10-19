import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../line_ups/application/line_up_detail_controller.dart' show SetlistSong;
import '../../../practice/application/practice_controller.dart';
import '../../../practice/presentation/widgets/listenable_selector.dart';
import '../../../songs/domain/display_prefs.dart';
import '../../../songs/presentation/widgets/chart_format.dart';
import '../../../songs/presentation/widgets/chord_sheet.dart';
import '../../../songs/presentation/widgets/lyrics_sheet.dart';
import '../../application/perform_controller.dart';
import '../../domain/perform_sections.dart';
import '../../domain/perform_theme.dart';

/// Width from which a landscape tablet sets the chart in two columns.
const performTwoColumnWidth = 900.0;

/// What the chart needs from Practice's clock: the beat (to light the bar
/// playing), whether to flash it, and the loop.
@immutable
class PracticeChartClock {
  const PracticeChartClock({required this.beat, required this.flash, required this.onLoop, this.loop});

  final ValueListenable<PracticeBeat?> beat;
  final bool flash;
  final SectionLoop? loop;

  /// Long-press on a section: loop it (again: stop).
  final void Function(int song, String sectionId) onLoop;
}

/// One song of the set: its heading, then its sections in the order this
/// line-up plays them. Songs stack into one scroll, so the end of one and
/// the start of the next can share the screen.
class PerformSongView extends StatelessWidget {
  const PerformSongView({
    super.key,
    required this.song,
    required this.number,
    required this.count,
    required this.zoom,
    required this.notesVisible,
    required this.activeSectionId,
    required this.sectionKeys,
    required this.onSelectSection,
    required this.onOpenSong,
    this.practice,
  });

  final PerformSong song;
  final int number;

  /// Practicing: the clock lights the bar being played.
  final PracticeChartClock? practice;
  final int count;
  final double zoom;
  final bool notesVisible;
  final String? activeSectionId;

  /// Filled in by section id so the screen can scroll a section into view.
  final Map<String, GlobalKey> sectionKeys;
  final ValueChanged<String> onSelectSection;
  final VoidCallback onOpenSong;

  GlobalKey _keyFor(String id) => sectionKeys.putIfAbsent(id, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    final sections = song.sections;
    final width = MediaQuery.sizeOf(context).width;
    final twoColumns =
        width >= performTwoColumnWidth &&
        MediaQuery.orientationOf(context) == Orientation.landscape &&
        sections.length > 1;

    Widget block(PerformSection s, int i) => PerformSectionBlock(
      key: _keyFor(s.id),
      section: s,
      index: i,
      song: song,
      zoom: zoom,
      notesVisible: notesVisible,
      active: s.id == activeSectionId,
      onSelect: () => onSelectSection(s.id),
      songIndex: number - 1,
      practice: practice,
    );

    final Widget chart;
    if (sections.isEmpty) {
      chart = _NoChart(viewMode: song.viewMode);
    } else if (twoColumns) {
      final split = _balancedSplit(sections);
      chart = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (var i = 0; i < split; i++) block(sections[i], i)],
            ),
          ),
          const SizedBox(width: DaloySpace.s6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (var i = split; i < sections.length; i++) block(sections[i], i)],
            ),
          ),
        ],
      );
    } else {
      chart = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final (i, s) in sections.indexed) block(s, i)],
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: twoColumns ? 1400 : 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SongHeading(song: song, number: number, count: count, onOpenSong: onOpenSong),
            const SizedBox(height: DaloySpace.s4),
            chart,
          ],
        ),
      ),
    );
  }

  /// Where to break the sections so both columns carry about as many lines.
  static int _balancedSplit(List<PerformSection> sections) {
    final total = sections.fold<int>(0, (sum, s) => sum + s.lines.length + 2);
    var running = 0;
    for (var i = 0; i < sections.length; i++) {
      running += sections[i].lines.length + 2;
      if (running * 2 >= total) return (i + 1).clamp(1, sections.length - 1);
    }
    return sections.length - 1;
  }
}

class _SongHeading extends StatelessWidget {
  const _SongHeading({required this.song, required this.number, required this.count, required this.onOpenSong});

  final PerformSong song;
  final int number;
  final int count;
  final VoidCallback onOpenSong;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final row = song.row;
    final wide = MediaQuery.sizeOf(context).width >= DaloyBreakpoints.tablet;
    final subtitle = [?row.artist, ?row.tempo].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count > 1 ? 'SONG $number OF $count' : 'SONG',
            style: context.text.labelSmall!.copyWith(color: c.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s1),
          Text(row.title, style: context.text.displaySmall!.copyWith(fontSize: wide ? 32 : 26)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
          ],
          const SizedBox(height: DaloySpace.s2_5),
          Wrap(
            spacing: DaloySpace.s1_5,
            runSpacing: DaloySpace.s1_5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _ToolPill(
                icon: TablerIcons.music,
                label: row.displayKey == null ? 'No key' : 'Key ${row.displayKey}',
                emphasis: row.isTransposed,
                onPressed: onOpenSong,
              ),
              _ToolPill(
                icon: TablerIcons.adjustments,
                label: row.capo > 0 ? 'Capo ${row.capo}' : 'No capo',
                emphasis: row.capo > 0,
                onPressed: onOpenSong,
              ),
              if (row.numberingReference case final ref?)
                Text(ref, style: context.text.labelMedium!.copyWith(color: c.primaryInk)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Key or capo as a tappable pill — opens the song sheet.
class _ToolPill extends StatelessWidget {
  const _ToolPill({required this.icon, required this.label, required this.emphasis, required this.onPressed});

  final IconData icon;
  final String label;
  final bool emphasis;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onPressed: onPressed,
      semanticLabel: '$label. Change',
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s2_5),
        decoration: BoxDecoration(
          color: emphasis ? c.primary.withValues(alpha: 0.1) : c.muted.withValues(alpha: 0.7),
          border: Border.all(color: emphasis ? c.primary.withValues(alpha: 0.3) : c.border),
          borderRadius: DaloyRadii.all(DaloyRadii.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: emphasis ? c.primaryInk : c.mutedForeground),
            const SizedBox(width: DaloySpace.s1_5),
            Text(
              label,
              style: context.text.labelLarge!
                  .copyWith(
                    color: emphasis ? c.primaryInk : c.foreground,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  )
                  .weight(FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// One section: its label, then its lines. A tap anywhere on it marks it as
/// the one being played (again clears it). The live section is outlined solid in the theme's highlight
/// so it reads from across a stage.
class PerformSectionBlock extends StatelessWidget {
  const PerformSectionBlock({
    super.key,
    required this.section,
    required this.index,
    required this.song,
    required this.zoom,
    required this.notesVisible,
    required this.active,
    required this.onSelect,
    this.songIndex = 0,
    this.practice,
  });

  final PerformSection section;

  /// The song's place in the set, to match the clock's position.
  final int songIndex;
  final PracticeChartClock? practice;
  final int index;
  final PerformSong song;
  final double zoom;
  final bool notesVisible;
  final bool active;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = PerformPaletteScope.of(context);
    final row = song.row;
    final hasHeader = section.label.isNotEmpty || section.repeat > 1;
    final practice = this.practice;
    final looping = practice?.loop?.song == songIndex && practice?.loop?.sectionId == section.id;
    final clock = practice?.beat;
    // The shared section label, so the editor's preview heads sections alike.
    final headerStyle = sectionLabelStyle(context, color: active ? palette.highlightForeground : null, strong: active);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onSelect,
      onLongPress: practice == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              practice.onLoop(songIndex, section.id);
            },
      child: AnimatedContainer(
        duration: palette.flat ? Duration.zero : DaloyMotion.medium,
        curve: DaloyMotion.ease,
        margin: const EdgeInsets.only(bottom: DaloySpace.s1),
        padding: const EdgeInsets.fromLTRB(DaloySpace.s3, DaloySpace.s2, DaloySpace.s3, DaloySpace.s2),
        decoration: BoxDecoration(
          color: active ? palette.highlight.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: active ? palette.highlight : Colors.transparent, width: 2),
          borderRadius: DaloyRadii.all(DaloyRadii.xl2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasHeader || active || looping)
              Semantics(
                button: true,
                selected: active,
                label: '${sectionChipLabel(section, index)}${active ? ', playing' : ''}${looping ? ', looping' : ''}',
                excludeSemantics: true,
                onTap: onSelect,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: DaloySpace.s1_5),
                  child: AnimatedContainer(
                    duration: palette.flat ? Duration.zero : DaloyMotion.fast,
                    padding: EdgeInsets.symmetric(horizontal: active ? DaloySpace.s2 : 0, vertical: 2),
                    decoration: BoxDecoration(
                      color: active ? palette.highlight : Colors.transparent,
                      borderRadius: DaloyRadii.all(DaloyRadii.full),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (active) const TextSpan(text: '● NOW  '),
                          if (section.label.isNotEmpty) TextSpan(text: section.label.toUpperCase()),
                          if (section.repeat > 1) TextSpan(text: '  ×${section.repeat}'),
                          if (looping) const TextSpan(text: '  ↻ LOOP'),
                          if (active && clock != null)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: ListenableSelector<PracticeBeat?, String?>(
                                listenable: clock,
                                select: (b) =>
                                    b == null || b.barNumber == null || b.isCountIn || b.position.song != songIndex
                                    ? null
                                    : '  ·  BAR ${b.barNumber}/${b.barCount}',
                                builder: (context, text) =>
                                    text == null ? const SizedBox.shrink() : Text(text, style: headerStyle),
                              ),
                            ),
                        ],
                      ),
                      style: headerStyle,
                    ),
                  ),
                ),
              ),
            switch (song.viewMode) {
              SongViewMode.chords when clock != null => ListenableSelector<PracticeBeat?, ChartBarHighlight?>(
                listenable: clock,
                select: (b) => _litBar(b, practice!.flash),
                builder: (context, lit) => _chords(context, row, highlight: lit, color: palette.highlight),
              ),
              SongViewMode.chords => _chords(context, row),
              SongViewMode.lyrics => LyricsSheet(lyrics: section.body, zoom: zoom),
            },
          ],
        ),
      ),
    );
  }
}

extension on PerformSectionBlock {
  Widget _chords(BuildContext context, SetlistSong row, {ChartBarHighlight? highlight, Color? color}) => ChordSheet(
    content: section.body,
    transposition: row.chartTransposition,
    zoom: zoom,
    musicalKey: row.originalKey,
    notation: row.notation,
    notes: notesVisible ? notesForSection(song.notes, section) : const [],
    lineOffset: section.startLine,
    highlight: highlight,
    highlightColor: color,
  );

  /// The bar to light in this section, if the clock is in it.
  ChartBarHighlight? _litBar(PracticeBeat? b, bool flash) {
    final step = b?.step;
    if (b == null || step == null || b.position.song != songIndex || step.sectionId != section.id) return null;
    final waiting = !b.playing || b.isCountIn;
    return ChartBarHighlight(
      line: step.line,
      bar: step.bar,
      atom: waiting ? null : b.atom,
      pending: waiting,
      pulse: flash && !waiting ? b.serial : null,
    );
  }
}

class _NoChart extends StatelessWidget {
  const _NoChart({required this.viewMode});

  final SongViewMode viewMode;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DaloySpace.s10),
      child: Column(
        children: [
          Icon(
            viewMode == SongViewMode.chords ? TablerIcons.music_off : TablerIcons.align_left,
            size: 26,
            color: c.mutedForeground.withValues(alpha: 0.7),
          ),
          const SizedBox(height: DaloySpace.s2),
          Text(
            viewMode == SongViewMode.chords ? 'No chords for this song yet.' : 'No lyrics for this song yet.',
            style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
          ),
        ],
      ),
    );
  }
}

/// Under the last song: where the set ends.
class PerformSetEnd extends StatelessWidget {
  const PerformSetEnd({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Text('End of the set', style: context.text.labelMedium!.copyWith(color: context.colors.mutedForeground)),
  );
}
