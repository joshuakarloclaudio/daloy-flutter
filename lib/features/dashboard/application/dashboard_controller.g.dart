// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All of Home's state and actions — the twin of `use-dashboard-page.ts`.
/// Everything is read from Drift (works offline) except the live session,
/// which is polled from the network.

@ProviderFor(DashboardController)
final dashboardControllerProvider = DashboardControllerProvider._();

/// All of Home's state and actions — the twin of `use-dashboard-page.ts`.
/// Everything is read from Drift (works offline) except the live session,
/// which is polled from the network.
final class DashboardControllerProvider
    extends $NotifierProvider<DashboardController, DashboardState> {
  /// All of Home's state and actions — the twin of `use-dashboard-page.ts`.
  /// Everything is read from Drift (works offline) except the live session,
  /// which is polled from the network.
  DashboardControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardControllerHash();

  @$internal
  @override
  DashboardController create() => DashboardController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardState>(value),
    );
  }
}

String _$dashboardControllerHash() =>
    r'f687c2a9c954fe7edc8e0f9043e450698ed880cb';

/// All of Home's state and actions — the twin of `use-dashboard-page.ts`.
/// Everything is read from Drift (works offline) except the live session,
/// which is polled from the network.

abstract class _$DashboardController extends $Notifier<DashboardState> {
  DashboardState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DashboardState, DashboardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DashboardState, DashboardState>,
              DashboardState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
