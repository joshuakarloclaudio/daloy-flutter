// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_prefs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Loaded in `main()` before the first frame so the theme never flashes.
/// Null in tests, where nothing persists.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Loaded in `main()` before the first frame so the theme never flashes.
/// Null in tests, where nothing persists.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences?,
          SharedPreferences?,
          SharedPreferences?
        >
    with $Provider<SharedPreferences?> {
  /// Loaded in `main()` before the first frame so the theme never flashes.
  /// Null in tests, where nothing persists.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences? create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences?>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'efc8dcb2ecba79b47bc2d0862a052964c20a8faa';

@ProviderFor(DevicePrefsController)
final devicePrefsControllerProvider = DevicePrefsControllerProvider._();

final class DevicePrefsControllerProvider
    extends $NotifierProvider<DevicePrefsController, DevicePrefs> {
  DevicePrefsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devicePrefsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devicePrefsControllerHash();

  @$internal
  @override
  DevicePrefsController create() => DevicePrefsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DevicePrefs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DevicePrefs>(value),
    );
  }
}

String _$devicePrefsControllerHash() =>
    r'a3c80b087d899c2c25fe61f25f7419bd59df9a80';

abstract class _$DevicePrefsController extends $Notifier<DevicePrefs> {
  DevicePrefs build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DevicePrefs, DevicePrefs>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DevicePrefs, DevicePrefs>,
              DevicePrefs,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
