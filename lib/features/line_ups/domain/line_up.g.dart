// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_up.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LineUp _$LineUpFromJson(Map<String, dynamic> json) => _LineUp(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  date: json['date'] as String,
  worshipLeader: json['worship_leader'] as String?,
  songsCount: (json['songs_count'] as num?)?.toInt() ?? 0,
  version: (json['version'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$LineUpToJson(_LineUp instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'date': instance.date,
  'worship_leader': instance.worshipLeader,
  'songs_count': instance.songsCount,
  'version': instance.version,
};

_LineUpListPage _$LineUpListPageFromJson(Map<String, dynamic> json) =>
    _LineUpListPage(
      lineUps: (json['line_ups'] as List<dynamic>)
          .map((e) => LineUp.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LineUpListPageToJson(_LineUpListPage instance) =>
    <String, dynamic>{
      'line_ups': instance.lineUps.map((e) => e.toJson()).toList(),
    };

_LineUpDetail _$LineUpDetailFromJson(Map<String, dynamic> json) =>
    _LineUpDetail(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      date: json['date'] as String,
      worshipLeader: json['worship_leader'] as String?,
      songsCount: (json['songs_count'] as num?)?.toInt() ?? 0,
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map((e) => LineUpSongEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <LineUpSongEntry>[],
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$LineUpDetailToJson(_LineUpDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'date': instance.date,
      'worship_leader': instance.worshipLeader,
      'songs_count': instance.songsCount,
      'songs': instance.songs.map((e) => e.toJson()).toList(),
      'version': instance.version,
    };

_LineUpSongEntry _$LineUpSongEntryFromJson(Map<String, dynamic> json) =>
    _LineUpSongEntry(
      lineUpSongId: (json['line_up_song_id'] as num).toInt(),
      order: (json['order'] as num).toInt(),
      transposition: (json['transposition'] as num?)?.toInt() ?? 0,
      song: Song.fromJson(json['song'] as Map<String, dynamic>),
      notes:
          (json['notes'] as List<dynamic>?)
              ?.map((e) => LineUpSongNote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <LineUpSongNote>[],
      sectionArrangement: json['section_arrangement'] == null
          ? null
          : SectionArrangement.fromJson(
              json['section_arrangement'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$LineUpSongEntryToJson(_LineUpSongEntry instance) =>
    <String, dynamic>{
      'line_up_song_id': instance.lineUpSongId,
      'order': instance.order,
      'transposition': instance.transposition,
      'song': instance.song.toJson(),
      'notes': instance.notes.map((e) => e.toJson()).toList(),
      'section_arrangement': instance.sectionArrangement?.toJson(),
    };

_LineUpSongNote _$LineUpSongNoteFromJson(Map<String, dynamic> json) =>
    _LineUpSongNote(
      id: json['id'] as String,
      line: (json['line'] as num).toInt(),
      text: json['text'] as String,
    );

Map<String, dynamic> _$LineUpSongNoteToJson(_LineUpSongNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'line': instance.line,
      'text': instance.text,
    };

_SectionArrangement _$SectionArrangementFromJson(Map<String, dynamic> json) =>
    _SectionArrangement(
      chords: json['chords'] == null
          ? const SectionArrangementField()
          : SectionArrangementField.fromJson(
              json['chords'] as Map<String, dynamic>,
            ),
      lyrics: json['lyrics'] == null
          ? const SectionArrangementField()
          : SectionArrangementField.fromJson(
              json['lyrics'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SectionArrangementToJson(_SectionArrangement instance) =>
    <String, dynamic>{
      'chords': instance.chords.toJson(),
      'lyrics': instance.lyrics.toJson(),
    };

_SectionArrangementField _$SectionArrangementFieldFromJson(
  Map<String, dynamic> json,
) => _SectionArrangementField(
  order:
      (json['order'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  removed:
      (json['removed'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
);

Map<String, dynamic> _$SectionArrangementFieldToJson(
  _SectionArrangementField instance,
) => <String, dynamic>{'order': instance.order, 'removed': instance.removed};

_LineUpShareLink _$LineUpShareLinkFromJson(Map<String, dynamic> json) =>
    _LineUpShareLink(
      enabled: json['enabled'] as bool,
      token: json['token'] as String?,
      sharePath: json['share_path'] as String?,
    );

Map<String, dynamic> _$LineUpShareLinkToJson(_LineUpShareLink instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'token': instance.token,
      'share_path': instance.sharePath,
    };
