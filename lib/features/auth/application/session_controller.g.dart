// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Who is signed in, and into which workspace. The router redirects on it,
/// and the HTTP layer reads the same credentials from [SessionStore].
///
/// Offline-first: a stored session is trusted immediately, then the user is
/// refreshed from `/api/auth/me` in the background when reachable.

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

/// Who is signed in, and into which workspace. The router redirects on it,
/// and the HTTP layer reads the same credentials from [SessionStore].
///
/// Offline-first: a stored session is trusted immediately, then the user is
/// refreshed from `/api/auth/me` in the background when reachable.
final class SessionControllerProvider
    extends $AsyncNotifierProvider<SessionController, AuthSession?> {
  /// Who is signed in, and into which workspace. The router redirects on it,
  /// and the HTTP layer reads the same credentials from [SessionStore].
  ///
  /// Offline-first: a stored session is trusted immediately, then the user is
  /// refreshed from `/api/auth/me` in the background when reachable.
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();
}

String _$sessionControllerHash() => r'5e98ee71006deb62b488201d3ef0e811777de58d';

/// Who is signed in, and into which workspace. The router redirects on it,
/// and the HTTP layer reads the same credentials from [SessionStore].
///
/// Offline-first: a stored session is trusted immediately, then the user is
/// refreshed from `/api/auth/me` in the background when reachable.

abstract class _$SessionController extends $AsyncNotifier<AuthSession?> {
  FutureOr<AuthSession?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthSession?>, AuthSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthSession?>, AuthSession?>,
              AsyncValue<AuthSession?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(activeWorkspaceId)
final activeWorkspaceIdProvider = ActiveWorkspaceIdProvider._();

final class ActiveWorkspaceIdProvider
    extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  ActiveWorkspaceIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeWorkspaceIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeWorkspaceIdHash();

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return activeWorkspaceId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$activeWorkspaceIdHash() => r'35f5ec8834a8417c1c25edad7d6220d128f87ee0';
