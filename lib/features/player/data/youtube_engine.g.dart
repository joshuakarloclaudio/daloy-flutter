// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'youtube_engine.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Makes the one YouTube player; tests swap in a fake.

@ProviderFor(youtubeEngineFactory)
final youtubeEngineFactoryProvider = YoutubeEngineFactoryProvider._();

/// Makes the one YouTube player; tests swap in a fake.

final class YoutubeEngineFactoryProvider
    extends
        $FunctionalProvider<
          YouTubeEngine Function(),
          YouTubeEngine Function(),
          YouTubeEngine Function()
        >
    with $Provider<YouTubeEngine Function()> {
  /// Makes the one YouTube player; tests swap in a fake.
  YoutubeEngineFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'youtubeEngineFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$youtubeEngineFactoryHash();

  @$internal
  @override
  $ProviderElement<YouTubeEngine Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  YouTubeEngine Function() create(Ref ref) {
    return youtubeEngineFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(YouTubeEngine Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<YouTubeEngine Function()>(value),
    );
  }
}

String _$youtubeEngineFactoryHash() =>
    r'168a41e72ed9bf92e2af2c7144eb88f03d334edb';
