// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_up_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Everything the edit screen does. Opens from Drift (after a quick refresh
/// when online), edits a draft in memory, and saves through the outbox, so
/// it works offline. Nothing reaches Drift until Save.

@ProviderFor(LineUpEdit)
final lineUpEditProvider = LineUpEditFamily._();

/// Everything the edit screen does. Opens from Drift (after a quick refresh
/// when online), edits a draft in memory, and saves through the outbox, so
/// it works offline. Nothing reaches Drift until Save.
final class LineUpEditProvider
    extends $AsyncNotifierProvider<LineUpEdit, LineUpEditState> {
  /// Everything the edit screen does. Opens from Drift (after a quick refresh
  /// when online), edits a draft in memory, and saves through the outbox, so
  /// it works offline. Nothing reaches Drift until Save.
  LineUpEditProvider._({
    required LineUpEditFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lineUpEditProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lineUpEditHash();

  @override
  String toString() {
    return r'lineUpEditProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LineUpEdit create() => LineUpEdit();

  @override
  bool operator ==(Object other) {
    return other is LineUpEditProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lineUpEditHash() => r'890826cfe2669ecf51cb79724a8b61ef52440bc0';

/// Everything the edit screen does. Opens from Drift (after a quick refresh
/// when online), edits a draft in memory, and saves through the outbox, so
/// it works offline. Nothing reaches Drift until Save.

final class LineUpEditFamily extends $Family
    with
        $ClassFamilyOverride<
          LineUpEdit,
          AsyncValue<LineUpEditState>,
          LineUpEditState,
          FutureOr<LineUpEditState>,
          int
        > {
  LineUpEditFamily._()
    : super(
        retry: null,
        name: r'lineUpEditProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Everything the edit screen does. Opens from Drift (after a quick refresh
  /// when online), edits a draft in memory, and saves through the outbox, so
  /// it works offline. Nothing reaches Drift until Save.

  LineUpEditProvider call(int lineUpId) =>
      LineUpEditProvider._(argument: lineUpId, from: this);

  @override
  String toString() => r'lineUpEditProvider';
}

/// Everything the edit screen does. Opens from Drift (after a quick refresh
/// when online), edits a draft in memory, and saves through the outbox, so
/// it works offline. Nothing reaches Drift until Save.

abstract class _$LineUpEdit extends $AsyncNotifier<LineUpEditState> {
  late final _$args = ref.$arg as int;
  int get lineUpId => _$args;

  FutureOr<LineUpEditState> build(int lineUpId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<LineUpEditState>, LineUpEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LineUpEditState>, LineUpEditState>,
              AsyncValue<LineUpEditState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
