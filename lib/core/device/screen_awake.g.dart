// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_awake.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(screenAwake)
final screenAwakeProvider = ScreenAwakeProvider._();

final class ScreenAwakeProvider
    extends $FunctionalProvider<ScreenAwake, ScreenAwake, ScreenAwake>
    with $Provider<ScreenAwake> {
  ScreenAwakeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'screenAwakeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$screenAwakeHash();

  @$internal
  @override
  $ProviderElement<ScreenAwake> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ScreenAwake create(Ref ref) {
    return screenAwake(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScreenAwake value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScreenAwake>(value),
    );
  }
}

String _$screenAwakeHash() => r'7f3c7916e5aa938f36659754c7903e1258f55593';
