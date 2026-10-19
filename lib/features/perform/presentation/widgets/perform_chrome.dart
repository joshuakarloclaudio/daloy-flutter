import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_button.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../application/perform_controller.dart';
import '../../domain/perform_sections.dart';
import '../../domain/perform_theme.dart';
import 'perform_sheets.dart';
import 'perform_themed.dart';

/// The row of section chips under the top bar.
const performChipsHeight = 44.0;

/// The transport capsule's height.
const performTransportHeight = 64.0;

/// Air between the floating chrome and the screen's edge, and between pieces.
const performChromeGap = DaloySpace.s2;

/// How far the floating chrome sits in from the sides.
const performChromeSide = DaloySpace.s3;

/// The bottom pieces stay a thumb's width on a tablet, not the screen's.
const performDockMaxWidth = 720.0;

/// What the top chrome covers under the status bar: the bar's capsule and
/// the chips' row (room is kept for it on a song without any).
const performTopChromeHeight = performChromeGap + DaloyChrome.topBarHeight + performChromeGap + performChipsHeight;

/// What the transport covers above the home indicator: the capsule and the
/// gap under it.
const performBottomChromeHeight = performTransportHeight + performChromeGap;

/// A floating piece of Perform's chrome: frosted, rounded, edged and lifted
/// off the chart — solid and flat on e-ink.
class PerformFloating extends StatelessWidget {
  const PerformFloating({super.key, required this.child, this.radius = DaloyRadii.full});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) => PerformGlass(
    borderRadius: DaloyRadii.all(radius),
    border: Border.all(color: context.colors.border),
    shadow: true,
    child: child,
  );
}

/// Docks [child] at the bottom: in from the sides, clear of the home
/// indicator, no wider than [performDockMaxWidth].
class PerformBottomDock extends StatelessWidget {
  const PerformBottomDock({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        performChromeSide + padding.left,
        0,
        performChromeSide + padding.right,
        padding.bottom + performChromeGap,
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: performDockMaxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Slides chrome off its edge and fades it; nothing under it moves.
class PerformChromeSlide extends StatelessWidget {
  const PerformChromeSlide({super.key, required this.visible, required this.fromTop, required this.child});

  final bool visible;
  final bool fromTop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final still = PerformPaletteScope.of(context).flat || MediaQuery.disableAnimationsOf(context);
    final duration = still ? Duration.zero : DaloyMotion.medium;
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : Offset(0, fromTop ? -1 : 1),
          duration: duration,
          curve: DaloyMotion.ease,
          child: AnimatedOpacity(opacity: visible ? 1 : 0, duration: duration, child: child),
        ),
      ),
    );
  }
}

/// Stays in the corner while the chrome is hidden: where you are in the set,
/// and one tap brings the chrome back. Quiet enough to sit over the chart.
class PerformChromeHandle extends StatelessWidget {
  const PerformChromeHandle({
    super.key,
    required this.visible,
    required this.label,
    required this.live,
    required this.onPressed,
  });

  final bool visible;
  final String? label;
  final bool live;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final palette = PerformPaletteScope.of(context);
    final still = palette.flat || MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: still ? Duration.zero : DaloyMotion.medium,
          child: Pressable(
            onPressed: onPressed,
            semanticLabel: 'Show controls',
            // A comfortable target around a small pill.
            child: Padding(
              padding: const EdgeInsets.all(DaloySpace.s1),
              child: PerformGlass(
                borderRadius: DaloyRadii.all(DaloyRadii.full),
                border: Border.all(color: c.border),
                child: SizedBox(
                  height: 36,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (live) ...[
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(color: palette.highlight, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: DaloySpace.s1_5),
                        ],
                        if (label != null) ...[
                          Text(
                            label!,
                            style: context.text.labelMedium!.copyWith(
                              color: c.mutedForeground,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: DaloySpace.s1_5),
                        ],
                        Icon(TablerIcons.dots, size: 16, color: c.mutedForeground),
                      ],
                    ),
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

/// Close, where you are in the set, and the panels; the current song's
/// sections underneath. The bar is a floating capsule (one blur, not one per
/// button); the chips float on their own in a row beneath it, scrolling
/// edge to edge. A song with fewer than two sections has no chips.
class PerformTopBar extends StatelessWidget {
  const PerformTopBar({
    super.key,
    required this.state,
    required this.onClose,
    required this.onOpenSetlist,
    required this.onOpenSettings,
    required this.onSelectSection,
    this.live,
    this.mode = 'Perform',
    this.onLoopSection,
    this.loopSectionId,
    this.onPlayAlong,
    this.onOpenCues,
    this.cuesOpen = false,
    this.unreadCues = 0,
    this.cuesTyping = false,
  });

  final PerformState state;

  /// The cues chat, while in a live session.
  final VoidCallback? onOpenCues;

  /// The docked cue panel is showing.
  final bool cuesOpen;

  /// Cues from the team since the chat was last open.
  final int unreadCues;

  /// Someone on the team is typing a cue.
  final bool cuesTyping;

  /// Starts the set's YouTube videos playing along; null when there are none,
  /// or they already are.
  final VoidCallback? onPlayAlong;

  /// "Perform" or "Practice": the fallback title and what closing leaves.
  final String mode;

  /// Practice: a long press on a chip loops that section.
  final ValueChanged<String>? onLoopSection;
  final String? loopSectionId;
  final VoidCallback onClose;
  final VoidCallback? onOpenSetlist;
  final VoidCallback onOpenSettings;
  final ValueChanged<String> onSelectSection;

  /// The live session control, before the panels.
  final Widget? live;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final current = state.current;
    final sections = current?.sections ?? const <PerformSection>[];

    final padding = MediaQuery.paddingOf(context);
    final sides = EdgeInsets.only(left: performChromeSide + padding.left, right: performChromeSide + padding.right);
    return Padding(
      padding: EdgeInsets.only(top: padding.top + performChromeGap),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: sides,
            child: PerformFloating(
              child: SizedBox(
                height: DaloyChrome.topBarHeight,
                child: Row(
                  children: [
                    const SizedBox(width: DaloySpace.s1),
                    TopBarIconButton(icon: TablerIcons.x, tooltip: 'Leave $mode', onPressed: onClose),
                    const SizedBox(width: DaloySpace.s1),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.title ?? mode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleSmall!.weight(FontWeight.w600),
                          ),
                          if (state.songs.length > 1)
                            Text(
                              '${state.songIndex + 1} of ${state.songs.length} · ${current?.row.title ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                            ),
                        ],
                      ),
                    ),
                    ?live,
                    if (onOpenCues != null)
                      _CuesButton(open: cuesOpen, unread: unreadCues, typing: cuesTyping, onPressed: onOpenCues!),
                    if (onPlayAlong != null)
                      TopBarIconButton(
                        icon: TablerIcons.brand_youtube,
                        tooltip: 'Play along with YouTube',
                        onPressed: onPlayAlong,
                      ),
                    if (onOpenSetlist != null)
                      TopBarIconButton(icon: TablerIcons.list_numbers, tooltip: 'Setlist', onPressed: onOpenSetlist),
                    TopBarIconButton(
                      icon: TablerIcons.adjustments_horizontal,
                      tooltip: 'Display',
                      onPressed: onOpenSettings,
                    ),
                    const SizedBox(width: DaloySpace.s1),
                  ],
                ),
              ),
            ),
          ),
          if (sections.length >= 2) ...[
            const SizedBox(height: performChromeGap),
            SizedBox(
              height: performChipsHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                // The chips' shadows run past the row.
                clipBehavior: Clip.none,
                // Edge to edge as it scrolls; at rest the first chip lines up
                // with the bar above.
                padding: sides,
                itemCount: sections.length,
                separatorBuilder: (_, _) => const SizedBox(width: DaloySpace.s1_5),
                itemBuilder: (context, i) => Center(
                  child: PerformChip(
                    label: sectionChipLabel(sections[i], i),
                    active: sections[i].id == state.activeSectionId,
                    looping: sections[i].id == loopSectionId,
                    floating: true,
                    onPressed: () => onSelectSection(sections[i].id),
                    onLongPress: onLoopSection == null ? null : () => onLoopSection!(sections[i].id),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Previous · the song (tap for the setlist) · next, at the thumb: a
/// floating capsule over the bottom of the chart.
class PerformTransport extends StatelessWidget {
  const PerformTransport({
    super.key,
    required this.state,
    required this.onPrev,
    required this.onNext,
    required this.onOpenSetlist,
  });

  final PerformState state;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback? onOpenSetlist;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final current = state.current;
    final next = state.next;

    return PerformBottomDock(
      child: PerformFloating(
        child: SizedBox(
          height: performTransportHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s1_5),
            child: Row(
              children: [
                _StepButton(
                  icon: TablerIcons.player_skip_back,
                  tooltip: 'Previous song',
                  onPressed: state.hasPrev ? onPrev : null,
                ),
                Expanded(
                  child: Pressable(
                    pressedScale: 0.98,
                    onPressed: onOpenSetlist,
                    semanticLabel: onOpenSetlist == null ? null : 'Open setlist',
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          current?.row.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall!.weight(FontWeight.w600),
                        ),
                        Text(
                          next == null ? (state.songs.length > 1 ? 'Last song' : ' ') : 'Next: ${next.row.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ),
                _StepButton(
                  icon: TablerIcons.player_skip_forward,
                  tooltip: 'Next song',
                  onPressed: state.hasNext ? onNext : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onPressed: onPressed,
      semanticLabel: tooltip,
      child: SizedBox.square(
        dimension: 52,
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onPressed == null ? Colors.transparent : c.muted.withValues(alpha: 0.8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: onPressed == null ? c.mutedForeground.withValues(alpha: 0.4) : c.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

/// The top bar's way into the cues chat: lit while the panel is docked open,
/// a dot when the team has said something since you last looked.
class _CuesButton extends StatelessWidget {
  const _CuesButton({required this.open, required this.unread, required this.typing, required this.onPressed});

  final bool typing;
  final bool open;
  final int unread;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (open)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.18), shape: BoxShape.circle),
          ),
        TopBarIconButton(
          icon: open ? TablerIcons.message_circle_filled : TablerIcons.message_circle,
          tooltip: unread > 0 ? 'Cues, $unread new' : 'Cues',
          onPressed: onPressed,
        ),
        if (typing && unread == 0)
          Positioned(
            top: 6,
            right: 4,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: c.primaryInk,
                  borderRadius: DaloyRadii.all(DaloyRadii.full),
                  border: Border.all(color: c.card, width: 1.5),
                ),
                child: Icon(TablerIcons.dots, size: 12, color: c.primaryForeground),
              ),
            ),
          ),
        if (unread > 0)
          Positioned(
            top: 8,
            right: 8,
            child: IgnorePointer(
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: c.primaryInk,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.card, width: 1.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
