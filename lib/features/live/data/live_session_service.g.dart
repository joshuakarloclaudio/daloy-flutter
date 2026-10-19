// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_session_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(liveSessionService)
final liveSessionServiceProvider = LiveSessionServiceProvider._();

final class LiveSessionServiceProvider
    extends
        $FunctionalProvider<
          LiveSessionService,
          LiveSessionService,
          LiveSessionService
        >
    with $Provider<LiveSessionService> {
  LiveSessionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveSessionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveSessionServiceHash();

  @$internal
  @override
  $ProviderElement<LiveSessionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LiveSessionService create(Ref ref) {
    return liveSessionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveSessionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveSessionService>(value),
    );
  }
}

String _$liveSessionServiceHash() =>
    r'39b5dc38854b25f56c2a5bb38704ce5d9f743186';
