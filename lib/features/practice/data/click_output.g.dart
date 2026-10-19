// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'click_output.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A fresh output per Practice screen; tests override it with a silent one.

@ProviderFor(clickOutput)
final clickOutputProvider = ClickOutputProvider._();

/// A fresh output per Practice screen; tests override it with a silent one.

final class ClickOutputProvider
    extends $FunctionalProvider<ClickOutput, ClickOutput, ClickOutput>
    with $Provider<ClickOutput> {
  /// A fresh output per Practice screen; tests override it with a silent one.
  ClickOutputProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clickOutputProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clickOutputHash();

  @$internal
  @override
  $ProviderElement<ClickOutput> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClickOutput create(Ref ref) {
    return clickOutput(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClickOutput value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClickOutput>(value),
    );
  }
}

String _$clickOutputHash() => r'd0ca49ec7b63a6a17c6edb7f29c59467d2e5a077';
