import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/pressable.dart';
import '../../perform/application/perform_controller.dart';
import '../../perform/presentation/widgets/perform_chrome.dart';
import '../application/music_player_controller.dart';
import 'mini_player.dart';
import 'player_controls.dart';
import 'player_video_slot.dart';

/// The capsule's height.
const _height = 56.0;

/// What the strip covers: the capsule and the gap under it.
const performPlayerStripHeight = _height + performChromeGap;

/// Playing along in Perform and Practice: the video, small, in a floating
/// capsule above the transport — it stays when the chrome hides, dropping
/// to the bottom, since the video can't play unseen. Drawn like the mini
/// player (Play/Pause ringed by the song's progress), in Perform's glass.
/// Tap the video or the title to open the player up.
class PerformPlayerStrip extends ConsumerWidget {
  const PerformPlayerStrip({super.key, required this.source});

  /// The set on screen: when it's what's playing, say where in it.
  final PerformSource source;

  /// The video's height, at 16:9.
  static const _video = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final player = ref.watch(musicPlayerProvider);
    final track = player.current;
    if (track == null) return const SizedBox.shrink();
    final controller = ref.read(musicPlayerProvider.notifier);
    final linked = player.isPlayingFrom(source);
    final wide = MediaQuery.sizeOf(context).width >= DaloyBreakpoints.tablet;
    final subtitle = !linked
        ? 'Playing from ${player.title ?? 'another set'}'
        : player.tracks.length > 1
        ? 'Playing along · ${track.number} of ${player.tracks.length}'
        : 'Playing along';

    return PerformBottomDock(
      child: PerformFloating(
        child: SizedBox(
          height: _height,
          child: Padding(
            padding: const EdgeInsets.only(left: DaloySpace.s2, right: DaloySpace.s1),
            child: Row(
              children: [
                Expanded(
                  child: Pressable(
                    pressedScale: 0.99,
                    semanticLabel: 'Open the player',
                    onPressed: () => expandPlayer(context, ref),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _video * 16 / 9,
                          height: _video,
                          child: PlayerVideoSlot(
                            // Inside the capsule's round end.
                            borderRadius: DaloyRadii.all(DaloyRadii.xl),
                            onTap: () => expandPlayer(context, ref),
                          ),
                        ),
                        const SizedBox(width: DaloySpace.s2_5),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.titleSmall!.copyWith(color: c.foreground),
                              ),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PlayerButton(
                  icon: TablerIcons.player_skip_back_filled,
                  tooltip: 'Previous',
                  size: 36,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    unawaited(controller.previous());
                  },
                ),
                const PlayerPlayPauseRing(),
                PlayerButton(
                  icon: TablerIcons.player_skip_forward_filled,
                  tooltip: 'Next',
                  size: 36,
                  onPressed: player.hasNext
                      ? () {
                          HapticFeedback.selectionClick();
                          controller.next();
                        }
                      : null,
                ),
                if (wide)
                  PlayerButton(
                    icon: TablerIcons.x,
                    tooltip: 'Close player',
                    size: 36,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      controller.close();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
