import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';

/// A song's key as a small neutral chip — "E", "Bb", "C#m". Kept in its
/// written case (unlike `StatusChip`), and nothing at all when the song has
/// no key.
class SongKeyChip extends StatelessWidget {
  const SongKeyChip({super.key, required this.keyName});

  final String? keyName;

  /// The chip's height at the current text scale, for layouts that need a
  /// fixed size up front.
  static double height(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(_style(context).fontSize!) * _style(context).height! + 6;

  static TextStyle _style(BuildContext context) =>
      context.text.labelMedium!.weight(FontWeight.w600).copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  @override
  Widget build(BuildContext context) {
    final key = keyName?.trim().isNotEmpty == true ? keyName!.trim() : null;
    if (key == null) return const SizedBox.shrink();
    final c = context.colors;
    return Semantics(
      label: 'Key $key',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.sm)),
        child: Text(key, maxLines: 1, style: _style(context).copyWith(color: c.foreground)),
      ),
    );
  }
}
