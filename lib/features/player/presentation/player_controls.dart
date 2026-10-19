import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/filter_pill.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/sheet_nav_bar.dart';
import '../application/music_player_controller.dart';
import '../domain/player_queue.dart';

/// A round transport button. [primary] is the big Play/Pause.
class PlayerButton extends StatelessWidget {
  const PlayerButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.primary = false,
    this.size = 44,
    this.loading = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool primary;
  final double size;

  /// The track is loading: a spinner in place of the icon.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null;
    final fg = primary ? c.primaryForeground : (enabled ? c.foreground : c.mutedForeground.withValues(alpha: 0.5));
    return Pressable(
      onPressed: onPressed,
      semanticLabel: tooltip,
      child: SizedBox.square(
        dimension: size < 44 ? 44 : size,
        child: Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary ? c.primary : Colors.transparent,
              // The coloured lift of a filled ModeButton.
              boxShadow: primary && enabled
                  ? [
                      BoxShadow(
                        color: c.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: -6,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: loading
                  ? DaloySpinner(size: size * 0.4, color: fg)
                  : Icon(icon, size: size * (primary ? 0.42 : 0.5), color: fg),
            ),
          ),
        ),
      ),
    );
  }
}

/// Previous · Play/Pause · Next, for whatever's playing. [expanded] spreads
/// them across the width (the now-playing screen); otherwise they sit
/// together, [spacing] apart.
class PlayerTransport extends ConsumerWidget {
  const PlayerTransport({
    super.key,
    this.size = 44,
    this.primarySize = 64,
    this.spacing = DaloySpace.s4,
    this.expanded = false,
  });

  final double size;
  final double primarySize;
  final double spacing;
  final bool expanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(musicPlayerProvider);
    final controller = ref.read(musicPlayerProvider.notifier);
    final gap = expanded ? const Spacer() : SizedBox(width: spacing);
    return Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (expanded) const Spacer(),
        PlayerButton(
          icon: TablerIcons.player_skip_back_filled,
          tooltip: 'Previous',
          size: size,
          onPressed: player.isOpen
              ? () {
                  HapticFeedback.selectionClick();
                  unawaited(controller.previous());
                }
              : null,
        ),
        gap,
        PlayerPlayPause(size: primarySize),
        gap,
        PlayerButton(
          icon: TablerIcons.player_skip_forward_filled,
          tooltip: 'Next',
          size: size,
          onPressed: player.hasNext
              ? () {
                  HapticFeedback.selectionClick();
                  controller.next();
                }
              : null,
        ),
        if (expanded) const Spacer(),
      ],
    );
  }
}

/// Play/Pause on its own — the mini player's one button.
class PlayerPlayPause extends ConsumerWidget {
  const PlayerPlayPause({super.key, this.size = 64, this.primary = true});

  final double size;
  final bool primary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(musicPlayerProvider);
    return PlayerButton(
      icon: player.isPlaying ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
      tooltip: player.isPlaying ? 'Pause' : 'Play',
      primary: primary,
      size: size,
      loading: player.status == PlayerStatus.loading,
      onPressed: player.isOpen
          ? () {
              HapticFeedback.selectionClick();
              unawaited(ref.read(musicPlayerProvider.notifier).togglePlay());
            }
          : null,
    );
  }
}

/// Where the song is, with the times beneath: a bar the full width of its
/// column, no thumb (like Music's). Touch anywhere along it — the hit area
/// is much taller than the bar — and drag; it swells while held and seeks
/// on release. A tap seeks straight there. Listens to the player's progress
/// on its own, so the page doesn't rebuild as it plays.
class PlayerScrubber extends ConsumerStatefulWidget {
  const PlayerScrubber({super.key});

  @override
  ConsumerState<PlayerScrubber> createState() => _PlayerScrubberState();
}

class _PlayerScrubberState extends ConsumerState<PlayerScrubber> {
  static const _bar = 6.0;
  static const _barHeld = 12.0;
  static const _hit = 40.0;

  /// A VoiceOver swipe moves this far.
  static const _step = Duration(seconds: 10);

  /// While a finger is on it: where it would seek to.
  double? _dragging;

  double _at(double dx, double width) => width <= 0 ? 0 : (dx / width).clamp(0.0, 1.0);

  void _start(double fraction) {
    HapticFeedback.selectionClick();
    setState(() => _dragging = fraction);
  }

  void _release(Duration duration) {
    final to = _dragging;
    setState(() => _dragging = null);
    if (to != null) unawaited(ref.read(musicPlayerProvider.notifier).seek(duration * to));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final controller = ref.read(musicPlayerProvider.notifier);
    return ValueListenableBuilder(
      valueListenable: controller.progress,
      builder: (context, progress, _) {
        final duration = progress.duration;
        final known = duration > Duration.zero;
        final held = _dragging != null;
        final value = _dragging ?? progress.fraction;
        final shown = held ? duration * value : progress.position;
        final times = context.text.labelSmall!.copyWith(
          color: held ? c.foreground : c.mutedForeground,
          fontWeight: FontWeight.w500,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

        void nudge(Duration by) {
          final to = progress.position + by;
          unawaited(controller.seek(to < Duration.zero ? Duration.zero : (to > duration ? duration : to)));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              slider: true,
              label: 'Song position',
              value: '${formatPlaybackTime(shown)} of ${formatPlaybackTime(duration)}',
              onIncrease: known ? () => nudge(_step) : null,
              onDecrease: known ? () => nudge(-_step) : null,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: known ? (d) => _start(_at(d.localPosition.dx, width)) : null,
                    onHorizontalDragUpdate: known
                        ? (d) => setState(() => _dragging = _at(d.localPosition.dx, width))
                        : null,
                    onHorizontalDragEnd: known ? (_) => _release(duration) : null,
                    onHorizontalDragCancel: known ? () => setState(() => _dragging = null) : null,
                    onTapUp: known
                        ? (d) {
                            HapticFeedback.selectionClick();
                            unawaited(controller.seek(duration * _at(d.localPosition.dx, width)));
                          }
                        : null,
                    child: SizedBox(
                      height: _hit,
                      child: Center(
                        child: AnimatedContainer(
                          duration: DaloyMotion.fast,
                          curve: DaloyMotion.ease,
                          height: held ? _barHeld : _bar,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: _ScrubberPainter(
                              value: value,
                              track: c.foreground.withValues(alpha: 0.12),
                              fill: held ? c.foreground : c.foreground.withValues(alpha: 0.78),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Text(formatPlaybackTime(shown), style: times),
                const Spacer(),
                Text(known ? '-${formatPlaybackTime(duration - shown)}' : '--:--', style: times),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// A rounded bar, filled to [value].
class _ScrubberPainter extends CustomPainter {
  _ScrubberPainter({required this.value, required this.track, required this.fill});

  final double value;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final bar = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(size.height / 2));
    canvas
      ..drawRRect(bar, Paint()..color = track)
      ..save()
      ..clipRRect(bar)
      ..drawRect(Rect.fromLTWH(0, 0, size.width * value.clamp(0.0, 1.0), size.height), Paint()..color = fill)
      ..restore();
  }

  @override
  bool shouldRepaint(_ScrubberPainter old) => old.value != value || old.track != track || old.fill != fill;
}

/// Play/Pause ringed by how far the song has played — the mini player's
/// one big control, so its progress needs no line of its own.
class PlayerPlayPauseRing extends ConsumerWidget {
  const PlayerPlayPauseRing({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final player = ref.watch(musicPlayerProvider);
    final controller = ref.read(musicPlayerProvider.notifier);
    return Pressable(
      semanticLabel: player.isPlaying ? 'Pause' : 'Play',
      onPressed: player.isOpen
          ? () {
              HapticFeedback.selectionClick();
              unawaited(controller.togglePlay());
            }
          : null,
      child: SizedBox.square(
        dimension: 44,
        child: Center(
          child: SizedBox.square(
            dimension: size,
            child: ValueListenableBuilder(
              valueListenable: controller.progress,
              builder: (context, progress, child) => CustomPaint(
                painter: _RingPainter(
                  value: progress.fraction,
                  track: c.foreground.withValues(alpha: 0.12),
                  fill: c.primaryInk,
                ),
                child: child,
              ),
              child: Center(
                child: player.status == PlayerStatus.loading
                    ? DaloySpinner(size: size * 0.4, color: c.foreground)
                    : Icon(
                        player.isPlaying ? TablerIcons.player_pause_filled : TablerIcons.player_play_filled,
                        size: size * 0.5,
                        color: c.foreground,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.track, required this.fill});

  final double value;
  final Color track;
  final Color fill;

  static const _stroke = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(_stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(rect, paint..color = track);
    final sweep = value.clamp(0.0, 1.0) * 2 * math.pi;
    if (sweep > 0) canvas.drawArc(rect, -math.pi / 2, sweep, false, paint..color = fill);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.value != value || old.track != track || old.fill != fill;
}

/// The song in other apps: YouTube and YouTube Music (where the video is),
/// Spotify, Apple Music. Each opens in its app when installed, else the
/// browser. Leaving pauses the video here.
class PlayerOtherApps extends ConsumerWidget {
  const PlayerOtherApps({super.key, required this.track});

  final PlayerTrack track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = track.videoId;
    final links = [
      if (video != null) (TablerIcons.brand_youtube, 'YouTube', 'https://www.youtube.com/watch?v=$video'),
      if (video != null) (TablerIcons.disc, 'YouTube Music', 'https://music.youtube.com/watch?v=$video'),
      if (track.spotifyUrl case final url?) (TablerIcons.brand_spotify, 'Spotify', url),
      if (track.appleMusicUrl case final url?) (TablerIcons.brand_apple, 'Apple Music', url),
    ];
    Future<void> open(String label, String url) async {
      unawaited(ref.read(musicPlayerProvider.notifier).pause());
      final trimmed = url.trim();
      final uri = Uri.tryParse(
        RegExp(r'^[a-z][a-z0-9+.-]*:', caseSensitive: false).hasMatch(trimmed) ? trimmed : 'https://$trimmed',
      );
      final opened = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        showDaloyToast(ScaffoldMessenger.of(context), "Couldn't open $label.");
      }
    }

    // Four at most: one row, scrolling sideways on a narrow phone.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (i, (icon, label, url)) in links.indexed) ...[
            if (i > 0) const SizedBox(width: DaloySpace.s2),
            FilterPill(label: label, icon: icon, onTap: () => open(label, url)),
          ],
        ],
      ),
    );
  }
}

/// Pastes a YouTube link for a song in the queue that has none (or one that
/// won't play here). Saved to the song, so it plays everywhere the song is
/// used — on this device at once, offline too.
Future<void> showYouTubeLinkSheet(BuildContext context, PlayerTrack track, {required bool replacing}) =>
    showDaloySheet<void>(
      context: context,
      toolbar: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => _YouTubeLinkSheet(track: track, replacing: replacing),
    );

class _YouTubeLinkSheet extends ConsumerStatefulWidget {
  const _YouTubeLinkSheet({required this.track, required this.replacing});

  final PlayerTrack track;
  final bool replacing;

  @override
  ConsumerState<_YouTubeLinkSheet> createState() => _YouTubeLinkSheetState();
}

class _YouTubeLinkSheetState extends ConsumerState<_YouTubeLinkSheet> {
  final _input = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) _input.text = text;
  }

  Future<void> _save() async {
    if (_input.text.trim().isEmpty || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await ref.read(musicPlayerProvider.notifier).saveLink(widget.track, _input.text);
    if (!mounted) return;
    if (error != null) {
      unawaited(HapticFeedback.heavyImpact());
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    showDaloyToast(messenger, 'Added a YouTube link to “${widget.track.title}”.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetNavBar(
              title: widget.replacing ? 'Replace link' : 'Add a link',
              onCancel: _saving ? null : () => Navigator.of(context).pop(),
              actionLabel: 'Save',
              onAction: _input.text.trim().isEmpty ? null : _save,
              pending: _saving,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s2, DaloySpace.s5, DaloySpace.s5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.replacing
                        ? 'YouTube won’t play the link “${widget.track.title}” has here. Paste another one.'
                        : 'For “${widget.track.title}”. It’s saved to the song, so it plays everywhere the song is used.',
                    style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                  ),
                  const SizedBox(height: DaloySpace.s4),
                  DaloyTextField(
                    label: 'YouTube link',
                    controller: _input,
                    hint: 'https://youtu.be/…',
                    icon: TablerIcons.brand_youtube,
                    error: _error,
                    enabled: !_saving,
                    autofocus: true,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => unawaited(_save()),
                    labelTrailing: DaloyButton(
                      variant: ButtonVariant.plain,
                      size: ControlSize.sm,
                      label: 'Paste',
                      onPressed: _saving ? null : _paste,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
