// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_up_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What opening a line-up does once: pull its songs and this user's capos.
/// Returns false only when the server says it doesn't exist. Watches just
/// the connection and workspace, so writing results to Drift can't re-run it.

@ProviderFor(lineUpDetailRefresh)
final lineUpDetailRefreshProvider = LineUpDetailRefreshFamily._();

/// What opening a line-up does once: pull its songs and this user's capos.
/// Returns false only when the server says it doesn't exist. Watches just
/// the connection and workspace, so writing results to Drift can't re-run it.

final class LineUpDetailRefreshProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// What opening a line-up does once: pull its songs and this user's capos.
  /// Returns false only when the server says it doesn't exist. Watches just
  /// the connection and workspace, so writing results to Drift can't re-run it.
  LineUpDetailRefreshProvider._({
    required LineUpDetailRefreshFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineUpDetailRefreshProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineUpDetailRefreshHash();

  @override
  String toString() {
    return r'lineUpDetailRefreshProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as int;
    return lineUpDetailRefresh(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LineUpDetailRefreshProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineUpDetailRefreshHash() =>
    r'460fc4d42082a26cdf83bb63c3b15a3cec758030';

/// What opening a line-up does once: pull its songs and this user's capos.
/// Returns false only when the server says it doesn't exist. Watches just
/// the connection and workspace, so writing results to Drift can't re-run it.

final class LineUpDetailRefreshFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, int> {
  LineUpDetailRefreshFamily._()
    : super(
        retry: null,
        name: r'lineUpDetailRefreshProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// What opening a line-up does once: pull its songs and this user's capos.
  /// Returns false only when the server says it doesn't exist. Watches just
  /// the connection and workspace, so writing results to Drift can't re-run it.

  LineUpDetailRefreshProvider call(int lineUpId) =>
      LineUpDetailRefreshProvider._(argument: lineUpId, from: this);

  @override
  String toString() => r'lineUpDetailRefreshProvider';
}

@ProviderFor(lineUpById)
final lineUpByIdProvider = LineUpByIdFamily._();

final class LineUpByIdProvider
    extends $FunctionalProvider<AsyncValue<LineUp?>, LineUp?, Stream<LineUp?>>
    with $FutureModifier<LineUp?>, $StreamProvider<LineUp?> {
  LineUpByIdProvider._({
    required LineUpByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineUpByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineUpByIdHash();

  @override
  String toString() {
    return r'lineUpByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<LineUp?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<LineUp?> create(Ref ref) {
    final argument = this.argument as int;
    return lineUpById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LineUpByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineUpByIdHash() => r'64379664138c19621eb5c1620a21ddf8090438d0';

final class LineUpByIdFamily extends $Family
    with $FunctionalFamilyOverride<Stream<LineUp?>, int> {
  LineUpByIdFamily._()
    : super(
        retry: null,
        name: r'lineUpByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LineUpByIdProvider call(int id) =>
      LineUpByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'lineUpByIdProvider';
}

@ProviderFor(lineUpSongsLoaded)
final lineUpSongsLoadedProvider = LineUpSongsLoadedFamily._();

final class LineUpSongsLoadedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  LineUpSongsLoadedProvider._({
    required LineUpSongsLoadedFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineUpSongsLoadedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineUpSongsLoadedHash();

  @override
  String toString() {
    return r'lineUpSongsLoadedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as int;
    return lineUpSongsLoaded(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LineUpSongsLoadedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineUpSongsLoadedHash() => r'79b210fae84548a819bb05b79dc35c8eac21a02e';

final class LineUpSongsLoadedFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, int> {
  LineUpSongsLoadedFamily._()
    : super(
        retry: null,
        name: r'lineUpSongsLoadedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LineUpSongsLoadedProvider call(int id) =>
      LineUpSongsLoadedProvider._(argument: id, from: this);

  @override
  String toString() => r'lineUpSongsLoadedProvider';
}

@ProviderFor(lineUpSetlist)
final lineUpSetlistProvider = LineUpSetlistFamily._();

final class LineUpSetlistProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SetlistEntry>>,
          List<SetlistEntry>,
          Stream<List<SetlistEntry>>
        >
    with
        $FutureModifier<List<SetlistEntry>>,
        $StreamProvider<List<SetlistEntry>> {
  LineUpSetlistProvider._({
    required LineUpSetlistFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineUpSetlistProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineUpSetlistHash();

  @override
  String toString() {
    return r'lineUpSetlistProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SetlistEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SetlistEntry>> create(Ref ref) {
    final argument = this.argument as int;
    return lineUpSetlist(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LineUpSetlistProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineUpSetlistHash() => r'23db9272a435bcc12c81f91ae56675b0b3a81814';

final class LineUpSetlistFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SetlistEntry>>, int> {
  LineUpSetlistFamily._()
    : super(
        retry: null,
        name: r'lineUpSetlistProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LineUpSetlistProvider call(int id) =>
      LineUpSetlistProvider._(argument: id, from: this);

  @override
  String toString() => r'lineUpSetlistProvider';
}

@ProviderFor(lineUpCapos)
final lineUpCaposProvider = LineUpCaposFamily._();

final class LineUpCaposProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, int>>,
          Map<int, int>,
          Stream<Map<int, int>>
        >
    with $FutureModifier<Map<int, int>>, $StreamProvider<Map<int, int>> {
  LineUpCaposProvider._({
    required LineUpCaposFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineUpCaposProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineUpCaposHash();

  @override
  String toString() {
    return r'lineUpCaposProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<int, int>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, int>> create(Ref ref) {
    final argument = this.argument as int;
    return lineUpCapos(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LineUpCaposProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineUpCaposHash() => r'a2650354c2b59da17ba9e0d6df2b2b225bdfba02';

final class LineUpCaposFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<int, int>>, int> {
  LineUpCaposFamily._()
    : super(
        retry: null,
        name: r'lineUpCaposProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LineUpCaposProvider call(int id) =>
      LineUpCaposProvider._(argument: id, from: this);

  @override
  String toString() => r'lineUpCaposProvider';
}

/// The line-up details screen — the twin of `use-line-up-detail-route.ts`.
/// Reads only from Drift, so it opens offline; key and capo changes land on
/// the device at once and reach the server when they can.

@ProviderFor(LineUpDetailController)
final lineUpDetailControllerProvider = LineUpDetailControllerFamily._();

/// The line-up details screen — the twin of `use-line-up-detail-route.ts`.
/// Reads only from Drift, so it opens offline; key and capo changes land on
/// the device at once and reach the server when they can.
final class LineUpDetailControllerProvider
    extends $NotifierProvider<LineUpDetailController, LineUpDetailState> {
  /// The line-up details screen — the twin of `use-line-up-detail-route.ts`.
  /// Reads only from Drift, so it opens offline; key and capo changes land on
  /// the device at once and reach the server when they can.
  LineUpDetailControllerProvider._({
    required LineUpDetailControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineUpDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineUpDetailControllerHash();

  @override
  String toString() {
    return r'lineUpDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LineUpDetailController create() => LineUpDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineUpDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineUpDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LineUpDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineUpDetailControllerHash() =>
    r'be897c94abff8b415dcdec83b512712ffd93b44d';

/// The line-up details screen — the twin of `use-line-up-detail-route.ts`.
/// Reads only from Drift, so it opens offline; key and capo changes land on
/// the device at once and reach the server when they can.

final class LineUpDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          LineUpDetailController,
          LineUpDetailState,
          LineUpDetailState,
          LineUpDetailState,
          int
        > {
  LineUpDetailControllerFamily._()
    : super(
        retry: null,
        name: r'lineUpDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The line-up details screen — the twin of `use-line-up-detail-route.ts`.
  /// Reads only from Drift, so it opens offline; key and capo changes land on
  /// the device at once and reach the server when they can.

  LineUpDetailControllerProvider call(int lineUpId) =>
      LineUpDetailControllerProvider._(argument: lineUpId, from: this);

  @override
  String toString() => r'lineUpDetailControllerProvider';
}

/// The line-up details screen — the twin of `use-line-up-detail-route.ts`.
/// Reads only from Drift, so it opens offline; key and capo changes land on
/// the device at once and reach the server when they can.

abstract class _$LineUpDetailController extends $Notifier<LineUpDetailState> {
  late final _$args = ref.$arg as int;
  int get lineUpId => _$args;

  LineUpDetailState build(int lineUpId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LineUpDetailState, LineUpDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LineUpDetailState, LineUpDetailState>,
              LineUpDetailState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Deletes that can still be undone. Kept alive: the window outlasts the
/// screen the delete started on.

@ProviderFor(LineUpDeletions)
final lineUpDeletionsProvider = LineUpDeletionsProvider._();

/// Deletes that can still be undone. Kept alive: the window outlasts the
/// screen the delete started on.
final class LineUpDeletionsProvider
    extends $NotifierProvider<LineUpDeletions, void> {
  /// Deletes that can still be undone. Kept alive: the window outlasts the
  /// screen the delete started on.
  LineUpDeletionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lineUpDeletionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lineUpDeletionsHash();

  @$internal
  @override
  LineUpDeletions create() => LineUpDeletions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$lineUpDeletionsHash() => r'292039b70f3841d5f16c7aa6c4b071fdbbcce561';

/// Deletes that can still be undone. Kept alive: the window outlasts the
/// screen the delete started on.

abstract class _$LineUpDeletions extends $Notifier<void> {
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
