// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'os_search_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(osSearchIndex)
final osSearchIndexProvider = OsSearchIndexProvider._();

final class OsSearchIndexProvider
    extends $FunctionalProvider<OsSearchIndex, OsSearchIndex, OsSearchIndex>
    with $Provider<OsSearchIndex> {
  OsSearchIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'osSearchIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$osSearchIndexHash();

  @$internal
  @override
  $ProviderElement<OsSearchIndex> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OsSearchIndex create(Ref ref) {
    return osSearchIndex(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OsSearchIndex value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OsSearchIndex>(value),
    );
  }
}

String _$osSearchIndexHash() => r'e41c9ae47dcddb2a3afbd524a513e36d05518bf0';

/// Keeps the OS's search in step with the active workspace's songs and
/// line-ups: re-sent a few seconds after they settle (a sync writes many
/// rows at once), and only when what the OS would show actually changed.
/// A workspace switch replaces everything with the new workspace's items.

@ProviderFor(OsSearchSync)
final osSearchSyncProvider = OsSearchSyncProvider._();

/// Keeps the OS's search in step with the active workspace's songs and
/// line-ups: re-sent a few seconds after they settle (a sync writes many
/// rows at once), and only when what the OS would show actually changed.
/// A workspace switch replaces everything with the new workspace's items.
final class OsSearchSyncProvider extends $NotifierProvider<OsSearchSync, void> {
  /// Keeps the OS's search in step with the active workspace's songs and
  /// line-ups: re-sent a few seconds after they settle (a sync writes many
  /// rows at once), and only when what the OS would show actually changed.
  /// A workspace switch replaces everything with the new workspace's items.
  OsSearchSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'osSearchSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$osSearchSyncHash();

  @$internal
  @override
  OsSearchSync create() => OsSearchSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$osSearchSyncHash() => r'15d6bfacdf78c68663b5f6ff469e17d1944fa20d';

/// Keeps the OS's search in step with the active workspace's songs and
/// line-ups: re-sent a few seconds after they settle (a sync writes many
/// rows at once), and only when what the OS would show actually changed.
/// A workspace switch replaces everything with the new workspace's items.

abstract class _$OsSearchSync extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
