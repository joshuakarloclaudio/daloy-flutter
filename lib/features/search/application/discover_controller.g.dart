// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Kept alive so the segment you left is the one you come back to.

@ProviderFor(SongsSegmentController)
final songsSegmentControllerProvider = SongsSegmentControllerProvider._();

/// Kept alive so the segment you left is the one you come back to.
final class SongsSegmentControllerProvider
    extends $NotifierProvider<SongsSegmentController, SongsSegment> {
  /// Kept alive so the segment you left is the one you come back to.
  SongsSegmentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songsSegmentControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songsSegmentControllerHash();

  @$internal
  @override
  SongsSegmentController create() => SongsSegmentController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongsSegment value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongsSegment>(value),
    );
  }
}

String _$songsSegmentControllerHash() =>
    r'e67c3684cba1d9c701b1702bcd111719d625626f';

/// Kept alive so the segment you left is the one you come back to.

abstract class _$SongsSegmentController extends $Notifier<SongsSegment> {
  SongsSegment build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SongsSegment, SongsSegment>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SongsSegment, SongsSegment>,
              SongsSegment,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Discover's list: other teams' shared songs, paged, plus our own. Network
/// only on purpose — these aren't ours until they're added. Cleared when the
/// workspace changes (what's "already added" belongs to the old one).

@ProviderFor(DiscoverController)
final discoverControllerProvider = DiscoverControllerProvider._();

/// Discover's list: other teams' shared songs, paged, plus our own. Network
/// only on purpose — these aren't ours until they're added. Cleared when the
/// workspace changes (what's "already added" belongs to the old one).
final class DiscoverControllerProvider
    extends $NotifierProvider<DiscoverController, DiscoverState> {
  /// Discover's list: other teams' shared songs, paged, plus our own. Network
  /// only on purpose — these aren't ours until they're added. Cleared when the
  /// workspace changes (what's "already added" belongs to the old one).
  DiscoverControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverControllerHash();

  @$internal
  @override
  DiscoverController create() => DiscoverController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiscoverState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiscoverState>(value),
    );
  }
}

String _$discoverControllerHash() =>
    r'6723e1375bea009c2039f593563eb6bbefcd1065';

/// Discover's list: other teams' shared songs, paged, plus our own. Network
/// only on purpose — these aren't ours until they're added. Cleared when the
/// workspace changes (what's "already added" belongs to the old one).

abstract class _$DiscoverController extends $Notifier<DiscoverState> {
  DiscoverState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DiscoverState, DiscoverState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DiscoverState, DiscoverState>,
              DiscoverState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
