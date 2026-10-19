import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/flow_artwork.dart';

/// A song's generated artwork, drawn like a line-up's cover: its own
/// palette and flow lines, with the key in serif as its type.
///
/// Below 80px it's a list tile — just the key, centred (a music glyph when
/// the song has no key). Larger, it's the song's cover: an overline, the
/// key large, and an optional [caption] along the bottom.
class SongArtwork extends StatelessWidget {
  const SongArtwork({
    super.key,
    required this.songId,
    this.keyName,
    this.width = 40,
    this.height,
    this.overline = 'Key',
    this.caption,
    this.animate = false,
    this.shadow = false,
  });

  final int songId;
  final String? keyName;
  final double width;
  final double? height;
  final String overline;
  final String? caption;
  final bool animate;
  final bool shadow;

  /// The palette a song's artwork (and its page's wash) is drawn in.
  static FlowPalette paletteFor(int songId) => FlowPalette.seeded(songId + 1);

  /// Spread so a song and a line-up with the same id don't share a pattern.
  int get _seed => songId * 7919 + 13;

  @override
  Widget build(BuildContext context) {
    final h = height ?? width;
    final m = math.min(width, h);
    final key = keyName?.trim().isNotEmpty == true ? keyName!.trim() : null;
    const ink = Colors.white;

    final Widget type;
    if (m < 80) {
      type = Padding(
        padding: EdgeInsets.all(m * 0.14),
        child: Center(
          child: key == null
              ? Icon(TablerIcons.music, size: m * 0.42, color: ink.withValues(alpha: 0.9))
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    key,
                    maxLines: 1,
                    style: daloyText(
                      DaloyFonts.serif,
                      m * 0.42,
                      FontWeight.w700,
                      height: 1,
                      letterSpacingEm: -0.02,
                    ).copyWith(color: ink),
                  ),
                ),
        ),
      );
    } else {
      final small = daloyText(
        DaloyFonts.sans,
        math.max(9.5, m * 0.06),
        FontWeight.w700,
        height: 1,
        letterSpacingEm: 0.18,
      ).copyWith(color: ink.withValues(alpha: 0.85));
      type = Padding(
        padding: EdgeInsets.all(math.max(12, m * 0.09)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (key != null) ...[
              Text(overline.toUpperCase(), style: small),
              SizedBox(height: m * 0.02),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: AnimatedSwitcher(
                    duration: DaloyMotion.medium,
                    child: Text(
                      key,
                      key: ValueKey(key),
                      maxLines: 1,
                      style: daloyText(
                        DaloyFonts.serif,
                        m * 0.36,
                        FontWeight.w700,
                        height: 1.05,
                        letterSpacingEm: -0.03,
                      ).copyWith(color: ink),
                    ),
                  ),
                ),
              ),
            ] else
              Icon(TablerIcons.music, size: m * 0.26, color: ink.withValues(alpha: 0.9)),
            const Spacer(),
            if (caption != null)
              Text(
                caption!.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: small.copyWith(color: ink.withValues(alpha: 0.8), letterSpacing: 1.2),
              ),
          ],
        ),
      );
    }

    return ExcludeSemantics(
      child: FlowArtwork(
        seed: _seed,
        palette: paletteFor(songId),
        width: width,
        height: h,
        radius: m < 80 ? DaloyRadii.xl * m / 48 : m * 0.16,
        animate: animate,
        shadow: shadow,
        child: type,
      ),
    );
  }
}
