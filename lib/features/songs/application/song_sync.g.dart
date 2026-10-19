// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every song that isn't plainly synced, by id: new songs and edits still on
/// this device, ones on the wire, refused ones, and ones that just landed.

@ProviderFor(songSync)
final songSyncProvider = SongSyncProvider._();

/// Every song that isn't plainly synced, by id: new songs and edits still on
/// this device, ones on the wire, refused ones, and ones that just landed.

final class SongSyncProvider
    extends
        $FunctionalProvider<
          Map<int, SongSync>,
          Map<int, SongSync>,
          Map<int, SongSync>
        >
    with $Provider<Map<int, SongSync>> {
  /// Every song that isn't plainly synced, by id: new songs and edits still on
  /// this device, ones on the wire, refused ones, and ones that just landed.
  SongSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songSyncHash();

  @$internal
  @override
  $ProviderElement<Map<int, SongSync>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<int, SongSync> create(Ref ref) {
    return songSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, SongSync> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, SongSync>>(value),
    );
  }
}

String _$songSyncHash() => r'5d5816488a4486d992d1bc7f70cbbab24ffc1041';
