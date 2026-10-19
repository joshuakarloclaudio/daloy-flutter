import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/mode_button.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../line_ups/domain/line_up.dart';
import '../../../line_ups/domain/live_session.dart';
import '../../../line_ups/presentation/widgets/line_up_cover.dart';

/// "Live now": the workspace's running performance — its cover, a teal
/// wash, and a way to join.
class LiveSessionCard extends StatelessWidget {
  const LiveSessionCard({
    super.key,
    required this.session,
    required this.lineUp,
    required this.onOpen,
    required this.onJoin,
  });

  final LiveSession session;

  /// Null when the line-up isn't cached yet (or we're offline).
  final LineUp? lineUp;
  final VoidCallback onOpen;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final title = lineUp?.title ?? 'Live performance';
    final subtitle = lineUp == null
        ? 'Line-up unavailable offline'
        : '${lineUp!.leader ?? 'Worship team'} · ${lineUpSongsLabel(lineUp!.songsCount)}';

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
        border: Border.all(color: c.primary.withValues(alpha: 0.25)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.alphaBlend(c.primary.withValues(alpha: 0.12), c.card), c.card, c.card],
          stops: const [0, 0.55, 1],
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Stack(
        children: [
          // Soft glow in the corner (`-top-8 -right-8 size-32 bg-primary/10 blur-2xl`).
          Positioned(top: -32, right: -32, child: _Glow(color: c.primary.withValues(alpha: 0.12), size: 128)),
          Padding(
            padding: const EdgeInsets.all(DaloySpace.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pressable(
                  onPressed: onOpen,
                  pressedScale: 0.99,
                  child: Row(
                    children: [
                      if (lineUp != null) ...[
                        LineUpCover(lineUp: lineUp!, keyFlow: const [], size: 88, animate: false),
                        const SizedBox(width: DaloySpace.s4),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StatusChip(
                              label: 'Live now',
                              color: c.primaryInk,
                              background: c.primary.withValues(alpha: 0.15),
                              pulse: true,
                            ),
                            const SizedBox(height: DaloySpace.s2),
                            Text(
                              title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.headlineSmall,
                            ),
                            const SizedBox(height: DaloySpace.s1),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DaloySpace.s5),
                Row(
                  children: [
                    Expanded(
                      child: ModeButton(
                        icon: TablerIcons.player_play_filled,
                        label: 'Join performance',
                        filled: true,
                        height: ControlSize.lg.height,
                        onPressed: onJoin,
                      ),
                    ),
                    const SizedBox(width: DaloySpace.s3),
                    _ParticipantsPill(count: session.participantCount),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantsPill extends StatelessWidget {
  const _ParticipantsPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.background.withValues(alpha: 0.7),
        border: Border.all(color: c.border.withValues(alpha: 0.6)),
        borderRadius: DaloyRadii.all(DaloyRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(TablerIcons.users, size: 14, color: c.mutedForeground),
          const SizedBox(width: DaloySpace.s1_5),
          Text(peopleLabel(count), style: context.text.labelMedium!.copyWith(color: c.mutedForeground)),
        ],
      ),
    );
  }
}

/// A blurred colored disc, drawn as a radial gradient (cheap, no backdrop).
class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    ),
  );
}
