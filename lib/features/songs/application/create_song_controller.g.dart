// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_song_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The new-song sheet's save. The song is written to Drift first, so it is
/// in the library the moment the sheet closes, online or not; the push to the
/// server happens behind it (and again on reconnect, via the workspace sync).

@ProviderFor(CreateSong)
final createSongProvider = CreateSongProvider._();

/// The new-song sheet's save. The song is written to Drift first, so it is
/// in the library the moment the sheet closes, online or not; the push to the
/// server happens behind it (and again on reconnect, via the workspace sync).
final class CreateSongProvider extends $NotifierProvider<CreateSong, void> {
  /// The new-song sheet's save. The song is written to Drift first, so it is
  /// in the library the moment the sheet closes, online or not; the push to the
  /// server happens behind it (and again on reconnect, via the workspace sync).
  CreateSongProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createSongProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createSongHash();

  @$internal
  @override
  CreateSong create() => CreateSong();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createSongHash() => r'c9ef86c73403d7258e74c9b2ed95d55da5dc493d';

/// The new-song sheet's save. The song is written to Drift first, so it is
/// in the library the moment the sheet closes, online or not; the push to the
/// server happens behind it (and again on reconnect, via the workspace sync).

abstract class _$CreateSong extends $Notifier<void> {
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
