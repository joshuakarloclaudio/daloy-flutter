import 'package:flutter/foundation.dart';

import '../../line_ups/application/line_up_detail_controller.dart';
import '../../songs/domain/song.dart';
import '../../songs/domain/youtube_link.dart';

/// One song in the player's queue — the twin of the web's `MusicPlayerTrack`.
/// Songs without a link stay in the queue (dimmed), so it still reads like
/// the set.
@immutable
class PlayerTrack {
  const PlayerTrack({
    required this.index,
    required this.songId,
    required this.title,
    this.artist,
    this.displayKey,
    this.videoId,
    this.spotifyUrl,
    this.appleMusicUrl,
  });

  /// 0-based place in the queue — the same index Perform gives the song, so
  /// the chart and the player can point at each other.
  final int index;

  /// The library song: where a new YouTube link is saved.
  final int songId;
  final String title;
  final String? artist;

  /// The key the band plays it in.
  final String? displayKey;

  /// Null when the song has no usable YouTube link: shown, never played.
  final String? videoId;
  final String? spotifyUrl;
  final String? appleMusicUrl;

  int get number => index + 1;
  bool get hasVideo => videoId != null;

  /// The other apps this song can be heard in.
  bool get hasOtherApps => _present(spotifyUrl) || _present(appleMusicUrl);

  static bool _present(String? s) => s != null && s.trim().isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is PlayerTrack &&
      other.index == index &&
      other.songId == songId &&
      other.title == title &&
      other.artist == artist &&
      other.displayKey == displayKey &&
      other.videoId == videoId &&
      other.spotifyUrl == spotifyUrl &&
      other.appleMusicUrl == appleMusicUrl;

  @override
  int get hashCode => Object.hash(index, songId, title, artist, displayKey, videoId, spotifyUrl, appleMusicUrl);
}

String? _blank(String? s) => s == null || s.trim().isEmpty ? null : s;

PlayerTrack _track(int index, Song song, String? displayKey) => PlayerTrack(
  index: index,
  songId: song.id,
  title: song.title,
  artist: _blank(song.artist),
  displayKey: displayKey,
  videoId: songYouTubeVideoId(song.youtubeUrl),
  spotifyUrl: _blank(song.spotifyUrl),
  appleMusicUrl: _blank(song.appleMusicUrl),
);

/// A line-up's set in order, each song in this service's key.
List<PlayerTrack> buildLineUpQueue(List<SetlistSong> rows) => [
  for (final (i, row) in rows.indexed) _track(i, row.entry.song, row.displayKey),
];

/// A queue of one, for a song from the library.
List<PlayerTrack> buildSongQueue(Song? song, String? displayKey) =>
    song == null ? const [] : [_track(0, song, displayKey)];

/// The next playable track after [from] going in [direction] (1 or -1),
/// skipping songs without a link and videos YouTube wouldn't play (by video
/// id, so a new link gets a fresh chance). Null at either end: the player
/// doesn't wrap.
int? findPlayableIndex(List<PlayerTrack> tracks, int from, int direction, {Set<String> unavailable = const {}}) {
  for (var i = from + direction; i >= 0 && i < tracks.length; i += direction) {
    if (isPlayable(tracks[i], unavailable)) return i;
  }
  return null;
}

bool isPlayable(PlayerTrack track, Set<String> unavailable) =>
    track.videoId != null && !unavailable.contains(track.videoId);
