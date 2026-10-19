import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/connectivity/online_status.dart';
import '../core/router/routes.dart';
import '../core/theme/daloy_theme.dart';
import '../core/utils/formatters.dart';
import '../features/line_ups/data/line_ups_repository.dart';
import '../shared/widgets/daloy_glass.dart';
import '../shared/widgets/pressable.dart';
import '../shared/widgets/status_chip.dart';
import 'floating_tab_bar.dart';

/// "Live now", docked above the tab bar so a running performance is one tap
/// from anywhere in the shell — the twin of the web's `LiveSessionStrip`. A
/// floating glass capsule that lines up with the tab bar's side inset, like
/// the other floating chrome, and sits in the layout (the accessory slot) so
/// it never covers content.
///
/// Home already leads with the full Live card, so [hidden] drops the bar there.
class LiveSessionBar extends ConsumerWidget {
  const LiveSessionBar({super.key, this.hidden = false});

  final bool hidden;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(isOnlineProvider);
    final session = online && !hidden ? ref.watch(activeLiveSessionProvider).value : null;
    final lineUps = session == null ? null : ref.watch(workspaceLineUpsProvider).value;
    final lineUp = lineUps?.where((l) => l.id == session!.lineUpId).firstOrNull;

    return AnimatedSize(
      duration: DaloyMotion.medium,
      curve: DaloyMotion.ease,
      alignment: Alignment.bottomCenter,
      child: session == null
          ? const SizedBox(width: double.infinity)
          : _Bar(
              title: lineUp?.title ?? 'Live performance',
              participants: session.participantCount,
              onOpen: () => context.push(Routes.lineUp(session.lineUpId)),
              onJoin: () => context.push(Routes.perform(session.lineUpId)),
            ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.title, required this.participants, required this.onOpen, required this.onJoin});

  final String title;
  final int participants;
  final VoidCallback onOpen;
  final VoidCallback onJoin;

  static const _height = 52.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      container: true,
      liveRegion: true,
      label: '$title is live',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FloatingGlassTabBar.side,
          DaloySpace.s2,
          FloatingGlassTabBar.side,
          DaloySpace.s2,
        ),
        child: DaloyGlass.capsule(
          child: SizedBox(
            height: _height,
            child: Padding(
              padding: const EdgeInsets.only(left: DaloySpace.s2, right: DaloySpace.s1_5),
              child: Row(
                children: [
                  Expanded(
                    child: Pressable(
                      onPressed: onOpen,
                      pressedScale: 0.99,
                      semanticLabel: 'Open $title',
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: c.primary.withValues(alpha: 0.14)),
                            child: PulseDot(color: c.primaryInk, size: 8),
                          ),
                          const SizedBox(width: DaloySpace.s2_5),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleSmall!.copyWith(color: c.foreground),
                                ),
                                Text(
                                  'Live now · ${peopleLabel(participants)}',
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
                  const SizedBox(width: DaloySpace.s2),
                  Pressable(
                    onPressed: onJoin,
                    semanticLabel: 'Join $title',
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: c.primary, borderRadius: DaloyRadii.all(DaloyRadii.full)),
                      child: Text('Join', style: context.text.labelLarge!.copyWith(color: c.primaryForeground)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
