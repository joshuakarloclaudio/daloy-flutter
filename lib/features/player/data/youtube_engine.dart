import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yt;

import '../../../core/config/app_config.dart';
import '../../../core/utils/platform.dart';

part 'youtube_engine.g.dart';

/// What the YouTube player is doing.
enum EngineStatus { loading, cued, playing, paused, buffering, ended }

/// Something the engine reports.
sealed class EngineEvent {
  const EngineEvent();
}

final class EngineStatusChanged extends EngineEvent {
  const EngineStatusChanged(this.status);

  final EngineStatus status;
}

/// The video won't play here (removed, private, or embedding is off).
final class EngineFailed extends EngineEvent {
  const EngineFailed(this.code);

  final int code;
}

/// Where the video is, a few times a second while it plays.
final class EngineProgress extends EngineEvent {
  const EngineProgress(this.position, this.duration);

  final Duration position;
  final Duration duration;
}

/// One YouTube player, behind a seam so tests run without a WebView. The
/// player always draws through [buildSurface]; YouTube's terms don't allow
/// it to play hidden, so there is no audio-only mode.
abstract class YouTubeEngine {
  Stream<EngineEvent> get events;

  /// Loads and plays [videoId].
  Future<void> load(String videoId);

  /// Loads [videoId] ready to play, without starting it.
  Future<void> cue(String videoId);
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<Duration> position();

  /// The video itself. Built in one place at a time.
  Widget buildSurface(BuildContext context);
  Future<void> dispose();
}

/// The YouTube iframe player in a WebView (`youtube_player_iframe`), with
/// YouTube's own controls off: the app's transport drives it.
class IframeYouTubeEngine implements YouTubeEngine {
  IframeYouTubeEngine() {
    _value = _controller.stream.listen(_onValue);
    _progress = _controller.videoStateStream.listen((s) {
      _events.add(EngineProgress(s.position, _controller.value.metaData.duration));
    });
    // The player page has to load before it takes commands (they wait for it).
    // ignore: invalid_use_of_internal_member
    unawaited(_controller.init());
  }

  final _controller = yt.YoutubePlayerController(
    params: const yt.YoutubePlayerParams(
      mute: AppConfig.playerMuted,
      showControls: false,
      showFullscreenButton: false,
      enableCaption: false,
      strictRelatedVideos: true,
      pointerEvents: yt.PointerEvents.none,
    ),
  );
  final _events = StreamController<EngineEvent>.broadcast();
  late final StreamSubscription<yt.YoutubePlayerValue> _value;
  late final StreamSubscription<yt.YoutubeVideoState> _progress;
  yt.YoutubeError _lastError = yt.YoutubeError.none;

  void _onValue(yt.YoutubePlayerValue value) {
    if (value.error != _lastError) {
      _lastError = value.error;
      if (value.hasError) _events.add(EngineFailed(value.error.code));
    }
    final status = switch (value.playerState) {
      yt.PlayerState.playing => EngineStatus.playing,
      yt.PlayerState.paused => EngineStatus.paused,
      yt.PlayerState.buffering => EngineStatus.buffering,
      yt.PlayerState.ended => EngineStatus.ended,
      yt.PlayerState.cued => EngineStatus.cued,
      yt.PlayerState.unStarted || yt.PlayerState.unknown => null,
    };
    if (status != null) _events.add(EngineStatusChanged(status));
  }

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  Future<void> load(String videoId) async {
    await _controller.loadVideoById(videoId: videoId);
    if (AppConfig.playerMuted) await _controller.mute();
  }

  @override
  Future<void> cue(String videoId) => _controller.cueVideoById(videoId: videoId);

  @override
  Future<void> play() => _controller.playVideo();

  @override
  Future<void> pause() => _controller.pauseVideo();

  @override
  Future<void> seekTo(Duration position) =>
      _controller.seekTo(seconds: position.inMilliseconds / 1000, allowSeekAhead: true);

  @override
  Future<Duration> position() async => Duration(milliseconds: ((await _controller.currentTime) * 1000).round());

  @override
  Widget buildSurface(BuildContext context) {
    // The Mac's WebView has no opacity switch, so it throws on this; it draws
    // over black there anyway.
    if (!isMacOS) unawaited(_controller.webViewController.setBackgroundColor(Colors.black));
    return WebViewWidget(controller: _controller.webViewController);
  }

  @override
  Future<void> dispose() async {
    await _value.cancel();
    await _progress.cancel();
    await _controller.close();
    await _events.close();
  }
}

/// Makes the one YouTube player; tests swap in a fake.
@Riverpod(keepAlive: true)
YouTubeEngine Function() youtubeEngineFactory(Ref ref) => IframeYouTubeEngine.new;
