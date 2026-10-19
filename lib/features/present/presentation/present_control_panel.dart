import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../domain/present_deck.dart';
import 'present_slide_view.dart';

/// The operator's view while the slides are somewhere else (a projector, or
/// the device this one controls): what the room sees now, what's next, the
/// buttons, and every slide to jump to. The web's control panel.
class PresentControlPanel extends StatefulWidget {
  const PresentControlPanel({
    super.key,
    required this.deck,
    required this.onCommand,
    required this.status,
    this.aspectRatio = 16 / 9,
  });

  final PresentDeckState deck;
  final ValueChanged<PresentCommand> onCommand;

  /// Where the slides are showing: "On LG TV", "Controlling Ana's iPad".
  final String status;
  final double aspectRatio;

  @override
  State<PresentControlPanel> createState() => _PresentControlPanelState();
}

class _PresentControlPanelState extends State<PresentControlPanel> {
  final _currentKey = GlobalKey();

  @override
  void didUpdateWidget(PresentControlPanel old) {
    super.didUpdateWidget(old);
    if (old.deck.index != widget.deck.index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = _currentKey.currentContext;
        if (target != null && target.mounted) {
          Scrollable.ensureVisible(target, alignment: 0.3, duration: const Duration(milliseconds: 250));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deck = widget.deck;
    final wide = MediaQuery.sizeOf(context).width >= 720;

    final now = _Stage(deck: deck, status: widget.status, aspectRatio: widget.aspectRatio);
    final transport = _Transport(deck: deck, onCommand: widget.onCommand);
    final list = _SlideList(deck: deck, currentKey: _currentKey, onJump: (i) => widget.onCommand(PresentJump(i)));

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            // The buttons stay put; the previews scroll on a short screen.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s4, DaloySpace.s5, 0),
                    child: now,
                  ),
                ),
                Padding(padding: const EdgeInsets.all(DaloySpace.s4), child: transport),
              ],
            ),
          ),
          VerticalDivider(width: 1, color: context.colors.border),
          Expanded(flex: 2, child: list),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s2, DaloySpace.s4, 0), child: now),
        Padding(padding: const EdgeInsets.all(DaloySpace.s4), child: transport),
        Divider(height: 1, color: context.colors.border),
        Expanded(child: list),
      ],
    );
  }
}

/// The slide on the wall, and the next one smaller.
class _Stage extends StatelessWidget {
  const _Stage({required this.deck, required this.status, required this.aspectRatio});

  final PresentDeckState deck;
  final String status;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final current = deck.current;
    final next = deck.next;
    final caption = context.text.labelSmall!.copyWith(color: c.mutedForeground);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: deck.blanked ? c.mutedForeground : c.primary, shape: BoxShape.circle),
            ),
            const SizedBox(width: DaloySpace.s2),
            Expanded(
              child: Text(
                deck.blanked ? 'BLANK · $status'.toUpperCase() : status.toUpperCase(),
                style: caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (deck.slides.isNotEmpty) Text('${deck.index + 1} / ${deck.slides.length}', style: caption),
          ],
        ),
        const SizedBox(height: DaloySpace.s2),
        _Frame(
          aspectRatio: aspectRatio,
          child: PresentSlideView(slide: current, look: deck.look, blanked: deck.blanked, aspectRatio: aspectRatio),
        ),
        if (current != null) ...[
          const SizedBox(height: DaloySpace.s2),
          Text(
            [
              current.songTitle,
              if (current.displayKey case final k?) 'Key $k',
              ?current.tempo,
            ].where((s) => s.isNotEmpty).join(' · '),
            style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: DaloySpace.s3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 132,
              child: _Frame(
                aspectRatio: aspectRatio,
                dim: next == null,
                child: PresentSlideView(slide: next, look: deck.look, aspectRatio: aspectRatio, animate: false),
              ),
            ),
            const SizedBox(width: DaloySpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NEXT', style: caption),
                  const SizedBox(height: DaloySpace.s1),
                  Text(
                    next == null
                        ? 'End of the set'
                        : next.songIndex != current?.songIndex
                        ? next.songTitle
                        : (next.fullLabel.isEmpty ? next.previewLines(1).first : next.fullLabel),
                    style: context.text.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.aspectRatio, required this.child, this.dim = false});

  final double aspectRatio;
  final Widget child;
  final bool dim;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: aspectRatio,
    child: Opacity(
      opacity: dim ? 0.4 : 1,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: DaloyRadii.all(DaloyRadii.lg),
          border: Border.all(color: context.colors.border),
        ),
        child: ClipRRect(borderRadius: DaloyRadii.all(DaloyRadii.lg), child: child),
      ),
    ),
  );
}

class _Transport extends StatelessWidget {
  const _Transport({required this.deck, required this.onCommand});

  final PresentDeckState deck;
  final ValueChanged<PresentCommand> onCommand;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      DaloyButton.outline(
        label: 'Back',
        icon: TablerIcons.chevron_left,
        size: ControlSize.lg,
        onPressed: deck.hasPrev ? () => onCommand(const PresentPrev()) : null,
      ),
      const SizedBox(width: DaloySpace.s2),
      DaloyButton.outline(
        label: deck.blanked ? 'Show' : 'Blank',
        icon: deck.blanked ? TablerIcons.eye : TablerIcons.eye_off,
        size: ControlSize.lg,
        onPressed: () => onCommand(const PresentToggleBlank()),
      ),
      const SizedBox(width: DaloySpace.s2),
      Expanded(
        child: DaloyButton(
          label: 'Next',
          icon: TablerIcons.chevron_right,
          size: ControlSize.lg,
          expand: true,
          onPressed: deck.hasNext ? () => onCommand(const PresentNext()) : null,
        ),
      ),
    ],
  );
}

/// Every slide, grouped by song; tap one to put it up.
class _SlideList extends StatelessWidget {
  const _SlideList({required this.deck, required this.currentKey, required this.onJump});

  final PresentDeckState deck;
  final GlobalKey currentKey;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final songs = deck.songs;
    return CustomScrollView(
      slivers: [
        for (final (n, song) in songs.indexed) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s4, DaloySpace.s4, DaloySpace.s1),
              child: Text(
                ['${n + 1}. ${song.title}', ?song.displayKey].join(' · '),
                style: context.text.labelLarge!.copyWith(color: c.mutedForeground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SliverList.builder(
            itemCount: (n + 1 < songs.length ? songs[n + 1].firstSlide : deck.slides.length) - song.firstSlide,
            itemBuilder: (_, i) {
              final index = song.firstSlide + i;
              final slide = deck.slides[index];
              final current = index == deck.index;
              return Pressable(
                key: current ? currentKey : null,
                pressedScale: 0.99,
                onPressed: () => onJump(index),
                semanticLabel: 'Slide ${index + 1}${current ? ', showing' : ''}',
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2_5),
                  decoration: BoxDecoration(
                    color: current ? c.primary.withValues(alpha: 0.1) : null,
                    borderRadius: DaloyRadii.all(DaloyRadii.md),
                    border: Border.all(color: current ? c.primary.withValues(alpha: 0.5) : Colors.transparent),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (slide.fullLabel.isNotEmpty)
                        Text(
                          slide.fullLabel.toUpperCase(),
                          style: context.text.labelSmall!.copyWith(color: current ? c.primaryInk : c.mutedForeground),
                        ),
                      Text(
                        slide.lines.isEmpty ? 'No lyrics' : slide.previewLines().join(' / '),
                        style: context.text.bodyMedium!.copyWith(color: slide.lines.isEmpty ? c.mutedForeground : null),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: DaloySpace.s8)),
      ],
    );
  }
}
