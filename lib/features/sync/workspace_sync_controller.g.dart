// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_sync_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Pulls the active workspace's library into Drift: on sign-in, on workspace
/// switch, on reconnect, and on pull-to-refresh. Screens never wait on it —
/// they watch Drift and update when the write lands.

@ProviderFor(WorkspaceSync)
final workspaceSyncProvider = WorkspaceSyncProvider._();

/// Pulls the active workspace's library into Drift: on sign-in, on workspace
/// switch, on reconnect, and on pull-to-refresh. Screens never wait on it —
/// they watch Drift and update when the write lands.
final class WorkspaceSyncProvider
    extends $NotifierProvider<WorkspaceSync, WorkspaceSyncState> {
  /// Pulls the active workspace's library into Drift: on sign-in, on workspace
  /// switch, on reconnect, and on pull-to-refresh. Screens never wait on it —
  /// they watch Drift and update when the write lands.
  WorkspaceSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspaceSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspaceSyncHash();

  @$internal
  @override
  WorkspaceSync create() => WorkspaceSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkspaceSyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkspaceSyncState>(value),
    );
  }
}

String _$workspaceSyncHash() => r'296426cf0e3939ddab3fcf7454c1520ebbe0cbf4';

/// Pulls the active workspace's library into Drift: on sign-in, on workspace
/// switch, on reconnect, and on pull-to-refresh. Screens never wait on it —
/// they watch Drift and update when the write lands.

abstract class _$WorkspaceSync extends $Notifier<WorkspaceSyncState> {
  WorkspaceSyncState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WorkspaceSyncState, WorkspaceSyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WorkspaceSyncState, WorkspaceSyncState>,
              WorkspaceSyncState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
