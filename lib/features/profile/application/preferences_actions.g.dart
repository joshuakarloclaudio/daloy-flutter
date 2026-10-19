// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Changes to what a chart opens as. Both take effect on this device at once
/// and then follow the account, so a new device starts the same way.

@ProviderFor(PreferencesActions)
final preferencesActionsProvider = PreferencesActionsProvider._();

/// Changes to what a chart opens as. Both take effect on this device at once
/// and then follow the account, so a new device starts the same way.
final class PreferencesActionsProvider
    extends $NotifierProvider<PreferencesActions, void> {
  /// Changes to what a chart opens as. Both take effect on this device at once
  /// and then follow the account, so a new device starts the same way.
  PreferencesActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferencesActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferencesActionsHash();

  @$internal
  @override
  PreferencesActions create() => PreferencesActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$preferencesActionsHash() =>
    r'e452e0d960b4462199dcfa40276fb49de2de2d0a';

/// Changes to what a chart opens as. Both take effect on this device at once
/// and then follow the account, so a new device starts the same way.

abstract class _$PreferencesActions extends $Notifier<void> {
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
