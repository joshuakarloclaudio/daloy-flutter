// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_status.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Network reachability, the twin of `use-online-status.ts`. Connectivity is
/// a hint, not a guarantee — requests still fail gracefully when it lies.

@ProviderFor(onlineStatus)
final onlineStatusProvider = OnlineStatusProvider._();

/// Network reachability, the twin of `use-online-status.ts`. Connectivity is
/// a hint, not a guarantee — requests still fail gracefully when it lies.

final class OnlineStatusProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Network reachability, the twin of `use-online-status.ts`. Connectivity is
  /// a hint, not a guarantee — requests still fail gracefully when it lies.
  OnlineStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onlineStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onlineStatusHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return onlineStatus(ref);
  }
}

String _$onlineStatusHash() => r'2534a3f6488eca323a969eb1c8ca0eab92d34810';

/// Optimistic until the first reading arrives.

@ProviderFor(isOnline)
final isOnlineProvider = IsOnlineProvider._();

/// Optimistic until the first reading arrives.

final class IsOnlineProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Optimistic until the first reading arrives.
  IsOnlineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOnlineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOnlineHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOnline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOnlineHash() => r'0a43a5b8213e036c5c3e1d57cbdc3e8baa279d88';
