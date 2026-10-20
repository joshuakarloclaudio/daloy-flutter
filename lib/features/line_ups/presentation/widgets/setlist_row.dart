import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../core/utils/platform.dart';
import '../../../../shared/widgets/daloy_menu.dart';
import '../../application/line_up_detail_controller.dart';

/// One song in a line-up's set: its number, title, artist and tempo, how
/// many team notes it carries, and the key it's played in at this service.
/// Tap to preview the chart; long-press for more.
class SetlistRow extends StatelessWidget {
  const SetlistRow({super.key, required this.song, required this.onTap, required this.menu, this.showDivider = true});

  final SetlistSong song;
  final VoidCallback onTap;
  final List<DaloyMenuItem> Function() menu;

  /// Hairline under the row, inset to the title column.
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subtitle = [?song.artist, ?song.tempo].join(' · ');
    final isApple = Theme.of(context).platform.isApple;

    return DaloyContextMenu(
      items: menu,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        splashFactory: isApple ? NoSplash.splashFactory : null,
        child: Padding(
          padding: const EdgeInsets.only(left: DaloySpace.s1),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  '${song.number}',
                  textAlign: TextAlign.center,
                  style: daloyText(
                    DaloyFonts.serif,
                    15,
                    FontWeight.w600,
                    height: 1,
                  ).copyWith(color: c.mutedForeground, fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ),
              const SizedBox(width: DaloySpace.s2),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 64),
                  padding: const EdgeInsets.fromLTRB(0, DaloySpace.s3, DaloySpace.s1, DaloySpace.s3),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: showDivider ? c.border : Colors.transparent)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              song.title,
                              style: context.text.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodyMedium!.copyWith(color: c.mutedForeground, height: 1.3),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (song.entry.notes.isNotEmpty) ...[
                        const SizedBox(width: DaloySpace.s2),
                        _NotesBadge(count: song.entry.notes.length),
                      ],
                      if (song.displayKey != null) ...[
                        const SizedBox(width: DaloySpace.s2),
                        KeyBadge(keyName: song.displayKey!, highlighted: song.isTransposed, capo: song.capo),
                      ],
                      const SizedBox(width: DaloySpace.s1),
                      Icon(TablerIcons.chevron_right, size: 18, color: c.mutedForeground.withValues(alpha: 0.6)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The key a song is played in. Teal when it differs from how it's written;
/// a capo rides along underneath.
class KeyBadge extends StatelessWidget {
  const KeyBadge({super.key, required this.keyName, this.highlighted = false, this.capo = 0});

  final String keyName;
  final bool highlighted;
  final int capo;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final badge = Container(
      constraints: const BoxConstraints(minWidth: 34),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlighted ? c.primary.withValues(alpha: 0.12) : c.muted,
        borderRadius: DaloyRadii.all(DaloyRadii.md),
      ),
      child: Text(
        keyName,
        textAlign: TextAlign.center,
        style: context.text.labelLarge!.copyWith(
          color: highlighted ? c.primaryInk : c.foreground,
          fontWeight: FontWeight.w700,
          fontVariations: const [FontVariation.weight(700)],
        ),
      ),
    );
    final label = capo > 0 ? 'Key of $keyName, capo $capo' : 'Key of $keyName';
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: capo == 0
          ? badge
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                badge,
                const SizedBox(height: 2),
                Text('Capo $capo', style: context.text.labelMedium!.copyWith(color: c.mutedForeground, fontSize: 10.5)),
              ],
            ),
    );
  }
}

class _NotesBadge extends StatelessWidget {
  const _NotesBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: count == 1 ? '1 note' : '$count notes',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: c.primary.withValues(alpha: 0.1),
          borderRadius: DaloyRadii.all(DaloyRadii.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(TablerIcons.notes, size: 12, color: c.primaryInk),
            const SizedBox(width: 3),
            Text(
              '$count',
              style: context.text.labelMedium!.copyWith(
                color: c.primaryInk,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
