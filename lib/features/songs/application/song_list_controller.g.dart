// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the Songs screen is currently searching, filtering and sorting by.
/// Kept alive so the choices survive switching tabs; the sort is also
/// remembered on this device.

@ProviderFor(SongListController)
final songListControllerProvider = SongListControllerProvider._();

/// What the Songs screen is currently searching, filtering and sorting by.
/// Kept alive so the choices survive switching tabs; the sort is also
/// remembered on this device.
final class SongListControllerProvider
    extends $NotifierProvider<SongListController, SongListQuery> {
  /// What the Songs screen is currently searching, filtering and sorting by.
  /// Kept alive so the choices survive switching tabs; the sort is also
  /// remembered on this device.
  SongListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListControllerHash();

  @$internal
  @override
  SongListController create() => SongListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongListQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongListQuery>(value),
    );
  }
}

String _$songListControllerHash() =>
    r'4a9263a780d7e9d13b95af6db69c52484f376827';

/// What the Songs screen is currently searching, filtering and sorting by.
/// Kept alive so the choices survive switching tabs; the sort is also
/// remembered on this device.

abstract class _$SongListController extends $Notifier<SongListQuery> {
  SongListQuery build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SongListQuery, SongListQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SongListQuery, SongListQuery>,
              SongListQuery,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The library for the current [SongListController] query. A query change
/// rebuilds this provider, which keeps the previous list as `value` while
/// the next one loads — so the list never flashes empty mid-typing.

@ProviderFor(librarySongs)
final librarySongsProvider = LibrarySongsProvider._();

/// The library for the current [SongListController] query. A query change
/// rebuilds this provider, which keeps the previous list as `value` while
/// the next one loads — so the list never flashes empty mid-typing.

final class LibrarySongsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Song>>,
          List<Song>,
          Stream<List<Song>>
        >
    with $FutureModifier<List<Song>>, $StreamProvider<List<Song>> {
  /// The library for the current [SongListController] query. A query change
  /// rebuilds this provider, which keeps the previous list as `value` while
  /// the next one loads — so the list never flashes empty mid-typing.
  LibrarySongsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'librarySongsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$librarySongsHash();

  @$internal
  @override
  $StreamProviderElement<List<Song>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Song>> create(Ref ref) {
    return librarySongs(ref);
  }
}

String _$librarySongsHash() => r'c703ae5c5669fc8cea47d7e008414e4bc2910035';
