// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_song_to_line_up.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lineUpsWithSong)
final lineUpsWithSongProvider = LineUpsWithSongFamily._();

final class LineUpsWithSongProvider
    extends
        $FunctionalProvider<AsyncValue<Set<int>>, Set<int>, Stream<Set<int>>>
    with $FutureModifier<Set<int>>, $StreamProvider<Set<int>> {
  LineUpsWithSongProvider._({
    required LineUpsWithSongFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineUpsWithSongProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineUpsWithSongHash();

  @override
  String toString() {
    return r'lineUpsWithSongProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Set<int>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Set<int>> create(Ref ref) {
    final argument = this.argument as int;
    return lineUpsWithSong(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LineUpsWithSongProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineUpsWithSongHash() => r'702e3cb4e9b39e76aec904452c5e643d1ad3ae17';

final class LineUpsWithSongFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Set<int>>, int> {
  LineUpsWithSongFamily._()
    : super(
        retry: null,
        name: r'lineUpsWithSongProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LineUpsWithSongProvider call(int songId) =>
      LineUpsWithSongProvider._(argument: songId, from: this);

  @override
  String toString() => r'lineUpsWithSongProvider';
}

/// Kept alive: an add outlives the sheet it started from.

@ProviderFor(songLineUpAdder)
final songLineUpAdderProvider = SongLineUpAdderProvider._();

/// Kept alive: an add outlives the sheet it started from.

final class SongLineUpAdderProvider
    extends
        $FunctionalProvider<SongLineUpAdder, SongLineUpAdder, SongLineUpAdder>
    with $Provider<SongLineUpAdder> {
  /// Kept alive: an add outlives the sheet it started from.
  SongLineUpAdderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songLineUpAdderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songLineUpAdderHash();

  @$internal
  @override
  $ProviderElement<SongLineUpAdder> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SongLineUpAdder create(Ref ref) {
    return songLineUpAdder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongLineUpAdder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongLineUpAdder>(value),
    );
  }
}

String _$songLineUpAdderHash() => r'2c13ace5e7c783380e7db1776dfd2662405a2784';
