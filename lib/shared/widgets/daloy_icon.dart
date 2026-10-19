import 'package:flutter/widgets.dart';

/// [Icon], corrected for icon-font glyphs on combining-mark codepoints.
///
/// Tabler puts a few filled icons (`home_filled`, `key_filled`,
/// `layout_cards_filled`, …) on U+FE20–FE2F, which Unicode reserves for
/// combining half marks. The text shaper gives those zero width and hangs
/// them off the previous character, so a plain [Icon] draws them half its
/// size to the left of its box (the zero-width glyph is centred, and its ink
/// ends at that centre). This shifts them back.
class DaloyIcon extends StatelessWidget {
  const DaloyIcon(this.icon, {super.key, this.size, this.color, this.semanticLabel});

  final IconData icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  static bool _isCombiningMark(int codePoint) => codePoint >= 0xFE20 && codePoint <= 0xFE2F;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(icon, size: size, color: color, semanticLabel: semanticLabel);
    if (!_isCombiningMark(icon.codePoint)) return glyph;
    final resolvedSize = size ?? IconTheme.of(context).size ?? 24;
    return Transform.translate(offset: Offset(resolvedSize / 2, 0), child: glyph);
  }
}
