import 'package:flutter/material.dart';

import '../../../core/theme/daloy_theme.dart';

/// Perform's page themes — the web's `[data-perf-theme]` blocks in
/// `app.css`, converted from OKLCH. Remembered per device: a stage iPad and
/// a phone often want different ones.
enum PerformTheme {
  appDefault('Default'),
  light('Light'),
  dark('Dark'),
  paper('Paper'),
  eInk('E-Ink'),
  eInkDark('E-Ink Dark');

  const PerformTheme(this.label);

  final String label;

  static PerformTheme parse(String? value) => values.where((t) => t.name == value).firstOrNull ?? appDefault;

  /// The palette for this theme; [appDefault] follows [platform].
  PerformPalette resolve(Brightness platform) => switch (this) {
    appDefault => platform == Brightness.dark ? PerformPalette.dark : PerformPalette.light,
    light => PerformPalette.light,
    dark => PerformPalette.dark,
    paper => PerformPalette.paper,
    eInk => PerformPalette.eInk,
    eInkDark => PerformPalette.eInkDark,
  };
}

/// One theme's colours, plus the live-section highlight the app theme
/// doesn't have.
@immutable
class PerformPalette {
  const PerformPalette({
    required this.colors,
    required this.brightness,
    required this.highlight,
    required this.highlightForeground,
    this.flat = false,
  });

  final DaloyColors colors;
  final Brightness brightness;

  /// The section being played — solid, so it reads from across a stage.
  final Color highlight;
  final Color highlightForeground;

  /// E-ink panels: no blur, no translucency, no motion.
  final bool flat;

  ThemeData get theme => DaloyTheme.build(colors, brightness);

  static const light = PerformPalette(
    colors: DaloyColors.light,
    brightness: Brightness.light,
    highlight: Color(0xFF008259),
    highlightForeground: Color(0xFFEEFFF7),
  );

  static const dark = PerformPalette(
    colors: DaloyColors.dark,
    brightness: Brightness.dark,
    highlight: Color(0xFF41DCA5),
    highlightForeground: Color(0xFF02130C),
  );

  static final paper = PerformPalette(
    colors: _derive(
      DaloyColors.light,
      background: const Color(0xFFF8EFE0),
      foreground: const Color(0xFF1C140C),
      card: const Color(0xFFF4E8D5),
      primary: const Color(0xFF00704E),
      primaryForeground: const Color(0xFFE9FAF2),
      secondaryForeground: const Color(0xFF2B221A),
      muted: const Color(0xFFEADCC9),
      mutedForeground: const Color(0xFF695B4B),
      border: const Color(0xFFD3C1AA),
      ring: const Color(0xFF8A7E70),
      chordInk: const Color(0xFF00704E),
    ),
    brightness: Brightness.light,
    highlight: const Color(0xFF00704E),
    highlightForeground: const Color(0xFFE9FAF2),
  );

  static final eInk = PerformPalette(
    colors: _derive(
      DaloyColors.light,
      background: const Color(0xFFE9EBEE),
      foreground: const Color(0xFF0D0D0D),
      card: const Color(0xFFE0E1E4),
      primary: const Color(0xFF161616),
      primaryForeground: const Color(0xFFF8F8F8),
      secondaryForeground: const Color(0xFF1B1B1B),
      muted: const Color(0xFFCFD1D4),
      mutedForeground: const Color(0xFF4D4D4D),
      border: const Color(0xFF696969),
      ring: const Color(0xFF424242),
      destructive: const Color(0xFF292929),
      chordInk: const Color(0xFF121212),
    ),
    brightness: Brightness.light,
    highlight: const Color(0xFF0D0D0D),
    highlightForeground: const Color(0xFFF8F8F8),
    flat: true,
  );

  static final eInkDark = PerformPalette(
    colors: _derive(
      DaloyColors.dark,
      background: const Color(0xFF050607),
      foreground: const Color(0xFFE4E4E4),
      card: const Color(0xFF111213),
      primary: const Color(0xFFC4C4C4),
      primaryForeground: const Color(0xFF020202),
      secondaryForeground: const Color(0xFFC4C4C4),
      muted: const Color(0xFF28292B),
      mutedForeground: const Color(0xFF989898),
      border: const Color(0xFF5D5D5D),
      ring: const Color(0xFF868686),
      destructive: const Color(0xFFA4A4A4),
      chordInk: const Color(0xFFC4C4C4),
    ),
    brightness: Brightness.dark,
    highlight: const Color(0xFFE4E4E4),
    highlightForeground: const Color(0xFF020202),
    flat: true,
  );

  /// A full palette from a base; "today" colours never show in Perform.
  static DaloyColors _derive(
    DaloyColors base, {
    required Color background,
    required Color foreground,
    required Color card,
    required Color primary,
    required Color primaryForeground,
    required Color secondaryForeground,
    required Color muted,
    required Color mutedForeground,
    required Color border,
    required Color ring,
    required Color chordInk,
    Color? destructive,
  }) => DaloyColors(
    background: background,
    foreground: foreground,
    card: card,
    primary: primary,
    primaryForeground: primaryForeground,
    secondaryForeground: secondaryForeground,
    muted: muted,
    mutedForeground: mutedForeground,
    border: border,
    ring: ring,
    destructive: destructive ?? base.destructive,
    sidebar: card,
    sidebarPrimary: primary,
    chordInk: chordInk,
    today: base.today,
    todayInk: base.todayInk,
    todayBorder: base.todayBorder,
    todayWashFrom: base.todayWashFrom,
    todayWashTo: base.todayWashTo,
    todayOrb: base.todayOrb,
    todayOrbAlt: base.todayOrbAlt,
  );
}

/// The palette Perform is drawn in, for widgets under its [Theme]. An
/// [InheritedTheme], so sheets and dialogs opened from Perform keep it.
class PerformPaletteScope extends InheritedTheme {
  const PerformPaletteScope({super.key, required this.palette, required super.child});

  final PerformPalette palette;

  static PerformPalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PerformPaletteScope>()?.palette ??
      (Theme.of(context).brightness == Brightness.dark ? PerformPalette.dark : PerformPalette.light);

  @override
  Widget wrap(BuildContext context, Widget child) => PerformPaletteScope(palette: palette, child: child);

  @override
  bool updateShouldNotify(PerformPaletteScope old) => old.palette != palette;
}
