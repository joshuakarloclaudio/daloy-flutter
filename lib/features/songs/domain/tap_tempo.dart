import 'new_song.dart';

/// Tap along to a song to find its tempo. Averages the last few gaps between
/// taps; a pause longer than [resetAfter] starts over.
class TapTempo {
  TapTempo({this.resetAfter = const Duration(seconds: 2), this.window = 6});

  final Duration resetAfter;

  /// Most taps averaged.
  final int window;

  final _taps = <DateTime>[];

  /// Records a tap; the tempo so far, or null until there are two taps.
  int? tap([DateTime? at]) {
    final now = at ?? DateTime.now();
    if (_taps.isNotEmpty && now.difference(_taps.last) > resetAfter) _taps.clear();
    _taps.add(now);
    if (_taps.length > window) _taps.removeAt(0);
    if (_taps.length < 2) return null;

    final span = _taps.last.difference(_taps.first).inMicroseconds;
    final bpm = (60000000 * (_taps.length - 1) / span).round();
    return bpm.clamp(NewSong.minBpm, NewSong.maxBpm);
  }

  void reset() => _taps.clear();
}
