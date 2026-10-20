import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/platform.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/status_chip.dart';
import '../application/song_sync.dart';
import '../domain/song.dart';
import 'widgets/song_key_chip.dart';
import 'widgets/song_sync_badge.dart';

/// One song in a list (`SongListRow`): title and artist, with the key in
/// serif down the right edge. Edge to edge with its own padding so the press
/// highlight fills the row; the parent draws the dividers.
class SongListRow extends StatelessWidget {
  const SongListRow({
    super.key,
    required this.song,
    required this.onTap,
    required this.menu,
    this.sync,
    this.highlighted = false,
  });

  final Song song;
  final VoidCallback onTap;
  final List<DaloyMenuItem> Function() menu;

  /// Where the song stands with the server; null when it's plainly synced.
  final SongSync? sync;

  /// Briefly tints the row — "here's the song you just added".
  final bool highlighted;

  /// Pins every line to the primary font's metrics. Emoji and bullets come
  /// from fallback fonts with taller lines, which would otherwise push a row
  /// past its fixed extent.
  static StrutStyle _strut(TextStyle style) => StrutStyle(
    fontFamily: style.fontFamily,
    fontSize: style.fontSize,
    height: style.height,
    leadingDistribution: style.leadingDistribution,
    forceStrutHeight: true,
  );

  /// The height a row lays out to at the current text scale, so a long list
  /// can use fixed-extent slivers (no per-row layout probing, exact jumps).
  static double extent(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final c = context.colors;
    double line(TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: 'Ag', style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        strutStyle: _strut(style),
        maxLines: 1,
      )..layout();
      final height = painter.height;
      painter.dispose();
      return height;
    }

    final text = context.text;
    // The title line also holds the "Public" chip (label + 2×3 padding).
    final title = math.max(line(text.titleMedium!), line(text.labelSmall!) + 6);
    final subtitle = line(text.bodyMedium!.copyWith(color: c.mutedForeground, height: 1.3));
    return title + 2 + subtitle + DaloySpace.s3 * 2;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subtitle = song.artist?.isNotEmpty == true ? song.artist! : 'Unknown artist';

    final isApple = Theme.of(context).platform.isApple;
    // No overflow button: touch and hold opens the actions, and screen readers
    // get each one as a custom action.
    return DaloyContextMenu(
      items: menu,
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            // iOS cells highlight on press; Android ripples.
            splashFactory: isApple ? NoSplash.splashFactory : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s3),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                song.title,
                                style: context.text.titleMedium,
                                strutStyle: _strut(context.text.titleMedium!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SongSyncBadge(sync: sync),
                            if (song.isPublic) ...[
                              const SizedBox(width: DaloySpace.s2),
                              StatusChip(
                                label: 'Shared',
                                color: c.primaryInk,
                                background: c.primary.withValues(alpha: 0.1),
                                dense: true,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: context.text.bodyMedium!.copyWith(color: c.mutedForeground, height: 1.3),
                          strutStyle: _strut(context.text.bodyMedium!.copyWith(height: 1.3)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: DaloySpace.s3),
                  SongKeyChip(keyName: song.key),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: highlighted ? 1 : 0,
                duration: DaloyMotion.fast,
                child: ColoredBox(color: c.primary.withValues(alpha: 0.12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
