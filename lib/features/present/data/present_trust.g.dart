// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'present_trust.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This install's id on the network, so paired devices know each other
/// again tomorrow, under whatever name or address.

@ProviderFor(presentDeviceId)
final presentDeviceIdProvider = PresentDeviceIdProvider._();

/// This install's id on the network, so paired devices know each other
/// again tomorrow, under whatever name or address.

final class PresentDeviceIdProvider extends $FunctionalProvider<String, String, String> with $Provider<String> {
  /// This install's id on the network, so paired devices know each other
  /// again tomorrow, under whatever name or address.
  PresentDeviceIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presentDeviceIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presentDeviceIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return presentDeviceId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<String>(value));
  }
}

String _$presentDeviceIdHash() => r'1573d026f02b8d0329582841e100456e0b0a1b17';

/// Devices allowed to drive this one's presentation.

@ProviderFor(presentTrustedControllers)
final presentTrustedControllersProvider = PresentTrustedControllersProvider._();

/// Devices allowed to drive this one's presentation.

final class PresentTrustedControllersProvider extends $FunctionalProvider<PresentKeys, PresentKeys, PresentKeys>
    with $Provider<PresentKeys> {
  /// Devices allowed to drive this one's presentation.
  PresentTrustedControllersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presentTrustedControllersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presentTrustedControllersHash();

  @$internal
  @override
  $ProviderElement<PresentKeys> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  PresentKeys create(Ref ref) {
    return presentTrustedControllers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresentKeys value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<PresentKeys>(value));
  }
}

String _$presentTrustedControllersHash() => r'954d57aff8868a9dce69beda805136e776a1d524';

/// Keys this device was given to drive others' presentations.

@ProviderFor(presentPresenterKeys)
final presentPresenterKeysProvider = PresentPresenterKeysProvider._();

/// Keys this device was given to drive others' presentations.

final class PresentPresenterKeysProvider extends $FunctionalProvider<PresentKeys, PresentKeys, PresentKeys>
    with $Provider<PresentKeys> {
  /// Keys this device was given to drive others' presentations.
  PresentPresenterKeysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presentPresenterKeysProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presentPresenterKeysHash();

  @$internal
  @override
  $ProviderElement<PresentKeys> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  PresentKeys create(Ref ref) {
    return presentPresenterKeys(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresentKeys value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<PresentKeys>(value));
  }
}

String _$presentPresenterKeysHash() => r'746394e5989e4d064aa3c563ffa7268fc7c5126e';

/// Whether this device looks for presentations nearby in the background (the
/// pill above the tab bar). Off until it has opened Present or Remote once,
/// so the system's Local Network prompt comes up where it makes sense.

@ProviderFor(PresentDiscovery)
final presentDiscoveryProvider = PresentDiscoveryProvider._();

/// Whether this device looks for presentations nearby in the background (the
/// pill above the tab bar). Off until it has opened Present or Remote once,
/// so the system's Local Network prompt comes up where it makes sense.
final class PresentDiscoveryProvider extends $NotifierProvider<PresentDiscovery, bool> {
  /// Whether this device looks for presentations nearby in the background (the
  /// pill above the tab bar). Off until it has opened Present or Remote once,
  /// so the system's Local Network prompt comes up where it makes sense.
  PresentDiscoveryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presentDiscoveryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presentDiscoveryHash();

  @$internal
  @override
  PresentDiscovery create() => PresentDiscovery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$presentDiscoveryHash() => r'd164444ece1cb5562fcff62dff3186d01638b2e9';

/// Whether this device looks for presentations nearby in the background (the
/// pill above the tab bar). Off until it has opened Present or Remote once,
/// so the system's Local Network prompt comes up where it makes sense.

abstract class _$PresentDiscovery extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
