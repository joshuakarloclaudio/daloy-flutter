import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/daloy_menu.dart';
import '../../../../shared/widgets/mode_button.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../line_ups/domain/line_up.dart';
import '../../../line_ups/presentation/widgets/line_up_cover.dart';

/// "Up next" (`LineUpFeaturedCard`): the line-up's cover beside its name,
/// then Perform and Practice. Its state shows in a full tinted border
/// and a soft wash — never a colored side stripe:
/// - **Today**: emerald border, emerald→teal wash, floating glow orbs, the
///   pulsing Live Glow, and an emerald Perform button.
/// - **Tomorrow**: teal-tinted border and wash.
/// - Otherwise: plain card with the date.
class FeaturedLineUpCard extends StatelessWidget {
  const FeaturedLineUpCard({
    super.key,
    required this.lineUp,
    required this.onOpen,
    required this.onGoLive,
    required this.onPractice,
    required this.menu,
  });

  final LineUp lineUp;
  final VoidCallback onOpen;
  final VoidCallback onGoLive;
  final VoidCallback onPractice;
  final List<DaloyMenuItem> Function() menu;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chip = lineUpDayChip(lineUp.date);
    final isToday = chip == DayChip.today;
    final isTomorrow = chip == DayChip.tomorrow;

    final body = Padding(
      padding: const EdgeInsets.all(DaloySpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pressable(
            onPressed: onOpen,
            pressedScale: 0.99,
            child: Row(
              children: [
                // The same cover the line-up's page leads with, so the card
                // and the page it opens read as one thing.
                LineUpCover(lineUp: lineUp, keyFlow: const [], size: 96, animate: false),
                const SizedBox(width: DaloySpace.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      switch (chip) {
                        DayChip.today => StatusChip(
                          label: 'Today',
                          color: c.todayInk,
                          background: c.today.withValues(alpha: 0.15),
                          pulse: true,
                        ),
                        DayChip.tomorrow => StatusChip(
                          label: 'Tomorrow',
                          color: c.primaryInk,
                          background: c.primary.withValues(alpha: 0.12),
                        ),
                        null => Text(
                          formatLineUpDate(lineUp.date),
                          style: context.text.titleSmall!.copyWith(color: c.mutedForeground),
                        ),
                      },
                      const SizedBox(height: DaloySpace.s2),
                      Text.rich(
                        TextSpan(
                          text: lineUp.title,
                          children: [
                            if (lineUp.isEmpty)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: DaloySpace.s2),
                                  child: StatusChip.muted(context, 'Empty'),
                                ),
                              ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.headlineSmall,
                      ),
                      const SizedBox(height: DaloySpace.s1),
                      Text(
                        '${lineUp.leader ?? 'No worship leader yet'} · ${lineUpSongsLabel(lineUp.songsCount)}',
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
                  icon: TablerIcons.broadcast,
                  label: 'Go live',
                  filled: true,
                  today: isToday,
                  height: ControlSize.lg.height,
                  onPressed: onGoLive,
                ),
              ),
              const SizedBox(width: DaloySpace.s2),
              Expanded(
                child: ModeButton(
                  icon: TablerIcons.metronome,
                  label: 'Practice',
                  height: ControlSize.lg.height,
                  onPressed: onPractice,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // No overflow button: touch and hold (or a right click) opens the
    // actions, lifting the whole card, and screen readers get each one as a
    // custom action.
    final card = isToday ? _TodayFrame(child: body) : _card(c, isTomorrow, body);
    return DaloyContextMenu(items: menu, previewRadius: DaloyRadii.xl2, child: card);
  }

  Widget _card(DaloyColors c, bool isTomorrow, Widget body) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
        border: Border.all(color: isTomorrow ? c.primary.withValues(alpha: 0.3) : c.border.withValues(alpha: 0.7)),
        color: isTomorrow ? null : c.card,
        gradient: isTomorrow
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.alphaBlend(c.primary.withValues(alpha: 0.05), c.card), c.card, c.card],
                stops: const [0, 0.55, 1],
              )
            : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: body,
    );
  }
}

/// Emerald wash, drifting glow orbs and the pulsing Live Glow — reserved
/// for the one line-up happening today.
class _TodayFrame extends StatefulWidget {
  const _TodayFrame({required this.child});

  final Widget child;

  @override
  State<_TodayFrame> createState() => _TodayFrameState();
}

class _TodayFrameState extends State<_TodayFrame> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value * 2 * math.pi;
        final glow = 0.5 + 0.5 * math.sin(t * 2.5); // ~2s breathing
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: DaloyRadii.all(DaloyRadii.xl2),
            border: Border.all(color: c.todayBorder),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.alphaBlend(c.todayWashFrom, c.card), c.card, Color.alphaBlend(c.todayWashTo, c.card)],
            ),
            boxShadow: [
              BoxShadow(color: c.today.withValues(alpha: 0.35 + 0.25 * glow), spreadRadius: 1),
              BoxShadow(
                color: c.today.withValues(alpha: 0.25 + 0.2 * glow),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -32 + 8 * math.sin(t),
                right: -32 + 6 * math.cos(t),
                child: _Orb(color: c.todayOrb, size: 160),
              ),
              Positioned(
                bottom: -40 + 8 * math.cos(t * 0.8),
                left: -24 + 6 * math.sin(t * 0.8),
                child: _Orb(color: c.todayOrbAlt, size: 128),
              ),
              child!,
            ],
          ),
        );
      },
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});

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
