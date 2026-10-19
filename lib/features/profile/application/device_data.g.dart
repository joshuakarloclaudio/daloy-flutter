// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [DeviceData], read again shortly after any write settles, so the numbers
/// climb while a workspace downloads.

@ProviderFor(deviceData)
final deviceDataProvider = DeviceDataProvider._();

/// [DeviceData], read again shortly after any write settles, so the numbers
/// climb while a workspace downloads.

final class DeviceDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceData>,
          DeviceData,
          Stream<DeviceData>
        >
    with $FutureModifier<DeviceData>, $StreamProvider<DeviceData> {
  /// [DeviceData], read again shortly after any write settles, so the numbers
  /// climb while a workspace downloads.
  DeviceDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceDataHash();

  @$internal
  @override
  $StreamProviderElement<DeviceData> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<DeviceData> create(Ref ref) {
    return deviceData(ref);
  }
}

String _$deviceDataHash() => r'9afa4b0b1b2fb3df4b4bb24036d06703f755f99f';

/// Clearing the downloaded library. Changes made here go to the server
/// first, and the active workspace downloads again straight after.

@ProviderFor(DeviceDataClear)
final deviceDataClearProvider = DeviceDataClearProvider._();

/// Clearing the downloaded library. Changes made here go to the server
/// first, and the active workspace downloads again straight after.
final class DeviceDataClearProvider
    extends $NotifierProvider<DeviceDataClear, ClearPhase> {
  /// Clearing the downloaded library. Changes made here go to the server
  /// first, and the active workspace downloads again straight after.
  DeviceDataClearProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceDataClearProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceDataClearHash();

  @$internal
  @override
  DeviceDataClear create() => DeviceDataClear();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearPhase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearPhase>(value),
    );
  }
}

String _$deviceDataClearHash() => r'f37ed6a2d13173f4e8e5bd619ead2904b6ba8700';

/// Clearing the downloaded library. Changes made here go to the server
/// first, and the active workspace downloads again straight after.

abstract class _$DeviceDataClear extends $Notifier<ClearPhase> {
  ClearPhase build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ClearPhase, ClearPhase>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClearPhase, ClearPhase>,
              ClearPhase,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
