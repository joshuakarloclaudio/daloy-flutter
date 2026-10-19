import '../chart/nashville.dart';

enum SongViewMode {
  chords,
  lyrics;

  static SongViewMode parse(String? value) => value == 'lyrics' ? lyrics : chords;
}

/// How this device draws a chart (`userPreferences` on the web).
class ChartPrefs {
  const ChartPrefs({this.viewMode = SongViewMode.chords, this.zoom = defaultZoom, this.notation});

  static const minZoom = 75;
  static const maxZoom = 200;
  static const zoomStep = 5;
  static const defaultZoom = 100;

  final SongViewMode viewMode;

  /// Percent of the base chart size.
  final int zoom;

  /// Null until the user picks one — the account's setting applies until then.
  final ChordNotation? notation;

  static int clampZoom(num value) => ((value / zoomStep).round() * zoomStep).clamp(minZoom, maxZoom);

  bool get canZoomIn => zoom < maxZoom;
  bool get canZoomOut => zoom > minZoom;
}
