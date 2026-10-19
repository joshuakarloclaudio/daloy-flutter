import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_top_bar.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/pinned_section_header.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../../shared/widgets/pull_to_refresh.dart';
import '../../../shared/widgets/split_view.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../../shell/primary_action.dart';
import '../../../shell/shell_layout.dart';
import '../../search/application/discover_controller.dart';
import '../../search/presentation/discover/discover_screen.dart';
import '../../search/presentation/discover/songs_segment_switch.dart';
import '../../search/presentation/search_button.dart';
import '../../sync/workspace_sync_controller.dart';
import '../application/song_list_controller.dart';
import '../application/song_sync.dart';
import '../data/songs_repository.dart';
import '../domain/song.dart';
import '../domain/song_list_query.dart';
import 'new_song_sheet.dart';
import 'song_actions.dart';
import 'song_detail_screen.dart';
import 'song_list_row.dart';
import 'widgets/alphabet_rail.dart';
import 'widgets/song_list_header.dart';

/// Below this many songs the index rail is more clutter than help.
const _railThreshold = 20;

/// The workspace song library: search, sort and filter run as SQL against
/// Drift; the list is fixed-extent slivers so only on-screen rows are built
/// or laid out, however large the library.
class SongsScreen extends ConsumerStatefulWidget {
  const SongsScreen({super.key});

  @override
  ConsumerState<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends ConsumerState<SongsScreen> {
  static const _searchDebounce = Duration(milliseconds: 200);

  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  bool _pulling = false;

  // Grouping is cached against the list it was built from, so scrolling
  // and unrelated rebuilds never regroup.
  List<Song>? _groupedFrom;
  SongSort? _groupedSort;
  List<_Section> _sections = const [];

  // The song just added: scrolled into view once, then tinted briefly. Matched
  // by title and artist because its id changes when the server accepts it.
  ({String title, String? artist})? _reveal;
  bool _revealScrolled = false;
  Timer? _revealTimer;

  // A tablet in landscape shows the chosen song beside the list.
  bool _split = false;
  bool _compactList = false;
  int? _selected;

  @override
  void dispose() {
    _debounce?.cancel();
    _revealTimer?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  SongListController get _controller => ref.read(songListControllerProvider.notifier);

  void _toTop() {
    if (_scroll.hasClients && _scroll.offset > 0) _scroll.jumpTo(0);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounce, () {
      _controller.setSearch(value);
      _toTop();
    });
    // Clearing is instant — no reason to make someone wait to see everything again.
    if (value.isEmpty) {
      _debounce?.cancel();
      _controller.setSearch('');
      _toTop();
    }
  }

  void _clearAll() {
    _debounce?.cancel();
    _search.clear();
    _controller
      ..setSearch('')
      ..clearFilters();
    _toTop();
  }

  Future<void> _pullRefresh() async {
    setState(() => _pulling = true);
    try {
      await ref.read(workspaceSyncProvider.notifier).refresh();
    } finally {
      if (mounted) setState(() => _pulling = false);
    }
  }

  List<_Section> _sectionsFor(List<Song> songs, SongSort sort) {
    if (identical(songs, _groupedFrom) && sort == _groupedSort) return _sections;
    _groupedFrom = songs;
    _groupedSort = sort;
    if (!sort.isAlphabetical) return _sections = [_Section(null, songs)];

    final byLetter = <String, List<Song>>{};
    for (final song in songs) {
      byLetter.putIfAbsent(songSectionLetter(song.title), () => []).add(song);
    }
    // Digits and punctuation file last, as in Contacts.
    final letters = byLetter.keys.toList()..sort((a, b) => a == '#' ? 1 : (b == '#' ? -1 : 0));
    return _sections = [for (final l in letters) _Section(l, byLetter[l]!)];
  }

  /// The large title that leads the list, and the Library | Discover row
  /// under it in a split view's narrow list.
  double get _leadExtent => LargeTitle.height + (_compactList ? _switchRowHeight : 0);

  static const _switchRowHeight = 52.0;

  void _jumpToLetter(String letter, double rowExtent) {
    if (!_scroll.hasClients) return;
    var offset = _leadExtent + SongListHeader.height;
    for (final section in _sections) {
      if (section.letter == letter) break;
      offset += PinnedSectionHeader.height + section.songs.length * rowExtent;
    }
    _scroll.jumpTo(offset.clamp(0.0, _scroll.position.maxScrollExtent));
  }

  void _open(Song song, Map<int, String?> outbox) {
    if (song.isPending) return _showPendingActions(song, outbox);
    _controller.recordOpened(song);
    if (_split) {
      setState(() => _selected = song.id);
      return;
    }
    context.push(Routes.song(song.id));
  }

  void _showPendingActions(Song song, Map<int, String?> outbox) => askDiscardPendingSong(
    context,
    song,
    error: outbox[song.id],
    onDiscard: () => ref.read(songsRepositoryProvider).discardPending(song.id),
  );

  Future<void> _create() async {
    // A search or filter could hide the song they're about to add.
    _clearAll();
    final id = await showNewSongSheet(context);
    if (id == null || !mounted) return;
    final song = await ref.read(songsRepositoryProvider).findLocal(id);
    if (song == null || !mounted) return;
    setState(() {
      _reveal = (title: song.title, artist: song.artist);
      _revealScrolled = false;
    });
    // Give up if the song never shows up (it shouldn't — it's local).
    _revealTimer?.cancel();
    _revealTimer = Timer(const Duration(seconds: 5), _endReveal);
  }

  void _endReveal() {
    _revealTimer?.cancel();
    if (mounted) setState(() => _reveal = null);
  }

  /// The newest song matching the one just added.
  Song? _revealTarget(List<Song> songs) {
    final reveal = _reveal;
    if (reveal == null) return null;
    Song? best;
    for (final s in songs) {
      if (s.title == reveal.title && s.artist == reveal.artist) {
        // Pending songs are the newest; otherwise the highest server id.
        if (best == null || s.isPending || (!best.isPending && s.id > best.id)) best = s;
      }
    }
    return best;
  }

  void _scrollToSong(Song song, double rowExtent) {
    _revealScrolled = true;
    _revealTimer?.cancel();
    _revealTimer = Timer(const Duration(milliseconds: 1800), _endReveal);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      var offset = _leadExtent + SongListHeader.height;
      for (final section in _sections) {
        if (section.letter != null) offset += PinnedSectionHeader.height;
        final index = section.songs.indexWhere((s) => s.id == song.id);
        if (index >= 0) {
          offset += index * rowExtent;
          break;
        }
        offset += section.songs.length * rowExtent;
      }
      final position = _scroll.position;
      final inView = offset >= position.pixels && offset + rowExtent <= position.pixels + position.viewportDimension;
      if (inView) return;
      _scroll.animateTo(
        (offset - position.viewportDimension / 3).clamp(0.0, position.maxScrollExtent),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Both halves of the tab share the bar's `+` and its Library | Discover
    // control, so Discover registers them too.
    Widget inBar(Widget screen) => RegisterPrimaryAction(
      branch: 1,
      label: 'New song',
      icon: TablerIcons.plus,
      onPressed: (_) => _create(),
      inline: const SongsSegmentSwitch(),
      child: screen,
    );
    if (ref.watch(songsSegmentControllerProvider) == SongsSegment.discover) return inBar(const DiscoverScreen());
    final query = ref.watch(songListControllerProvider);
    final library = ref.watch(librarySongsProvider);
    final sync = ref.watch(workspaceSyncProvider);
    final online = ref.watch(isOnlineProvider);

    final songs = library.value;
    final loading = songs == null || (songs.isEmpty && query.isDefault && sync.isInitialSync);
    final sections = loading ? const <_Section>[] : _sectionsFor(songs, query.sort);
    // Where each section's rows start in the whole list — their entrance order.
    final sectionStarts = [for (var i = 0, n = 0; i < sections.length; n += sections[i].songs.length, i++) n];
    final showRail = !loading && query.sort.isAlphabetical && songs.length >= _railThreshold && sections.length > 1;
    final rowExtent = SongListRow.extent(context);
    final outbox = ref.watch(songOutboxProvider).value ?? const <int, String?>{};
    final songSync = ref.watch(songSyncProvider);
    final revealed = loading ? null : _revealTarget(songs);
    if (revealed != null && !_revealScrolled) _scrollToSong(revealed, rowExtent);
    final gutter = DaloySpace.gutter(context);

    final create = _create;
    final isTablet = ShellLayout.of(context) == ShellLayout.tablet;

    Widget listScaffold({required bool compact}) {
      _compactList = compact;
      return Scaffold(
        appBar: DaloyTopBar(
          title: 'Songs',
          largeTitle: true,
          actions: [
            if (sync.isSyncing && !_pulling)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: DaloySpace.s2),
                child: DaloySpinner(size: 18),
              ),
            const TopBarSearchButton(),
            // A phone has the detached + at the tab bar; a tablet has no tab bar.
            if (isTablet) PrimaryActionButton(icon: TablerIcons.plus, label: 'New song', onPressed: create),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Centre a capped column on wide tablets while the scroll view
            // (and its scrollbar) stays full width.
            final side = math.max(gutter, (constraints.maxWidth - DaloyBreakpoints.contentMaxWidth) / 2);
            final listSide = math.max(0.0, side - DaloySpace.s4);

            final list = EntranceScope(
              ready: !loading,
              child: PullToRefreshScrollView(
                controller: _scroll,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                onRefresh: online ? _pullRefresh : null,
                slivers: [
                  // A phone's Library | Discover lives in the tab bar; a tablet's
                  // bar row belongs to the tabs, so it sits on the title's line.
                  // A tablet's bar row belongs to the tabs, so its Library |
                  // Discover sits on the title's line, or under it in a split
                  // view's narrow list.
                  SliverLargeTitle(
                    'Songs',
                    inset: side,
                    trailing: isTablet && !compact ? const SongsSegmentSwitch() : null,
                  ),
                  if (compact)
                    SliverToBoxAdapter(
                      child: Container(
                        height: _switchRowHeight,
                        padding: EdgeInsets.fromLTRB(side, DaloySpace.s2, side, DaloySpace.s1),
                        alignment: Alignment.centerLeft,
                        child: const SongsSegmentSwitch(),
                      ),
                    ),
                  SliverToBoxAdapter(
                    key: const ValueKey('header'),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: side - gutter),
                      child: SongListHeader(
                        searchController: _search,
                        query: query,
                        onSearchChanged: _onSearchChanged,
                        onSortChanged: (sort) {
                          _controller.setSort(sort);
                          _toTop();
                        },
                        onKeyChanged: (key) {
                          _controller.setKey(key);
                          _toTop();
                        },
                        onContentToggled: (filter) {
                          _controller.toggleContent(filter);
                          _toTop();
                        },
                        onClear: () {
                          _controller.clearFilters();
                          _toTop();
                        },
                      ),
                    ),
                  ),
                  if (loading)
                    const SliverToBoxAdapter(child: ListSkeleton())
                  else if (songs.isEmpty)
                    SliverToBoxAdapter(
                      child: query.isDefault
                          ? ListEmptyState(
                              icon: TablerIcons.music,
                              title: 'No songs yet',
                              description: 'Add your first song, or browse Discover for songs other teams shared.',
                              actionLabel: 'Add a song',
                              actionIcon: TablerIcons.plus,
                              onAction: create,
                            )
                          : ListEmptyState(
                              icon: TablerIcons.search_off,
                              title: 'No songs match',
                              description: 'Try a different search or clear the filters.',
                              actionLabel: 'Clear search & filters',
                              onAction: _clearAll,
                            ),
                    )
                  else ...[
                    SliverPadding(
                      padding: EdgeInsets.only(
                        left: listSide,
                        right: listSide + (showRail ? AlphabetRail.width - 8 : 0),
                      ),
                      sliver: SliverMainAxisGroup(
                        slivers: [
                          for (final (s, section) in sections.indexed)
                            SliverMainAxisGroup(
                              // Stable across regroupings so a section's rows keep their state.
                              key: ValueKey(section.letter ?? '*'),
                              slivers: [
                                if (section.letter != null)
                                  SliverPersistentHeader(
                                    pinned: true,
                                    delegate: PinnedSectionHeader(
                                      label: section.letter!,
                                      colors: context.colors,
                                      text: context.text,
                                    ),
                                  ),
                                SliverFixedExtentList.builder(
                                  itemExtent: rowExtent,
                                  itemCount: section.songs.length,
                                  itemBuilder: (_, i) {
                                    final song = section.songs[i];
                                    return Entrance(
                                      key: ValueKey(song.id),
                                      index: sectionStarts[s] + i,
                                      child: PaneSelection(
                                        selected: _split && song.id == _selected,
                                        child: SongListRow(
                                          song: song,
                                          onTap: () => _open(song, outbox),
                                          menu: () => song.isPending
                                              ? pendingSongMenuItems(
                                                  context,
                                                  song,
                                                  error: outbox[song.id],
                                                  onDiscard: () =>
                                                      ref.read(songsRepositoryProvider).discardPending(song.id),
                                                )
                                              : songMenuItems(context, ref, song),
                                          sync: songSync[song.id],
                                          highlighted: song.id == revealed?.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _Footer(count: songs.length, filtered: !query.isDefault),
                    ),
                  ],
                  // Room to scroll the last row clear of the FAB.
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: DaloySpace.s10 + DaloyChrome.fabSize + MediaQuery.paddingOf(context).bottom,
                    ),
                  ),
                ],
              ),
            );

            // One tree whether or not the rail shows. Swapping the root here
            // would rebuild the search field — and drop its focus — the moment
            // typing narrows the list below the rail threshold.
            return Stack(
              children: [
                Positioned.fill(child: list),
                if (showRail)
                  Positioned(
                    top: 0,
                    right: 0,
                    bottom: DaloySpace.s10 + DaloyChrome.fabSize + MediaQuery.paddingOf(context).bottom,
                    width: AlphabetRail.width,
                    child: AlphabetRail(
                      present: [for (final s in sections) s.letter!],
                      onSelect: (letter) => _jumpToLetter(letter, rowExtent),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    return inBar(
      LayoutBuilder(
        builder: (context, box) {
          _split = isTablet && SplitView.fits(context, box.maxWidth);
          if (!_split) return listScaffold(compact: false);
          // A song deleted (or filtered away) leaves the pane empty.
          final selected = _selected;
          final showing = selected != null && (songs?.any((s) => s.id == selected) ?? false);
          return SplitView(
            list: listScaffold(compact: true),
            detail: showing ? SongDetailScreen(key: ValueKey(selected), songId: selected) : null,
            placeholder: const SplitPlaceholder(icon: TablerIcons.music, message: 'Choose a song'),
          );
        },
      ),
    );
  }
}

class _Section {
  const _Section(this.letter, this.songs);

  /// Null in lists that aren't alphabetical.
  final String? letter;
  final List<Song> songs;
}

class _Footer extends StatelessWidget {
  const _Footer({required this.count, required this.filtered});

  final int count;
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final noun = count == 1 ? 'song' : 'songs';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DaloySpace.s5),
      child: Center(
        child: Text(
          filtered ? '$count matching $noun' : '$count $noun',
          style: context.text.bodySmall!.copyWith(color: context.colors.mutedForeground),
        ),
      ),
    );
  }
}
