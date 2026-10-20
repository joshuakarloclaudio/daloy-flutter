import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder, CupertinoThemeData;
import 'package:flutter/material.dart';

import 'daloy_colors.dart';
import 'daloy_tokens.dart';
import 'daloy_typography.dart';

export 'daloy_colors.dart';
export 'daloy_tokens.dart';
export 'daloy_typography.dart';

/// "The Quiet Instrument": a neutral canvas, one teal accent, flat bordered
/// content, and glass only for chrome that floats over moving content.
abstract final class DaloyTheme {
  static ThemeData light() => build(DaloyColors.light, Brightness.light);
  static ThemeData dark() => build(DaloyColors.dark, Brightness.dark);

  /// The whole theme from one palette — Perform's themes use this.
  static ThemeData build(DaloyColors c, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.primaryForeground,
      secondary: c.muted,
      onSecondary: c.secondaryForeground,
      error: c.destructive,
      onError: Colors.white,
      surface: c.background,
      onSurface: c.foreground,
      onSurfaceVariant: c.mutedForeground,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.card,
      surfaceContainer: c.card,
      surfaceContainerHigh: c.card,
      surfaceContainerHighest: c.muted,
      outline: c.border,
      outlineVariant: c.border,
    );
    final text = daloyTextTheme(c.foreground, c.mutedForeground);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [c],
      fontFamily: DaloyFonts.sans,
      textTheme: text,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.border,
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      // No ripples: a press is a background highlight, as on iOS.
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: c.muted.withValues(alpha: 0.5),
      // Teal caret, selection and handles; Cupertino tints from the same hue.
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary,
        selectionColor: c.primary.withValues(alpha: 0.25),
        selectionHandleColor: c.primary,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(brightness: brightness, primaryColor: c.primary),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: DaloyRadii.all(DaloyRadii.xl2),
          side: BorderSide(color: c.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s3),
        hintStyle: text.bodyMedium?.copyWith(color: c.mutedForeground),
        border: _inputBorder(c.border),
        enabledBorder: _inputBorder(c.border),
        focusedBorder: _inputBorder(c.ring),
        errorBorder: _inputBorder(c.destructive.withValues(alpha: 0.6)),
        focusedErrorBorder: _inputBorder(c.destructive),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.card,
        surfaceTintColor: Colors.transparent,
        // Lighter than Material's 32%: the page stays readable behind a sheet.
        modalBarrierColor: Colors.black.withValues(alpha: brightness == Brightness.dark ? 0.4 : 0.2),
        // Sheets draw their own grabber (`showDaloySheet`).
        showDragHandle: false,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(DaloyRadii.xl3))),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.primary),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: DaloyRadii.all(DaloyRadii.xl),
    borderSide: BorderSide(color: color),
  );
}

extension DaloyThemeContext on BuildContext {
  DaloyColors get colors => Theme.of(this).extension<DaloyColors>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
