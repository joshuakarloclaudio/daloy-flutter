import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_glass.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shell/floating_tab_bar.dart';
import '../../perform/application/perform_controller.dart';
import '../application/music_player_controller.dart';
import 'player_controls.dart';
import 'player_video_slot.dart';

/// The now-playing screen for what [source] names.
String listenRoute(PerformSource source) => switch (source) {
  LineUpSource(:final id) => Routes.listen(id),
  SongSource(:final id) => Routes.songListen(id),
};

/// Opens the player up to the now-playing screen.
void expandPlayer(BuildContext context, WidgetRef ref) {
  final source = ref.read(musicPlayerProvider).source;
  if (source == null) return;
  unawaited(HapticFeedback.lightImpact());
  unawaited(context.push(listenRoute(source)));
}

/// The mini player: docked under the screen while something plays, so the
/// song carries on from screen to screen. A floating glass capsule like the
/// live bar — same height, same side inset — in the layout so it never
/// covers content. The video stays on screen (YouTube's terms), small, on
/// the left; how far the song has played rings Play/Pause. A tap (or a
/// swipe up) opens the now-playing screen.
class MiniPlayerBar extends ConsumerWidget {
  const MiniPlayerBar({super.key, this.safeBottom = false});

  /// Pad for the home indicator — when nothing sits below the bar.
  final bool safeBottom;

  static const height = 52.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(musicPlayerProvider.select((s) => s.isOpen));
    return AnimatedSize(
      duration: DaloyMotion.medium,
      curve: DaloyMotion.ease,
      alignment: Alignment.bottomCenter,
      child: open ? _Bar(safeBottom: safeBottom) : const SizedBox(width: double.infinity),
    );
  }
}

class _Bar extends ConsumerWidget {
  const _Bar({required this.safeBottom});

  final bool safeBottom;

  /// The video's height: the live bar's 36pt badge, at 16:9.
  static const _video = 36.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final player = ref.watch(musicPlayerProvider);
    final track = player.current!;
    final controller = ref.read(musicPlayerProvider.notifier);
    final subtitle = player.tracks.length > 1
        ? '${track.number} of ${player.tracks.length} · ${player.title ?? ''}'
        : (track.artist ?? player.title ?? '');

    return Semantics(
      container: true,
      label: 'Now playing: ${track.title}',
      child: SafeArea(
        top: false,
        bottom: safeBottom,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            FloatingGlassTabBar.side,
            DaloySpace.s2,
            FloatingGlassTabBar.side,
            DaloySpace.s2,
          ),
          child: GestureDetector(
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0) < -300) expandPlayer(context, ref);
            },
            child: DaloyGlass.capsule(
              child: SizedBox(
                height: MiniPlayerBar.height,
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
                                    if (subtitle.isNotEmpty)
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
          ),
        ),
      ),
    );
  }
}

/// A full-screen route with the mini player docked beneath it, for the
/// screens that cover the tab shell (song and line-up details, editors).
/// While the bar shows, it takes the home-indicator inset, so [child]
/// doesn't pad for it twice.
class MiniPlayerFrame extends ConsumerWidget {
  const MiniPlayerFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.watch(musicPlayerProvider.select((s) => s.isOpen));
    return ColoredBox(
      color: context.colors.background,
      child: Column(
        children: [
          Expanded(
            child: open ? MediaQuery.removePadding(context: context, removeBottom: true, child: child) : child,
          ),
          const MiniPlayerBar(safeBottom: true),
        ],
      ),
    );
  }
}
