// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perform_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where you are in the set — kept apart from [PerformController], which
/// rebuilds on every Drift write and would otherwise lose it.

@ProviderFor(PerformCursor)
final performCursorProvider = PerformCursorFamily._();

/// Where you are in the set — kept apart from [PerformController], which
/// rebuilds on every Drift write and would otherwise lose it.
final class PerformCursorProvider
    extends
        $NotifierProvider<PerformCursor, ({String? sectionId, int songIndex})> {
  /// Where you are in the set — kept apart from [PerformController], which
  /// rebuilds on every Drift write and would otherwise lose it.
  PerformCursorProvider._({
    required PerformCursorFamily super.from,
    required PerformSource super.argument,
  }) : super(
         retry: null,
         name: r'performCursorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$performCursorHash();

  @override
  String toString() {
    return r'performCursorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PerformCursor create() => PerformCursor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(({String? sectionId, int songIndex}) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<({String? sectionId, int songIndex})>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PerformCursorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$performCursorHash() => r'71b1063443d4259e3c5aefce99e074ae1b29021d';

/// Where you are in the set — kept apart from [PerformController], which
/// rebuilds on every Drift write and would otherwise lose it.

final class PerformCursorFamily extends $Family
    with
        $ClassFamilyOverride<
          PerformCursor,
          ({String? sectionId, int songIndex}),
          ({String? sectionId, int songIndex}),
          ({String? sectionId, int songIndex}),
          PerformSource
        > {
  PerformCursorFamily._()
    : super(
        retry: null,
        name: r'performCursorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Where you are in the set — kept apart from [PerformController], which
  /// rebuilds on every Drift write and would otherwise lose it.

  PerformCursorProvider call(PerformSource source) =>
      PerformCursorProvider._(argument: source, from: this);

  @override
  String toString() => r'performCursorProvider';
}

/// Where you are in the set — kept apart from [PerformController], which
/// rebuilds on every Drift write and would otherwise lose it.

abstract class _$PerformCursor
    extends $Notifier<({String? sectionId, int songIndex})> {
  late final _$args = ref.$arg as PerformSource;
  PerformSource get source => _$args;

  ({String? sectionId, int songIndex}) build(PerformSource source);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              ({String? sectionId, int songIndex}),
              ({String? sectionId, int songIndex})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ({String? sectionId, int songIndex}),
                ({String? sectionId, int songIndex})
              >,
              ({String? sectionId, int songIndex}),
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// All of Perform's state and actions — the twin of
/// `use-performance-mode-page.ts` for a solo performance. Builds on the
/// line-up detail controller, so keys, capos and display prefs are the same
/// rows the line-up page edits, read from Drift and usable offline.

@ProviderFor(PerformController)
final performControllerProvider = PerformControllerFamily._();

/// All of Perform's state and actions — the twin of
/// `use-performance-mode-page.ts` for a solo performance. Builds on the
/// line-up detail controller, so keys, capos and display prefs are the same
/// rows the line-up page edits, read from Drift and usable offline.
final class PerformControllerProvider
    extends $NotifierProvider<PerformController, PerformState> {
  /// All of Perform's state and actions — the twin of
  /// `use-performance-mode-page.ts` for a solo performance. Builds on the
  /// line-up detail controller, so keys, capos and display prefs are the same
  /// rows the line-up page edits, read from Drift and usable offline.
  PerformControllerProvider._({
    required PerformControllerFamily super.from,
    required PerformSource super.argument,
  }) : super(
         retry: null,
         name: r'performControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$performControllerHash();

  @override
  String toString() {
    return r'performControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PerformController create() => PerformController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PerformState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PerformState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PerformControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$performControllerHash() => r'705f20bbba5f3a4e6818ecd02f3adeabb0184bcf';

/// All of Perform's state and actions — the twin of
/// `use-performance-mode-page.ts` for a solo performance. Builds on the
/// line-up detail controller, so keys, capos and display prefs are the same
/// rows the line-up page edits, read from Drift and usable offline.

final class PerformControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PerformController,
          PerformState,
          PerformState,
          PerformState,
          PerformSource
        > {
  PerformControllerFamily._()
    : super(
        retry: null,
        name: r'performControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// All of Perform's state and actions — the twin of
  /// `use-performance-mode-page.ts` for a solo performance. Builds on the
  /// line-up detail controller, so keys, capos and display prefs are the same
  /// rows the line-up page edits, read from Drift and usable offline.

  PerformControllerProvider call(PerformSource source) =>
      PerformControllerProvider._(argument: source, from: this);

  @override
  String toString() => r'performControllerProvider';
}

/// All of Perform's state and actions — the twin of
/// `use-performance-mode-page.ts` for a solo performance. Builds on the
/// line-up detail controller, so keys, capos and display prefs are the same
/// rows the line-up page edits, read from Drift and usable offline.

abstract class _$PerformController extends $Notifier<PerformState> {
  late final _$args = ref.$arg as PerformSource;
  PerformSource get source => _$args;

  PerformState build(PerformSource source);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PerformState, PerformState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PerformState, PerformState>,
              PerformState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
