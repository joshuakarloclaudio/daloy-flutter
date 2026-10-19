// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_workspace_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The new-workspace sheet and the first-run setup screen
/// (web: `use-workspaces-page.ts` create mutation).

@ProviderFor(CreateWorkspace)
final createWorkspaceProvider = CreateWorkspaceProvider._();

/// The new-workspace sheet and the first-run setup screen
/// (web: `use-workspaces-page.ts` create mutation).
final class CreateWorkspaceProvider
    extends $NotifierProvider<CreateWorkspace, CreateWorkspaceState> {
  /// The new-workspace sheet and the first-run setup screen
  /// (web: `use-workspaces-page.ts` create mutation).
  CreateWorkspaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createWorkspaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createWorkspaceHash();

  @$internal
  @override
  CreateWorkspace create() => CreateWorkspace();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateWorkspaceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateWorkspaceState>(value),
    );
  }
}

String _$createWorkspaceHash() => r'f80249cbc145dc60dad00174ca3933fbe74c1cc6';

/// The new-workspace sheet and the first-run setup screen
/// (web: `use-workspaces-page.ts` create mutation).

abstract class _$CreateWorkspace extends $Notifier<CreateWorkspaceState> {
  CreateWorkspaceState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CreateWorkspaceState, CreateWorkspaceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateWorkspaceState, CreateWorkspaceState>,
              CreateWorkspaceState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Re-pulls the workspace list for the setup screen, so someone invited
/// after signing in can pick that workspace instead of creating one.

@ProviderFor(refreshWorkspaces)
final refreshWorkspacesProvider = RefreshWorkspacesProvider._();

/// Re-pulls the workspace list for the setup screen, so someone invited
/// after signing in can pick that workspace instead of creating one.

final class RefreshWorkspacesProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Re-pulls the workspace list for the setup screen, so someone invited
  /// after signing in can pick that workspace instead of creating one.
  RefreshWorkspacesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'refreshWorkspacesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$refreshWorkspacesHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return refreshWorkspaces(ref);
  }
}

String _$refreshWorkspacesHash() => r'9ebe36396e77a164500a6a773d145cb72c895b1d';
