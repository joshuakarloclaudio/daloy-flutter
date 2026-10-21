// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'present_display.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(presentDisplayChannel)
final presentDisplayChannelProvider = PresentDisplayChannelProvider._();

final class PresentDisplayChannelProvider
    extends
        $FunctionalProvider<
          PresentDisplayChannel,
          PresentDisplayChannel,
          PresentDisplayChannel
        >
    with $Provider<PresentDisplayChannel> {
  PresentDisplayChannelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'presentDisplayChannelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$presentDisplayChannelHash();

  @$internal
  @override
  $ProviderElement<PresentDisplayChannel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PresentDisplayChannel create(Ref ref) {
    return presentDisplayChannel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PresentDisplayChannel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PresentDisplayChannel>(value),
    );
  }
}

String _$presentDisplayChannelHash() =>
    r'8128b7a042db06fd6de15259753727f154b78352';

/// The external screen, if one is connected — follows plugging in and out.

@ProviderFor(externalDisplay)
final externalDisplayProvider = ExternalDisplayProvider._();

/// The external screen, if one is connected — follows plugging in and out.

final class ExternalDisplayProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExternalDisplay?>,
          ExternalDisplay?,
          Stream<ExternalDisplay?>
        >
    with $FutureModifier<ExternalDisplay?>, $StreamProvider<ExternalDisplay?> {
  /// The external screen, if one is connected — follows plugging in and out.
  ExternalDisplayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'externalDisplayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$externalDisplayHash();

  @$internal
  @override
  $StreamProviderElement<ExternalDisplay?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ExternalDisplay?> create(Ref ref) {
    return externalDisplay(ref);
  }
}

String _$externalDisplayHash() => r'23fba6b1a5a89ca52f5b9e132fb80295a57cb553';
