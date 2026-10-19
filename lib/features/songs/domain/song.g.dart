// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Song _$SongFromJson(Map<String, dynamic> json) => _Song(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  artist: json['artist'] as String?,
  key: json['key'] as String?,
  transposition: (json['transposition'] as num?)?.toInt(),
  bpm: (json['bpm'] as num?)?.toInt(),
  timeSignature: json['time_signature'] as String?,
  content: json['content'] as String?,
  lyrics: json['lyrics'] as String?,
  youtubeUrl: json['youtube_url'] as String?,
  spotifyUrl: json['spotify_url'] as String?,
  appleMusicUrl: json['apple_music_url'] as String?,
  otherUrl: json['other_url'] as String?,
  isPublic: json['is_public'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  lastUsedAt: json['last_used_at'] == null
      ? null
      : DateTime.parse(json['last_used_at'] as String),
  version: (json['version'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$SongToJson(_Song instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'artist': instance.artist,
  'key': instance.key,
  'transposition': instance.transposition,
  'bpm': instance.bpm,
  'time_signature': instance.timeSignature,
  'content': instance.content,
  'lyrics': instance.lyrics,
  'youtube_url': instance.youtubeUrl,
  'spotify_url': instance.spotifyUrl,
  'apple_music_url': instance.appleMusicUrl,
  'other_url': instance.otherUrl,
  'is_public': instance.isPublic,
  'created_at': instance.createdAt?.toIso8601String(),
  'last_used_at': instance.lastUsedAt?.toIso8601String(),
  'version': instance.version,
};

_SongsPage _$SongsPageFromJson(Map<String, dynamic> json) => _SongsPage(
  data: (json['data'] as List<dynamic>)
      .map((e) => Song.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: PageMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SongsPageToJson(_SongsPage instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'meta': instance.meta.toJson(),
    };

_PageMeta _$PageMetaFromJson(Map<String, dynamic> json) => _PageMeta(
  currentPage: (json['current_page'] as num).toInt(),
  lastPage: (json['last_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$PageMetaToJson(_PageMeta instance) => <String, dynamic>{
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'total': instance.total,
};
