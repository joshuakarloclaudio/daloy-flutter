// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_deletions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deletes that can still be undone. Kept alive: the window outlasts the
/// screen the delete started on.

@ProviderFor(SongDeletions)
final songDeletionsProvider = SongDeletionsProvider._();

/// Deletes that can still be undone. Kept alive: the window outlasts the
/// screen the delete started on.
final class SongDeletionsProvider
    extends $NotifierProvider<SongDeletions, void> {
  /// Deletes that can still be undone. Kept alive: the window outlasts the
  /// screen the delete started on.
  SongDeletionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songDeletionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songDeletionsHash();

  @$internal
  @override
  SongDeletions create() => SongDeletions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$songDeletionsHash() => r'8edf66c208e2ad12ded57dcab407c52550b14b43';

/// Deletes that can still be undone. Kept alive: the window outlasts the
/// screen the delete started on.

abstract class _$SongDeletions extends $Notifier<void> {
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
