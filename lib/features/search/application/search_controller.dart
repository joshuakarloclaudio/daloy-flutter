import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/connectivity/online_status.dart';
import '../../auth/application/session_controller.dart';
import '../data/network_songs_repository.dart';
import '../data/search_repository.dart';
import '../domain/network_song.dart';
import '../domain/search_query.dart';
import '../domain/search_results.dart';

part 'search_controller.g.dart';

class SearchState {
  const SearchState({this.input = '', this.scope = SearchScope.all, this.query = const SearchQuery()});

  /// What's in the field, as typed.
  final String input;
  final SearchScope scope;

  /// [input] as last searched — trails typing by a beat.
  final SearchQuery query;

  SearchState copyWith({String? input, SearchScope? scope, SearchQuery? query}) =>
      SearchState(input: input ?? this.input, scope: scope ?? this.scope, query: query ?? this.query);
}

/// The search field and chips. Kept alive, so the phone's Search tab still
/// holds your query and results when you come back to it; cleared when the
/// workspace changes, since the results belong to the old one.
@Riverpod(keepAlive: true)
class SearchPageController extends _$SearchPageController {
  static const debounce = Duration(milliseconds: 120);

  Timer? _timer;

  @override
  SearchState build() {
    ref.watch(activeWorkspaceIdProvider);
    ref.onDispose(() => _timer?.cancel());
    return const SearchState();
  }

  void setInput(String input) {
    state = state.copyWith(input: input);
    _timer?.cancel();
    // Clearing is instant; typing waits for a pause.
    if (input.trim().isEmpty) return _run();
    _timer = Timer(debounce, _run);
  }

  void setScope(SearchScope scope) {
    state = state.copyWith(scope: scope);
    _timer?.cancel();
    _run();
  }

  /// Runs [input] now (a recent search tapped, a token chip removed).
  void submit(String input) {
    state = state.copyWith(input: input);
    _timer?.cancel();
    _run();
  }

  void clear() => submit('');

  void _run() => state = state.copyWith(query: SearchQuery.parse(state.input, scope: state.scope));

  /// Saves what's searched once it led somewhere — opening a result or
  /// pressing Search — so recents are searches that worked.
  Future<void> remember() async {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    final term = state.input.trim();
    if (workspaceId == null || term.isEmpty) return;
    // Counted here rather than per keystroke: a search that led somewhere.
    unawaited(
      ref.read(analyticsProvider).trackAndFlush(AnalyticsEvent.songSearched, properties: {'query_length': term.length}),
    );
    await ref.read(searchRepositoryProvider).remember(workspaceId, state.input);
  }
}

@riverpod
Stream<SearchResults> searchResults(Ref ref) {
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  final query = ref.watch(searchPageControllerProvider.select((s) => s.query));
  if (workspaceId == null) return Stream.value(SearchResults.empty);
  return ref.watch(searchRepositoryProvider).watch(workspaceId, query);
}

/// Discover matches for the current query: online only, asked for once
/// typing has settled a little longer than the local search. Null means
/// "not asked" (offline, or a query that doesn't want them).
@riverpod
Future<List<NetworkSong>?> networkSearchResults(Ref ref) async {
  final query = ref.watch(searchPageControllerProvider.select((s) => s.query));
  final online = ref.watch(isOnlineProvider);
  ref.watch(activeWorkspaceIdProvider);
  if (!online || !query.wantsNetwork) return null;

  var cancelled = false;
  ref.onDispose(() => cancelled = true);
  await Future<void>.delayed(const Duration(milliseconds: 350));
  if (cancelled) return null;
  return ref.read(networkSongsRepositoryProvider).search(query.text);
}

@riverpod
Stream<List<String>> recentSearches(Ref ref) {
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  if (workspaceId == null) return Stream.value(const []);
  return ref.watch(searchRepositoryProvider).watchRecent(workspaceId);
}

/// Asks the Search tab to focus its field (the tab tapped again, ⌘K).
@Riverpod(keepAlive: true)
class SearchFocusRequests extends _$SearchFocusRequests {
  @override
  int build() => 0;

  void request() => state++;
}
