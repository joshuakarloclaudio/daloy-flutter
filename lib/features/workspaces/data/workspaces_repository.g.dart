// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspaces_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workspacesRepository)
final workspacesRepositoryProvider = WorkspacesRepositoryProvider._();

final class WorkspacesRepositoryProvider
    extends
        $FunctionalProvider<
          WorkspacesRepository,
          WorkspacesRepository,
          WorkspacesRepository
        >
    with $Provider<WorkspacesRepository> {
  WorkspacesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspacesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspacesRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkspacesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkspacesRepository create(Ref ref) {
    return workspacesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkspacesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkspacesRepository>(value),
    );
  }
}

String _$workspacesRepositoryHash() =>
    r'276fd4be6595f3e8093eb3ba80c2563ef3a117a1';

@ProviderFor(activeWorkspace)
final activeWorkspaceProvider = ActiveWorkspaceProvider._();

final class ActiveWorkspaceProvider
    extends
        $FunctionalProvider<
          AsyncValue<Workspace?>,
          Workspace?,
          Stream<Workspace?>
        >
    with $FutureModifier<Workspace?>, $StreamProvider<Workspace?> {
  ActiveWorkspaceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeWorkspaceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeWorkspaceHash();

  @$internal
  @override
  $StreamProviderElement<Workspace?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Workspace?> create(Ref ref) {
    return activeWorkspace(ref);
  }
}

String _$activeWorkspaceHash() => r'cdde09b94fa6acd2d8c7191f0f0684578eff3a03';

@ProviderFor(workspaces)
final workspacesProvider = WorkspacesProvider._();

final class WorkspacesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Workspace>>,
          List<Workspace>,
          Stream<List<Workspace>>
        >
    with $FutureModifier<List<Workspace>>, $StreamProvider<List<Workspace>> {
  WorkspacesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspacesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspacesHash();

  @$internal
  @override
  $StreamProviderElement<List<Workspace>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Workspace>> create(Ref ref) {
    return workspaces(ref);
  }
}

String _$workspacesHash() => r'da47fb4b4e583892610c39f9bb35cc47312b52ce';
