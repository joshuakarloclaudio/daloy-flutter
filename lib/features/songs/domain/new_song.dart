/// What the new-song form collects. Chords and lyrics usually come later, in
/// the editor; a ChordPro import brings them along.
class NewSong {
  const NewSong({required this.title, this.artist, this.key, this.bpm, this.timeSignature, this.content, this.lyrics});

  static const maxTextLength = 255;
  static const minBpm = 20;
  static const maxBpm = 300;

  /// Web: `TIME_SIGNATURES`.
  static const timeSignatures = ['2/4', '3/4', '4/4', '5/4', '6/8', '9/8', '12/8'];

  final String title;
  final String? artist;
  final String? key;
  final int? bpm;
  final String? timeSignature;
  final String? content;
  final String? lyrics;

  bool get hasContent => (content?.trim().isNotEmpty ?? false) || (lyrics?.trim().isNotEmpty ?? false);

  static bool isValidTitle(String title) => title.trim().isNotEmpty && title.trim().length <= maxTextLength;

  static bool isValidBpm(int bpm) => bpm >= minBpm && bpm <= maxBpm;

  /// The `CreateSongData` body.
  Map<String, Object?> toJson() => {
    'title': title,
    'artist': artist,
    'key': key,
    'bpm': bpm,
    'time_signature': timeSignature,
    'content': ?content,
    'lyrics': ?lyrics,
  };
}
