// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What opening a song does once: counts as using it, and pulls what only the
/// server knows (capo, upcoming line-ups). Watches *only* the connection and
/// workspace, so writing those results to Drift can't re-trigger it.

@ProviderFor(songDetailRefresh)
final songDetailRefreshProvider = SongDetailRefreshFamily._();

/// What opening a song does once: counts as using it, and pulls what only the
/// server knows (capo, upcoming line-ups). Watches *only* the connection and
/// workspace, so writing those results to Drift can't re-trigger it.

final class SongDetailRefreshProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// What opening a song does once: counts as using it, and pulls what only the
  /// server knows (capo, upcoming line-ups). Watches *only* the connection and
  /// workspace, so writing those results to Drift can't re-trigger it.
  SongDetailRefreshProvider._({
    required SongDetailRefreshFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'songDetailRefreshProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songDetailRefreshHash();

  @override
  String toString() {
    return r'songDetailRefreshProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as int;
    return songDetailRefresh(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SongDetailRefreshProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songDetailRefreshHash() => r'f0da14753bf721c1dd323381b5b1927cde2cbe5a';

/// What opening a song does once: counts as using it, and pulls what only the
/// server knows (capo, upcoming line-ups). Watches *only* the connection and
/// workspace, so writing those results to Drift can't re-trigger it.

final class SongDetailRefreshFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  SongDetailRefreshFamily._()
    : super(
        retry: null,
        name: r'songDetailRefreshProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What opening a song does once: counts as using it, and pulls what only the
  /// server knows (capo, upcoming line-ups). Watches *only* the connection and
  /// workspace, so writing those results to Drift can't re-trigger it.

  SongDetailRefreshProvider call(int songId) =>
      SongDetailRefreshProvider._(argument: songId, from: this);

  @override
  String toString() => r'songDetailRefreshProvider';
}

/// All of the song details screen's state and actions — the twin of
/// `use-song-detail-page.ts`. Everything is read from Drift, so it works
/// offline; edits land in Drift first and reach the server when they can.

@ProviderFor(SongDetailController)
final songDetailControllerProvider = SongDetailControllerFamily._();

/// All of the song details screen's state and actions — the twin of
/// `use-song-detail-page.ts`. Everything is read from Drift, so it works
/// offline; edits land in Drift first and reach the server when they can.
final class SongDetailControllerProvider
    extends $NotifierProvider<SongDetailController, SongDetailState> {
  /// All of the song details screen's state and actions — the twin of
  /// `use-song-detail-page.ts`. Everything is read from Drift, so it works
  /// offline; edits land in Drift first and reach the server when they can.
  SongDetailControllerProvider._({
    required SongDetailControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'songDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songDetailControllerHash();

  @override
  String toString() {
    return r'songDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SongDetailController create() => SongDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SongDetailControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songDetailControllerHash() =>
    r'5094cd9fabbea368ae047c464f82486d6f8ce2d1';

/// All of the song details screen's state and actions — the twin of
/// `use-song-detail-page.ts`. Everything is read from Drift, so it works
/// offline; edits land in Drift first and reach the server when they can.

final class SongDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SongDetailController,
          SongDetailState,
          SongDetailState,
          SongDetailState,
          int
        > {
  SongDetailControllerFamily._()
    : super(
        retry: null,
        name: r'songDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// All of the song details screen's state and actions — the twin of
  /// `use-song-detail-page.ts`. Everything is read from Drift, so it works
  /// offline; edits land in Drift first and reach the server when they can.

  SongDetailControllerProvider call(int songId) =>
      SongDetailControllerProvider._(argument: songId, from: this);

  @override
  String toString() => r'songDetailControllerProvider';
}

/// All of the song details screen's state and actions — the twin of
/// `use-song-detail-page.ts`. Everything is read from Drift, so it works
/// offline; edits land in Drift first and reach the server when they can.

abstract class _$SongDetailController extends $Notifier<SongDetailState> {
  late final _$args = ref.$arg as int;
  int get songId => _$args;

  SongDetailState build(int songId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SongDetailState, SongDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SongDetailState, SongDetailState>,
              SongDetailState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
