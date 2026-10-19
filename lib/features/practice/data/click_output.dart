import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'click_output.g.dart';

/// Where the metronome's clicks go, and the clock they are timed on.
///
/// Clicks are scheduled ahead on the output's own clock, so they land
/// sample-accurately however late a Dart timer fires.
abstract interface class ClickOutput {
  /// Gets the output ready; false when there is no audio (the clock still runs).
  Future<bool> open();

  /// The output's clock.
  Duration now();

  /// A click at [at] on [now]'s clock; at [volume] 0 nothing is heard.
  void click(Duration at, {required bool accent, required double volume});

  /// Sets the volume of clicks scheduled but not yet heard.
  void setPendingVolume(double volume);

  /// Drops clicks scheduled but not yet heard.
  void cancelPending();

  Future<void> close();
}

/// Clicks through SoLoud, scheduled sample-accurately with `playScheduled`.
///
/// The beat runs on a steady wall clock ([now]); each click is mapped onto
/// the engine's own clock. The engine clock only moves while the device is
/// mixing, so it can't drive the beat itself: with the click muted (nothing
/// scheduled) it would stand still, and the chart with it.
class SoLoudClickOutput implements ClickOutput {
  /// How far the engine may drift from the wall clock before the mapping
  /// snaps to it (the engine clock steps a buffer at a time, ~12ms).
  static const _resync = Duration(milliseconds: 40);

  SoLoud get _soloud => SoLoud.instance;

  final _wall = Stopwatch();
  Duration? _offset;
  AudioSource? _accent;
  AudioSource? _beat;
  bool _ready = false;
  final _pending = <({Duration at, SoundHandle handle})>[];

  @override
  Future<bool> open() async {
    _wall.start();
    if (_ready) return true;
    try {
      if (!_soloud.isInitialized) await _soloud.init(bufferSize: 512);
      _accent = await _soloud.loadMem('daloy-click-accent.wav', clickWav(frequency: 1760, gain: 0.9));
      _beat = await _soloud.loadMem('daloy-click.wav', clickWav(frequency: 1320, gain: 0.6));
      _ready = true;
    } on Object catch (e) {
      debugPrint('Practice: no audio ($e)');
      _ready = false;
    }
    return _ready;
  }

  @override
  Duration now() => _wall.elapsed;

  /// [at] on the wall clock, as engine time.
  Duration _engineTime(Duration at) {
    final candidate = _soloud.getEngineTime() - _wall.elapsed;
    final offset = _offset;
    if (offset == null || (candidate - offset).abs() > _resync) _offset = candidate;
    return at + _offset!;
  }

  @override
  void click(Duration at, {required bool accent, required double volume}) {
    final source = accent ? _accent : _beat;
    // Muted: nothing to schedule — the beat runs on the wall clock anyway.
    if (!_ready || source == null || volume <= 0) return;
    try {
      final engineAt = _engineTime(at);
      final handle = _soloud.playScheduled(
        source,
        engineAt,
        volume: volume,
        duration: const Duration(milliseconds: 60),
      );
      _pending.add((at: at, handle: handle));
      _prune();
    } on Object catch (e) {
      debugPrint('Practice: click failed ($e)');
    }
  }

  /// Forgets clicks already heard.
  void _prune() {
    final heard = now();
    _pending.removeWhere((p) => p.at < heard);
  }

  @override
  void setPendingVolume(double volume) {
    if (!_ready) return;
    if (volume <= 0) {
      cancelPending();
      return;
    }
    _prune();
    for (final p in _pending) {
      if (_soloud.getIsValidVoiceHandle(p.handle)) _soloud.setVolume(p.handle, volume);
    }
  }

  @override
  void cancelPending() {
    if (!_ready) return;
    _prune();
    for (final p in _pending) {
      if (_soloud.getIsValidVoiceHandle(p.handle)) unawaited(_soloud.stop(p.handle));
    }
    _pending.clear();
  }

  @override
  Future<void> close() async {
    cancelPending();
    _wall.stop();
    if (_ready) {
      // Let go of the audio device: other apps (and the Listen player) need it.
      _soloud.deinit();
    }
    _ready = false;
    _accent = null;
    _beat = null;
  }
}

/// No sound, and a stopwatch for a clock: the fallback when audio won't
/// start, and what tests run against.
class SilentClickOutput implements ClickOutput {
  SilentClickOutput({this.clock});

  /// Stands in for the audio clock in tests; a stopwatch otherwise.
  final Duration Function()? clock;
  final _watch = Stopwatch();

  /// Every click asked for, for tests.
  final clicks = <({Duration at, bool accent, double volume})>[];

  @override
  Future<bool> open() async {
    _watch.start();
    return false;
  }

  @override
  Duration now() => clock?.call() ?? _watch.elapsed;

  @override
  void click(Duration at, {required bool accent, required double volume}) =>
      clicks.add((at: at, accent: accent, volume: volume));

  @override
  void setPendingVolume(double volume) {}

  @override
  void cancelPending() {}

  @override
  Future<void> close() async => _watch.stop();
}

/// A short woodblock-ish tick as a 16-bit mono WAV: a sine with a fast
/// exponential decay, so it cuts through a band without a hard edge.
Uint8List clickWav({required double frequency, required double gain, int sampleRate = 44100}) {
  const length = Duration(milliseconds: 45);
  final samples = sampleRate * length.inMicroseconds ~/ 1000000;
  final data = ByteData(44 + samples * 2);

  void ascii(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      data.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + samples * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  data.setUint32(40, samples * 2, Endian.little);

  for (var i = 0; i < samples; i++) {
    final t = i / sampleRate;
    // 1ms attack keeps the onset from clicking twice.
    final attack = math.min(1.0, t / 0.001);
    final envelope = attack * math.exp(-t * 90);
    final value = math.sin(2 * math.pi * frequency * t) * envelope * gain;
    data.setInt16(44 + i * 2, (value * 32767).round().clamp(-32768, 32767), Endian.little);
  }
  return data.buffer.asUint8List();
}

/// A fresh output per Practice screen; tests override it with a silent one.
@riverpod
ClickOutput clickOutput(Ref ref) => SoLoudClickOutput();
