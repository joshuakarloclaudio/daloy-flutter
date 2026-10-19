// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Workspace _$WorkspaceFromJson(Map<String, dynamic> json) => _Workspace(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  role: json['role'] as String,
  isMember: json['is_member'] as bool? ?? true,
);

Map<String, dynamic> _$WorkspaceToJson(_Workspace instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': instance.role,
      'is_member': instance.isMember,
    };
