// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_sync_activity.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Songs on the wire and songs that just landed.

@ProviderFor(SongSyncActivity)
final songSyncActivityProvider = SongSyncActivityProvider._();

/// Songs on the wire and songs that just landed.
final class SongSyncActivityProvider
    extends $NotifierProvider<SongSyncActivity, SongSyncActivityState> {
  /// Songs on the wire and songs that just landed.
  SongSyncActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songSyncActivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songSyncActivityHash();

  @$internal
  @override
  SongSyncActivity create() => SongSyncActivity();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongSyncActivityState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongSyncActivityState>(value),
    );
  }
}

String _$songSyncActivityHash() => r'5dececccbb26cd30f55928af8fcbc450fbd48eb2';

/// Songs on the wire and songs that just landed.

abstract class _$SongSyncActivity extends $Notifier<SongSyncActivityState> {
  SongSyncActivityState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SongSyncActivityState, SongSyncActivityState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SongSyncActivityState, SongSyncActivityState>,
              SongSyncActivityState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
