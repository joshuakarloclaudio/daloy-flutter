import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/application/session_controller.dart';
import '../data/network_songs_repository.dart';
import '../domain/discover_query.dart';
import '../domain/network_song.dart';

part 'discover_controller.g.dart';

/// Which half of the Songs tab is showing.
/// [library] is the workspace's own songs — the team's, not a person's.
enum SongsSegment { library, discover }

/// Kept alive so the segment you left is the one you come back to.
@Riverpod(keepAlive: true)
class SongsSegmentController extends _$SongsSegmentController {
  @override
  SongsSegment build() => SongsSegment.library;

  void select(SongsSegment segment) => state = segment;
}

class DiscoverState {
  const DiscoverState({
    this.query = const DiscoverQuery(),
    this.songs = const [],
    this.nextCursor,
    this.loading = true,
    this.loadingMore = false,
    this.offline = false,
    this.refreshing = false,
    this.error,
    this.shared = const [],
  });

  final DiscoverQuery query;
  final List<NetworkSong> songs;
  final String? nextCursor;

  /// First page in flight.
  final bool loading;
  final bool loadingMore;
  final bool offline;

  /// A new query or refresh is in flight over the list already showing.
  final bool refreshing;
  final String? error;

  /// Our own workspace's shared songs ("Shared by us").
  final List<NetworkSong> shared;

  bool get hasMore => nextCursor != null;

  DiscoverState copyWith({
    DiscoverQuery? query,
    List<NetworkSong>? songs,
    String? Function()? nextCursor,
    bool? loading,
    bool? loadingMore,
    bool? offline,
    bool? refreshing,
    String? Function()? error,
    List<NetworkSong>? shared,
  }) => DiscoverState(
    query: query ?? this.query,
    songs: songs ?? this.songs,
    nextCursor: nextCursor != null ? nextCursor() : this.nextCursor,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    offline: offline ?? this.offline,
    refreshing: refreshing ?? this.refreshing,
    error: error != null ? error() : this.error,
    shared: shared ?? this.shared,
  );
}

/// Discover's list: other teams' shared songs, paged, plus our own. Network
/// only on purpose — these aren't ours until they're added. Cleared when the
/// workspace changes (what's "already added" belongs to the old one).
@Riverpod(keepAlive: true)
class DiscoverController extends _$DiscoverController {
  static const debounce = Duration(milliseconds: 300);

  Timer? _timer;
  int _generation = 0;

  @override
  DiscoverState build() {
    final workspaceId = ref.watch(activeWorkspaceIdProvider);
    ref.onDispose(() => _timer?.cancel());
    if (workspaceId != null) Future.microtask(_reload);
    return const DiscoverState();
  }

  NetworkSongsRepository get _repo => ref.read(networkSongsRepositoryProvider);

  void setSearch(String search) {
    state = state.copyWith(query: state.query.copyWith(search: search));
    _timer?.cancel();
    if (search.trim().isEmpty) return unawaited(_loadFirst());
    _timer = Timer(debounce, _loadFirst);
  }

  void setSort(DiscoverSort sort) => _change(state.query.copyWith(sort: sort));

  void setKey(String? key) => _change(state.query.withFilters(key: key, tempo: state.query.tempo));

  void setTempo(DiscoverTempo? tempo) => _change(state.query.withFilters(key: state.query.key, tempo: tempo));

  void clearFilters() => _change(state.query.withFilters());

  void _change(DiscoverQuery query) {
    state = state.copyWith(query: query);
    _timer?.cancel();
    unawaited(_loadFirst());
  }

  /// Pull to refresh, retry, and after something was added or unshared.
  Future<void> refresh() => _reload();

  Future<void> _reload() async {
    await Future.wait([_loadFirst(), _loadShared()]);
  }

  Future<void> _loadFirst() async {
    final generation = ++_generation;
    final query = state.query;
    state = state.copyWith(loading: state.songs.isEmpty, refreshing: state.songs.isNotEmpty, error: () => null);
    try {
      final page = await _repo.list(query);
      if (generation != _generation) return;
      state = state.copyWith(
        songs: page.songs,
        nextCursor: () => page.nextCursor,
        loading: false,
        refreshing: false,
        loadingMore: false,
        offline: false,
      );
    } on NetworkException {
      if (generation != _generation) return;
      state = state.copyWith(loading: false, refreshing: false, offline: true);
    } on ApiException catch (e) {
      if (generation != _generation) return;
      state = state.copyWith(loading: false, refreshing: false, error: () => e.message);
    }
  }

  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.loadingMore || state.loading) return;
    final generation = _generation;
    state = state.copyWith(loadingMore: true);
    try {
      final page = await _repo.list(state.query, cursor: cursor);
      if (generation != _generation) return;
      final seen = {for (final s in state.songs) s.id};
      state = state.copyWith(
        songs: [...state.songs, ...page.songs.where((s) => !seen.contains(s.id))],
        nextCursor: () => page.nextCursor,
        loadingMore: false,
      );
    } on ApiException {
      if (generation == _generation) state = state.copyWith(loadingMore: false);
    }
  }

  Future<void> _loadShared() async {
    try {
      final page = await _repo.list(const DiscoverQuery(scope: DiscoverScope.own));
      state = state.copyWith(shared: page.songs);
    } on ApiException {
      // The row just stays as it was.
    }
  }

  /// A song was added to the library: show it as added without a reload.
  void markAdded(int id) => state = state.copyWith(
    songs: [
      for (final s in state.songs) s.id == id ? s.copyWith(alreadyAdded: true, importCount: s.importCount + 1) : s,
    ],
  );
}
