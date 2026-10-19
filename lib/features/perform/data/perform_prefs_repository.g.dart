// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perform_prefs_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(performPrefsRepository)
final performPrefsRepositoryProvider = PerformPrefsRepositoryProvider._();

final class PerformPrefsRepositoryProvider
    extends
        $FunctionalProvider<
          PerformPrefsRepository,
          PerformPrefsRepository,
          PerformPrefsRepository
        >
    with $Provider<PerformPrefsRepository> {
  PerformPrefsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performPrefsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performPrefsRepositoryHash();

  @$internal
  @override
  $ProviderElement<PerformPrefsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PerformPrefsRepository create(Ref ref) {
    return performPrefsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PerformPrefsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PerformPrefsRepository>(value),
    );
  }
}

String _$performPrefsRepositoryHash() =>
    r'40f7592ca69e23a198ce48704404bd94046d3d3c';

@ProviderFor(performPrefs)
final performPrefsProvider = PerformPrefsProvider._();

final class PerformPrefsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PerformPrefs>,
          PerformPrefs,
          Stream<PerformPrefs>
        >
    with $FutureModifier<PerformPrefs>, $StreamProvider<PerformPrefs> {
  PerformPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'performPrefsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$performPrefsHash();

  @$internal
  @override
  $StreamProviderElement<PerformPrefs> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PerformPrefs> create(Ref ref) {
    return performPrefs(ref);
  }
}

String _$performPrefsHash() => r'afbd419afaabb7de09e613cbac55c3931a25230a';
