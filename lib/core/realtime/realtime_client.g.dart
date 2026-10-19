// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(realtimeClient)
final realtimeClientProvider = RealtimeClientProvider._();

final class RealtimeClientProvider
    extends $FunctionalProvider<RealtimeClient, RealtimeClient, RealtimeClient>
    with $Provider<RealtimeClient> {
  RealtimeClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'realtimeClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$realtimeClientHash();

  @$internal
  @override
  $ProviderElement<RealtimeClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RealtimeClient create(Ref ref) {
    return realtimeClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RealtimeClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RealtimeClient>(value),
    );
  }
}

String _$realtimeClientHash() => r'367076c875a571cb64fa99816e032710c68b7476';
