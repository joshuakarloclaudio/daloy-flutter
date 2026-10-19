// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_line_up_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The new-line-up sheet's save. Written to Drift first, so it is in the
/// list (and editable) the moment the sheet closes, online or not; the push
/// to the server happens behind it and again on reconnect.

@ProviderFor(CreateLineUp)
final createLineUpProvider = CreateLineUpProvider._();

/// The new-line-up sheet's save. Written to Drift first, so it is in the
/// list (and editable) the moment the sheet closes, online or not; the push
/// to the server happens behind it and again on reconnect.
final class CreateLineUpProvider extends $NotifierProvider<CreateLineUp, void> {
  /// The new-line-up sheet's save. Written to Drift first, so it is in the
  /// list (and editable) the moment the sheet closes, online or not; the push
  /// to the server happens behind it and again on reconnect.
  CreateLineUpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createLineUpProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createLineUpHash();

  @$internal
  @override
  CreateLineUp create() => CreateLineUp();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createLineUpHash() => r'93b247dd012d2a5a3dda3c4c5addc151eb4a362e';

/// The new-line-up sheet's save. Written to Drift first, so it is in the
/// list (and editable) the moment the sheet closes, online or not; the push
/// to the server happens behind it and again on reconnect.

abstract class _$CreateLineUp extends $Notifier<void> {
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
