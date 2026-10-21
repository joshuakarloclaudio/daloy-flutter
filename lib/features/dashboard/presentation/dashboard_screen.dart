import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../line_ups/presentation/widgets/line_up_cover.dart';
import '../../../shared/widgets/flow_artwork.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_top_bar.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../../shared/widgets/pull_to_refresh.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../../shell/primary_action.dart';
import '../../../shell/shell_layout.dart';
import '../../line_ups/data/line_ups_repository.dart';
import '../../line_ups/domain/line_up.dart';
import '../../line_ups/presentation/line_up_actions.dart';
import '../../line_ups/presentation/line_up_list_row.dart';
import '../../line_ups/presentation/new_line_up_sheet.dart';
import '../../live/presentation/go_live_dialog.dart';
import '../../search/presentation/search_button.dart';
import '../../songs/application/song_sync.dart';
import '../../songs/data/songs_repository.dart';
import '../../songs/domain/song.dart';
import '../../songs/presentation/new_song_sheet.dart';
import '../../songs/presentation/song_actions.dart';
import '../../songs/presentation/song_list_row.dart';
import '../../workspaces/presentation/workspace_switcher.dart';
import '../application/dashboard_controller.dart';
import 'widgets/dashboard_skeletons.dart';
import 'widgets/empty_section.dart';
import 'widgets/featured_line_up_card.dart';
import 'widgets/home_section.dart';
import 'widgets/live_session_card.dart';
import 'widgets/recent_shelf.dart';

/// Home. Renders [DashboardController] state; holds no logic of its own
/// beyond wiring taps to routes.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  /// A pull-to-refresh is running — its own indicator already shows, so the
  /// top bar's sync spinner stays out of the way.
  bool _pulling = false;

  Future<void> _pullRefresh() async {
    setState(() => _pulling = true);
    try {
      await ref.read(dashboardControllerProvider.notifier).refresh();
    } finally {
      if (mounted) setState(() => _pulling = false);
    }
  }

  /// Joining a session already running needs no asking; starting one does.
  Future<void> _goLive(LineUp lineUp) async {
    if (ref.read(activeLiveSessionProvider).value?.lineUpId == lineUp.id) {
      await context.push(Routes.perform(lineUp.id));
      return;
    }
    if (!await confirmGoLive(context, title: lineUp.title) || !mounted) return;
    await context.push(Routes.performLive(lineUp.id));
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);
    final isWide = ShellLayout.of(context).wide;
    final gutter = DaloySpace.gutter(context);

    void openSong(Song song) {
      controller.recordSongOpened(song);
      context.push(Routes.song(song.id));
    }

    final sync = ref.watch(songSyncProvider);

    // A song the server hasn't accepted yet can't be opened, only dropped
    // (as on the Songs list).
    void showPending(Song song) => askDiscardPendingSong(
      context,
      song,
      error: sync[song.id]?.error,
      onDiscard: () => ref.read(songsRepositoryProvider).discardPending(song.id),
    );

    final songsBand = HomeSection(
      label: 'Recently added',
      onViewAll: page.recentSongs.isEmpty ? null : () => context.go(Routes.songs),
      child: page.showSkeletons
          ? const HomeList(
              key: ValueKey('skeleton'),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: HomeSection.bleed),
                  child: RowSkeletons(),
                ),
              ],
            )
          : page.recentSongs.isEmpty
          ? EmptySection(
              compact: true,
              icon: TablerIcons.music,
              title: 'No songs yet',
              description: 'Add your first song to start building the library.',
              action: page.isOnline
                  ? DaloyButton(
                      variant: ButtonVariant.link,
                      label: 'Add a song',
                      icon: TablerIcons.plus,
                      size: ControlSize.sm,
                      onPressed: () => showNewSongSheet(context),
                    )
                  : null,
            )
          : HomeList(
              children: [
                for (final song in page.recentSongs)
                  SongListRow(
                    song: song,
                    sync: sync[song.id],
                    onTap: () => song.isPending ? showPending(song) : openSong(song),
                    menu: () => song.isPending
                        ? pendingSongMenuItems(
                            context,
                            song,
                            error: sync[song.id]?.error,
                            onDiscard: () => ref.read(songsRepositoryProvider).discardPending(song.id),
                          )
                        : songMenuItems(context, ref, song),
                  ),
              ],
            ),
    );

    final lineUpsBand = HomeSection(
      label: 'Line-ups',
      onViewAll: page.recentLineUps.isEmpty ? null : () => context.go(Routes.lineUps),
      child: page.showSkeletons
          ? const HomeList(
              key: ValueKey('skeleton'),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: HomeSection.bleed),
                  child: RowSkeletons(),
                ),
              ],
            )
          : page.recentLineUps.isEmpty
          ? EmptySection(
              compact: true,
              icon: TablerIcons.layout_list,
              title: 'No line-ups yet',
              description: "Assemble a setlist when you're ready to plan.",
              action: DaloyButton(
                variant: ButtonVariant.link,
                label: 'Create a line-up',
                size: ControlSize.sm,
                onPressed: () => startNewLineUp(context),
              ),
            )
          : HomeList(
              children: [
                for (final lineUp in page.recentLineUps)
                  LineUpListRow(
                    lineUp: lineUp,
                    onTap: () =>
                        context.push(lineUp.isPending ? Routes.lineUpEdit(lineUp.id) : Routes.lineUp(lineUp.id)),
                    menu: () => lineUpMenuItems(context, ref, lineUp),
                  ),
              ],
            ),
    );

    // The menu opens from the button, wherever that is: the detached + at the
    // tab bar on a phone, the top bar's on a tablet.
    void create(Rect anchor) => showDaloyMenu(
      context,
      anchor: anchor,
      items: [
        DaloyMenuItem(icon: TablerIcons.music, label: 'New song', onSelected: () => showNewSongSheet(context)),
        DaloyMenuItem(icon: TablerIcons.layout_list, label: 'New line-up', onSelected: () => startNewLineUp(context)),
      ],
    );

    final sections = [
      if (page.showLiveSection)
        HomeSection(
          label: 'Live now',
          child: page.liveSession == null
              ? const FeaturedCardSkeleton()
              : LiveSessionCard(
                  session: page.liveSession!,
                  lineUp: page.liveSessionLineUp,
                  onOpen: () => context.push(Routes.lineUp(page.liveSession!.lineUpId)),
                  onJoin: () => context.push(Routes.perform(page.liveSession!.lineUpId)),
                ),
        ),
      HomeSection(
        label: 'Up next',
        child: page.showSkeletons
            ? const FeaturedCardSkeleton()
            : page.featuredLineUp == null
            ? EmptySection(
                icon: TablerIcons.layout_list,
                title: 'No upcoming services',
                description: "Plan your next worship set so the team knows what's coming.",
                action: DaloyButton(
                  variant: ButtonVariant.link,
                  label: 'Create a line-up',
                  icon: TablerIcons.plus,
                  size: ControlSize.sm,
                  onPressed: () => startNewLineUp(context),
                ),
              )
            : FeaturedLineUpCard(
                lineUp: page.featuredLineUp!,
                onOpen: () => context.push(
                  page.featuredLineUp!.isPending
                      ? Routes.lineUpEdit(page.featuredLineUp!.id)
                      : Routes.lineUp(page.featuredLineUp!.id),
                ),
                onGoLive: () => _goLive(page.featuredLineUp!),
                onPractice: () => context.push(Routes.practice(page.featuredLineUp!.id)),
                menu: () => lineUpMenuItems(context, ref, page.featuredLineUp!),
              ),
      ),
      if (page.jumpBackInSongs.isNotEmpty)
        HomeSection(
          label: 'Jump back in',
          child: RecentShelf(songs: page.jumpBackInSongs, onOpen: openSong),
        ),
    ];

    final featured = page.featuredLineUp;

    return RegisterPrimaryAction(
      branch: 0,
      label: 'Create',
      icon: TablerIcons.plus,
      onPressed: create,
      child: _wash(
        featured,
        Scaffold(
          backgroundColor: featured == null ? null : Colors.transparent,
          appBar: DaloyTopBar(
            washed: featured != null,
            // A tablet's shell already carries the workspace (top bar, sidebar);
            // phones put the switcher in the bar.
            title: isWide ? 'Home' : null,
            titleWidget: isWide ? null : const WorkspaceSwitcherHeading(),
            actions: [
              // Background sync shows as a quiet spinner; pulling down is how
              // you ask for one.
              if (page.isSyncing && !_pulling)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: DaloySpace.s2),
                  child: DaloySpinner(size: 18),
                ),
              const TopBarSearchButton(),
              // Line-ups can be created offline; they sync on reconnect. A phone
              // has the detached + at the tab bar; a tablet has no tab bar.
              if (isWide)
                Builder(
                  builder: (buttonContext) => PrimaryActionButton(
                    icon: TablerIcons.plus,
                    label: 'Create',
                    onPressed: () => create(anchorOf(buttonContext)),
                  ),
                ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= DaloyBreakpoints.wide;
              // Centre a capped column while keeping the scroll view (and its
              // scrollbar and overscroll) full width.
              final side = math.max(gutter, (constraints.maxWidth - DaloyBreakpoints.contentMaxWidth) / 2);

              return PullToRefreshScrollView(
                onRefresh: page.isOnline ? _pullRefresh : null,
                slivers: [
                  SliverPadding(
                    // Wider by the bleed, so Home's lists reach into the gutter;
                    // everything else pads itself back in.
                    padding: EdgeInsets.fromLTRB(
                      side - HomeSection.bleed,
                      DaloySpace.s2,
                      side - HomeSection.bleed,
                      DaloySpace.s10 + DaloyChrome.fabSize + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: SliverList.list(
                      children: [
                        Entrance(
                          index: 0,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: HomeSection.bleed),
                            child: _Header(page: page),
                          ),
                        ),
                        for (final (i, section) in sections.indexed) ...[
                          const SizedBox(height: DaloySpace.s6),
                          Entrance(key: ValueKey(section.label), index: i + 1, child: section),
                        ],
                        const SizedBox(height: DaloySpace.s6),
                        if (wide)
                          Entrance(
                            index: sections.length + 1,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 11, child: songsBand),
                                // The bands' bleeds already part them by 2 × bleed.
                                const SizedBox(width: DaloySpace.s8 - HomeSection.bleed * 2),
                                Expanded(flex: 9, child: lineUpsBand),
                              ],
                            ),
                          )
                        else ...[
                          Entrance(index: sections.length + 1, child: songsBand),
                          const SizedBox(height: DaloySpace.s6),
                          Entrance(index: sections.length + 2, child: lineUpsBand),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// What's up next lends Home its colour, as its cover does on its page.
  Widget _wash(LineUp? featured, Widget child) =>
      featured == null ? child : PageWash(palette: lineUpPalette(featured), child: child);
}

/// The large title: today's date as an overline, the greeting in the
/// serif, and one line about what's next.
class _Header extends StatelessWidget {
  const _Header({required this.page});

  final DashboardState page;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()).toUpperCase(),
          style: context.text.labelMedium!
              .copyWith(color: c.mutedForeground, letterSpacing: 0.6)
              .weight(FontWeight.w600),
        ),
        const SizedBox(height: DaloySpace.s1),
        Text('${greeting()}, ${page.displayName}', style: context.text.displaySmall!.copyWith(fontSize: 30)),
        const SizedBox(height: DaloySpace.s1_5),
        Text(page.subtitle, style: context.text.bodyLarge!.copyWith(color: c.mutedForeground, height: 1.4)),
        if (!page.isOnline) ...[const SizedBox(height: DaloySpace.s3), const _OfflineBanner()],
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s1_5),
      decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(TablerIcons.wifi_off, size: 14, color: c.mutedForeground),
          const SizedBox(width: DaloySpace.s1_5),
          Flexible(
            child: Text(
              'Offline · showing your saved library',
              style: context.text.labelMedium!.copyWith(color: c.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}
