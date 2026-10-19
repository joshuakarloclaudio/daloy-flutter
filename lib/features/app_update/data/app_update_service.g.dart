// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appUpdateService)
final appUpdateServiceProvider = AppUpdateServiceProvider._();

final class AppUpdateServiceProvider
    extends
        $FunctionalProvider<
          AppUpdateService,
          AppUpdateService,
          AppUpdateService
        >
    with $Provider<AppUpdateService> {
  AppUpdateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateServiceHash();

  @$internal
  @override
  $ProviderElement<AppUpdateService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppUpdateService create(Ref ref) {
    return appUpdateService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUpdateService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppUpdateService>(value),
    );
  }
}

String _$appUpdateServiceHash() => r'a4c4f1228b9013ce0904b0ecebe1b51d5a42fab2';

@ProviderFor(installedVersion)
final installedVersionProvider = InstalledVersionProvider._();

final class InstalledVersionProvider
    extends
        $FunctionalProvider<
          AsyncValue<InstalledVersion>,
          InstalledVersion,
          FutureOr<InstalledVersion>
        >
    with $FutureModifier<InstalledVersion>, $FutureProvider<InstalledVersion> {
  InstalledVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installedVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installedVersionHash();

  @$internal
  @override
  $FutureProviderElement<InstalledVersion> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InstalledVersion> create(Ref ref) {
    return installedVersion(ref);
  }
}

String _$installedVersionHash() => r'aec81669a89641d541dae56a7210baaf444259f6';
