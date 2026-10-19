// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// "Check for updates" on You, and the quiet check at launch. Android asks
/// Google Play first (it can update in place) and the API for the minimum
/// build; iOS only has the API, which offers nothing until there's an App
/// Store listing.

@ProviderFor(AppUpdate)
final appUpdateProvider = AppUpdateProvider._();

/// "Check for updates" on You, and the quiet check at launch. Android asks
/// Google Play first (it can update in place) and the API for the minimum
/// build; iOS only has the API, which offers nothing until there's an App
/// Store listing.
final class AppUpdateProvider extends $NotifierProvider<AppUpdate, AppUpdateState> {
  /// "Check for updates" on You, and the quiet check at launch. Android asks
  /// Google Play first (it can update in place) and the API for the minimum
  /// build; iOS only has the API, which offers nothing until there's an App
  /// Store listing.
  AppUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateHash();

  @$internal
  @override
  AppUpdate create() => AppUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUpdateState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AppUpdateState>(value));
  }
}

String _$appUpdateHash() => r'30e1665fba45630a2a1b78a0ff1260eefa11d884';

/// "Check for updates" on You, and the quiet check at launch. Android asks
/// Google Play first (it can update in place) and the API for the minimum
/// build; iOS only has the API, which offers nothing until there's an App
/// Store listing.

abstract class _$AppUpdate extends $Notifier<AppUpdateState> {
  AppUpdateState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppUpdateState, AppUpdateState>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<AppUpdateState, AppUpdateState>, AppUpdateState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
