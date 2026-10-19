import 'new_song.dart';
import 'song.dart';

const Object _keep = Object();

/// What the edit screen changes on a song: the web's `DraftFields`. Chords
/// (`content`) and lyrics are separate on purpose — two fields, two editors.
class SongFields {
  const SongFields({
    required this.title,
    this.artist = '',
    this.key,
    this.bpm = '',
    this.timeSignature,
    this.chords = '',
    this.lyrics = '',
    this.youtubeUrl = '',
    this.spotifyUrl = '',
    this.appleMusicUrl = '',
    this.otherUrl = '',
  });

  factory SongFields.fromSong(Song s) => SongFields(
    title: s.title,
    artist: s.artist ?? '',
    key: s.key,
    bpm: s.bpm?.toString() ?? '',
    timeSignature: s.timeSignature,
    chords: s.content ?? '',
    lyrics: s.lyrics ?? '',
    youtubeUrl: s.youtubeUrl ?? '',
    spotifyUrl: s.spotifyUrl ?? '',
    appleMusicUrl: s.appleMusicUrl ?? '',
    otherUrl: s.otherUrl ?? '',
  );

  final String title;
  final String artist;
  final String? key;
  final String bpm;
  final String? timeSignature;
  final String chords;
  final String lyrics;
  final String youtubeUrl;
  final String spotifyUrl;
  final String appleMusicUrl;
  final String otherUrl;

  static const maxUrlLength = 255;

  SongFields copyWith({
    String? title,
    String? artist,
    Object? key = _keep,
    String? bpm,
    Object? timeSignature = _keep,
    String? chords,
    String? lyrics,
    String? youtubeUrl,
    String? spotifyUrl,
    String? appleMusicUrl,
    String? otherUrl,
  }) => SongFields(
    title: title ?? this.title,
    artist: artist ?? this.artist,
    key: identical(key, _keep) ? this.key : key as String?,
    bpm: bpm ?? this.bpm,
    timeSignature: identical(timeSignature, _keep) ? this.timeSignature : timeSignature as String?,
    chords: chords ?? this.chords,
    lyrics: lyrics ?? this.lyrics,
    youtubeUrl: youtubeUrl ?? this.youtubeUrl,
    spotifyUrl: spotifyUrl ?? this.spotifyUrl,
    appleMusicUrl: appleMusicUrl ?? this.appleMusicUrl,
    otherUrl: otherUrl ?? this.otherUrl,
  );

  static String? _blankToNull(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  /// Null for a blank field, or for text that isn't a number.
  int? get bpmValue => int.tryParse(bpm.trim());

  String? get titleError => title.trim().isEmpty
      ? 'Give the song a title.'
      : title.trim().length > NewSong.maxTextLength
      ? 'Keep the title under ${NewSong.maxTextLength} characters.'
      : null;

  String? get bpmError {
    if (bpm.trim().isEmpty) return null;
    final v = bpmValue;
    return v != null && NewSong.isValidBpm(v) ? null : 'Tempo is between ${NewSong.minBpm} and ${NewSong.maxBpm} BPM.';
  }

  /// The API wants a URL; a link typed without its scheme is rejected there,
  /// so it's caught here.
  static String? urlError(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    if (t.length > maxUrlLength) return 'That link is too long.';
    final uri = Uri.tryParse(t);
    final ok = uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.contains('.');
    return ok ? null : 'Start the link with https://';
  }

  bool get isValid =>
      titleError == null &&
      bpmError == null &&
      urlError(youtubeUrl) == null &&
      urlError(spotifyUrl) == null &&
      urlError(appleMusicUrl) == null &&
      urlError(otherUrl) == null;

  int get linkCount => [youtubeUrl, spotifyUrl, appleMusicUrl, otherUrl].where((u) => u.trim().isNotEmpty).length;

  /// Same song once trimmed and blanks are null — what "unsaved changes" means.
  bool matches(SongFields o) =>
      title.trim() == o.title.trim() &&
      _blankToNull(artist) == _blankToNull(o.artist) &&
      key == o.key &&
      bpmValue == o.bpmValue &&
      timeSignature == o.timeSignature &&
      chords == o.chords &&
      lyrics == o.lyrics &&
      _blankToNull(youtubeUrl) == _blankToNull(o.youtubeUrl) &&
      _blankToNull(spotifyUrl) == _blankToNull(o.spotifyUrl) &&
      _blankToNull(appleMusicUrl) == _blankToNull(o.appleMusicUrl) &&
      _blankToNull(otherUrl) == _blankToNull(o.otherUrl);

  /// The song as it will be stored: [base] with these fields applied.
  Song applyTo(Song base) => base.copyWith(
    title: title.trim(),
    artist: _blankToNull(artist),
    key: key,
    bpm: bpmValue,
    timeSignature: timeSignature,
    content: chords.isEmpty ? null : chords,
    lyrics: lyrics.isEmpty ? null : lyrics,
    youtubeUrl: _blankToNull(youtubeUrl),
    spotifyUrl: _blankToNull(spotifyUrl),
    appleMusicUrl: _blankToNull(appleMusicUrl),
    otherUrl: _blankToNull(otherUrl),
  );
}
