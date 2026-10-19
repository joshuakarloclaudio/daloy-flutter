// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiveSession _$LiveSessionFromJson(Map<String, dynamic> json) => _LiveSession(
  id: (json['id'] as num).toInt(),
  lineUpId: (json['line_up_id'] as num).toInt(),
  currentSongIndex: (json['current_song_index'] as num?)?.toInt() ?? 0,
  activeSectionIdChords: json['active_section_id_chords'] as String?,
  activeSectionIdLyrics: json['active_section_id_lyrics'] as String?,
  participantCount: (json['participant_count'] as num?)?.toInt() ?? 0,
  startedByUserId: (json['started_by_user_id'] as num).toInt(),
  startedByUserName: json['started_by_user_name'] as String,
  startedAt: DateTime.parse(json['started_at'] as String),
  leaderUserId: (json['leader_user_id'] as num?)?.toInt(),
  leaderName: json['leader_name'] as String?,
);

Map<String, dynamic> _$LiveSessionToJson(_LiveSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'line_up_id': instance.lineUpId,
      'current_song_index': instance.currentSongIndex,
      'active_section_id_chords': instance.activeSectionIdChords,
      'active_section_id_lyrics': instance.activeSectionIdLyrics,
      'participant_count': instance.participantCount,
      'started_by_user_id': instance.startedByUserId,
      'started_by_user_name': instance.startedByUserName,
      'started_at': instance.startedAt.toIso8601String(),
      'leader_user_id': instance.leaderUserId,
      'leader_name': instance.leaderName,
    };
