import 'package:freezed_annotation/freezed_annotation.dart';

part 'song.freezed.dart';
part 'song.g.dart';

/// `SongListItemData` from the API.
@freezed
abstract class Song with _$Song {
  const Song._();

  const factory Song({
    required int id,
    required String title,
    String? artist,
    String? key,
    int? transposition,
    int? bpm,
    String? timeSignature,
    String? content,
    String? lyrics,
    String? youtubeUrl,
    String? spotifyUrl,
    String? appleMusicUrl,
    String? otherUrl,
    @Default(false) bool isPublic,
    DateTime? createdAt,

    /// When it was last added to a line-up. Only the library list carries it.
    DateTime? lastUsedAt,

    /// Bumped by the server on every change.
    @Default(1) int version,

    /// The last shared change: when, and who (null for older changes).
    DateTime? updatedAt,
    UserBrief? updatedBy,
  }) = _Song;

  factory Song.fromJson(Map<String, dynamic> json) => _$SongFromJson(json);

  /// Created on this device and not yet accepted by the server. Local ids are
  /// negative so they can never collide with a server id.
  bool get isPending => id < 0;

  /// Artist, else "Key of X" — the line under a title everywhere.
  String? get subtitle {
    if (artist case final a? when a.isNotEmpty) return a;
    if (key case final k? when k.isNotEmpty) return 'Key of $k';
    return null;
  }
}

/// `UserBriefData` — a teammate, named.
@freezed
abstract class UserBrief with _$UserBrief {
  const factory UserBrief({required int id, required String name}) = _UserBrief;

  factory UserBrief.fromJson(Map<String, dynamic> json) => _$UserBriefFromJson(json);
}

/// `GET /api/songs` — a raw Laravel paginator (no envelope).
@freezed
abstract class SongsPage with _$SongsPage {
  const factory SongsPage({required List<Song> data, required PageMeta meta}) = _SongsPage;

  factory SongsPage.fromJson(Map<String, dynamic> json) => _$SongsPageFromJson(json);
}

@freezed
abstract class PageMeta with _$PageMeta {
  const factory PageMeta({required int currentPage, required int lastPage, required int total}) = _PageMeta;

  factory PageMeta.fromJson(Map<String, dynamic> json) => _$PageMetaFromJson(json);
}
