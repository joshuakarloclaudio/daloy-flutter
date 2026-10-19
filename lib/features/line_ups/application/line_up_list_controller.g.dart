// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_up_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What the Line-ups screen is currently searching, filtering and sorting
/// by. Kept alive so the choices survive switching tabs.

@ProviderFor(LineUpListController)
final lineUpListControllerProvider = LineUpListControllerProvider._();

/// What the Line-ups screen is currently searching, filtering and sorting
/// by. Kept alive so the choices survive switching tabs.
final class LineUpListControllerProvider
    extends $NotifierProvider<LineUpListController, LineUpListQuery> {
  /// What the Line-ups screen is currently searching, filtering and sorting
  /// by. Kept alive so the choices survive switching tabs.
  LineUpListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineUpListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineUpListControllerHash();

  @$internal
  @override
  LineUpListController create() => LineUpListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineUpListQuery value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineUpListQuery>(value),
    );
  }
}

String _$lineUpListControllerHash() =>
    r'd029216d115de5ac5f1beae71367e8de80b4ae0e';

/// What the Line-ups screen is currently searching, filtering and sorting
/// by. Kept alive so the choices survive switching tabs.

abstract class _$LineUpListController extends $Notifier<LineUpListQuery> {
  LineUpListQuery build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LineUpListQuery, LineUpListQuery>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LineUpListQuery, LineUpListQuery>,
              LineUpListQuery,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The library for the current [LineUpListController] query. Rebuilds keep
/// the previous list as `value` while the next one loads.

@ProviderFor(libraryLineUps)
final libraryLineUpsProvider = LibraryLineUpsProvider._();

/// The library for the current [LineUpListController] query. Rebuilds keep
/// the previous list as `value` while the next one loads.

final class LibraryLineUpsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LineUp>>,
          List<LineUp>,
          Stream<List<LineUp>>
        >
    with $FutureModifier<List<LineUp>>, $StreamProvider<List<LineUp>> {
  /// The library for the current [LineUpListController] query. Rebuilds keep
  /// the previous list as `value` while the next one loads.
  LibraryLineUpsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryLineUpsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryLineUpsHash();

  @$internal
  @override
  $StreamProviderElement<List<LineUp>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LineUp>> create(Ref ref) {
    return libraryLineUps(ref);
  }
}

String _$libraryLineUpsHash() => r'de1a9400e6ff907fa5a2ffde36eefc0bda39a74d';
