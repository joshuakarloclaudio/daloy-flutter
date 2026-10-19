// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_realtime.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(remoteChangeBus)
final remoteChangeBusProvider = RemoteChangeBusProvider._();

final class RemoteChangeBusProvider
    extends
        $FunctionalProvider<RemoteChangeBus, RemoteChangeBus, RemoteChangeBus>
    with $Provider<RemoteChangeBus> {
  RemoteChangeBusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteChangeBusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteChangeBusHash();

  @$internal
  @override
  $ProviderElement<RemoteChangeBus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RemoteChangeBus create(Ref ref) {
    return remoteChangeBus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteChangeBus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteChangeBus>(value),
    );
  }
}

String _$remoteChangeBusHash() => r'e2b9130009e1ce6c0c83d89034f614e225953a44';

/// Keeps this device in step with the workspace in real time: the
/// workspace channel's pings (`song.changed`, `song.deleted`,
/// `line-up.changed`, `line-up.deleted`) and my own channel's
/// `capo.changed`. A ping carries no content: the item is fetched when its
/// version is newer than this device's copy, and written to Drift through the
/// same paths a sync uses — so unsent changes made here still win, and every
/// screen watching the item redraws. After a reconnect (and, from the shell,
/// on return to the app) a sync catches up on pings missed meanwhile.
///
/// Kept alive; the shell starts it.

@ProviderFor(WorkspaceRealtime)
final workspaceRealtimeProvider = WorkspaceRealtimeProvider._();

/// Keeps this device in step with the workspace in real time: the
/// workspace channel's pings (`song.changed`, `song.deleted`,
/// `line-up.changed`, `line-up.deleted`) and my own channel's
/// `capo.changed`. A ping carries no content: the item is fetched when its
/// version is newer than this device's copy, and written to Drift through the
/// same paths a sync uses — so unsent changes made here still win, and every
/// screen watching the item redraws. After a reconnect (and, from the shell,
/// on return to the app) a sync catches up on pings missed meanwhile.
///
/// Kept alive; the shell starts it.
final class WorkspaceRealtimeProvider
    extends $NotifierProvider<WorkspaceRealtime, void> {
  /// Keeps this device in step with the workspace in real time: the
  /// workspace channel's pings (`song.changed`, `song.deleted`,
  /// `line-up.changed`, `line-up.deleted`) and my own channel's
  /// `capo.changed`. A ping carries no content: the item is fetched when its
  /// version is newer than this device's copy, and written to Drift through the
  /// same paths a sync uses — so unsent changes made here still win, and every
  /// screen watching the item redraws. After a reconnect (and, from the shell,
  /// on return to the app) a sync catches up on pings missed meanwhile.
  ///
  /// Kept alive; the shell starts it.
  WorkspaceRealtimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspaceRealtimeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspaceRealtimeHash();

  @$internal
  @override
  WorkspaceRealtime create() => WorkspaceRealtime();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$workspaceRealtimeHash() => r'56b46acaff44bdfa6a24e2f5f3ede1e373fdb652';

/// Keeps this device in step with the workspace in real time: the
/// workspace channel's pings (`song.changed`, `song.deleted`,
/// `line-up.changed`, `line-up.deleted`) and my own channel's
/// `capo.changed`. A ping carries no content: the item is fetched when its
/// version is newer than this device's copy, and written to Drift through the
/// same paths a sync uses — so unsent changes made here still win, and every
/// screen watching the item redraws. After a reconnect (and, from the shell,
/// on return to the app) a sync catches up on pings missed meanwhile.
///
/// Kept alive; the shell starts it.

abstract class _$WorkspaceRealtime extends $Notifier<void> {
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

/// Changes from other devices as they land, for screens to announce.

@ProviderFor(remoteChanges)
final remoteChangesProvider = RemoteChangesProvider._();

/// Changes from other devices as they land, for screens to announce.

final class RemoteChangesProvider
    extends
        $FunctionalProvider<
          AsyncValue<RemoteChange>,
          RemoteChange,
          Stream<RemoteChange>
        >
    with $FutureModifier<RemoteChange>, $StreamProvider<RemoteChange> {
  /// Changes from other devices as they land, for screens to announce.
  RemoteChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteChangesHash();

  @$internal
  @override
  $StreamProviderElement<RemoteChange> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<RemoteChange> create(Ref ref) {
    return remoteChanges(ref);
  }
}

String _$remoteChangesHash() => r'060518cdd040162305a82755522d1ff8db870b0c';
