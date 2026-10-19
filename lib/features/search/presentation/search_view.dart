import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/filter_pill.dart';
import '../../../shared/widgets/list_states.dart';
import '../../auth/application/session_controller.dart';
import '../../line_ups/domain/line_up.dart';
import '../../line_ups/presentation/new_line_up_sheet.dart';
import '../../songs/data/songs_repository.dart';
import '../../songs/domain/song.dart';
import '../../songs/presentation/new_song_sheet.dart';
import '../../workspaces/presentation/workspace_switcher.dart';
import '../application/search_controller.dart';
import '../data/search_repository.dart';
import '../domain/network_song.dart';
import '../domain/search_query.dart';
import '../domain/search_results.dart';
import 'network_song_sheet.dart';
import 'widgets/search_rows.dart';

const _recentlyOpenedLimit = 5;

/// One selectable result: how to draw it (given whether the keyboard has
/// it selected) and what opening it does.
class _Entry {
  const _Entry(this.build, this.open);

  final Widget Function(bool active) build;
  final VoidCallback open;
}

/// The search field, its chips and the grouped results — shared by the
/// phone's search page and the tablet's floating panel. Everything local
/// comes from Drift, so it all works offline; only the Discover group
/// needs a connection.
class SearchView extends ConsumerStatefulWidget {
  const SearchView({
    super.key,
    this.host,
    this.onDismiss,
    this.onClose,
    this.autofocus = false,
    this.listenForFocus = false,
  });

  /// Where navigation and sheets start from once a result is chosen — the
  /// panel's opener, since the panel itself closes first. This view's own
  /// context when null.
  final BuildContext? host;

  /// Closes the panel (Esc, Cancel, or before opening a result). Null on
  /// the page, which stays under whatever a result opens.
  final VoidCallback? onDismiss;

  /// Leaves the search page: what Cancel does there. The page itself stays
  /// put while a result opens on top of it, so the query and results are
  /// still there when you come back.
  final VoidCallback? onClose;
  final bool autofocus;

  /// Focus the field when [SearchFocusRequests] fires (the tab tapped again).
  final bool listenForFocus;

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  late final _field = TextEditingController(text: ref.read(searchPageControllerProvider).input);
  late final _focus = FocusNode(onKeyEvent: _onKey);
  final _scroll = ScrollController();

  /// The keyboard's selection among [_entries] (tablet with a keyboard).
  int _active = 0;
  List<_Entry> _entries = const [];

  SearchPageController get _controller => ref.read(searchPageControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    // Coming back to a kept query: select it, so typing replaces it.
    if (_field.text.isNotEmpty) _field.selection = TextSelection(baseOffset: 0, extentOffset: _field.text.length);
  }

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _setText(String text) {
    _field.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _controller.submit(text);
    _resetActive();
  }

  void _resetActive() {
    _active = 0;
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape && widget.onDismiss != null) {
      widget.onDismiss!();
      return KeyEventResult.handled;
    }
    if (_entries.isEmpty) return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.arrowDown || key == LogicalKeyboardKey.arrowUp) {
      final step = key == LogicalKeyboardKey.arrowDown ? 1 : -1;
      setState(() => _active = (_active + step).clamp(0, _entries.length - 1));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Return in the panel opens the selected result, like a command palette.
  /// The phone's Search key just keeps the search and lowers the keyboard,
  /// so you can look over the results.
  void _onSubmitted(String _) {
    if (widget.onDismiss != null && _entries.isNotEmpty) {
      _entries[_active.clamp(0, _entries.length - 1)].open();
      return;
    }
    _controller.remember();
    if (widget.onDismiss != null) _focus.requestFocus();
  }

  /// Closes the panel if there is one, then [action] from the host.
  void _open(void Function(BuildContext host, GoRouter router) action, {bool remember = true}) {
    if (remember) _controller.remember();
    final host = widget.host ?? context;
    final router = GoRouter.of(host);
    widget.onDismiss?.call();
    action(host, router);
  }

  void _openSong(Song song, {LyricHit? hit}) => _open((host, router) {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId != null) ref.read(songsRepositoryProvider).recordOpened(song.id, workspaceId);
    router.push(hit == null ? Routes.song(song.id) : Routes.songAt(song.id, line: hit.line, view: hit.view.name));
  });

  void _openLineUp(LineUp lineUp) =>
      _open((_, router) => router.push(lineUp.isPending ? Routes.lineUpEdit(lineUp.id) : Routes.lineUp(lineUp.id)));

  void _openNetwork(NetworkSong song) => _open((host, _) => showNetworkSongSheet(host, song));

  void _openDestination(SearchDestination d) => _open((host, router) {
    switch (d) {
      case SearchDestination.newSong:
        showNewSongSheet(host);
      case SearchDestination.newLineUp:
        startNewLineUp(host);
      case SearchDestination.home:
        router.go(Routes.home);
      case SearchDestination.songs:
        router.go(Routes.songs);
      case SearchDestination.lineUps:
        router.go(Routes.lineUps);
      case SearchDestination.profile:
        router.go(Routes.profile);
      case SearchDestination.switchWorkspace:
        showWorkspaceSwitcher(host);
      case SearchDestination.chordGuide:
        router.push(Routes.chordSyntaxGuide);
    }
  }, remember: false);

  @override
  Widget build(BuildContext context) {
    if (widget.listenForFocus) {
      ref.listen(searchFocusRequestsProvider, (_, _) {
        _focus.requestFocus();
        _field.selection = TextSelection(baseOffset: 0, extentOffset: _field.text.length);
      });
    }
    // Cleared from elsewhere (a workspace switch): follow.
    ref.listen(searchPageControllerProvider.select((s) => s.input), (_, input) {
      if (input != _field.text) _field.text = input;
    });

    final state = ref.watch(searchPageControllerProvider);
    final query = state.query;
    final typing = state.input.trim().isNotEmpty;

    return Column(
      children: [
        _SearchBar(
          controller: _field,
          focusNode: _focus,
          autofocus: widget.autofocus,
          onChanged: (text) {
            _controller.setInput(text);
            _resetActive();
          },
          onSubmitted: _onSubmitted,
          onCancel: widget.onDismiss ?? widget.onClose ?? (typing || _focus.hasFocus ? () => _setText('') : null),
        ),
        _Chips(
          state: state,
          onScope: (scope) {
            _controller.setScope(scope);
            _resetActive();
          },
          onRemoveKey: () => _setText(removeSearchToken(state.input, key: true)),
          onRemoveBpm: () => _setText(removeSearchToken(state.input, bpm: true)),
        ),
        Expanded(child: typing ? _results(context, query) : _idle(context)),
      ],
    );
  }

  Widget _idle(BuildContext context) {
    _entries = const [];
    final recent = ref.watch(recentSearchesProvider).value ?? const [];
    final opened = (ref.watch(recentlyOpenedSongsProvider).value ?? const <Song>[]).take(_recentlyOpenedLimit);
    final workspaceId = ref.watch(activeWorkspaceIdProvider);
    final repo = ref.read(searchRepositoryProvider);
    final c = context.colors;

    return ListView(
      controller: _scroll,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: DaloySpace.s6 + MediaQuery.paddingOf(context).bottom),
      children: [
        if (recent.isNotEmpty) ...[
          SearchGroupLabel(
            'Recent searches',
            trailing: workspaceId == null
                ? null
                : DaloyButton(
                    variant: ButtonVariant.plain,
                    size: ControlSize.sm,
                    label: 'Clear',
                    onPressed: () => repo.forgetAll(workspaceId),
                  ),
          ),
          for (final q in recent)
            SearchRecentRow(
              query: q,
              onTap: () => _setText(q),
              onRemove: () {
                if (workspaceId != null) repo.forget(workspaceId, q);
              },
            ),
        ],
        if (opened.isNotEmpty) ...[
          const SearchGroupLabel('Recently opened'),
          for (final song in opened) SearchSongRow(song: song, terms: const [], onTap: () => _openSong(song)),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s6, DaloySpace.s5, 0),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Find songs by title, artist or a line of the lyrics, and line-ups by name or day. Try ',
                ),
                TextSpan(
                  text: 'key:G',
                  style: TextStyle(color: c.primaryInk),
                ),
                const TextSpan(text: ' or '),
                TextSpan(
                  text: '120bpm',
                  style: TextStyle(color: c.primaryInk),
                ),
                const TextSpan(text: '.'),
              ],
            ),
            textAlign: TextAlign.center,
            style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
          ),
        ),
      ],
    );
  }

  Widget _results(BuildContext context, SearchQuery query) {
    final results = ref.watch(searchResultsProvider).value ?? SearchResults.empty;
    final network = ref.watch(networkSearchResultsProvider);
    final terms = query.terms;
    final networkSongs = network.value ?? const <NetworkSong>[];

    final entries = <_Entry>[];
    final children = <Widget>[];
    void group(String label, List<_Entry> items, {Widget? trailing}) {
      if (items.isEmpty) return;
      children.add(SearchGroupLabel(label, trailing: trailing));
      for (final item in items) {
        final index = entries.length;
        entries.add(item);
        children.add(item.build(index == _active));
      }
    }

    group('Songs', [
      for (final s in results.songs)
        _Entry((a) => SearchSongRow(song: s, terms: terms, active: a, onTap: () => _openSong(s)), () => _openSong(s)),
    ]);
    group('In lyrics', [
      for (final h in results.lyrics)
        _Entry(
          (a) => SearchLyricRow(
            hit: h,
            terms: terms,
            active: a,
            onTap: () => _openSong(h.song, hit: h),
          ),
          () => _openSong(h.song, hit: h),
        ),
    ]);
    group('Line-ups', [
      for (final l in results.lineUps)
        _Entry(
          (a) => SearchLineUpRow(lineUp: l, terms: terms, active: a, onTap: () => _openLineUp(l)),
          () => _openLineUp(l),
        ),
    ]);
    group('Go to', [
      for (final d in results.destinations)
        _Entry(
          (a) => SearchDestinationRow(
            label: d.label,
            icon: _destinationIcon(d),
            terms: terms,
            active: a,
            onTap: () => _openDestination(d),
          ),
          () => _openDestination(d),
        ),
    ]);
    final localEmpty = results.isEmpty;
    group('From Discover', [
      for (final s in networkSongs)
        _Entry(
          (a) => SearchNetworkRow(song: s, terms: terms, active: a, onTap: () => _openNetwork(s)),
          () => _openNetwork(s),
        ),
    ]);
    _entries = entries;
    if (_active >= entries.length) _active = 0;

    final c = context.colors;
    Widget? networkStatus;
    if (network.isLoading && network.value == null && query.wantsNetwork) {
      networkStatus = _NetworkStatus(leading: const DaloySpinner(size: 14), text: 'Searching Discover…');
    } else if (network.hasError) {
      networkStatus = _NetworkStatus(
        leading: Icon(TablerIcons.cloud_off, size: 16, color: c.mutedForeground),
        text: "Couldn't reach Discover.",
      );
    }

    return ListView(
      controller: _scroll,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(bottom: DaloySpace.s6 + MediaQuery.paddingOf(context).bottom),
      children: [
        if (localEmpty && networkSongs.isEmpty && networkStatus == null)
          ListEmptyState(
            icon: TablerIcons.search_off,
            title: 'No matches',
            description: query.hasMusicFilter && !query.hasText
                ? 'No songs in this workspace match those filters.'
                : 'Nothing in this workspace matches “${query.text}”.',
          ),
        ...children,
        ?networkStatus,
      ],
    );
  }

  static IconData _destinationIcon(SearchDestination d) => switch (d) {
    SearchDestination.newSong || SearchDestination.newLineUp => TablerIcons.plus,
    SearchDestination.home => TablerIcons.home,
    SearchDestination.songs => TablerIcons.music,
    SearchDestination.lineUps => TablerIcons.layout_list,
    SearchDestination.profile => TablerIcons.user_circle,
    SearchDestination.switchWorkspace => TablerIcons.switch_horizontal,
    SearchDestination.chordGuide => TablerIcons.book,
  };
}

/// The field, with Cancel beside it when there's something to cancel.
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.onChanged,
    required this.onSubmitted,
    required this.onCancel,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onCancel;

  static final _borderless = OutlineInputBorder(
    borderRadius: DaloyRadii.all(DaloyRadii.xl),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s2, DaloySpace.s2, DaloySpace.s2),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: autofocus,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                enableSuggestions: false,
                style: context.text.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Songs, lyrics, line-ups',
                  isDense: true,
                  filled: true,
                  fillColor: c.muted.withValues(alpha: 0.7),
                  contentPadding: const EdgeInsets.symmetric(vertical: DaloySpace.s3),
                  border: _borderless,
                  enabledBorder: _borderless,
                  focusedBorder: _borderless,
                  prefixIcon: Icon(TablerIcons.search, size: 18, color: c.mutedForeground),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (_, value, _) => value.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: Icon(TablerIcons.circle_x_filled, size: 18, color: c.mutedForeground),
                            onPressed: () {
                              controller.clear();
                              onChanged('');
                              focusNode.requestFocus();
                            },
                          ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: DaloyMotion.fast,
            curve: DaloyMotion.ease,
            child: onCancel == null
                ? const SizedBox(width: DaloySpace.s2)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
                    child: DaloyButton(
                      variant: ButtonVariant.plain,
                      label: 'Cancel',
                      onPressed: () {
                        focusNode.unfocus();
                        onCancel!();
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Scope pills, then the key / tempo filters read from the query as chips
/// you can tap away.
class _Chips extends StatelessWidget {
  const _Chips({required this.state, required this.onScope, required this.onRemoveKey, required this.onRemoveBpm});

  final SearchState state;
  final ValueChanged<SearchScope> onScope;
  final VoidCallback onRemoveKey;
  final VoidCallback onRemoveBpm;

  @override
  Widget build(BuildContext context) {
    final parsed = SearchQuery.parse(state.input, scope: state.scope);
    // Filters read from the query first: they're what you just typed, and
    // the strip is narrower than all the chips on a phone.
    final chips = [
      if (parsed.keyLabel case final label?)
        FilterPill(label: label, icon: TablerIcons.x, trailingIcon: true, active: true, onTap: onRemoveKey),
      if (parsed.bpmLabel case final label?)
        FilterPill(label: label, icon: TablerIcons.x, trailingIcon: true, active: true, onTap: onRemoveBpm),
      for (final scope in SearchScope.values)
        FilterPill(label: scope.label, active: state.scope == scope, onTap: () => onScope(scope)),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: DaloySpace.s2),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}

class _NetworkStatus extends StatelessWidget {
  const _NetworkStatus({required this.leading, required this.text});

  final Widget leading;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s5, DaloySpace.s4, 0),
      child: Row(
        children: [
          leading,
          const SizedBox(width: DaloySpace.s2),
          Text(text, style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
        ],
      ),
    );
  }
}
