import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/platform.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/flow_artwork.dart';
import '../../../shared/widgets/glass_buttons.dart';
import '../../../shared/widgets/hairline.dart';
import '../../perform/application/perform_controller.dart';
import '../../songs/presentation/widgets/song_artwork.dart';
import '../application/music_player_controller.dart';
import 'player_controls.dart';
import 'player_queue_list.dart';
import 'player_video_slot.dart';

/// Listen: the player opened up — the video, the song, the transport and
/// the queue. Opening it plays [source] (unless it's already playing).
/// Drag it down, or tap the chevron, and it shrinks into the mini player;
/// the song plays on. On a tablet the player holds the left and the queue
/// scrolls on the right.
class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key, required this.source});

  final PerformSource source;

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> with SingleTickerProviderStateMixin {
  /// How far a drag pulls the page down before letting go minimizes it.
  static const _dismissDistance = 120.0;

  late final _settle = AnimationController(vsync: this, duration: DaloyMotion.medium)..addListener(_onSettle);
  double _drag = 0;
  double _settleFrom = 0;

  /// The player has been asked to play this; after that, closing it leaves.
  bool _started = false;

  /// The route coming up and going down. The page slides itself (the route
  /// is see-through), so the slide, a drag and the backdrop share one offset.
  CurvedAnimation? _shown;

  @override
  void initState() {
    super.initState();
    // Not while building: the player changes state as it opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(musicPlayerProvider.notifier).open(widget.source);
      setState(() => _started = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context)?.animation;
    if (_shown == null && route != null) {
      _shown = CurvedAnimation(parent: route, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
    }
  }

  @override
  void dispose() {
    _shown?.dispose();
    _settle.dispose();
    super.dispose();
  }

  void _onSettle() => setState(() => _drag = _settleFrom * (1 - Curves.easeOutCubic.transform(_settle.value)));

  void _onDragUpdate(DragUpdateDetails d) {
    _settle.stop();
    setState(() => _drag = math.max(0, _drag + d.delta.dy));
  }

  void _onDragEnd(DragEndDetails d) {
    if (_drag > _dismissDistance || (d.primaryVelocity ?? 0) > 700) {
      unawaited(HapticFeedback.lightImpact());
      _minimize();
      return;
    }
    _settleFrom = _drag;
    unawaited(_settle.forward(from: 0));
  }

  /// Back to where you were; the mini player carries on.
  void _minimize() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(switch (widget.source) {
        LineUpSource(:final id) => Routes.lineUp(id),
        SongSource(:final id) => Routes.song(id),
      });
    }
  }

  void _close() {
    unawaited(HapticFeedback.lightImpact());
    ref.read(musicPlayerProvider.notifier).close();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(musicPlayerProvider);
    // Closed (here or because the set lost its links): nothing to show.
    ref.listen(musicPlayerProvider.select((s) => s.source == null), (was, closed) {
      if (_started && closed && was == false) _minimize();
    });

    final media = MediaQuery.of(context);
    final wide = media.size.width >= DaloyBreakpoints.tablet && media.size.width > media.size.height;
    final onThis = player.source == widget.source;

    final Widget body;
    if (!onThis || !player.isOpen) {
      body = _started && player.source == null ? _NothingToPlay(onBack: _minimize) : const SizedBox.expand();
    } else if (wide) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(DaloySpace.s8, DaloySpace.s2, DaloySpace.s8, DaloySpace.s8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _Hero(onDragUpdate: _onDragUpdate, onDragEnd: _onDragEnd),
                ),
              ),
            ),
          ),
          if (player.tracks.length > 1)
            SizedBox(
              width: 380,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: context.colors.border)),
                ),
                child: _Queue(bottom: media.padding.bottom),
              ),
            ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s5),
            child: _Hero(onDragUpdate: _onDragUpdate, onDragEnd: _onDragEnd),
          ),
          if (player.tracks.length > 1) ...[
            const SizedBox(height: DaloySpace.s3),
            const Hairline(),
            Expanded(child: _Queue(bottom: media.padding.bottom)),
          ] else
            const Spacer(),
        ],
      );
    }

    final songId = onThis ? player.current?.songId : null;
    final page = Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // The song's colour washes the top, as on its page; it shifts
          // with the queue.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: media.padding.top + (wide ? 520 : 420),
            child: AnimatedSwitcher(
              duration: DaloyMotion.medium * 2,
              child: songId == null
                  ? const SizedBox.expand()
                  : SizedBox.expand(
                      key: ValueKey(songId),
                      child: ArtworkWash(
                        palette: SongArtwork.paletteFor(songId),
                        background: context.colors.background,
                      ),
                    ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragEnd,
                  child: _Header(
                    eyebrow: widget.source is LineUpSource ? 'Playing from line-up' : 'Playing song',
                    title: onThis ? player.title : null,
                    onMinimize: _minimize,
                    onClose: onThis && player.isOpen ? _close : null,
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );

    final shown = _shown;
    if (shown == null) return Transform.translate(offset: Offset(0, _drag), child: page);
    return AnimatedBuilder(
      animation: shown,
      child: page,
      builder: (context, page) {
        final height = media.size.height;
        final offset = (1 - shown.value) * height + _drag;
        // What's under shows through as the page goes: dimmed and blurred
        // while it covers the screen, clear by the time it's gone.
        final cover = (1 - offset / height).clamp(0.0, 1.0);
        // Rounds into a sheet as soon as it moves.
        final radius = 34 * (offset / 48).clamp(0.0, 1.0);
        return Stack(
          fit: StackFit.expand,
          children: [
            if (offset > 0) _Backdrop(cover: cover),
            Transform.translate(
              offset: Offset(0, offset),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
                child: page,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The screen under the player while it moves: blurred and dimmed by
/// [cover] (1 while the player covers it all, 0 once it's gone).
class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.cover});

  final double cover;

  @override
  Widget build(BuildContext context) {
    final dim = ColoredBox(color: Colors.black.withValues(alpha: 0.4 * cover));
    // Only dimmed on Windows, where a full-screen blur stutters (DaloyGlass).
    return IgnorePointer(
      child: isWindows
          ? dim
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16 * cover, sigmaY: 16 * cover),
              child: dim,
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.eyebrow, required this.title, required this.onMinimize, required this.onClose});

  final String eyebrow;
  final String? title;
  final VoidCallback onMinimize;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: DaloyChrome.topBarHeight + DaloySpace.s2,
      child: Row(
        children: [
          const SizedBox(width: DaloySpace.s2),
          GlassIconButton(icon: TablerIcons.chevron_down, label: 'Minimize player', onPressed: onMinimize),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: context.text.labelSmall!.copyWith(
                    color: c.mutedForeground,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (title != null)
                  Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall!.weight(FontWeight.w600),
                  ),
              ],
            ),
          ),
          if (onClose != null)
            GlassIconButton(icon: TablerIcons.x, label: 'Close player', onPressed: onClose)
          else
            const SizedBox(width: 44),
          const SizedBox(width: DaloySpace.s2),
        ],
      ),
    );
  }
}

/// The video, what's playing, where it is, and the transport. Dragging the
/// video down minimizes, like the header.
class _Hero extends ConsumerWidget {
  const _Hero({required this.onDragUpdate, required this.onDragEnd});

  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final player = ref.watch(musicPlayerProvider);
    final track = player.current!;
    final subtitle = [?track.artist, if (track.displayKey case final k?) 'Key of $k'].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onVerticalDragUpdate: onDragUpdate,
          onVerticalDragEnd: onDragEnd,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: DaloyRadii.all(DaloyRadii.xl3),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 32, offset: const Offset(0, 14)),
                ],
              ),
              child: PlayerVideoSlot(
                borderRadius: DaloyRadii.all(DaloyRadii.xl3),
                onTap: () => unawaited(ref.read(musicPlayerProvider.notifier).togglePlay()),
              ),
            ),
          ),
        ),
        const SizedBox(height: DaloySpace.s6),
        Text(
          track.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.headlineSmall!.weight(FontWeight.w700),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyLarge!.copyWith(color: c.mutedForeground),
          ),
        ],
        const SizedBox(height: DaloySpace.s3),
        const PlayerScrubber(),
        const SizedBox(height: DaloySpace.s2),
        const PlayerTransport(size: 52, primarySize: 72, expanded: true),
        const SizedBox(height: DaloySpace.s5),
        PlayerOtherApps(track: track),
      ],
    );
  }
}

class _Queue extends StatelessWidget {
  const _Queue({required this.bottom});

  final double bottom;

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, _) {
      final player = ref.watch(musicPlayerProvider);
      final c = context.colors;
      final playable = player.playableCount;
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s4, DaloySpace.s5, DaloySpace.s2),
              child: Row(
                children: [
                  Text('Queue', style: context.text.titleSmall!.weight(FontWeight.w600)),
                  const Spacer(),
                  Text(
                    playable == player.tracks.length
                        ? '${player.tracks.length} songs'
                        : '$playable of ${player.tracks.length} with YouTube',
                    style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
          PlayerQueueSliver(padding: EdgeInsets.fromLTRB(DaloySpace.s2, 0, DaloySpace.s2, bottom + DaloySpace.s6)),
        ],
      );
    },
  );
}

class _NothingToPlay extends StatelessWidget {
  const _NothingToPlay({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(DaloySpace.s8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Nothing to play', style: context.text.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: DaloySpace.s2),
          Text(
            'None of these songs has a YouTube link yet.',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s5),
          DaloyButton.outline(label: 'Go back', onPressed: onBack),
        ],
      ),
    ),
  );
}
