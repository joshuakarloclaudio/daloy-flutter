// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Everything the song edit screen does. Edits a draft in memory and saves
/// through the song outbox, so it works offline; nothing reaches Drift until
/// Save. Last write wins.

@ProviderFor(SongEdit)
final songEditProvider = SongEditFamily._();

/// Everything the song edit screen does. Edits a draft in memory and saves
/// through the song outbox, so it works offline; nothing reaches Drift until
/// Save. Last write wins.
final class SongEditProvider
    extends $AsyncNotifierProvider<SongEdit, SongEditState> {
  /// Everything the song edit screen does. Edits a draft in memory and saves
  /// through the song outbox, so it works offline; nothing reaches Drift until
  /// Save. Last write wins.
  SongEditProvider._({
    required SongEditFamily super.from,
    required int super.argument,
  }) : super(
         retry: _retry,
         name: r'songEditProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songEditHash();

  @override
  String toString() {
    return r'songEditProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SongEdit create() => SongEdit();

  @override
  bool operator ==(Object other) {
    return other is SongEditProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songEditHash() => r'9bfe0eef7e708e49b31708c4eecd165d9c051024';

/// Everything the song edit screen does. Edits a draft in memory and saves
/// through the song outbox, so it works offline; nothing reaches Drift until
/// Save. Last write wins.

final class SongEditFamily extends $Family
    with
        $ClassFamilyOverride<
          SongEdit,
          AsyncValue<SongEditState>,
          SongEditState,
          FutureOr<SongEditState>,
          int
        > {
  SongEditFamily._()
    : super(
        retry: _retry,
        name: r'songEditProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Everything the song edit screen does. Edits a draft in memory and saves
  /// through the song outbox, so it works offline; nothing reaches Drift until
  /// Save. Last write wins.

  SongEditProvider call(int songId) =>
      SongEditProvider._(argument: songId, from: this);

  @override
  String toString() => r'songEditProvider';
}

/// Everything the song edit screen does. Edits a draft in memory and saves
/// through the song outbox, so it works offline; nothing reaches Drift until
/// Save. Last write wins.

abstract class _$SongEdit extends $AsyncNotifier<SongEditState> {
  late final _$args = ref.$arg as int;
  int get songId => _$args;

  FutureOr<SongEditState> build(int songId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SongEditState>, SongEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SongEditState>, SongEditState>,
              AsyncValue<SongEditState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
