import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/connectivity/online_status.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_menu.dart';
import '../../../../shared/widgets/daloy_spinner.dart';
import '../../../../shared/widgets/daloy_toast.dart';
import '../../../../shared/widgets/daloy_top_bar.dart';
import '../../../../shared/widgets/filter_pill.dart';
import '../../../../shared/widgets/list_header.dart';
import '../../../../shared/widgets/list_states.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/pull_to_refresh.dart';
import '../../../../shared/widgets/skeleton.dart';
import '../../../../shared/widgets/staggered_entrance.dart';
import '../../../../shell/shell_layout.dart';
import '../../../auth/application/session_controller.dart';
import '../../../songs/presentation/widgets/song_key_chip.dart';
import '../../../songs/presentation/widgets/song_list_sheets.dart';
import '../../application/discover_controller.dart';
import '../../data/network_songs_repository.dart';
import '../../domain/discover_query.dart';
import '../../domain/network_song.dart';
import '../network_song_sheet.dart';
import '../search_button.dart';
import 'discover_song_card.dart';
import 'songs_segment_switch.dart';

/// Discover — songs other teams shared, to browse and add to your own
/// library. The other half of the Songs tab (the web's "Song Network").
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  int? _adding;

  @override
  void initState() {
    super.initState();
    _search.text = ref.read(discoverControllerProvider).query.search;
    _scroll.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  DiscoverController get _controller => ref.read(discoverControllerProvider.notifier);

  void _maybeLoadMore() {
    if (_scroll.hasClients && _scroll.position.extentAfter < 600) unawaited(_controller.loadMore());
  }

  void _toTop() {
    if (_scroll.hasClients && _scroll.offset > 0) _scroll.jumpTo(0);
  }

  void _clearAll() {
    _search.clear();
    _controller
      ..setSearch('')
      ..clearFilters();
    _toTop();
  }

  Future<void> _pickSort(BuildContext pillContext) async {
    final query = ref.read(discoverControllerProvider).query;
    final sort = await showDaloyChoiceMenu(
      pillContext,
      title: 'Sort by',
      options: [for (final s in DiscoverSort.values) (s, s.label)],
      current: query.sort,
    );
    if (sort == null) return;
    _controller.setSort(sort);
    _toTop();
  }

  Future<void> _pickKey(BuildContext pill) async {
    final result = await showKeySheet(context, ref.read(discoverControllerProvider).query.key, anchor: anchorOf(pill));
    if (result == null) return;
    _controller.setKey(result.key);
    _toTop();
  }

  Future<void> _pickTempo(BuildContext pillContext) async {
    final current = ref.read(discoverControllerProvider).query.tempo;
    final picked = await showDaloyChoiceMenu<String>(
      pillContext,
      title: 'Tempo',
      options: [('any', 'Any tempo'), for (final t in DiscoverTempo.values) (t.name, '${t.label} · ${t.range} BPM')],
      current: current?.name ?? 'any',
    );
    if (picked == null) return;
    _controller.setTempo(DiscoverTempo.values.where((t) => t.name == picked).firstOrNull);
    _toTop();
  }

  void _open(NetworkSong song) => showNetworkSongSheet(context, song);

  Future<void> _quickAdd(NetworkSong song) async {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId == null || _adding != null) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    void toast(String message, {String? actionLabel, VoidCallback? onAction}) =>
        showDaloyToast(messenger, message, actionLabel: actionLabel, onAction: onAction);
    setState(() => _adding = song.id);
    try {
      final id = await ref.read(networkSongsRepositoryProvider).addToLibrary(song.id, workspaceId);
      _controller.markAdded(song.id);
      unawaited(HapticFeedback.mediumImpact());
      toast(
        'Added “${song.title}” to your library.',
        actionLabel: 'Open',
        onAction: () => router.push(Routes.song(id)),
      );
    } on NetworkException {
      toast("You're offline. Connect to add this song.");
    } on ApiException catch (e) {
      toast(e.message);
    } finally {
      if (mounted) setState(() => _adding = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverControllerProvider);
    final online = ref.watch(isOnlineProvider);
    final query = state.query;
    final gutter = DaloySpace.gutter(context);
    final isFiltering = !query.isDefault;
    final showShared = state.shared.isNotEmpty && !isFiltering;

    final isWide = ShellLayout.of(context).wide;

    return Scaffold(
      appBar: const DaloyTopBar(title: 'Discover', largeTitle: true, actions: [TopBarSearchButton()]),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final side = math.max(gutter, (constraints.maxWidth - DaloyBreakpoints.contentMaxWidth) / 2);
          final wide = constraints.maxWidth >= DaloyBreakpoints.tablet;

          return EntranceScope(
            ready: !state.loading,
            child: PullToRefreshScrollView(
              controller: _scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              onRefresh: online ? _controller.refresh : null,
              slivers: [
                SliverLargeTitle('Discover', inset: side, trailing: isWide ? const SongsSegmentSwitch() : null),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: side - gutter),
                    child: ListHeader(
                      searchController: _search,
                      searchHint: 'Search shared songs',
                      onSearchChanged: (v) {
                        _controller.setSearch(v);
                        _toTop();
                      },
                      chips: [
                        Builder(
                          builder: (pillContext) => FilterPill(
                            label: query.sort.label,
                            icon: TablerIcons.arrows_sort,
                            onTap: () => _pickSort(pillContext),
                          ),
                        ),
                        Builder(
                          builder: (pillContext) => FilterPill(
                            label: query.key == null ? 'Key' : 'Key: ${query.key}',
                            icon: TablerIcons.chevron_down,
                            trailingIcon: true,
                            active: query.key != null,
                            onTap: () => _pickKey(pillContext),
                          ),
                        ),
                        Builder(
                          builder: (pillContext) => FilterPill(
                            label: query.tempo?.label ?? 'Tempo',
                            icon: TablerIcons.chevron_down,
                            trailingIcon: true,
                            active: query.tempo != null,
                            onTap: () => _pickTempo(pillContext),
                          ),
                        ),
                        if (query.hasFilters)
                          FilterPill(label: 'Clear', icon: TablerIcons.x, quiet: true, onTap: _controller.clearFilters),
                      ],
                    ),
                  ),
                ),
                if (showShared)
                  SliverToBoxAdapter(
                    child: _SharedByUs(songs: state.shared, side: side, onOpen: _open),
                  ),
                if (state.offline && state.songs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(side, 0, side, DaloySpace.s3),
                      child: Row(
                        children: [
                          Icon(TablerIcons.cloud_off, size: 16, color: context.colors.mutedForeground),
                          const SizedBox(width: DaloySpace.s2),
                          Expanded(
                            child: Text(
                              'Offline. These may be out of date.',
                              style: context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (state.loading)
                  const SliverToBoxAdapter(child: _CardSkeleton())
                else if (state.offline && state.songs.isEmpty)
                  SliverToBoxAdapter(
                    child: ListEmptyState(
                      icon: TablerIcons.cloud_off,
                      title: "You're offline",
                      description: 'Discover needs a connection. Your library is still here.',
                      actionLabel: 'Try again',
                      onAction: _controller.refresh,
                    ),
                  )
                else if (state.error != null && state.songs.isEmpty)
                  SliverToBoxAdapter(
                    child: ListEmptyState(
                      icon: TablerIcons.alert_circle,
                      title: "Couldn't load songs",
                      description: state.error!,
                      actionLabel: 'Try again',
                      onAction: _controller.refresh,
                    ),
                  )
                else if (state.songs.isEmpty)
                  SliverToBoxAdapter(
                    child: isFiltering
                        ? ListEmptyState(
                            icon: TablerIcons.search_off,
                            title: 'Nothing found',
                            description: 'No shared songs match. Try fewer filters.',
                            actionLabel: 'Clear search & filters',
                            onAction: _clearAll,
                          )
                        : const ListEmptyState(
                            icon: TablerIcons.compass,
                            title: 'Nothing shared yet',
                            description: 'When teams share songs, they show up here. Share one of yours from its menu.',
                          ),
                  )
                else ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(side, DaloySpace.s2, side, 0),
                    sliver: SliverOpacity(
                      opacity: state.refreshing ? 0.5 : 1,
                      sliver: wide
                          ? SliverGrid.builder(
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 480,
                                mainAxisExtent: MediaQuery.textScalerOf(context).scale(172),
                                crossAxisSpacing: DaloySpace.s3,
                                mainAxisSpacing: DaloySpace.s3,
                              ),
                              itemCount: state.songs.length,
                              itemBuilder: (_, i) => _card(state.songs[i], i),
                            )
                          : SliverList.separated(
                              itemCount: state.songs.length,
                              separatorBuilder: (_, _) => const SizedBox(height: DaloySpace.s3),
                              itemBuilder: (_, i) => _card(state.songs[i], i),
                            ),
                    ),
                  ),
                  if (state.loadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(DaloySpace.s6),
                        child: Center(child: DaloySpinner(size: 20)),
                      ),
                    ),
                ],
                SliverToBoxAdapter(child: SizedBox(height: DaloySpace.s10 + MediaQuery.paddingOf(context).bottom)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card(NetworkSong song, int index) => Entrance(
    key: ValueKey(song.id),
    index: index,
    child: DiscoverSongCard(
      song: song,
      adding: _adding == song.id,
      onTap: () => _open(song),
      onAdd: () => _quickAdd(song),
    ),
  );
}

/// Our team's own shared songs: a quiet strip, tap one to see it as others
/// do — and to stop sharing it.
class _SharedByUs extends StatelessWidget {
  const _SharedByUs({required this.songs, required this.side, required this.onOpen});

  final List<NetworkSong> songs;
  final double side;
  final ValueChanged<NetworkSong> onOpen;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: DaloySpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(side, 0, side, DaloySpace.s2),
            child: Row(
              children: [
                Text('Shared by us', style: context.text.titleSmall!.copyWith(color: c.mutedForeground)),
                const SizedBox(width: DaloySpace.s2),
                Text('${songs.length}', style: context.text.labelMedium!.copyWith(color: c.mutedForeground)),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.textScalerOf(context).scale(64),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: side),
              itemCount: songs.length,
              separatorBuilder: (_, _) => const SizedBox(width: DaloySpace.s2),
              itemBuilder: (_, i) {
                final song = songs[i];
                return Pressable(
                  onPressed: () => onOpen(song),
                  child: Container(
                    width: 190,
                    padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2),
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.07),
                      border: Border.all(color: c.primary.withValues(alpha: 0.2)),
                      borderRadius: DaloyRadii.all(DaloyRadii.xl),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: context.text.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                song.importCount == 0
                                    ? 'Not added yet'
                                    : (song.importCount == 1
                                          ? 'Added by 1 team'
                                          : 'Added by ${song.importCount} teams'),
                                style: context.text.labelMedium!.copyWith(color: c.mutedForeground),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SongKeyChip(keyName: song.key),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    final gutter = DaloySpace.gutter(context);
    return SkeletonPulse(
      child: Column(
        children: [
          for (var i = 0; i < 4; i++)
            Padding(
              padding: EdgeInsets.fromLTRB(gutter, DaloySpace.s2, gutter, DaloySpace.s1),
              child: const SkeletonBox(width: double.infinity, height: 132, radius: DaloyRadii.xl2),
            ),
        ],
      ),
    );
  }
}
