// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The search field and chips. Kept alive, so the phone's Search tab still
/// holds your query and results when you come back to it; cleared when the
/// workspace changes, since the results belong to the old one.

@ProviderFor(SearchPageController)
final searchPageControllerProvider = SearchPageControllerProvider._();

/// The search field and chips. Kept alive, so the phone's Search tab still
/// holds your query and results when you come back to it; cleared when the
/// workspace changes, since the results belong to the old one.
final class SearchPageControllerProvider
    extends $NotifierProvider<SearchPageController, SearchState> {
  /// The search field and chips. Kept alive, so the phone's Search tab still
  /// holds your query and results when you come back to it; cleared when the
  /// workspace changes, since the results belong to the old one.
  SearchPageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchPageControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchPageControllerHash();

  @$internal
  @override
  SearchPageController create() => SearchPageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchState>(value),
    );
  }
}

String _$searchPageControllerHash() =>
    r'fee062a2888d50a9950b5b75cc0aa9fbe5f720ac';

/// The search field and chips. Kept alive, so the phone's Search tab still
/// holds your query and results when you come back to it; cleared when the
/// workspace changes, since the results belong to the old one.

abstract class _$SearchPageController extends $Notifier<SearchState> {
  SearchState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SearchState, SearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchState, SearchState>,
              SearchState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsProvider._();

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SearchResults>,
          SearchResults,
          Stream<SearchResults>
        >
    with $FutureModifier<SearchResults>, $StreamProvider<SearchResults> {
  SearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  $StreamProviderElement<SearchResults> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SearchResults> create(Ref ref) {
    return searchResults(ref);
  }
}

String _$searchResultsHash() => r'f2ffbbf01edade35a0a9113aec6fa726ed258ef6';

/// Discover matches for the current query: online only, asked for once
/// typing has settled a little longer than the local search. Null means
/// "not asked" (offline, or a query that doesn't want them).

@ProviderFor(networkSearchResults)
final networkSearchResultsProvider = NetworkSearchResultsProvider._();

/// Discover matches for the current query: online only, asked for once
/// typing has settled a little longer than the local search. Null means
/// "not asked" (offline, or a query that doesn't want them).

final class NetworkSearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<NetworkSong>?>,
          List<NetworkSong>?,
          FutureOr<List<NetworkSong>?>
        >
    with
        $FutureModifier<List<NetworkSong>?>,
        $FutureProvider<List<NetworkSong>?> {
  /// Discover matches for the current query: online only, asked for once
  /// typing has settled a little longer than the local search. Null means
  /// "not asked" (offline, or a query that doesn't want them).
  NetworkSearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkSearchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkSearchResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<NetworkSong>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<NetworkSong>?> create(Ref ref) {
    return networkSearchResults(ref);
  }
}

String _$networkSearchResultsHash() =>
    r'ba8537ad3749c647e81e1be16ff6c13c24745a4f';

@ProviderFor(recentSearches)
final recentSearchesProvider = RecentSearchesProvider._();

final class RecentSearchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  RecentSearchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSearchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSearchesHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return recentSearches(ref);
  }
}

String _$recentSearchesHash() => r'5cbc828ea54a34aab386c47b34cd1899a73ef2fd';

/// Asks the Search tab to focus its field (the tab tapped again, ⌘K).

@ProviderFor(SearchFocusRequests)
final searchFocusRequestsProvider = SearchFocusRequestsProvider._();

/// Asks the Search tab to focus its field (the tab tapped again, ⌘K).
final class SearchFocusRequestsProvider
    extends $NotifierProvider<SearchFocusRequests, int> {
  /// Asks the Search tab to focus its field (the tab tapped again, ⌘K).
  SearchFocusRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchFocusRequestsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchFocusRequestsHash();

  @$internal
  @override
  SearchFocusRequests create() => SearchFocusRequests();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$searchFocusRequestsHash() =>
    r'c8a3a41f35fbb742c65303dfce977840b972e981';

/// Asks the Search tab to focus its field (the tab tapped again, ⌘K).

abstract class _$SearchFocusRequests extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
