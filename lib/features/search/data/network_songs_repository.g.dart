// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_songs_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(networkSongsRepository)
final networkSongsRepositoryProvider = NetworkSongsRepositoryProvider._();

final class NetworkSongsRepositoryProvider
    extends
        $FunctionalProvider<
          NetworkSongsRepository,
          NetworkSongsRepository,
          NetworkSongsRepository
        >
    with $Provider<NetworkSongsRepository> {
  NetworkSongsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkSongsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkSongsRepositoryHash();

  @$internal
  @override
  $ProviderElement<NetworkSongsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NetworkSongsRepository create(Ref ref) {
    return networkSongsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkSongsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkSongsRepository>(value),
    );
  }
}

String _$networkSongsRepositoryHash() =>
    r'800c1fb49ae7d02482c95dfae76cc5f6b8e9c74d';

/// One network song with its chart, for the preview sheet.

@ProviderFor(networkSong)
final networkSongProvider = NetworkSongFamily._();

/// One network song with its chart, for the preview sheet.

final class NetworkSongProvider
    extends
        $FunctionalProvider<
          AsyncValue<NetworkSong>,
          NetworkSong,
          FutureOr<NetworkSong>
        >
    with $FutureModifier<NetworkSong>, $FutureProvider<NetworkSong> {
  /// One network song with its chart, for the preview sheet.
  NetworkSongProvider._({
    required NetworkSongFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'networkSongProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$networkSongHash();

  @override
  String toString() {
    return r'networkSongProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<NetworkSong> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NetworkSong> create(Ref ref) {
    final argument = this.argument as int;
    return networkSong(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NetworkSongProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$networkSongHash() => r'a470c0191cc8fc06fc27a5e16e1b2b16e50dcc5d';

/// One network song with its chart, for the preview sheet.

final class NetworkSongFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<NetworkSong>, int> {
  NetworkSongFamily._()
    : super(
        retry: null,
        name: r'networkSongProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One network song with its chart, for the preview sheet.

  NetworkSongProvider call(int id) =>
      NetworkSongProvider._(argument: id, from: this);

  @override
  String toString() => r'networkSongProvider';
}
