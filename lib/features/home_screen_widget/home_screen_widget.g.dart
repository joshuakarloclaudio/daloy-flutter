// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_widget.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the home-screen widget in step with the active workspace's coming
/// line-ups: re-sent a couple of seconds after the rows settle, and only
/// when what it would show changed. Lives under the app shell, beside the
/// OS search sync; signing out clears it (`SessionController`).

@ProviderFor(HomeWidgetSync)
final homeWidgetSyncProvider = HomeWidgetSyncProvider._();

/// Keeps the home-screen widget in step with the active workspace's coming
/// line-ups: re-sent a couple of seconds after the rows settle, and only
/// when what it would show changed. Lives under the app shell, beside the
/// OS search sync; signing out clears it (`SessionController`).
final class HomeWidgetSyncProvider
    extends $NotifierProvider<HomeWidgetSync, void> {
  /// Keeps the home-screen widget in step with the active workspace's coming
  /// line-ups: re-sent a couple of seconds after the rows settle, and only
  /// when what it would show changed. Lives under the app shell, beside the
  /// OS search sync; signing out clears it (`SessionController`).
  HomeWidgetSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeWidgetSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeWidgetSyncHash();

  @$internal
  @override
  HomeWidgetSync create() => HomeWidgetSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$homeWidgetSyncHash() => r'3cc9e772706df2ad83003a052091880bc439edfd';

/// Keeps the home-screen widget in step with the active workspace's coming
/// line-ups: re-sent a couple of seconds after the rows settle, and only
/// when what it would show changed. Lives under the app shell, beside the
/// OS search sync; signing out clears it (`SessionController`).

abstract class _$HomeWidgetSync extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Android launchers that can pin a widget from inside the app ("Add to
/// home screen" on You). iOS has no such API.

@ProviderFor(canPinHomeWidget)
final canPinHomeWidgetProvider = CanPinHomeWidgetProvider._();

/// Android launchers that can pin a widget from inside the app ("Add to
/// home screen" on You). iOS has no such API.

final class CanPinHomeWidgetProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Android launchers that can pin a widget from inside the app ("Add to
  /// home screen" on You). iOS has no such API.
  CanPinHomeWidgetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canPinHomeWidgetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canPinHomeWidgetHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return canPinHomeWidget(ref);
  }
}

String _$canPinHomeWidgetHash() => r'626bb6eb7cfc45db21b2c197012f7aed48953adf';
