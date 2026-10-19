import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_song.freezed.dart';
part 'network_song.g.dart';

/// `NetworkSongListItemData` / `NetworkSongDetailData` — a public song from
/// another workspace. The list leaves the chart fields null.
@freezed
abstract class NetworkSong with _$NetworkSong {
  const factory NetworkSong({
    required int id,
    required String title,
    String? artist,
    String? key,
    int? bpm,
    String? timeSignature,

    /// The first lyric lines, for a card's teaser (the list only).
    String? preview,
    @Default(false) bool hasMedia,
    required String workspaceName,
    @Default(false) bool isOwnWorkspace,
    @Default(0) int importCount,

    /// This workspace already has a copy.
    @Default(false) bool alreadyAdded,
    String? content,
    String? lyrics,
    String? youtubeUrl,
    String? spotifyUrl,
    String? appleMusicUrl,
    String? otherUrl,
    DateTime? createdAt,
  }) = _NetworkSong;

  factory NetworkSong.fromJson(Map<String, dynamic> json) => _$NetworkSongFromJson(json);
}

/// `NetworkSongCursorPageData`.
@freezed
abstract class NetworkSongPage with _$NetworkSongPage {
  const factory NetworkSongPage({required List<NetworkSong> songs, String? nextCursor}) = _NetworkSongPage;

  factory NetworkSongPage.fromJson(Map<String, dynamic> json) => _$NetworkSongPageFromJson(json);
}
