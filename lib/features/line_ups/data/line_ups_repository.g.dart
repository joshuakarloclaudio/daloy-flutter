// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_ups_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lineUpsService)
final lineUpsServiceProvider = LineUpsServiceProvider._();

final class LineUpsServiceProvider
    extends $FunctionalProvider<LineUpsService, LineUpsService, LineUpsService>
    with $Provider<LineUpsService> {
  LineUpsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineUpsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineUpsServiceHash();

  @$internal
  @override
  $ProviderElement<LineUpsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LineUpsService create(Ref ref) {
    return lineUpsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineUpsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineUpsService>(value),
    );
  }
}

String _$lineUpsServiceHash() => r'ce80faf506db8dfb737f423da557b4ce2846b5cd';

@ProviderFor(lineUpsRepository)
final lineUpsRepositoryProvider = LineUpsRepositoryProvider._();

final class LineUpsRepositoryProvider
    extends
        $FunctionalProvider<
          LineUpsRepository,
          LineUpsRepository,
          LineUpsRepository
        >
    with $Provider<LineUpsRepository> {
  LineUpsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineUpsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineUpsRepositoryHash();

  @$internal
  @override
  $ProviderElement<LineUpsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LineUpsRepository create(Ref ref) {
    return lineUpsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineUpsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineUpsRepository>(value),
    );
  }
}

String _$lineUpsRepositoryHash() => r'e649e1b3c255dc21a16e8010fc3ad03fcc7334a8';

/// Every cached line-up in the active workspace, newest id first.

@ProviderFor(workspaceLineUps)
final workspaceLineUpsProvider = WorkspaceLineUpsProvider._();

/// Every cached line-up in the active workspace, newest id first.

final class WorkspaceLineUpsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LineUp>>,
          List<LineUp>,
          Stream<List<LineUp>>
        >
    with $FutureModifier<List<LineUp>>, $StreamProvider<List<LineUp>> {
  /// Every cached line-up in the active workspace, newest id first.
  WorkspaceLineUpsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workspaceLineUpsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workspaceLineUpsHash();

  @$internal
  @override
  $StreamProviderElement<List<LineUp>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LineUp>> create(Ref ref) {
    return workspaceLineUps(ref);
  }
}

String _$workspaceLineUpsHash() => r'13b688d983e6cec3a112a78f42f4d8afa9b71358';

/// Pending line-ups (by id) and the server's last complaint about each.

@ProviderFor(lineUpOutbox)
final lineUpOutboxProvider = LineUpOutboxProvider._();

/// Pending line-ups (by id) and the server's last complaint about each.

final class LineUpOutboxProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, String?>>,
          Map<int, String?>,
          Stream<Map<int, String?>>
        >
    with
        $FutureModifier<Map<int, String?>>,
        $StreamProvider<Map<int, String?>> {
  /// Pending line-ups (by id) and the server's last complaint about each.
  LineUpOutboxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineUpOutboxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineUpOutboxHash();

  @$internal
  @override
  $StreamProviderElement<Map<int, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, String?>> create(Ref ref) {
    return lineUpOutbox(ref);
  }
}

String _$lineUpOutboxHash() => r'43416de22d206f576a43f511816c192e04049e88';

@ProviderFor(worshipLeaders)
final worshipLeadersProvider = WorshipLeadersProvider._();

final class WorshipLeadersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  WorshipLeadersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'worshipLeadersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$worshipLeadersHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return worshipLeaders(ref);
  }
}

String _$worshipLeadersHash() => r'bb96fa334c06f7fc78b1c755deb25766b0306d1d';

/// The running performance. Network-only on purpose: a stale "Live now" is
/// worse than none.
///
/// Realtime first: Reverb pushes `session.active` / `session.ended` on the
/// workspace channel, so it flips in about a second. REST stays the source of
/// truth for the initial value and after every reconnect, and a slow poll
/// covers the socket being down.

@ProviderFor(ActiveLiveSession)
final activeLiveSessionProvider = ActiveLiveSessionProvider._();

/// The running performance. Network-only on purpose: a stale "Live now" is
/// worse than none.
///
/// Realtime first: Reverb pushes `session.active` / `session.ended` on the
/// workspace channel, so it flips in about a second. REST stays the source of
/// truth for the initial value and after every reconnect, and a slow poll
/// covers the socket being down.
final class ActiveLiveSessionProvider
    extends $AsyncNotifierProvider<ActiveLiveSession, LiveSession?> {
  /// The running performance. Network-only on purpose: a stale "Live now" is
  /// worse than none.
  ///
  /// Realtime first: Reverb pushes `session.active` / `session.ended` on the
  /// workspace channel, so it flips in about a second. REST stays the source of
  /// truth for the initial value and after every reconnect, and a slow poll
  /// covers the socket being down.
  ActiveLiveSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeLiveSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeLiveSessionHash();

  @$internal
  @override
  ActiveLiveSession create() => ActiveLiveSession();
}

String _$activeLiveSessionHash() => r'3ab1f8a62f5d2a57de0c7c7d57ed9a0a36df9365';

/// The running performance. Network-only on purpose: a stale "Live now" is
/// worse than none.
///
/// Realtime first: Reverb pushes `session.active` / `session.ended` on the
/// workspace channel, so it flips in about a second. REST stays the source of
/// truth for the initial value and after every reconnect, and a slow poll
/// covers the socket being down.

abstract class _$ActiveLiveSession extends $AsyncNotifier<LiveSession?> {
  FutureOr<LiveSession?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LiveSession?>, LiveSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LiveSession?>, LiveSession?>,
              AsyncValue<LiveSession?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
