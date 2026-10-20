import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/platform.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/flow_artwork.dart';
import '../../../shared/widgets/hero_top_bar.dart';
import '../../../shared/widgets/mode_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../line_ups/domain/line_up.dart';
import '../../line_ups/presentation/widgets/line_up_cover.dart';
import '../../sync/realtime_scope.dart';
import '../../sync/workspace_realtime.dart';
import '../application/song_detail_controller.dart';
import '../domain/display_prefs.dart';
import '../domain/song.dart';
import 'song_actions.dart';
import 'widgets/chord_sheet.dart';
import 'widgets/lyrics_sheet.dart';
import 'widgets/pinch_zoom.dart';
import 'widgets/song_artwork.dart';
import 'widgets/song_display_sheet.dart';
import 'widgets/song_streaming_links.dart';
import 'widgets/song_sync_badge.dart';
import 'widgets/stepper_track.dart';

/// A song: its artwork and title, key and capo, and the chart or lyrics.
/// Drawn like a line-up's page — the artwork's colour washes the top, the
/// bar floats and takes the title once it scrolls by — so the chart can run
/// the full width. Reads only from Drift, so it opens offline; the key you
/// set is saved on the device at once and sent to the server when it can be.
class SongDetailScreen extends ConsumerStatefulWidget {
  const SongDetailScreen({super.key, required this.songId, this.focusLine, this.focusView});

  final int songId;

  /// A line to land on and light briefly — where a search hit on the song's
  /// words opens it — in the chords or lyrics as [focusView] says
  /// (`chords` / `lyrics`).
  final int? focusLine;
  final String? focusView;

  @override
  ConsumerState<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends ConsumerState<SongDetailScreen> {
  final _hero = HeroScrollState();

  /// The view the search hit is in, shown without touching the saved
  /// preference; dropped as soon as you pick a view yourself.
  late SongViewMode? _viewOverride = widget.focusLine == null
      ? null
      : SongViewMode.values.where((m) => m.name == widget.focusView).firstOrNull;
  final _focusKey = GlobalKey();
  bool _focusLit = false;
  bool _focusScheduled = false;
  Timer? _focusTimer;

  /// The live zoom while two fingers are down; null otherwise.
  double? _pinchZoom;
  bool _pinching = false;

  int get _songId => widget.songId;

  @override
  void dispose() {
    _focusTimer?.cancel();
    _hero.dispose();
    super.dispose();
  }

  /// Once the chart is drawn: scroll the hit into the upper third, light it,
  /// and let the light fade.
  void _scheduleFocus() {
    if (_focusScheduled || widget.focusLine == null) return;
    _focusScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Past the entrance animation, so the chart has its final height.
      _focusTimer = Timer(DaloyMotion.medium, () {
        final target = _focusKey.currentContext;
        if (!mounted || target == null) return;
        final reduceMotion = MediaQuery.disableAnimationsOf(context);
        Scrollable.ensureVisible(
          target,
          alignment: 0.3,
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
        setState(() => _focusLit = true);
        _focusTimer = Timer(const Duration(milliseconds: 1800), () {
          if (mounted) setState(() => _focusLit = false);
        });
      });
    });
  }

  void _pinchUpdate(double factor, int base) =>
      setState(() => _pinchZoom = (base * factor).clamp(ChartPrefs.minZoom.toDouble(), ChartPrefs.maxZoom.toDouble()));

  void _pinchEnd() {
    final zoom = _pinchZoom;
    setState(() => _pinchZoom = null);
    if (zoom != null) HapticFeedback.lightImpact();
    if (zoom != null) ref.read(songDetailControllerProvider(_songId).notifier).setZoom(ChartPrefs.clampZoom(zoom));
  }

  void _back() {
    final router = GoRouter.of(context);
    router.canPop() ? router.pop() : router.go(Routes.songs);
  }

  @override
  Widget build(BuildContext context) {
    listenRemoteChanges(ref, context, RemoteKind.song, widget.songId);
    final state = ref.watch(songDetailControllerProvider(_songId));
    final controller = ref.read(songDetailControllerProvider(_songId).notifier);
    final song = state.song;
    if (song != null) _scheduleFocus();
    final barBottom = MediaQuery.paddingOf(context).top + DaloyChrome.topBarHeight;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: state.isLoading
                ? const _DetailSkeleton()
                : song == null
                ? const _NotAvailable()
                : NotificationListener<ScrollNotification>(
                    onNotification: (n) => _hero.handle(context, n),
                    child: _content(context, state, controller, song),
                  ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HeroTopBar(
              title: song?.title,
              scrolled: _hero.scrolled,
              titleHidden: _hero.titleHidden,
              onBack: _back,
              actions: [
                if (song != null) ...[
                  Builder(
                    builder: (buttonContext) => TopBarIconButton(
                      icon: TablerIcons.adjustments_horizontal,
                      tooltip: 'Display',
                      onPressed: () => showSongDisplaySheet(context, _songId, anchor: anchorOf(buttonContext)),
                    ),
                  ),
                  TopBarIconButton(
                    icon: TablerIcons.pencil,
                    tooltip: 'Edit song',
                    onPressed: () => context.push(Routes.songEdit(_songId)),
                  ),
                  DaloyMenuButton(tooltip: 'More', items: songMenuItems(context, ref, song, onDetails: true)),
                ],
              ],
            ),
          ),
          // Names the size while two fingers are resizing the chart.
          Positioned(
            top: barBottom + DaloySpace.s3,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _pinching ? 1 : 0,
                duration: DaloyMotion.fast,
                child: Center(child: _ZoomPill(percent: (_pinchZoom ?? state.prefs.zoom).round())),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, SongDetailState state, SongDetailController controller, Song song) {
    final c = context.colors;
    final gutter = DaloySpace.gutter(context);
    final zoom = _pinchZoom ?? state.prefs.zoom.toDouble();
    final viewMode = _viewOverride ?? state.prefs.viewMode;
    final top = MediaQuery.paddingOf(context).top + DaloyChrome.topBarHeight;
    final bottom = MediaQuery.paddingOf(context).bottom + DaloySpace.s10;

    return SingleChildScrollView(
      physics: _pinching ? const NeverScrollableScrollPhysics() : null,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + 300,
            child: ArtworkWash(palette: SongArtwork.paletteFor(song.id), background: c.background),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(gutter, top + DaloySpace.s3, gutter, bottom),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 768),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Entrance(
                      index: 0,
                      child: _Hero(state: state, titleKey: _hero.titleKey),
                    ),
                    if (state.hasChords || state.hasLyrics) ...[
                      const SizedBox(height: DaloySpace.s5),
                      Entrance(
                        index: 1,
                        child: Row(
                          children: [
                            Expanded(
                              child: ModeButton(
                                icon: TablerIcons.metronome,
                                label: 'Practice',
                                onPressed: () => context.push(Routes.songPractice(_songId)),
                              ),
                            ),
                            if (state.hasLyrics) ...[
                              const SizedBox(width: DaloySpace.s2),
                              Expanded(
                                child: ModeButton(
                                  icon: TablerIcons.presentation,
                                  label: 'Present',
                                  onPressed: () => context.push(Routes.songPresent(_songId)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (state.upcomingLineUps.isNotEmpty) ...[
                      const SizedBox(height: DaloySpace.s5),
                      Entrance(index: 2, child: _UpcomingLineUps(lineUps: state.upcomingLineUps)),
                    ],
                    const SizedBox(height: DaloySpace.s6),
                    Entrance(
                      index: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Controls(state: state, controller: controller),
                          SongSyncLine(sync: state.sync, isOnline: state.isOnline),
                        ],
                      ),
                    ),
                    const SizedBox(height: DaloySpace.s6),
                    Entrance(
                      index: 4,
                      child: SegmentedControl<SongViewMode>(
                        value: viewMode,
                        options: const [(SongViewMode.chords, 'Chords'), (SongViewMode.lyrics, 'Lyrics')],
                        onChanged: (mode) {
                          setState(() => _viewOverride = null);
                          controller.setViewMode(mode);
                        },
                      ),
                    ),
                    const SizedBox(height: DaloySpace.s5),
                    // The chart is the page — no card around it.
                    Entrance(
                      index: 5,
                      child: PinchZoom(
                        onActiveChanged: (active) => setState(() => _pinching = active),
                        onUpdate: (factor) => _pinchUpdate(factor, state.prefs.zoom),
                        onEnd: (_) => _pinchEnd(),
                        child: SizedBox(
                          width: double.infinity,
                          // Cross-fades between chords and lyrics, easing to the new height.
                          child: AnimatedSize(
                            duration: DaloyMotion.medium,
                            curve: DaloyMotion.ease,
                            alignment: Alignment.topCenter,
                            child: AnimatedSwitcher(
                              duration: DaloyMotion.medium,
                              switchInCurve: DaloyMotion.ease,
                              switchOutCurve: Curves.easeIn,
                              layoutBuilder: (current, previous) =>
                                  Stack(alignment: Alignment.topLeft, children: [...previous, ?current]),
                              child: KeyedSubtree(
                                key: ValueKey(viewMode),
                                child: switch (viewMode) {
                                  SongViewMode.chords =>
                                    state.hasChords
                                        ? ChordSheet(
                                            content: song.content!,
                                            transposition: state.chartTransposition,
                                            zoom: zoom,
                                            musicalKey: state.originalKey,
                                            notation: state.notation,
                                            focusLine: viewMode == _viewOverride ? widget.focusLine : null,
                                            focusKey: _focusKey,
                                            focusLit: _focusLit,
                                          )
                                        : const _Empty(icon: TablerIcons.music_off, message: 'No chords added yet.'),
                                  SongViewMode.lyrics =>
                                    state.hasLyrics
                                        ? LyricsSheet(
                                            lyrics: song.lyrics!,
                                            zoom: zoom,
                                            focusLine: viewMode == _viewOverride ? widget.focusLine : null,
                                            focusKey: _focusKey,
                                            focusLit: _focusLit,
                                          )
                                        : const _Empty(icon: TablerIcons.align_left, message: 'No lyrics added yet.'),
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomPill extends StatelessWidget {
  const _ZoomPill({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3_5, vertical: DaloySpace.s1_5),
      decoration: BoxDecoration(
        color: c.foreground,
        borderRadius: DaloyRadii.all(DaloyRadii.full),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Text(
        '$percent%',
        style: context.text.labelLarge!.copyWith(
          color: c.background,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// The song's artwork beside its title: the key it's played in, large, on
/// the artwork (changing as you transpose), and what it is underneath the
/// title — artist, tempo, metre.
class _Hero extends StatelessWidget {
  const _Hero({required this.state, required this.titleKey});

  final SongDetailState state;
  final Key titleKey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final song = state.song!;
    final writtenIn = state.originalKey;
    final transposed = writtenIn != null && state.displayKey != writtenIn;
    final wide = MediaQuery.sizeOf(context).width >= DaloyBreakpoints.tablet;
    final artist = (song.artist ?? '').trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SongArtwork(
          songId: song.id,
          keyName: state.displayKey ?? song.key,
          width: wide ? 148 : 116,
          caption: state.capo > 0 ? 'Capo ${state.capo}' : null,
          animate: true,
          shadow: true,
        ),
        const SizedBox(width: DaloySpace.s5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                key: titleKey,
                style: context.text.displaySmall!.copyWith(fontSize: wide ? 30 : 26),
              ),
              if (artist.isNotEmpty) ...[
                const SizedBox(height: DaloySpace.s1),
                Text(artist, style: context.text.bodyLarge!.copyWith(color: c.mutedForeground)),
              ],
              const SizedBox(height: DaloySpace.s2_5),
              Wrap(
                spacing: DaloySpace.s1_5,
                runSpacing: DaloySpace.s1_5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (state.numberingReference != null) _Pill(state.numberingReference!, tint: true),
                  if (song.bpm != null) _Pill('${song.bpm} BPM'),
                  if ((song.timeSignature ?? '').isNotEmpty) _Pill(song.timeSignature!),
                  if (song.isPublic) StatusChip(label: 'On Discover', color: c.primaryInk, dense: true),
                  if (transposed)
                    Text('Written in $writtenIn', style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label, {this.tint = false});

  final String label;
  final bool tint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint ? c.primary.withValues(alpha: 0.1) : c.muted.withValues(alpha: 0.7),
        borderRadius: DaloyRadii.all(DaloyRadii.md),
      ),
      child: Text(
        label,
        style: context.text.labelMedium!.copyWith(
          color: tint ? c.primaryInk : c.foreground,
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// The services this song is in next, each with its line-up's cover — tap
/// to open it.
class _UpcomingLineUps extends StatelessWidget {
  const _UpcomingLineUps({required this.lineUps});

  final List<LineUp> lineUps;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Coming up in'),
        const SizedBox(height: DaloySpace.s2),
        Wrap(
          spacing: DaloySpace.s2,
          runSpacing: DaloySpace.s2,
          children: [
            for (final lineUp in lineUps)
              Pressable(
                onPressed: () => context.push(Routes.lineUp(lineUp.id)),
                semanticLabel: '${lineUp.title}, ${formatLineUpDate(lineUp.date)}',
                child: Container(
                  padding: const EdgeInsets.fromLTRB(DaloySpace.s1_5, DaloySpace.s1_5, DaloySpace.s3, DaloySpace.s1_5),
                  decoration: BoxDecoration(
                    color: c.card,
                    border: Border.all(color: c.border),
                    borderRadius: DaloyRadii.all(DaloyRadii.xl),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LineUpDateBlock(lineUp: lineUp, width: 36),
                      const SizedBox(width: DaloySpace.s2_5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lineUp.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleSmall!.weight(FontWeight.w600),
                            ),
                            Text(
                              formatLineUpDate(lineUp.date),
                              style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Key and capo side by side — one row, so the chart stays near the top —
/// with listen links beneath when the song has any.
class _Controls extends StatelessWidget {
  const _Controls({required this.state, required this.controller});

  final SongDetailState state;
  final SongDetailController controller;

  @override
  Widget build(BuildContext context) {
    final capo = StepperTrack(
      label: state.capo > 0 ? 'Capo ${state.capo}' : 'No capo',
      decreaseLabel: 'Capo down',
      increaseLabel: 'Capo up',
      onDecrease: state.capo > 0 ? controller.capoDown : null,
      onIncrease: state.capo < maxCapo ? controller.capoUp : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (state.canTranspose) ...[
              Expanded(
                child: StepperTrack(
                  label: 'Key ${state.displayKey}',
                  decreaseLabel: 'Transpose down',
                  increaseLabel: 'Transpose up',
                  onDecrease: controller.transposeDown,
                  onIncrease: controller.transposeUp,
                ),
              ),
              const SizedBox(width: DaloySpace.s2),
            ],
            Expanded(child: capo),
          ],
        ),
        if (state.hasStreamingLinks) ...[
          const SizedBox(height: DaloySpace.s2),
          SongStreamingLinks(
            song: state.song!,
            // Without the in-app player (Windows), YouTube opens in the browser.
            onPlayYouTube: hasInAppPlayer ? () => context.push(Routes.songListen(state.song!.id)) : null,
          ),
        ],
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DaloySpace.s8),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 26, color: c.mutedForeground.withValues(alpha: 0.7)),
            const SizedBox(height: DaloySpace.s2),
            Text(message, style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
          ],
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + DaloyChrome.topBarHeight;
    return SkeletonPulse(
      child: Padding(
        padding: EdgeInsets.fromLTRB(DaloySpace.gutter(context), top + DaloySpace.s3, DaloySpace.gutter(context), 0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 116, height: 116, radius: 18),
                SizedBox(width: DaloySpace.s5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(widthFactor: 0.8, height: 26, radius: DaloyRadii.lg),
                      SizedBox(height: DaloySpace.s2),
                      SkeletonBox(widthFactor: 0.5, height: 16),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: DaloySpace.s6),
            SkeletonBox(height: 44, radius: DaloyRadii.xl),
            SizedBox(height: DaloySpace.s6),
            SkeletonBox(height: 220, radius: DaloyRadii.xl2),
          ],
        ),
      ),
    );
  }
}

class _NotAvailable extends StatelessWidget {
  const _NotAvailable();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(DaloySpace.s8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Song not available', style: context.text.headlineSmall),
          const SizedBox(height: DaloySpace.s2),
          Text(
            "This song hasn't synced to this device yet. Go back to the library and try again when online.",
            textAlign: TextAlign.center,
            style: context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s5),
          DaloyButton.outline(label: 'Back to library', onPressed: () => context.go(Routes.songs)),
        ],
      ),
    ),
  );
}
