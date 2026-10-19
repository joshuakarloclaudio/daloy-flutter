import 'song.dart';

/// A song field one save can change on its own — the API's per-field save
/// (`PATCH /api/songs/{id}/changes`) names them by [api]. Values are read in
/// one form (blank text is null) so a draft and the server compare.
enum SongField {
  title('title', 'title'),
  artist('artist', 'artist'),
  key('key', 'key'),
  transposition('transposition', 'transposition'),
  bpm('bpm', 'tempo'),
  timeSignature('time_signature', 'time signature'),
  content('content', 'chords'),
  lyrics('lyrics', 'lyrics'),
  spotifyUrl('spotify_url', 'Spotify link'),
  youtubeUrl('youtube_url', 'YouTube link'),
  appleMusicUrl('apple_music_url', 'Apple Music link'),
  otherUrl('other_url', 'link');

  const SongField(this.api, this.label);

  final String api;

  /// How the conflict banner names it.
  final String label;

  static SongField? byApi(String name) {
    for (final f in values) {
      if (f.api == name) return f;
    }
    return null;
  }

  Object? read(Song s) => switch (this) {
    title => s.title,
    artist => _blank(s.artist),
    key => _blank(s.key),
    transposition => s.transposition ?? 0,
    bpm => s.bpm,
    timeSignature => _blank(s.timeSignature),
    content => _blank(s.content),
    lyrics => _blank(s.lyrics),
    spotifyUrl => _blank(s.spotifyUrl),
    youtubeUrl => _blank(s.youtubeUrl),
    appleMusicUrl => _blank(s.appleMusicUrl),
    otherUrl => _blank(s.otherUrl),
  };

  Song write(Song s, Object? value) => switch (this) {
    title => s.copyWith(title: value as String? ?? s.title),
    artist => s.copyWith(artist: _text(value)),
    key => s.copyWith(key: _text(value)),
    transposition => s.copyWith(transposition: _int(value) ?? 0),
    bpm => s.copyWith(bpm: _int(value)),
    timeSignature => s.copyWith(timeSignature: _text(value)),
    content => s.copyWith(content: _text(value)),
    lyrics => s.copyWith(lyrics: _text(value)),
    spotifyUrl => s.copyWith(spotifyUrl: _text(value)),
    youtubeUrl => s.copyWith(youtubeUrl: _text(value)),
    appleMusicUrl => s.copyWith(appleMusicUrl: _text(value)),
    otherUrl => s.copyWith(otherUrl: _text(value)),
  };

  static String? _blank(String? v) => v == null || v.isEmpty ? null : v;
  static String? _text(Object? v) => v == null ? null : _blank('$v');
  static int? _int(Object? v) => v is int ? v : (v is num ? v.toInt() : int.tryParse('${v ?? ''}'));
}

/// Equal for a save's purposes: blank and null match, numbers by value.
bool sameSongValue(Object? a, Object? b) {
  bool blank(Object? v) => v == null || v == '';
  if (blank(a) || blank(b)) return blank(a) && blank(b);
  if (a is num && b is num) return a == b;
  return '$a' == '$b';
}

/// The fields that differ between two copies of a song.
Set<SongField> changedSongFields(Song before, Song after) => {
  for (final f in SongField.values)
    if (!sameSongValue(f.read(before), f.read(after))) f,
};
