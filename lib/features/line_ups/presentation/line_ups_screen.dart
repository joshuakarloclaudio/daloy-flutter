import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
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
import '../../dashboard/presentation/widgets/live_session_card.dart';
import '../../search/presentation/search_button.dart';
import '../../sync/workspace_sync_controller.dart';
import '../application/line_up_list_controller.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up.dart';
import '../domain/line_up_list_query.dart';
import 'line_up_actions.dart';
import 'line_up_detail_screen.dart';
import 'new_line_up_sheet.dart';
import 'widgets/line_up_agenda_row.dart';
import 'widgets/line_up_list_header.dart';

/// The workspace's line-ups as an agenda: *Coming up*, then earlier months.
/// Search, timing/content filters and order run against Drift; rows are
/// fixed-extent slivers, so only what's on screen is built.
class LineUpsScreen extends ConsumerStatefulWidget {
  const LineUpsScreen({super.key, this.startNew = false});

  /// Opened as [Routes.newLineUp]: brings up the new-line-up sheet at once.
  final bool startNew;

  @override
  ConsumerState<LineUpsScreen> createState() => _LineUpsScreenState();
}

class _LineUpsScreenState extends ConsumerState<LineUpsScreen> {
  static const _searchDebounce = Duration(milliseconds: 200);

  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  bool _pulling = false;

  // Grouping is cached against the list it was built from.
  List<LineUp>? _groupedFrom;
  LineUpSort? _groupedSort;
  String? _groupedToday;
  List<LineUpSection> _sections = const [];

  // A tablet in landscape shows the chosen line-up beside the list.
  bool _split = false;
  int? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.startNew) _startNewFromLink();
  }

  @override
  void didUpdateWidget(LineUpsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startNew && !oldWidget.startNew) _startNewFromLink();
  }

  /// Drops `?new=1` first, so going back to the tab doesn't open it again.
  void _startNewFromLink() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    context.go(Routes.lineUps);
    unawaited(startNewLineUp(context));
  });

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  LineUpListController get _controller => ref.read(lineUpListControllerProvider.notifier);

  void _toTop() {
    if (_scroll.hasClients && _scroll.offset > 0) _scroll.jumpTo(0);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      // Clearing is instant — no reason to make someone wait to see everything again.
      _controller.setSearch('');
      _toTop();
      return;
    }
    _debounce = Timer(_searchDebounce, () {
      _controller.setSearch(value);
      _toTop();
    });
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

  List<LineUpSection> _sectionsFor(List<LineUp> lineUps, LineUpSort sort, String today) {
    if (identical(lineUps, _groupedFrom) && sort == _groupedSort && today == _groupedToday) return _sections;
    _groupedFrom = lineUps;
    _groupedSort = sort;
    _groupedToday = today;
    return _sections = groupLineUps(lineUps, today: today, sort: sort);
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(lineUpListControllerProvider);
    final library = ref.watch(libraryLineUpsProvider);
    final sync = ref.watch(workspaceSyncProvider);
    final online = ref.watch(isOnlineProvider);

    final lineUps = library.value;
    final loading = lineUps == null || (lineUps.isEmpty && query.isDefault && sync.isInitialSync);
    final today = todayIsoLocal();
    final sections = loading ? const <LineUpSection>[] : _sectionsFor(lineUps, query.sort, today);
    // Where each section's rows start in the whole list — their entrance order.
    final sectionStarts = [for (var i = 0, n = 0; i < sections.length; n += sections[i].lineUps.length, i++) n];
    final rowExtent = LineUpAgendaRow.extent(context);
    final gutter = DaloySpace.gutter(context);

    // The running performance, shown only on the unfiltered list.
    final live = online && query.isDefault ? ref.watch(activeLiveSessionProvider).value : null;
    final liveLineUp = live == null ? null : lineUps?.where((l) => l.id == live.lineUpId).firstOrNull;

    final outbox = ref.watch(lineUpOutboxProvider).value ?? const {};

    void create() => startNewLineUp(context);

    void open(int id) {
      if (_split) {
        setState(() => _selected = id);
      } else {
        context.push(Routes.lineUp(id));
      }
    }

    final listScaffold = Scaffold(
      appBar: DaloyTopBar(
        title: 'Line-ups',
        largeTitle: true,
        actions: [
          if (sync.isSyncing && !_pulling)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: DaloySpace.s2),
              child: DaloySpinner(size: 18),
            ),
          const TopBarSearchButton(),
          // Creating works offline: it's saved here and synced on reconnect. A
          // phone has the detached + at the tab bar; a tablet has no tab bar.
          if (ShellLayout.of(context).wide)
            PrimaryActionButton(icon: TablerIcons.plus, label: 'New line-up', onPressed: create),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Centre a capped column on wide tablets while the scroll view
          // (and its scrollbar) stays full width.
          final side = math.max(gutter, (constraints.maxWidth - DaloyBreakpoints.contentMaxWidth) / 2);
          final listSide = math.max(0.0, side - DaloySpace.s4);

          return EntranceScope(
            ready: !loading,
            child: PullToRefreshScrollView(
              controller: _scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              onRefresh: online ? _pullRefresh : null,
              slivers: [
                SliverLargeTitle('Line-ups', inset: side),
                SliverToBoxAdapter(
                  key: const ValueKey('header'),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: side - gutter),
                    child: LineUpListHeader(
                      searchController: _search,
                      query: query,
                      onSearchChanged: _onSearchChanged,
                      onSortChanged: (sort) {
                        _controller.setSort(sort);
                        _toTop();
                      },
                      onTimingToggled: (timing) {
                        _controller.toggleTiming(timing);
                        _toTop();
                      },
                      onContentToggled: (content) {
                        _controller.toggleContent(content);
                        _toTop();
                      },
                      onClear: () {
                        _controller.clearFilters();
                        _toTop();
                      },
                    ),
                  ),
                ),
                if (live != null)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(side, 0, side, DaloySpace.s3),
                    sliver: SliverToBoxAdapter(
                      child: LiveSessionCard(
                        session: live,
                        lineUp: liveLineUp,
                        onOpen: () => open(live.lineUpId),
                        onJoin: () => context.push(Routes.perform(live.lineUpId)),
                      ),
                    ),
                  ),
                if (loading)
                  const SliverToBoxAdapter(child: ListSkeleton())
                else if (lineUps.isEmpty)
                  SliverToBoxAdapter(
                    child: query.isDefault
                        ? ListEmptyState(
                            icon: TablerIcons.layout_list,
                            title: 'No line-ups yet',
                            description: "Assemble a setlist when you're ready to plan.",
                            actionLabel: 'Create a line-up',
                            actionIcon: TablerIcons.plus,
                            onAction: create,
                          )
                        : ListEmptyState(
                            icon: TablerIcons.search_off,
                            title: 'No line-ups match',
                            description: 'Try a different search or clear the filters.',
                            actionLabel: 'Clear search & filters',
                            onAction: _clearAll,
                          ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.only(left: listSide, right: listSide),
                    sliver: SliverMainAxisGroup(
                      slivers: [
                        for (final (s, section) in sections.indexed)
                          SliverMainAxisGroup(
                            key: ValueKey(section.id),
                            slivers: [
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: PinnedSectionHeader(
                                  label: section.label,
                                  colors: context.colors,
                                  text: context.text,
                                ),
                              ),
                              SliverFixedExtentList.builder(
                                itemExtent: rowExtent,
                                itemCount: section.lineUps.length,
                                itemBuilder: (_, i) {
                                  final lineUp = section.lineUps[i];
                                  return Entrance(
                                    key: ValueKey(lineUp.id),
                                    index: sectionStarts[s] + i,
                                    child: PaneSelection(
                                      selected: _split && lineUp.id == _selected,
                                      child: LineUpAgendaRow(
                                        lineUp: lineUp,
                                        today: today,
                                        isLive: live?.lineUpId == lineUp.id,
                                        sync: !outbox.containsKey(lineUp.id)
                                            ? null
                                            : outbox[lineUp.id] == null
                                            ? LineUpSyncState.waiting
                                            : LineUpSyncState.failed,
                                        // Not on the server yet, so there's no detail
                                        // to show — straight to the editor.
                                        onTap: () => lineUp.isPending
                                            ? context.push(Routes.lineUpEdit(lineUp.id))
                                            : open(lineUp.id),
                                        menu: () => lineUpMenuItems(context, ref, lineUp, error: outbox[lineUp.id]),
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
                // Room to scroll the last row clear of the FAB.
                SliverToBoxAdapter(
                  child: SizedBox(height: DaloySpace.s10 + DaloyChrome.fabSize + MediaQuery.paddingOf(context).bottom),
                ),
              ],
            ),
          );
        },
      ),
    );

    return RegisterPrimaryAction(
      branch: 2,
      label: 'New line-up',
      icon: TablerIcons.plus,
      onPressed: (_) => create(),
      child: LayoutBuilder(
        builder: (context, box) {
          _split = ShellLayout.of(context).wide && SplitView.fits(context, box.maxWidth);
          if (!_split) return listScaffold;
          // A line-up deleted (or filtered away) leaves the pane empty.
          final selected = _selected;
          final showing = selected != null && (lineUps?.any((l) => l.id == selected && !l.isPending) ?? false);
          return SplitView(
            list: listScaffold,
            detail: showing ? LineUpDetailScreen(key: ValueKey(selected), lineUpId: selected) : null,
            placeholder: const SplitPlaceholder(icon: TablerIcons.layout_list, message: 'Choose a line-up'),
          );
        },
      ),
    );
  }
}
