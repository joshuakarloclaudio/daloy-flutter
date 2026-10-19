import 'package:flutter/material.dart';

import '../domain/present_deck.dart';

/// How a theme paints the room: deep grounds and soft light, tuned for a
/// wall across a room rather than a music stand (the web's
/// `lib/present-themes.ts`, its oklch colours in sRGB).
class PresentThemeStyle {
  const PresentThemeStyle({required this.background, required this.ambient, required this.isDark});

  final Gradient background;

  /// A glow or vignette over the background.
  final Gradient ambient;
  final bool isDark;

  Color get foreground => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1C1917);

  static PresentThemeStyle of(PresentTheme theme) => switch (theme) {
    PresentTheme.cinema => const PresentThemeStyle(
      isDark: true,
      background: LinearGradient(colors: [Color(0xFF050505), Color(0xFF050505)]),
      ambient: RadialGradient(
        radius: 0.9,
        colors: [Color(0x00000000), Color(0x00000000), Color(0x73000000)],
        stops: [0, 0.4, 1],
      ),
    ),
    PresentTheme.sanctuary => const PresentThemeStyle(
      isDark: true,
      background: LinearGradient(
        begin: Alignment(-0.25, -1),
        end: Alignment(0.25, 1),
        colors: [Color(0xFF00020E), Color(0xFF060421)],
      ),
      ambient: RadialGradient(
        center: Alignment(0, -1.1),
        radius: 0.8,
        colors: [Color(0x5915133E), Color(0x0015133E)],
        stops: [0, 0.6],
      ),
    ),
    PresentTheme.dawn => const PresentThemeStyle(
      isDark: false,
      background: LinearGradient(
        begin: Alignment(-0.3, -1),
        end: Alignment(0.3, 1),
        colors: [Color(0xFFFAF2E6), Color(0xFFFCFCF9)],
      ),
      ambient: RadialGradient(
        center: Alignment(0, -1.2),
        radius: 0.7,
        colors: [Color(0x80FDE0B9), Color(0x00FDE0B9)],
        stops: [0, 0.55],
      ),
    ),
    PresentTheme.paper => const PresentThemeStyle(
      isDark: false,
      background: LinearGradient(colors: [Color(0xFFF8EFE0), Color(0xFFF8EFE0)]),
      ambient: RadialGradient(
        center: Alignment(0, -1),
        radius: 0.6,
        colors: [Color(0x99FEFCF4), Color(0x00FEFCF4)],
        stops: [0, 0.5],
      ),
    ),
    PresentTheme.stage => const PresentThemeStyle(
      isDark: true,
      background: RadialGradient(
        center: Alignment(0, -1),
        radius: 1.3,
        colors: [Color(0xFF3D0A05), Color(0xFF010000)],
        stops: [0, 0.68],
      ),
      ambient: RadialGradient(
        center: Alignment(0, -1),
        radius: 0.55,
        colors: [Color(0x40642211), Color(0x00642211)],
        stops: [0, 0.7],
      ),
    ),
  };
}

/// The height every slide is laid out at. Screens and previews scale the
/// result, so the projector, the control panel and a remote all break lines
/// in the same places.
const presentCanvasHeight = 1080.0;

/// Lyric size at 100%, on [presentCanvasHeight].
const presentBaseFontSize = 52.0;

/// A slide as the room sees it, filling its box. [aspectRatio] is the
/// projector's, so a preview on a phone wraps lines as the wall does.
class PresentSlideView extends StatelessWidget {
  const PresentSlideView({
    super.key,
    required this.slide,
    required this.look,
    this.blanked = false,
    this.aspectRatio = 16 / 9,
    this.animate = true,
  });

  final PresentSlide? slide;
  final PresentLook look;
  final bool blanked;
  final double aspectRatio;

  /// Fades between slides; off for small previews.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final style = PresentThemeStyle.of(look.theme);
    final width = presentCanvasHeight * aspectRatio;
    final content = blanked || slide == null
        ? const SizedBox.expand(key: ValueKey('blank'))
        : _SlideContent(key: ValueKey(slide), slide: slide!, look: look, style: style, width: width);

    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: style.background),
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: style.ambient),
          child: FittedBox(
            child: SizedBox(
              width: width,
              height: presentCanvasHeight,
              child: animate ? AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: content) : content,
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  const _SlideContent({super.key, required this.slide, required this.look, required this.style, required this.width});

  final double width;
  final PresentSlide slide;
  final PresentLook look;
  final PresentThemeStyle style;

  @override
  Widget build(BuildContext context) {
    final fg = style.foreground;
    final serif = look.font == PresentFont.serif;
    final size = presentBaseFontSize * look.zoom / 100;
    final lyric = TextStyle(
      fontFamily: serif ? 'Merriweather' : 'DMSans',
      fontVariations: [FontVariation('wght', serif ? 400 : 500)],
      fontSize: size,
      height: 1.5,
      color: fg,
      shadows: [
        style.isDark
            ? const Shadow(color: Color(0x80000000), offset: Offset(0, 2), blurRadius: 28)
            : const Shadow(color: Color(0xCCFFFFFF), offset: Offset(0, 1), blurRadius: 12),
      ],
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (slide.fullLabel.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            top: presentCanvasHeight * 0.14,
            child: Text(
              slide.fullLabel.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontVariations: const [FontVariation('wght', 600)],
                fontSize: 20,
                letterSpacing: 6,
                color: fg.withValues(alpha: 0.3),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 96, vertical: 64),
          child: Center(
            child: slide.lines.isEmpty
                ? Text(
                    'No lyrics for ${slide.songTitle}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'DMSans', fontSize: 24, color: fg.withValues(alpha: 0.4)),
                  )
                // Lines wrap at the slide's width; a section too tall at this
                // size shrinks to fit rather than run off the wall.
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: width - 192),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final line in slide.lines)
                            line.trim().isEmpty
                                ? SizedBox(height: size * 0.55)
                                : Text(line.trim(), textAlign: TextAlign.center, style: lyric),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
