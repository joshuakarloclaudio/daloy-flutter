import 'package:flutter/material.dart';

/// Merriweather for content titles, DM Sans for everything else.
///
/// **Serif-for-Substance:** Merriweather only ever sets song names, line-up
/// names and page headings — never buttons, chips or nav labels.
///
/// Both fonts are variable, so weight goes through [FontVariation] as well
/// as [FontWeight]. Use [TextStyleWeight.weight] to change weight; a bare
/// `copyWith(fontWeight:)` leaves the axis where it was.
abstract final class DaloyFonts {
  /// Set from the Typeface preference before the theme is built: every label
  /// then falls back to the platform's own font (null family).
  static bool system = false;

  static String? get sans => system ? null : 'DMSans';
  static String? get serif => system ? null : 'Merriweather';
}

TextStyle daloyText(String? family, double size, FontWeight weight, {double? height, double? letterSpacingEm}) =>
    TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
      height: height,
      letterSpacing: letterSpacingEm == null ? null : letterSpacingEm * size,
      leadingDistribution: TextLeadingDistribution.even,
    );

extension TextStyleWeight on TextStyle {
  TextStyle weight(FontWeight weight) =>
      copyWith(fontWeight: weight, fontVariations: [FontVariation.weight(weight.value.toDouble())]);
}

/// The type scale, as Material slots so stock widgets pick it up too.
TextTheme daloyTextTheme(Color ink, Color muted) {
  final sans = DaloyFonts.sans;
  final serif = DaloyFonts.serif;
  return TextTheme(
    // Greeting / page heading — `text-2xl sm:text-3xl font-heading`.
    displaySmall: daloyText(serif, 26, FontWeight.w600, height: 1.2, letterSpacingEm: -0.02),
    // Card titles (featured line-up, live session) — `text-xl`.
    headlineSmall: daloyText(serif, 20, FontWeight.w600, height: 1.25, letterSpacingEm: -0.01),
    // Top-bar title.
    titleLarge: daloyText(sans, 17, FontWeight.w600, height: 1.3),
    // List-row titles — `font-semibold`.
    titleMedium: daloyText(sans, 16, FontWeight.w600, height: 1.35),
    // Section labels, small titles — `text-sm font-medium`.
    titleSmall: daloyText(sans, 14, FontWeight.w500, height: 1.4),
    bodyLarge: daloyText(sans, 16, FontWeight.w400, height: 1.5),
    // Body / metadata — `text-sm leading-relaxed`.
    bodyMedium: daloyText(sans, 14, FontWeight.w400, height: 1.55),
    bodySmall: daloyText(sans, 12, FontWeight.w400, height: 1.4),
    // Buttons.
    labelLarge: daloyText(sans, 14, FontWeight.w500, height: 1.2),
    // Tab labels, small links — `text-xs font-medium`.
    labelMedium: daloyText(sans, 12, FontWeight.w500, height: 1.2),
    // Status chips ("LIVE NOW", "TODAY") — set in uppercase by the widget.
    labelSmall: daloyText(sans, 10.4, FontWeight.w600, height: 1, letterSpacingEm: 0.16),
  ).apply(bodyColor: ink, displayColor: ink);
}
