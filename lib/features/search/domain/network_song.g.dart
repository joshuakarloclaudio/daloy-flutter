// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NetworkSong _$NetworkSongFromJson(Map<String, dynamic> json) => _NetworkSong(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  artist: json['artist'] as String?,
  key: json['key'] as String?,
  bpm: (json['bpm'] as num?)?.toInt(),
  timeSignature: json['time_signature'] as String?,
  preview: json['preview'] as String?,
  hasMedia: json['has_media'] as bool? ?? false,
  workspaceName: json['workspace_name'] as String,
  isOwnWorkspace: json['is_own_workspace'] as bool? ?? false,
  importCount: (json['import_count'] as num?)?.toInt() ?? 0,
  alreadyAdded: json['already_added'] as bool? ?? false,
  content: json['content'] as String?,
  lyrics: json['lyrics'] as String?,
  youtubeUrl: json['youtube_url'] as String?,
  spotifyUrl: json['spotify_url'] as String?,
  appleMusicUrl: json['apple_music_url'] as String?,
  otherUrl: json['other_url'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$NetworkSongToJson(_NetworkSong instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'key': instance.key,
      'bpm': instance.bpm,
      'time_signature': instance.timeSignature,
      'preview': instance.preview,
      'has_media': instance.hasMedia,
      'workspace_name': instance.workspaceName,
      'is_own_workspace': instance.isOwnWorkspace,
      'import_count': instance.importCount,
      'already_added': instance.alreadyAdded,
      'content': instance.content,
      'lyrics': instance.lyrics,
      'youtube_url': instance.youtubeUrl,
      'spotify_url': instance.spotifyUrl,
      'apple_music_url': instance.appleMusicUrl,
      'other_url': instance.otherUrl,
      'created_at': instance.createdAt?.toIso8601String(),
    };

_NetworkSongPage _$NetworkSongPageFromJson(Map<String, dynamic> json) =>
    _NetworkSongPage(
      songs: (json['songs'] as List<dynamic>)
          .map((e) => NetworkSong.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$NetworkSongPageToJson(_NetworkSongPage instance) =>
    <String, dynamic>{
      'songs': instance.songs.map((e) => e.toJson()).toList(),
      'next_cursor': instance.nextCursor,
    };
