import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../line_ups/domain/line_up.dart';
import '../../chart/chart_parser.dart';
import '../../chart/nashville.dart';
import 'chart_format.dart';

export 'chart_format.dart' show chartBaseFontSize;

/// The bar Practice's clock is on, lit in the chart.
@immutable
class ChartBarHighlight {
  const ChartBarHighlight({required this.line, required this.bar, this.atom, this.pending = false, this.pulse});

  /// Line within the chart's content.
  final int line;

  /// Bar within the line (a chord, on a bare chord line).
  final int bar;

  /// Light only this atom of the bar; null lights the whole bar.
  final int? atom;

  /// Where the song will start (paused, or counting in): outlined, not filled.
  final bool pending;

  /// Changes on every beat to flash the bar; null: no flash.
  final Object? pulse;

  @override
  bool operator ==(Object other) =>
      other is ChartBarHighlight &&
      other.line == line &&
      other.bar == bar &&
      other.atom == atom &&
      other.pending == pending &&
      other.pulse == pulse;

  @override
  int get hashCode => Object.hash(line, bar, atom, pending, pulse);
}

/// A chord chart: chords in colour above the lyric line, section headers,
/// and barline rows that wrap at bar boundaries. The Flutter twin of the
/// web's `ChordSheet`; the text → lines step lives in `chart_parser.dart`.
class ChordSheet extends StatefulWidget {
  const ChordSheet({
    super.key,
    required this.content,
    required this.transposition,
    required this.zoom,
    this.musicalKey,
    this.notation = ChordNotation.letters,
    this.notes = const [],
    this.lineOffset = 0,
    this.highlight,
    this.highlightColor,
    this.onLineTap,
    this.onNoteTap,
    this.focusLine,
    this.focusKey,
    this.focusLit = false,
  });

  final String content;

  /// Semitones to shift letter chords by. Ignored for numbers.
  final int transposition;

  /// Percent; 100 draws at [chartBaseFontSize].
  final double zoom;

  /// The *written* key. Numbers are measured from it.
  final String? musicalKey;
  final ChordNotation notation;

  /// Team notes, drawn above the line they point at. A note on the line just
  /// past the end goes last.
  final List<LineUpSongNote> notes;

  /// Where [content] starts in the full chart, when it is one section of it
  /// — notes count lines from the top of the song.
  final int lineOffset;

  /// The bar being played (Practice).
  final ChartBarHighlight? highlight;

  /// What [highlight] is drawn in; the theme's primary by default.
  final Color? highlightColor;

  /// Makes each line tappable (Prepare's notes): called with the line's
  /// index in the full chart ([lineOffset] added).
  final ValueChanged<int>? onLineTap;

  /// Makes each note tappable.
  final ValueChanged<LineUpSongNote>? onNoteTap;

  /// A line to point out (a search hit), in full-chart numbering: it carries
  /// [focusKey], to be scrolled to, and a wash while [focusLit].
  final int? focusLine;
  final GlobalKey? focusKey;
  final bool focusLit;

  @override
  State<ChordSheet> createState() => _ChordSheetState();
}

class _ChordSheetState extends State<ChordSheet> {
  // Parsing is cached against the text so zooming (many rebuilds) never reparses.
  late List<ChartLine> _lines = parseChart(widget.content);

  @override
  void didUpdateWidget(ChordSheet old) {
    super.didUpdateWidget(old);
    if (old.content != widget.content) _lines = parseChart(widget.content);
  }

  @override
  Widget build(BuildContext context) {
    final style = ChartFormat.of(
      context,
      zoom: widget.zoom,
      notation: widget.notation,
      musicalKey: widget.musicalKey,
      transposition: widget.transposition,
      highlightColor: widget.highlightColor,
    );
    final size = style.em;
    final base = style.base;
    final lit = widget.highlight;
    ChartBarHighlight? litOn(int line) => lit != null && lit.line == line ? lit : null;
    Widget line(int i) {
      var drawn = _line(_lines[i], style, litOn(i));
      if (widget.focusLine == widget.lineOffset + i) {
        drawn = FocusedLine(key: widget.focusKey, lit: widget.focusLit, child: drawn);
      }
      final onTap = widget.onLineTap;
      return onTap == null ? drawn : _TappableLine(onTap: () => onTap(widget.lineOffset + i), child: drawn);
    }

    Widget note(LineUpSongNote n) {
      final drawn = ChartNote(text: n.text, fontSize: size * 0.75);
      final onTap = widget.onNoteTap;
      return onTap == null ? drawn : _TappableLine(onTap: () => onTap(n), semanticLabel: 'Edit note', child: drawn);
    }

    return DefaultTextStyle(
      style: base,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.notes.isEmpty
            ? [for (var i = 0; i < _lines.length; i++) line(i)]
            : [
                for (var i = 0; i <= _lines.length; i++) ...[
                  for (final n in widget.notes)
                    if (n.line - widget.lineOffset == i) note(n),
                  if (i < _lines.length) line(i),
                ],
              ],
      ),
    );
  }

  Widget _line(ChartLine line, ChartFormat s, ChartBarHighlight? lit) => switch (line) {
    BlankLine() => SizedBox(height: s.base.fontSize),
    SectionLine(:final label, :final repeat) => _SectionHeader(label: label, repeat: repeat, style: s),
    BarChartLine(:final bars, :final repeat) => _BarRow(bars: bars, repeat: repeat, style: s, lit: lit),
    ChordsLine(:final chords, :final repeat) => _ChordRow(chords: chords, repeat: repeat, style: s, lit: lit),
    TextLine(:final segments) when isChordLyricLine(segments) => _ChordLyricLine(
      words: chordLyricWords(segments),
      style: s,
    ),
    TextLine(:final segments) => Text.rich(
      TextSpan(
        children: [
          for (final seg in segments)
            switch (seg.kind) {
              SegmentKind.chord => s.chordSpan(seg.value),
              SegmentKind.section => TextSpan(text: seg.value.toUpperCase(), style: s.sectionStyle),
              _ => TextSpan(text: seg.value),
            },
        ],
      ),
    ),
  };
}

/// A line being pointed out: a soft primary wash that fades when [lit]
/// turns off. Bleeds a little past the text so the wash isn't tight to it.
class FocusedLine extends StatelessWidget {
  const FocusedLine({super.key, required this.lit, required this.child});

  final bool lit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s1_5),
      transform: Matrix4.translationValues(-DaloySpace.s1_5, 0, 0),
      decoration: BoxDecoration(
        color: lit ? c.primary.withValues(alpha: 0.16) : c.primary.withValues(alpha: 0),
        borderRadius: DaloyRadii.all(DaloyRadii.sm),
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.repeat, required this.style});

  final String label;
  final int repeat;
  final ChartFormat style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: DaloySpace.s3, bottom: DaloySpace.s1),
    child: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DaloySpace.s1_5,
      children: [
        Text(label.toUpperCase(), style: style.sectionStyle),
        if (repeat > 1) RepeatBadge(count: repeat, color: style.muted, size: style.em * 0.7),
      ],
    ),
  );
}

/// A lyric line with its chords drawn on a row above, each over the text it
/// lands on. Wraps only between words (see `chordLyricWords`); a chord wider
/// than its syllable pushes the rest of the lyric along rather than colliding
/// with the next chord.
class _ChordLyricLine extends StatelessWidget {
  const _ChordLyricLine({required this.words, required this.style});

  final List<List<ChordLyricUnit>> words;
  final ChartFormat style;

  // Non-breaking, so a word's trailing space keeps its width.
  static String _keepSpaces(String text) => text.isEmpty ? ' ' : text.replaceAll(' ', ' ');

  @override
  Widget build(BuildContext context) {
    final chord = style.chord.copyWith(height: 1.3);
    // Read as one line, not word by word.
    return MergeSemantics(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          for (final word in words)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final unit in word)
                  if (unit.section case final section?)
                    Padding(
                      padding: EdgeInsets.only(right: style.em * 0.5),
                      child: Text(section.toUpperCase(), style: style.sectionStyle),
                    )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (unit.chord case final token?)
                          Padding(
                            padding: EdgeInsets.only(right: style.em * 0.35),
                            child: Text.rich(style.chordSpan(token, style: chord), softWrap: false),
                          )
                        else
                          ExcludeSemantics(child: Text(' ', style: chord)),
                        Text(_keepSpaces(unit.text), softWrap: false),
                      ],
                    ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ChordRow extends StatelessWidget {
  const _ChordRow({required this.chords, required this.repeat, required this.style, this.lit});

  final List<String> chords;
  final int repeat;
  final ChartFormat style;
  final ChartBarHighlight? lit;

  @override
  Widget build(BuildContext context) {
    if (chords.isEmpty) return const SizedBox.shrink();
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DaloySpace.s4,
      children: [
        for (final (i, chord) in chords.indexed)
          _Lit(
            highlight: lit?.bar == i ? lit : null,
            color: style.highlightColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text.rich(style.chordSpan(chord)),
            ),
          ),
        if (repeat > 1) RepeatBadge(count: repeat, color: style.chord.color!, size: style.em),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({required this.bars, required this.repeat, required this.style, this.lit});

  final List<BarCell> bars;
  final int repeat;
  final ChartFormat style;
  final ChartBarHighlight? lit;

  @override
  Widget build(BuildContext context) {
    final color = style.chord.color!;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: DaloySpace.s1,
      children: [
        for (var i = 0; i < bars.length; i++)
          _BarUnit(bar: bars[i], isLast: i == bars.length - 1, style: style, lit: lit?.bar == i ? lit : null),
        if (repeat > 1)
          Padding(
            padding: const EdgeInsets.only(left: DaloySpace.s2),
            child: RepeatBadge(count: repeat, color: color, size: style.em),
          ),
      ],
    );
  }
}

/// One bar as a single unwrappable item. The leading barline lives inside it,
/// so a narrow screen breaks between bars and each wrapped row still opens
/// with a barline instead of splitting a bar in half.
class _BarUnit extends StatelessWidget {
  const _BarUnit({required this.bar, required this.isLast, required this.style, this.lit});

  final BarCell bar;
  final bool isLast;
  final ChartFormat style;

  /// This bar is playing.
  final ChartBarHighlight? lit;

  @override
  Widget build(BuildContext context) {
    final em = style.em;
    final color = style.chord.color!;
    final blank = bar.atoms.isEmpty && !bar.simile;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BarDivider(color: color, height: em * 1.15),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: blank ? em * 2 : 0),
          child: _Lit(
            // One atom lit when the bar wrote its rhythm; else the whole bar.
            highlight: lit != null && (lit!.atom == null || lit!.pending) ? lit : null,
            color: style.highlightColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (bar.simile)
                    Padding(
                      padding: EdgeInsets.only(right: bar.atoms.isEmpty ? 0 : DaloySpace.s2),
                      child: Text(
                        '⁄⁄',
                        style: style.chord.copyWith(fontSize: em * 0.9, color: color.withValues(alpha: 0.5)),
                      ),
                    ),
                  for (var i = 0; i < bar.atoms.length; i++) ...[
                    if (i > 0) const SizedBox(width: DaloySpace.s2),
                    _Lit(
                      highlight: lit != null && !lit!.pending && lit!.atom == i ? lit : null,
                      color: style.highlightColor,
                      tight: true,
                      child: _Atom(atom: bar.atoms[i], style: style),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (isLast) BarDivider(color: color, height: em * 1.15),
      ],
    );
  }
}

class _Atom extends StatelessWidget {
  const _Atom({required this.atom, required this.style});

  final List<Segment> atom;
  final ChartFormat style;

  @override
  Widget build(BuildContext context) {
    final color = style.chord.color!;
    if (isDotSeparatorAtom(atom)) return BeatDots(count: atom.first.value.length, color: color, size: style.em * 0.28);
    return Text.rich(
      TextSpan(
        children: [
          for (final seg in atom)
            seg.kind == SegmentKind.chord
                ? style.chordSpan(seg.value)
                : TextSpan(
                    text: seg.value,
                    style: TextStyle(color: color.withValues(alpha: 0.55)),
                  ),
        ],
      ),
      softWrap: false,
    );
  }
}

/// The playing bar's tint: filled while it sounds, outlined while it waits
/// (paused, counting in). With a pulse, it flares on each beat and settles.
class _Lit extends StatelessWidget {
  const _Lit({required this.highlight, required this.color, required this.child, this.tight = false});

  final ChartBarHighlight? highlight;
  final Color color;
  final Widget child;

  /// A single chord: the tint reaches a little past it, without moving
  /// anything around it.
  final bool tight;

  @override
  Widget build(BuildContext context) {
    final lit = highlight;
    if (lit == null) return child;

    BoxDecoration decoration(double flare) => BoxDecoration(
      color: lit.pending ? null : color.withValues(alpha: 0.16 + 0.22 * flare),
      border: Border.all(color: color.withValues(alpha: lit.pending ? 0.55 : 0.4 + 0.4 * flare), width: 1.5),
      borderRadius: DaloyRadii.all(DaloyRadii.md),
    );

    final inset = tight ? 4.0 : 0.0;
    final still = lit.pulse == null || MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: lit.pending ? 'Starts here' : 'Playing',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -inset,
            right: -inset,
            top: -1,
            bottom: -1,
            child: still
                ? DecoratedBox(decoration: decoration(0))
                : TweenAnimationBuilder<double>(
                    key: ValueKey(lit.pulse),
                    tween: Tween(begin: 1, end: 0),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    builder: (_, flare, _) => DecoratedBox(decoration: decoration(flare)),
                  ),
          ),
          child,
        ],
      ),
    );
  }
}

/// A team note pinned between chart lines: quiet, set off by an edge rule,
/// so it reads as an aside rather than as part of the song.
/// A chart line (or note) you can tap: a soft wash while pressed.
class _TappableLine extends StatefulWidget {
  const _TappableLine({required this.onTap, required this.child, this.semanticLabel});

  final VoidCallback onTap;
  final Widget child;
  final String? semanticLabel;

  @override
  State<_TappableLine> createState() => _TappableLineState();
}

class _TappableLineState extends State<_TappableLine> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DaloyMotion.fast,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _down ? c.primary.withValues(alpha: 0.10) : Colors.transparent,
            borderRadius: DaloyRadii.all(DaloyRadii.md),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class ChartNote extends StatelessWidget {
  const ChartNote({super.key, required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Note: $text',
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: DaloySpace.s1),
        padding: const EdgeInsets.fromLTRB(DaloySpace.s2_5, DaloySpace.s1_5, DaloySpace.s3, DaloySpace.s1_5),
        decoration: BoxDecoration(
          color: c.muted.withValues(alpha: 0.7),
          border: Border(left: BorderSide(color: c.mutedForeground.withValues(alpha: 0.6), width: 3)),
          borderRadius: DaloyRadii.all(DaloyRadii.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: fontSize * 0.2),
              child: Icon(TablerIcons.note, size: fontSize, color: c.mutedForeground),
            ),
            const SizedBox(width: DaloySpace.s2),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: fontSize, height: 1.4, color: c.foreground).weight(FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The rule drawn for a `|`.
class BarDivider extends StatelessWidget {
  const BarDivider({super.key, required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => Container(width: 1.5, height: height, color: color.withValues(alpha: 0.6));
}

/// Times-played marker for a repeated bar line, chord line or section: `×2`.
class RepeatBadge extends StatelessWidget {
  const RepeatBadge({super.key, required this.count, required this.color, required this.size});

  final int count;
  final Color color;

  /// The surrounding font size; the badge is 0.62 of it.
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: size * 0.62 * 0.6, vertical: size * 0.62 * 0.25),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: DaloyRadii.all(DaloyRadii.full)),
    child: Text(
      '×$count',
      style: TextStyle(
        fontSize: size * 0.62,
        height: 1.2,
        color: color.withValues(alpha: 0.85),
        fontFeatures: const [FontFeature.tabularFigures()],
      ).weight(FontWeight.w600),
    ),
  );
}

/// A beat written as a bare `.` — a rest or held beat with no chord of its own.
class BeatDots extends StatelessWidget {
  const BeatDots({super.key, required this.count, required this.color, required this.size});

  final int count;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < count; i++)
        Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : size * 0.8),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.45)),
          ),
        ),
    ],
  );
}
