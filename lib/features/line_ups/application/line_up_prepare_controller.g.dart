// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_up_prepare_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lineUpPrepOutbox)
final lineUpPrepOutboxProvider = LineUpPrepOutboxFamily._();

final class LineUpPrepOutboxProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, String?>>,
          Map<int, String?>,
          Stream<Map<int, String?>>
        >
    with
        $FutureModifier<Map<int, String?>>,
        $StreamProvider<Map<int, String?>> {
  LineUpPrepOutboxProvider._({
    required LineUpPrepOutboxFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineUpPrepOutboxProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineUpPrepOutboxHash();

  @override
  String toString() {
    return r'lineUpPrepOutboxProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<int, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<int, String?>> create(Ref ref) {
    final argument = this.argument as int;
    return lineUpPrepOutbox(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LineUpPrepOutboxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineUpPrepOutboxHash() => r'f40de0ba59c861ea3733db5516ee91a6ec425056';

final class LineUpPrepOutboxFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<int, String?>>, int> {
  LineUpPrepOutboxFamily._()
    : super(
        retry: null,
        name: r'lineUpPrepOutboxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LineUpPrepOutboxProvider call(int lineUpId) =>
      LineUpPrepOutboxProvider._(argument: lineUpId, from: this);

  @override
  String toString() => r'lineUpPrepOutboxProvider';
}

/// The Prepare screen: the team's notes and each song's section order for
/// this line-up. Every change lands on the device at once and is queued for
/// the server — no Save step, and it works offline.

@ProviderFor(LineUpPrepareController)
final lineUpPrepareControllerProvider = LineUpPrepareControllerFamily._();

/// The Prepare screen: the team's notes and each song's section order for
/// this line-up. Every change lands on the device at once and is queued for
/// the server — no Save step, and it works offline.
final class LineUpPrepareControllerProvider
    extends $NotifierProvider<LineUpPrepareController, LineUpPrepareState> {
  /// The Prepare screen: the team's notes and each song's section order for
  /// this line-up. Every change lands on the device at once and is queued for
  /// the server — no Save step, and it works offline.
  LineUpPrepareControllerProvider._({
    required LineUpPrepareControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineUpPrepareControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineUpPrepareControllerHash();

  @override
  String toString() {
    return r'lineUpPrepareControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LineUpPrepareController create() => LineUpPrepareController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LineUpPrepareState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LineUpPrepareState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LineUpPrepareControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineUpPrepareControllerHash() =>
    r'a1da8ebb7c9b980baf420cafd1a498e3eb4a29ec';

/// The Prepare screen: the team's notes and each song's section order for
/// this line-up. Every change lands on the device at once and is queued for
/// the server — no Save step, and it works offline.

final class LineUpPrepareControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          LineUpPrepareController,
          LineUpPrepareState,
          LineUpPrepareState,
          LineUpPrepareState,
          int
        > {
  LineUpPrepareControllerFamily._()
    : super(
        retry: null,
        name: r'lineUpPrepareControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The Prepare screen: the team's notes and each song's section order for
  /// this line-up. Every change lands on the device at once and is queued for
  /// the server — no Save step, and it works offline.

  LineUpPrepareControllerProvider call(int lineUpId) =>
      LineUpPrepareControllerProvider._(argument: lineUpId, from: this);

  @override
  String toString() => r'lineUpPrepareControllerProvider';
}

/// The Prepare screen: the team's notes and each song's section order for
/// this line-up. Every change lands on the device at once and is queued for
/// the server — no Save step, and it works offline.

abstract class _$LineUpPrepareController extends $Notifier<LineUpPrepareState> {
  late final _$args = ref.$arg as int;
  int get lineUpId => _$args;

  LineUpPrepareState build(int lineUpId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LineUpPrepareState, LineUpPrepareState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LineUpPrepareState, LineUpPrepareState>,
              LineUpPrepareState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
