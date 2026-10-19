// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_deletion_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccountDeletionPreview _$AccountDeletionPreviewFromJson(
  Map<String, dynamic> json,
) => _AccountDeletionPreview(
  requiresPassword: json['requires_password'] as bool,
  canDelete: json['can_delete'] as bool,
  blocking:
      (json['blocking'] as List<dynamic>?)
          ?.map((e) => DeletionWorkspace.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  willDelete:
      (json['will_delete'] as List<dynamic>?)
          ?.map((e) => DeletionWorkspace.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$AccountDeletionPreviewToJson(
  _AccountDeletionPreview instance,
) => <String, dynamic>{
  'requires_password': instance.requiresPassword,
  'can_delete': instance.canDelete,
  'blocking': instance.blocking.map((e) => e.toJson()).toList(),
  'will_delete': instance.willDelete.map((e) => e.toJson()).toList(),
};

_DeletionWorkspace _$DeletionWorkspaceFromJson(Map<String, dynamic> json) =>
    _DeletionWorkspace(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$DeletionWorkspaceToJson(_DeletionWorkspace instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};
