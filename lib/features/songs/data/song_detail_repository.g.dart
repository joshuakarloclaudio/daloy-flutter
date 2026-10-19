// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_detail_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(songDetailRepository)
final songDetailRepositoryProvider = SongDetailRepositoryProvider._();

final class SongDetailRepositoryProvider
    extends
        $FunctionalProvider<
          SongDetailRepository,
          SongDetailRepository,
          SongDetailRepository
        >
    with $Provider<SongDetailRepository> {
  SongDetailRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songDetailRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songDetailRepositoryHash();

  @$internal
  @override
  $ProviderElement<SongDetailRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SongDetailRepository create(Ref ref) {
    return songDetailRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongDetailRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongDetailRepository>(value),
    );
  }
}

String _$songDetailRepositoryHash() =>
    r'83a898d1d3c88f2fd0c4384431e6282ca7b981eb';

@ProviderFor(songById)
final songByIdProvider = SongByIdFamily._();

final class SongByIdProvider
    extends $FunctionalProvider<AsyncValue<Song?>, Song?, Stream<Song?>>
    with $FutureModifier<Song?>, $StreamProvider<Song?> {
  SongByIdProvider._({
    required SongByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'songByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songByIdHash();

  @override
  String toString() {
    return r'songByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Song?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Song?> create(Ref ref) {
    final argument = this.argument as int;
    return songById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SongByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songByIdHash() => r'0f41b7a24e65aa71e00e9258a1835d56acb89215';

final class SongByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Song?>, int> {
  SongByIdFamily._()
    : super(
        retry: null,
        name: r'songByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SongByIdProvider call(int id) => SongByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'songByIdProvider';
}

@ProviderFor(songCapo)
final songCapoProvider = SongCapoFamily._();

final class SongCapoProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  SongCapoProvider._({
    required SongCapoFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'songCapoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songCapoHash();

  @override
  String toString() {
    return r'songCapoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as int;
    return songCapo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SongCapoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songCapoHash() => r'd45ed44ab8bc776fc13d27b55d17ea66582b8061';

final class SongCapoFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, int> {
  SongCapoFamily._()
    : super(
        retry: null,
        name: r'songCapoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SongCapoProvider call(int songId) =>
      SongCapoProvider._(argument: songId, from: this);

  @override
  String toString() => r'songCapoProvider';
}

@ProviderFor(songUpcomingLineUps)
final songUpcomingLineUpsProvider = SongUpcomingLineUpsFamily._();

final class SongUpcomingLineUpsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LineUp>>,
          List<LineUp>,
          Stream<List<LineUp>>
        >
    with $FutureModifier<List<LineUp>>, $StreamProvider<List<LineUp>> {
  SongUpcomingLineUpsProvider._({
    required SongUpcomingLineUpsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'songUpcomingLineUpsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songUpcomingLineUpsHash();

  @override
  String toString() {
    return r'songUpcomingLineUpsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<LineUp>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<LineUp>> create(Ref ref) {
    final argument = this.argument as int;
    return songUpcomingLineUps(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SongUpcomingLineUpsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songUpcomingLineUpsHash() =>
    r'b1b7b6ad55697bcd68c79e767e2a86bd3875b71e';

final class SongUpcomingLineUpsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<LineUp>>, int> {
  SongUpcomingLineUpsFamily._()
    : super(
        retry: null,
        name: r'songUpcomingLineUpsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SongUpcomingLineUpsProvider call(int songId) =>
      SongUpcomingLineUpsProvider._(argument: songId, from: this);

  @override
  String toString() => r'songUpcomingLineUpsProvider';
}

@ProviderFor(chartPrefs)
final chartPrefsProvider = ChartPrefsProvider._();

final class ChartPrefsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChartPrefs>,
          ChartPrefs,
          Stream<ChartPrefs>
        >
    with $FutureModifier<ChartPrefs>, $StreamProvider<ChartPrefs> {
  ChartPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chartPrefsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chartPrefsHash();

  @$internal
  @override
  $StreamProviderElement<ChartPrefs> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<ChartPrefs> create(Ref ref) {
    return chartPrefs(ref);
  }
}

String _$chartPrefsHash() => r'0db084757707441d754e8019219a929ddfad2738';

@ProviderFor(pendingSongEdits)
final pendingSongEditsProvider = PendingSongEditsProvider._();

final class PendingSongEditsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, String?>>,
          Map<int, String?>,
          Stream<Map<int, String?>>
        >
    with
        $FutureModifier<Map<int, String?>>,
        $StreamProvider<Map<int, String?>> {
  PendingSongEditsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingSongEditsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingSongEditsHash();

  @$internal
  @override
  $StreamProviderElement<Map<int, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, String?>> create(Ref ref) {
    return pendingSongEdits(ref);
  }
}

String _$pendingSongEditsHash() => r'ac1767abece0679e8a0ca8b9622be1c240afbd6c';

/// Fields of this song the server refused (changed elsewhere first): theirs.

@ProviderFor(songConflicts)
final songConflictsProvider = SongConflictsFamily._();

/// Fields of this song the server refused (changed elsewhere first): theirs.

final class SongConflictsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<SongField, Object?>>,
          Map<SongField, Object?>,
          Stream<Map<SongField, Object?>>
        >
    with
        $FutureModifier<Map<SongField, Object?>>,
        $StreamProvider<Map<SongField, Object?>> {
  /// Fields of this song the server refused (changed elsewhere first): theirs.
  SongConflictsProvider._({
    required SongConflictsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'songConflictsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songConflictsHash();

  @override
  String toString() {
    return r'songConflictsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<SongField, Object?>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<SongField, Object?>> create(Ref ref) {
    final argument = this.argument as int;
    return songConflicts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SongConflictsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songConflictsHash() => r'994eefb501488dc5b3b898785bb565d6d12e7cf2';

/// Fields of this song the server refused (changed elsewhere first): theirs.

final class SongConflictsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<SongField, Object?>>, int> {
  SongConflictsFamily._()
    : super(
        retry: null,
        name: r'songConflictsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Fields of this song the server refused (changed elsewhere first): theirs.

  SongConflictsProvider call(int songId) =>
      SongConflictsProvider._(argument: songId, from: this);

  @override
  String toString() => r'songConflictsProvider';
}
