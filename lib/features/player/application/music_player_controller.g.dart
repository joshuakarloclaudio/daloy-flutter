// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'music_player_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The music player: plays a line-up's (or a song's) YouTube links in order
/// — the twin of `use-music-player.ts`, but one for the whole app, so it
/// plays on from screen to screen. The video is always on screen, through
/// [slots]; there's no background audio. Songs without a link stay in the
/// queue and are skipped; a video YouTube refuses is marked and skipped.

@ProviderFor(MusicPlayer)
final musicPlayerProvider = MusicPlayerProvider._();

/// The music player: plays a line-up's (or a song's) YouTube links in order
/// — the twin of `use-music-player.ts`, but one for the whole app, so it
/// plays on from screen to screen. The video is always on screen, through
/// [slots]; there's no background audio. Songs without a link stay in the
/// queue and are skipped; a video YouTube refuses is marked and skipped.
final class MusicPlayerProvider
    extends $NotifierProvider<MusicPlayer, MusicPlayerState> {
  /// The music player: plays a line-up's (or a song's) YouTube links in order
  /// — the twin of `use-music-player.ts`, but one for the whole app, so it
  /// plays on from screen to screen. The video is always on screen, through
  /// [slots]; there's no background audio. Songs without a link stay in the
  /// queue and are skipped; a video YouTube refuses is marked and skipped.
  MusicPlayerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'musicPlayerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$musicPlayerHash();

  @$internal
  @override
  MusicPlayer create() => MusicPlayer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MusicPlayerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MusicPlayerState>(value),
    );
  }
}

String _$musicPlayerHash() => r'162032aa17d62312ab8876708965fd79a9b26c43';

/// The music player: plays a line-up's (or a song's) YouTube links in order
/// — the twin of `use-music-player.ts`, but one for the whole app, so it
/// plays on from screen to screen. The video is always on screen, through
/// [slots]; there's no background audio. Songs without a link stay in the
/// queue and are skipped; a video YouTube refuses is marked and skipped.

abstract class _$MusicPlayer extends $Notifier<MusicPlayerState> {
  MusicPlayerState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MusicPlayerState, MusicPlayerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MusicPlayerState, MusicPlayerState>,
              MusicPlayerState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
