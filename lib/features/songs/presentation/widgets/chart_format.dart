import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../chart/chord_math.dart';
import '../../chart/nashville.dart';

/// The size 100% zoom draws a chart at (the web's `font-size: 125%` of 16px).
const chartBaseFontSize = 20.0;

/// How a chord chart is drawn, resolved once per build and shared by every
/// surface that shows one — the song page, Perform and Practice, the editor's
/// preview and the chord editor itself — so a chart reads the same in each.
class ChartFormat {
  const ChartFormat({
    required this.base,
    required this.chord,
    required this.muted,
    required this.ink,
    required this.notation,
    required this.musicalKey,
    required this.transposition,
    required this.highlightColor,
  });

  factory ChartFormat.of(
    BuildContext context, {
    required double zoom,
    ChordNotation notation = ChordNotation.letters,
    String? musicalKey,
    int transposition = 0,
    Color? highlightColor,
  }) {
    final c = context.colors;
    final base = context.text.bodyLarge!
        .copyWith(color: c.foreground, fontSize: chartBaseFontSize * zoom / 100, height: 1.5)
        .weight(FontWeight.w500);
    return ChartFormat(
      base: base,
      chord: base.copyWith(color: c.chordInk).weight(FontWeight.w600),
      muted: c.mutedForeground,
      ink: c.foreground,
      // A key that can't be numbered falls back to letters.
      notation: notation == ChordNotation.numbers && canUseNumbers(musicalKey)
          ? ChordNotation.numbers
          : ChordNotation.letters,
      musicalKey: musicalKey,
      transposition: transposition,
      highlightColor: highlightColor ?? c.primary,
    );
  }

  /// Lyrics and anything unbracketed.
  final TextStyle base;
  final TextStyle chord;
  final Color muted;
  final Color ink;
  final ChordNotation notation;
  final String? musicalKey;
  final int transposition;

  /// The bar Practice is on.
  final Color highlightColor;

  double get em => base.fontSize!;

  /// What barlines, `%` and repeat badges are drawn in.
  Color get structure => chord.color!;

  /// A `[Section]` label inside a lyric line.
  TextStyle get sectionStyle => base
      .copyWith(fontSize: em * 0.7, letterSpacing: em * 0.7 * 0.1, color: muted.withValues(alpha: 0.7))
      .weight(FontWeight.w600);

  /// A `|` written as text (the editor); the read-only chart draws [structure] rules.
  TextStyle get barStyle => base.copyWith(color: structure.withValues(alpha: 0.6)).weight(FontWeight.w300);

  /// `×2` written as text (the editor), matching the repeat badge.
  TextStyle get repeatStyle => base
      .copyWith(
        fontSize: em * 0.62,
        color: structure.withValues(alpha: 0.85),
        backgroundColor: structure.withValues(alpha: 0.1),
        fontFeatures: const [FontFeature.tabularFigures()],
      )
      .weight(FontWeight.w600);

  /// One chord. Falls back to letters per token, so one unconvertible chord
  /// never breaks the rest of the chart.
  InlineSpan chordSpan(String token, {TextStyle? style}) {
    final text = style ?? chord;
    final parts = notation == ChordNotation.numbers ? chordToNashvilleParts(token, musicalKey) : null;
    if (parts == null) {
      // A slash chord (`G/B`, from a lyric line) moves its bass too.
      return TextSpan(text: token.split('/').map((p) => transposeChord(p, transposition)).join('/'), style: text);
    }

    // Extensions sit a step smaller and lighter so `57` reads as one chord;
    // quality symbols (° ø + Δ) keep full size.
    final symbol = qualitySymbolPattern.firstMatch(parts.quality)?[0] ?? '';
    final extension = parts.quality.substring(symbol.length);
    return TextSpan(
      style: text.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
      children: [
        TextSpan(text: parts.degree),
        if (symbol.isNotEmpty)
          TextSpan(
            text: symbol,
            style: TextStyle(color: text.color?.withValues(alpha: 0.9)),
          ),
        if (extension.isNotEmpty)
          TextSpan(
            text: extension,
            style: TextStyle(fontSize: em * 0.82, color: text.color?.withValues(alpha: 0.75)).weight(FontWeight.w500),
          ),
        if (parts.bass != null) ...[
          TextSpan(
            text: '/',
            style: TextStyle(color: text.color?.withValues(alpha: 0.55)),
          ),
          TextSpan(text: parts.bass),
        ],
      ],
    );
  }
}

/// How lyrics are drawn: the serif, a step smaller than a chart, with
/// section headings in small spaced caps. Shared by the lyrics sheet and the
/// lyrics editor.
class LyricsFormat {
  const LyricsFormat({required this.body, required this.heading});

  factory LyricsFormat.of(BuildContext context, {double zoom = 100}) {
    final c = context.colors;
    final size = chartBaseFontSize * 0.8 * zoom / 100;
    final body = TextStyle(fontFamily: DaloyFonts.serif, fontSize: size, height: 1.6, color: c.foreground);
    return LyricsFormat(
      body: body,
      heading: body
          .copyWith(
            fontFamily: DaloyFonts.sans,
            fontSize: size * 0.7,
            letterSpacing: size * 0.7 * 0.1,
            color: c.mutedForeground.withValues(alpha: 0.8),
          )
          .weight(FontWeight.w600),
    );
  }

  final TextStyle body;
  final TextStyle heading;

  double get size => body.fontSize!;
}

/// A section's label over its lines (`VERSE 1  ×2`), as Perform and Practice
/// head each section. Fixed size, whatever the chart's zoom.
TextStyle sectionLabelStyle(BuildContext context, {Color? color, bool strong = false}) => context.text.labelSmall!
    .copyWith(
      letterSpacing: 1.6,
      color: color ?? context.colors.mutedForeground.withValues(alpha: 0.8),
      fontFeatures: const [FontFeature.tabularFigures()],
    )
    .weight(strong ? FontWeight.w800 : FontWeight.w600);

/// The text of a section label: `VERSE 1  ×2`.
String sectionLabelText(String label, int repeat) =>
    [if (label.isNotEmpty) label.toUpperCase(), if (repeat > 1) '×$repeat'].join('  ');
