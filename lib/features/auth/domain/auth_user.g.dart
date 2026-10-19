// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  lastWorkspaceId: (json['last_workspace_id'] as num?)?.toInt(),
  isSuperadmin: json['is_superadmin'] as bool? ?? false,
  preferredView: json['preferred_view'] as String?,
  chordNotation: json['chord_notation'] as String?,
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'last_workspace_id': instance.lastWorkspaceId,
  'is_superadmin': instance.isSuperadmin,
  'preferred_view': instance.preferredView,
  'chord_notation': instance.chordNotation,
};

_AuthResult _$AuthResultFromJson(Map<String, dynamic> json) => _AuthResult(
  user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
  token: json['token'] as String,
);

Map<String, dynamic> _$AuthResultToJson(_AuthResult instance) =>
    <String, dynamic>{'user': instance.user.toJson(), 'token': instance.token};
