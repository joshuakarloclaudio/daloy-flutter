// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songs_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(songsRepository)
final songsRepositoryProvider = SongsRepositoryProvider._();

final class SongsRepositoryProvider
    extends
        $FunctionalProvider<SongsRepository, SongsRepository, SongsRepository>
    with $Provider<SongsRepository> {
  SongsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SongsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SongsRepository create(Ref ref) {
    return songsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongsRepository>(value),
    );
  }
}

String _$songsRepositoryHash() => r'a6785f6795b30fac90e35e865d4f9d43abcdcb38';

@ProviderFor(libraryArtists)
final libraryArtistsProvider = LibraryArtistsProvider._();

final class LibraryArtistsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  LibraryArtistsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryArtistsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryArtistsHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return libraryArtists(ref);
  }
}

String _$libraryArtistsHash() => r'b2f364be9951877a6582517274cb6ebc5bdd48b1';

/// Songs matching [search], A–Z, for pickers — kept apart from the Songs
/// screen's own query so picking never disturbs it.

@ProviderFor(songSearch)
final songSearchProvider = SongSearchFamily._();

/// Songs matching [search], A–Z, for pickers — kept apart from the Songs
/// screen's own query so picking never disturbs it.

final class SongSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Song>>,
          List<Song>,
          Stream<List<Song>>
        >
    with $FutureModifier<List<Song>>, $StreamProvider<List<Song>> {
  /// Songs matching [search], A–Z, for pickers — kept apart from the Songs
  /// screen's own query so picking never disturbs it.
  SongSearchProvider._({
    required SongSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'songSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songSearchHash();

  @override
  String toString() {
    return r'songSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Song>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Song>> create(Ref ref) {
    final argument = this.argument as String;
    return songSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SongSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songSearchHash() => r'35059c0edc234b384e57eb5deea7a76f0aa93867';

/// Songs matching [search], A–Z, for pickers — kept apart from the Songs
/// screen's own query so picking never disturbs it.

final class SongSearchFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Song>>, String> {
  SongSearchFamily._()
    : super(
        retry: null,
        name: r'songSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Songs matching [search], A–Z, for pickers — kept apart from the Songs
  /// screen's own query so picking never disturbs it.

  SongSearchProvider call(String search) =>
      SongSearchProvider._(argument: search, from: this);

  @override
  String toString() => r'songSearchProvider';
}

/// Pending songs (by local id) and the server's last complaint about each.

@ProviderFor(songOutbox)
final songOutboxProvider = SongOutboxProvider._();

/// Pending songs (by local id) and the server's last complaint about each.

final class SongOutboxProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, String?>>,
          Map<int, String?>,
          Stream<Map<int, String?>>
        >
    with
        $FutureModifier<Map<int, String?>>,
        $StreamProvider<Map<int, String?>> {
  /// Pending songs (by local id) and the server's last complaint about each.
  SongOutboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songOutboxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songOutboxHash();

  @$internal
  @override
  $StreamProviderElement<Map<int, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, String?>> create(Ref ref) {
    return songOutbox(ref);
  }
}

String _$songOutboxHash() => r'4a5f82fcb0d5c9c0686afc0ec71dbeeb33a3e5ac';

@ProviderFor(recentSongs)
final recentSongsProvider = RecentSongsProvider._();

final class RecentSongsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Song>>,
          List<Song>,
          Stream<List<Song>>
        >
    with $FutureModifier<List<Song>>, $StreamProvider<List<Song>> {
  RecentSongsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentSongsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentSongsHash();

  @$internal
  @override
  $StreamProviderElement<List<Song>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Song>> create(Ref ref) {
    return recentSongs(ref);
  }
}

String _$recentSongsHash() => r'dad48aed3fdb2195c8807cbe1cf70d3ecaa4c958';

@ProviderFor(recentlyOpenedSongs)
final recentlyOpenedSongsProvider = RecentlyOpenedSongsProvider._();

final class RecentlyOpenedSongsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Song>>,
          List<Song>,
          Stream<List<Song>>
        >
    with $FutureModifier<List<Song>>, $StreamProvider<List<Song>> {
  RecentlyOpenedSongsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentlyOpenedSongsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentlyOpenedSongsHash();

  @$internal
  @override
  $StreamProviderElement<List<Song>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Song>> create(Ref ref) {
    return recentlyOpenedSongs(ref);
  }
}

String _$recentlyOpenedSongsHash() =>
    r'023800333640f1077ffc1a770bd63fd43260dcc5';
