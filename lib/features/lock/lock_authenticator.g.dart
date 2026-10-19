// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lock_authenticator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lockAuthenticator)
final lockAuthenticatorProvider = LockAuthenticatorProvider._();

final class LockAuthenticatorProvider
    extends
        $FunctionalProvider<
          LockAuthenticator,
          LockAuthenticator,
          LockAuthenticator
        >
    with $Provider<LockAuthenticator> {
  LockAuthenticatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockAuthenticatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockAuthenticatorHash();

  @$internal
  @override
  $ProviderElement<LockAuthenticator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LockAuthenticator create(Ref ref) {
    return lockAuthenticator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LockAuthenticator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LockAuthenticator>(value),
    );
  }
}

String _$lockAuthenticatorHash() => r'e6a72ca4241831e074d320310986bac7992e25c5';
