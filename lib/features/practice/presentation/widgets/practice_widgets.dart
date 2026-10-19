import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_button.dart';
import '../../../../shared/widgets/daloy_toast.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../perform/application/perform_controller.dart';
import '../../../perform/domain/perform_theme.dart';
import '../../../perform/presentation/widgets/perform_chrome.dart';
import '../../../perform/presentation/widgets/perform_sheets.dart';
import '../../../perform/presentation/widgets/perform_themed.dart';
import '../../../songs/domain/new_song.dart';
import '../../../songs/domain/tap_tempo.dart';
import '../../../songs/presentation/widgets/stepper_track.dart';
import '../../application/practice_controller.dart';
import '../../domain/practice_clock.dart';
import 'listenable_selector.dart';

// -- Transport -----------------------------------------------------------------

/// Practice's transport, a floating capsule like Perform's: the click switch
/// and the way back (previous song, or restart) on the left, Play/Pause in
/// the middle, the tempo and the way on to the right. Play/Pause runs the chart; the click is its own switch.
class PracticeTransport extends ConsumerWidget {
  const PracticeTransport({
    super.key,
    required this.source,
    required this.onPlay,
    required this.onPrev,
    required this.onNext,
    required this.onOpenTempo,
  });

  final PerformSource source;
  final VoidCallback onPlay;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback onOpenTempo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final practice = ref.watch(practiceControllerProvider(source));
    final controller = ref.read(practiceControllerProvider(source).notifier);
    final perform = ref.watch(performControllerProvider(source));
    final single = perform.songs.length < 2;

    return PerformBottomDock(
      child: PerformFloating(
        child: SizedBox(
          height: performTransportHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s1_5),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (single)
                        PracticeRoundButton(
                          icon: TablerIcons.arrow_back_up,
                          tooltip: 'Back to the top',
                          onPressed: controller.restart,
                        )
                      else
                        PracticeRoundButton(
                          icon: TablerIcons.player_skip_back,
                          tooltip: 'Previous song',
                          onPressed: onPrev,
                        ),
                      PracticeRoundButton(
                        icon: practice.clickOn ? TablerIcons.metronome : TablerIcons.volume_off,
                        tooltip: practice.clickOn ? 'Mute the click' : 'Turn the click on',
                        selected: practice.clickOn,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          unawaited(controller.setClick(!practice.clickOn));
                        },
                      ),
                    ],
                  ),
                ),
                PracticePlayButton(playing: practice.playing, onPressed: onPlay, onLongPress: controller.restart),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: _TempoPill(source: source, onPressed: onOpenTempo),
                      ),
                      if (!single)
                        PracticeRoundButton(
                          icon: TablerIcons.player_skip_forward,
                          tooltip: 'Next song',
                          onPressed: onNext,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Play/Pause: big, solid, in the middle. Hold it to go back to the top.
class PracticePlayButton extends StatelessWidget {
  const PracticePlayButton({super.key, required this.playing, required this.onPressed, required this.onLongPress});

  final bool playing;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final palette = PerformPaletteScope.of(context);
    return Semantics(
      button: true,
      label: playing ? 'Pause' : 'Play',
      onLongPressHint: 'Back to the top',
      excludeSemantics: true,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Pressable(
          onPressed: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          child: SizedBox.square(
            dimension: 60,
            child: Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: palette.highlight, shape: BoxShape.circle),
                child: Icon(
                  playing ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
                  size: 24,
                  color: palette.highlightForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PracticeRoundButton extends StatelessWidget {
  const PracticeRoundButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  /// On (the click): tinted in the theme's highlight.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final palette = PerformPaletteScope.of(context);
    final enabled = onPressed != null;
    return Semantics(
      toggled: selected ? true : null,
      child: Pressable(
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
                color: !enabled
                    ? Colors.transparent
                    : selected
                    ? palette.highlight.withValues(alpha: 0.14)
                    : c.muted.withValues(alpha: 0.8),
                border: selected ? Border.all(color: palette.highlight.withValues(alpha: 0.5)) : null,
              ),
              child: Icon(
                icon,
                size: 20,
                color: !enabled
                    ? c.mutedForeground.withValues(alpha: 0.4)
                    : selected
                    ? palette.highlight
                    : c.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The tempo at a glance — "♩72 · 4/4", with the beat ticking under it —
/// and the way into the tempo sheet.
class _TempoPill extends ConsumerWidget {
  const _TempoPill({required this.source, required this.onPressed});

  final PerformSource source;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final palette = PerformPaletteScope.of(context);
    final controller = ref.read(practiceControllerProvider(source).notifier);
    final practice = ref.watch(practiceControllerProvider(source));
    // Rebuild when the song changes, too: the tempo is per song.
    ref.watch(performControllerProvider(source).select((s) => s.songIndex));
    final tempo = controller.currentTempo;
    final bpm = tempo?.playingBpm;
    final label = bpm == null ? 'Set tempo' : '♩$bpm';
    final sub = [?tempo?.timeSignature, if (practice.tempoPercent != 100) '${practice.tempoPercent}%'].join(' · ');

    return Pressable(
      onPressed: onPressed,
      semanticLabel: bpm == null ? 'Set a tempo' : 'Tempo $bpm beats per minute${sub.isEmpty ? '' : ', $sub'}. Change',
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
        decoration: BoxDecoration(
          color: c.muted.withValues(alpha: 0.8),
          borderRadius: DaloyRadii.all(DaloyRadii.full),
          border: tempo?.differsFromSong ?? false ? Border.all(color: palette.highlight.withValues(alpha: 0.5)) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge!
                        .copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: bpm == null ? palette.highlight : null,
                        )
                        .weight(FontWeight.w700),
                  ),
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(width: DaloySpace.s1),
                  Text(sub, style: context.text.labelSmall!.copyWith(color: c.mutedForeground)),
                ],
              ],
            ),
            if (bpm != null) ...[const SizedBox(height: 3), _BeatDots(source: source, beats: tempo!.beats)],
          ],
        ),
      ),
    );
  }
}

/// One dot per beat of the bar; the one sounding lights up.
class _BeatDots extends ConsumerWidget {
  const _BeatDots({required this.source, required this.beats});

  final PerformSource source;
  final int beats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final palette = PerformPaletteScope.of(context);
    final clock = ref.read(practiceControllerProvider(source).notifier).beat;
    return ListenableSelector<PracticeBeat?, ({int? beat, int count})>(
      listenable: clock,
      select: (b) => (beat: b?.playing ?? false ? b!.beat : null, count: b?.playing ?? false ? b!.beatsInBar : beats),
      builder: (context, s) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < math.min(s.count, 12); i++)
            Container(
              width: i == 0 ? 6 : 4,
              height: i == 0 ? 6 : 4,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: s.beat == i ? palette.highlight : c.mutedForeground.withValues(alpha: 0.35),
              ),
            ),
        ],
      ),
    );
  }
}

// -- Count-in -------------------------------------------------------------------

/// The count-in, big enough to count along with: "3 · 2 · 1" in a ring that
/// drains a segment a beat. Shown whether or not the click is on — it's how
/// you know the chart is about to move. Tap to stop.
class PracticeCountIn extends StatelessWidget {
  const PracticeCountIn({super.key, required this.clock, required this.bpm, required this.onStop});

  final ValueListenable<PracticeBeat?> clock;
  final int bpm;
  final VoidCallback onStop;

  static const size = 96.0;

  @override
  Widget build(BuildContext context) => ListenableSelector<PracticeBeat?, ({int left, int beats})?>(
    listenable: clock,
    select: (b) => b?.countInLeft == null ? null : (left: b!.countInLeft!, beats: b.beatsInBar),
    builder: (context, count) {
      final still = PerformPaletteScope.of(context).flat || MediaQuery.disableAnimationsOf(context);
      return AnimatedSwitcher(
        duration: still ? Duration.zero : DaloyMotion.fast,
        child: count == null
            ? const SizedBox.shrink()
            : _CountInRing(
                key: const ValueKey('count-in'),
                left: count.left,
                beats: count.beats,
                bpm: bpm,
                onStop: onStop,
              ),
      );
    },
  );
}

class _CountInRing extends StatelessWidget {
  const _CountInRing({super.key, required this.left, required this.beats, required this.bpm, required this.onStop});

  final int left;
  final int beats;
  final int bpm;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final palette = PerformPaletteScope.of(context);
    final still = palette.flat || MediaQuery.disableAnimationsOf(context);
    // Drains to empty as the last count-in beat ends and the song starts.
    final remaining = ((left - 1) / beats).clamp(0.0, 1.0);
    final beat = Duration(microseconds: (60000000 / math.max(bpm, 1)).round());

    return Semantics(
      button: true,
      liveRegion: true,
      label: 'Counting in, $left ${left == 1 ? 'beat' : 'beats'} left. Tap to stop.',
      excludeSemantics: true,
      child: Pressable(
        onPressed: onStop,
        child: SizedBox.square(
          dimension: PracticeCountIn.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.background.withValues(alpha: 0.95),
                  border: Border.all(color: c.border),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(end: remaining),
                duration: still ? Duration.zero : beat,
                builder: (_, value, _) => CustomPaint(
                  size: const Size.square(PracticeCountIn.size),
                  painter: _RingPainter(fraction: value, color: palette.highlight, track: c.border),
                ),
              ),
              TweenAnimationBuilder<double>(
                key: ValueKey(left),
                tween: Tween(begin: still ? 1 : 1.25, end: 1),
                duration: const Duration(milliseconds: 150),
                builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                child: Text(
                  '$left',
                  style: context.text.displaySmall!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction, required this.color, required this.track});

  final double fraction;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = Offset.zero & size;
    final ring = rect.deflate(stroke / 2);
    canvas.drawArc(
      ring,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (fraction <= 0) return;
    canvas.drawArc(
      ring,
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction || old.color != color || old.track != track;
}

// -- Floating pills -------------------------------------------------------------

/// A small pill floating over the chart: "↻ Chorus · Stop", "Follow".
class PracticePill extends StatelessWidget {
  const PracticePill({super.key, required this.icon, required this.label, required this.onPressed, this.semanticLabel});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final palette = PerformPaletteScope.of(context);
    return Pressable(
      onPressed: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
      semanticLabel: semanticLabel ?? label,
      child: PerformGlass(
        borderRadius: DaloyRadii.all(DaloyRadii.full),
        border: Border.all(color: palette.highlight.withValues(alpha: 0.5)),
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: palette.highlight),
                const SizedBox(width: DaloySpace.s1_5),
                Text(label, style: context.text.labelLarge!.copyWith(color: c.foreground).weight(FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -- Tempo sheet ------------------------------------------------------------------

/// The tempo for this practice: the BPM (nudge or tap it), the time
/// signature, a slow-down percentage, and the click/haptic/flash switches.
/// Tempo and metre changes are for this practice only until "Save to song".
Future<void> showPracticeTempoSheet(BuildContext context, PerformSource source) {
  final container = ProviderScope.containerOf(context);
  final perform = container.read(performControllerProvider(source));
  final hasTempo = container.read(practiceControllerProvider(source).notifier).currentTempo?.hasTempo ?? false;
  return showPerformSheet<void>(
    context,
    title: 'Tempo',
    description: hasTempo ? perform.current?.row.title : 'This song has no tempo yet. Tap along, or set one.',
    builder: (_) => _TempoSheet(source: source),
  );
}

class _TempoSheet extends ConsumerStatefulWidget {
  const _TempoSheet({required this.source});

  final PerformSource source;

  @override
  ConsumerState<_TempoSheet> createState() => _TempoSheetState();
}

class _TempoSheetState extends ConsumerState<_TempoSheet> {
  final _tap = TapTempo();
  bool _saving = false;

  PracticeController get _controller => ref.read(practiceControllerProvider(widget.source).notifier);

  void _onTap() {
    HapticFeedback.lightImpact();
    final bpm = _tap.tap();
    if (bpm != null) _controller.setBpm(bpm);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _controller.saveTempoToSong();
    if (!mounted) return;
    setState(() => _saving = false);
    showDaloyToast(ScaffoldMessenger.of(context), 'Saved to the song.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final practice = ref.watch(practiceControllerProvider(widget.source));
    ref.watch(performControllerProvider(widget.source));
    final tempo = _controller.currentTempo;
    if (tempo == null) return const SizedBox.shrink();
    final bpm = tempo.bpm;
    final isSingle = ref.read(performControllerProvider(widget.source)).isSingleSong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PerformSheetLabel('Beats per minute'),
        StepperTrack(
          label: bpm == null ? 'No tempo' : '$bpm BPM',
          decreaseLabel: 'Slower',
          increaseLabel: 'Faster',
          onDecrease: bpm != null && bpm > minBpm ? () => _controller.setBpm(bpm - 1) : null,
          onIncrease: () => _controller.setBpm(bpm == null ? fallbackBpm : bpm + 1),
        ),
        const SizedBox(height: DaloySpace.s2),
        DaloyButton.outline(
          label: 'Tap to set the tempo',
          icon: TablerIcons.hand_click,
          expand: true,
          onPressed: _onTap,
        ),
        const SizedBox(height: DaloySpace.s5),
        const PerformSheetLabel('Time signature'),
        Wrap(
          spacing: DaloySpace.s1_5,
          runSpacing: DaloySpace.s1_5,
          children: [
            for (final ts in NewSong.timeSignatures)
              PerformChip(
                label: ts,
                active: (tempo.timeSignature ?? '4/4') == ts,
                onPressed: () => _controller.setTimeSignature(ts),
              ),
          ],
        ),
        if (tempo.differsFromSong) ...[
          const SizedBox(height: DaloySpace.s4),
          Text(
            tempo.savedBpm == null
                ? 'Just for this practice, until you save it.'
                : 'Just for this practice. The song says ${[if (tempo.savedBpm != null) '${tempo.savedBpm} BPM', ?tempo.savedTimeSignature].join(' · ')}.',
            style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s2),
          Row(
            children: [
              Expanded(
                child: DaloyButton.outline(label: 'Use the song’s', onPressed: _controller.resetTempo),
              ),
              const SizedBox(width: DaloySpace.s2),
              Expanded(
                child: DaloyButton(
                  label: isSingle ? 'Save to song' : 'Save to the song',
                  loading: _saving,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: DaloySpace.s5),
        const PerformSheetLabel('Practice speed'),
        Row(
          children: [
            Expanded(
              child: Slider.adaptive(
                value: practice.tempoPercent.toDouble(),
                min: 50,
                max: 120,
                divisions: 14,
                label: '${practice.tempoPercent}%',
                activeColor: PerformPaletteScope.of(context).highlight,
                onChanged: (v) {
                  if (v.round() != practice.tempoPercent) HapticFeedback.selectionClick();
                  _controller.setTempoPercent(v.round());
                },
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                '${practice.tempoPercent}%',
                textAlign: TextAlign.end,
                style: context.text.labelLarge!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
          ],
        ),
        Text(
          practice.tempoPercent == 100
              ? 'Slow it down to learn a part, then bring it back up.'
              : bpm == null
              ? ''
              : 'Playing at ${tempo.playingBpm} BPM.',
          style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
        ),
        if (practice.tempoPercent != 100)
          Align(
            alignment: Alignment.centerLeft,
            child: DaloyButton(
              variant: ButtonVariant.plain,
              label: 'Back to full speed',
              onPressed: () => _controller.setTempoPercent(100),
            ),
          ),
        const SizedBox(height: DaloySpace.s5),
        const PerformSheetLabel('On the beat'),
        PerformSwitchGroup(
          children: [
            PerformSwitchRow(
              label: 'Click',
              detail: practice.noAudio
                  ? 'Sound isn’t available on this device right now.'
                  : 'The chart keeps moving when it’s off.',
              value: practice.clickOn,
              onChanged: _controller.setClick,
            ),
            PerformSwitchRow(
              label: 'Haptic beat',
              detail: 'A tap on every beat, stronger on 1.',
              value: practice.prefs.practiceHaptics,
              onChanged: _controller.setHaptics,
            ),
            PerformSwitchRow(
              label: 'Flash the bar',
              detail: 'The playing bar pulses on the beat.',
              value: practice.prefs.practiceFlash,
              onChanged: _controller.setFlash,
            ),
          ],
        ),
      ],
    );
  }
}
