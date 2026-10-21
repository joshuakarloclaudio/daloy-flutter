import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/platform.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/flow_artwork.dart';
import '../../../shared/widgets/hero_top_bar.dart';
import '../../../shared/widgets/split_view.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/mode_button.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../live/presentation/go_live_dialog.dart';
import '../../songs/presentation/song_actions.dart' show editSongChords, editSongLyrics;
import '../../sync/realtime_scope.dart';
import '../../sync/workspace_realtime.dart';
import '../application/line_up_detail_controller.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up.dart';
import 'line_up_actions.dart';
import 'widgets/line_up_cover.dart';
import 'widgets/setlist_row.dart';
import 'widgets/setlist_song_sheet.dart';

/// A line-up: its cover, the ways to use it (Perform, Practice, Present,
/// Listen) and the set. Reads only from Drift, so it opens offline. On
/// phones it's one column whose title collapses into the top bar; on
/// tablets the cover and actions hold the left while the set scrolls.
class LineUpDetailScreen extends ConsumerStatefulWidget {
  const LineUpDetailScreen({super.key, required this.lineUpId});

  final int lineUpId;

  @override
  ConsumerState<LineUpDetailScreen> createState() => _LineUpDetailScreenState();
}

class _LineUpDetailScreenState extends ConsumerState<LineUpDetailScreen> {
  final _hero = HeroScrollState();

  /// What was on screen before the line-up left Drift — kept while a delete
  /// pops this screen, so its exit doesn't flash "not found".
  LineUpDetailState? _last;

  @override
  void dispose() {
    _hero.dispose();
    super.dispose();
  }

  void _back() {
    final router = GoRouter.of(context);
    router.canPop() ? router.pop() : router.go(Routes.lineUps);
  }

  void _openSong(SetlistSong song) => showSetlistSongSheet(context, lineUpId: widget.lineUpId, position: song.position);

  List<DaloyMenuItem> _songMenuItems(SetlistSong song) => [
    DaloyMenuItem(icon: TablerIcons.eye, label: 'Preview in this key', onSelected: () => _openSong(song)),
    DaloyMenuItem(
      icon: TablerIcons.layout_rows,
      label: 'Arrange sections',
      onSelected: () => context.push(Routes.lineUpPrepare(widget.lineUpId, song: song.entry.song.id)),
    ),
    DaloyMenuItem(
      icon: TablerIcons.note,
      label: 'Team notes',
      onSelected: () => context.push(Routes.lineUpPrepare(widget.lineUpId, song: song.entry.song.id, notes: true)),
    ),
    DaloyMenuItem(
      icon: TablerIcons.pencil,
      label: song.hasChords ? 'Edit chords' : 'Add chords',
      onSelected: () => editSongChords(context, ref, song.entry.song),
    ),
    DaloyMenuItem(
      icon: TablerIcons.align_left,
      label: song.hasLyrics ? 'Edit lyrics' : 'Add lyrics',
      onSelected: () => editSongLyrics(context, ref, song.entry.song),
    ),
    DaloyMenuItem(
      icon: TablerIcons.music,
      label: 'Open song',
      onSelected: () => context.push(Routes.song(song.entry.song.id)),
    ),
  ];

  void _needsSongs(String what) {
    HapticFeedback.lightImpact();
    showDaloyToast(ScaffoldMessenger.of(context), 'Add songs to this line-up to $what.');
  }

  void _go(String route) {
    HapticFeedback.lightImpact();
    context.push(route);
  }

  /// Joining a session already running needs no asking; starting one does.
  Future<void> _goLive(LineUp lineUp, {required bool joining}) async {
    if (joining) return _go(Routes.perform(lineUp.id));
    if (!await confirmGoLive(context, title: lineUp.title) || !mounted) return;
    _go(Routes.performLive(lineUp.id));
  }

  @override
  Widget build(BuildContext context) {
    listenRemoteChanges(ref, context, RemoteKind.lineUp, widget.lineUpId);
    var state = ref.watch(lineUpDetailControllerProvider(widget.lineUpId));
    if (state.lineUp != null) {
      _last = state;
    } else if (_last != null) {
      state = _last!;
    }
    final lineUp = state.lineUp;
    // Beside the list in a split view, one column (hero over setlist).
    final wide = !SplitPane.of(context) && MediaQuery.sizeOf(context).width >= DaloyBreakpoints.tablet;

    final Widget body;
    if (state.isLoading) {
      body = const _DetailSkeleton();
    } else if (lineUp == null) {
      body = const _NotFound();
    } else {
      final live = ref.watch(activeLiveSessionProvider).value?.lineUpId == lineUp.id;
      final hero = _Hero(
        lineUp: lineUp,
        state: state,
        live: live,
        titleKey: _hero.titleKey,
        onGoLive: state.hasSongs ? () => _goLive(lineUp, joining: live) : () => _needsSongs('go live'),
        onPractice: state.hasSongs ? () => _go(Routes.practice(lineUp.id)) : () => _needsSongs('practice it'),
        onPresent: state.hasSongs ? () => _go(Routes.present(lineUp.id)) : () => _needsSongs('present it'),
        onPrepare: state.hasSongs ? () => _go(Routes.lineUpPrepare(lineUp.id)) : () => _needsSongs('prepare it'),
        onListen: state.canListen
            ? () => _go(Routes.listen(lineUp.id))
            : () {
                HapticFeedback.lightImpact();
                showDaloyToast(ScaffoldMessenger.of(context), 'Add YouTube links to these songs to listen.');
              },
      );
      final setlist = _SetlistSliver(
        state: state,
        onOpen: _openSong,
        menu: _songMenuItems,
        onAddSongs: () => context.push(Routes.lineUpEdit(lineUp.id)),
      );
      body = NotificationListener<ScrollNotification>(
        onNotification: (n) => _hero.handle(context, n),
        child: wide
            ? _WideLayout(lineUp: lineUp, hero: hero, setlist: setlist)
            : _PhoneLayout(hero: hero, setlist: setlist),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HeroTopBar(
              title: lineUp?.title,
              scrolled: _hero.scrolled,
              titleHidden: wide ? _hero.never : _hero.titleHidden,
              onBack: _back,
              actions: [
                if (lineUp != null && !lineUp.isPending) ...[
                  Builder(
                    builder: (context) => TopBarIconButton(
                      icon: Theme.of(context).platform.isApple ? TablerIcons.share_2 : TablerIcons.share,
                      tooltip: 'Share',
                      onPressed: () => shareLineUpLink(context, ref, lineUp),
                    ),
                  ),
                  TopBarIconButton(
                    icon: TablerIcons.pencil,
                    tooltip: 'Edit line-up',
                    onPressed: () => context.push(Routes.lineUpEdit(lineUp.id)),
                  ),
                  DaloyMenuButton(
                    tooltip: 'More actions',
                    icon: Theme.of(context).platform.isApple ? TablerIcons.dots : TablerIcons.dots_vertical,
                    items: lineUpMenuItems(context, ref, lineUp, onDetails: true),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -- Layouts -------------------------------------------------------------------

class _PhoneLayout extends StatelessWidget {
  const _PhoneLayout({required this.hero, required this.setlist});

  final Widget hero;
  final Widget setlist;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + DaloySpace.s8;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: hero),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(DaloySpace.s3, DaloySpace.s2, DaloySpace.gutter(context), bottom),
          sliver: setlist,
        ),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.lineUp, required this.hero, required this.setlist});

  final LineUp lineUp;
  final Widget hero;
  final Widget setlist;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final padding = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final paneWidth = width >= DaloyBreakpoints.wide ? 420.0 : 360.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: paneWidth + padding.left,
          // The pane's own scroll stays out of the top bar's "scrolled" cue.
          child: NotificationListener<ScrollNotification>(
            onNotification: (_) => true,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: padding.left, bottom: padding.bottom + DaloySpace.s6),
              child: hero,
            ),
          ),
        ),
        SizedBox(width: 0.5, child: ColoredBox(color: c.border)),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  DaloySpace.s4,
                  padding.top + DaloyChrome.topBarHeight + DaloySpace.s4,
                  DaloySpace.s8 + padding.right,
                  padding.bottom + DaloySpace.s8,
                ),
                sliver: setlist,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -- Hero ----------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({
    required this.lineUp,
    required this.state,
    required this.titleKey,
    required this.onGoLive,
    required this.onPractice,
    required this.onPresent,
    required this.onListen,
    required this.onPrepare,
    this.live = false,
  });

  final LineUp lineUp;
  final LineUpDetailState state;

  /// The team is performing this line-up now: the main action joins them.
  final bool live;
  final Key titleKey;
  final VoidCallback onGoLive;
  final VoidCallback onPractice;
  final VoidCallback onPresent;
  final VoidCallback onListen;

  /// Notes and section order for this service.
  final VoidCallback onPrepare;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final top = MediaQuery.paddingOf(context).top + DaloyChrome.topBarHeight;
    final isToday = lineUpDayChip(lineUp.date) == DayChip.today;
    final meta = [
      lineUp.leader == null ? 'No worship leader yet' : 'Led by ${lineUp.leader}',
      lineUpSongsLabel(lineUp.songsCount),
    ].join(' · ');

    return Stack(
      children: [
        // The cover's colour, washed behind the top of the page.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: top + 340,
          child: ArtworkWash(palette: lineUpPalette(lineUp), background: c.background),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(DaloySpace.gutter(context), top + DaloySpace.s3, DaloySpace.gutter(context), 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: StaggeredColumn(
                children: [
                  Center(
                    child: LineUpCover(lineUp: lineUp, keyFlow: state.keyFlow),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: DaloySpace.s6),
                      _DayLine(date: lineUp.date),
                      const SizedBox(height: DaloySpace.s2),
                      Text(
                        lineUp.title,
                        key: titleKey,
                        textAlign: TextAlign.center,
                        style: context.text.displaySmall!.copyWith(fontSize: 28),
                      ),
                      const SizedBox(height: DaloySpace.s1_5),
                      Text(
                        meta,
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                      ),
                      if (state.hasPendingChanges) ...[
                        const SizedBox(height: DaloySpace.s2),
                        _SyncNote(online: state.isOnline),
                      ],
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: DaloySpace.s6),
                    child: Row(
                      children: [
                        Expanded(
                          child: ModeButton(
                            icon: TablerIcons.broadcast,
                            label: live ? 'Join live' : 'Go live',
                            filled: true,
                            today: isToday,
                            dimmed: !state.hasSongs,
                            onPressed: onGoLive,
                          ),
                        ),
                        const SizedBox(width: DaloySpace.s3),
                        Expanded(
                          child: ModeButton(
                            icon: TablerIcons.metronome,
                            label: 'Practice',
                            dimmed: !state.hasSongs,
                            onPressed: onPractice,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: DaloySpace.s2),
                    child: Row(
                      children: [
                        Expanded(
                          child: QuietAction(
                            icon: TablerIcons.presentation,
                            label: 'Present',
                            dimmed: !state.hasSongs,
                            onPressed: onPresent,
                          ),
                        ),
                        if (hasInAppPlayer)
                          Expanded(
                            child: QuietAction(
                              icon: TablerIcons.headphones,
                              label: 'Listen',
                              dimmed: !state.canListen,
                              onPressed: onListen,
                            ),
                          ),
                        Expanded(
                          child: QuietAction(
                            icon: TablerIcons.adjustments_horizontal,
                            label: 'Prepare',
                            dimmed: !state.hasSongs,
                            onPressed: onPrepare,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "TODAY · Sunday, October 19" — the chip only when it's today or tomorrow.
class _DayLine extends StatelessWidget {
  const _DayLine({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chip = lineUpDayChip(date);
    final full = DateFormat.MMMMEEEEd().format(DateTime.parse('${date}T12:00:00'));
    final dateStyle = context.text.titleSmall!.copyWith(color: c.mutedForeground);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DaloySpace.s2,
      runSpacing: DaloySpace.s1,
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
          null => const SizedBox.shrink(),
        },
        Text(_relative(date) == null ? full : '$full · ${_relative(date)}', style: dateStyle),
      ],
    );
  }

  /// "in 5 days" / "2 weeks ago" — only when no chip says it already.
  static String? _relative(String date) {
    if (lineUpDayChip(date) != null) return null;
    final today = DateTime.parse('${todayIsoLocal()}T12:00:00');
    final days = DateTime.parse('${date}T12:00:00').difference(today).inDays;
    if (days > 1 && days < 14) return 'in $days days';
    if (days >= 14 && days < 60) return 'in ${days ~/ 7} weeks';
    if (days == -1) return 'yesterday';
    if (days < -1 && days > -14) return '${-days} days ago';
    if (days <= -14 && days > -60) return '${-days ~/ 7} weeks ago';
    return null;
  }
}

class _SyncNote extends StatelessWidget {
  const _SyncNote({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(online ? TablerIcons.refresh : TablerIcons.cloud_off, size: 14, color: c.mutedForeground),
        const SizedBox(width: DaloySpace.s1_5),
        Flexible(
          child: Text(
            online ? 'Syncing your changes…' : "Changes saved on this device. They'll sync when you're online.",
            textAlign: TextAlign.center,
            style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
          ),
        ),
      ],
    );
  }
}

// -- Setlist ---------------------------------------------------------------------

class _SetlistSliver extends StatelessWidget {
  const _SetlistSliver({required this.state, required this.onOpen, required this.menu, required this.onAddSongs});

  final LineUpDetailState state;
  final ValueChanged<SetlistSong> onOpen;
  final List<DaloyMenuItem> Function(SetlistSong song) menu;
  final VoidCallback onAddSongs;

  @override
  Widget build(BuildContext context) {
    final songs = state.songs;
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(DaloySpace.s2, DaloySpace.s6, 0, DaloySpace.s2),
      child: const SectionLabel('Setlist'),
    );

    if (songs.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            Padding(
              padding: const EdgeInsets.only(left: DaloySpace.s2, top: DaloySpace.s1),
              child: state.songsMissing
                  ? InsetPlaceholder(
                      icon: state.isOnline ? TablerIcons.loader_2 : TablerIcons.cloud_off,
                      title: state.isOnline ? 'Loading songs…' : 'Songs not on this device yet',
                      body: state.isOnline
                          ? null
                          : 'Open this line-up once while online to keep its songs for offline use.',
                    )
                  : InsetPlaceholder(
                      icon: TablerIcons.music_plus,
                      title: 'No songs yet',
                      body: 'Build the set: add songs and pick a key for each.',
                      action: DaloyButton(label: 'Add songs', icon: TablerIcons.plus, onPressed: onAddSongs),
                    ),
            ),
          ],
        ),
      );
    }

    return SliverList.builder(
      itemCount: songs.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return header;
        final song = songs[i - 1];
        return SetlistRow(
          key: ValueKey(song.position),
          song: song,
          showDivider: i < songs.length,
          onTap: () => onOpen(song),
          menu: () => menu(song),
        );
      },
    );
  }
}

// -- Loading / missing -------------------------------------------------------------

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + DaloyChrome.topBarHeight;
    return SkeletonPulse(
      child: Padding(
        padding: EdgeInsets.fromLTRB(DaloySpace.gutter(context), top + DaloySpace.s3, DaloySpace.gutter(context), 0),
        child: Column(
          children: [
            const SkeletonBox(width: 184, height: 184, radius: 28),
            const SizedBox(height: DaloySpace.s6),
            const SkeletonBox(width: 160, height: 14),
            const SizedBox(height: DaloySpace.s3),
            const SkeletonBox(width: 220, height: 28, radius: DaloyRadii.lg),
            const SizedBox(height: DaloySpace.s6),
            Row(
              children: const [
                Expanded(child: SkeletonBox(height: 52, radius: 16)),
                SizedBox(width: DaloySpace.s3),
                Expanded(child: SkeletonBox(height: 52, radius: 16)),
              ],
            ),
            const SizedBox(height: DaloySpace.s8),
            for (var i = 0; i < 4; i++) ...[
              const SkeletonBox(height: 48, radius: DaloyRadii.lg),
              const SizedBox(height: DaloySpace.s3),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(DaloySpace.s8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Line-up not found', style: context.text.headlineSmall),
          const SizedBox(height: DaloySpace.s2),
          Text(
            "It may have been removed, or it hasn't synced to this device yet.",
            textAlign: TextAlign.center,
            style: context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s5),
          DaloyButton.outline(label: 'Back to line-ups', onPressed: () => context.go(Routes.lineUps)),
        ],
      ),
    ),
  );
}
