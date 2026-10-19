// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TeamMember _$TeamMemberFromJson(Map<String, dynamic> json) => _TeamMember(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$TeamMemberToJson(_TeamMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
    };

_TeamInvitation _$TeamInvitationFromJson(Map<String, dynamic> json) =>
    _TeamInvitation(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      role: json['role'] as String,
      invitedByName: json['invited_by_name'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TeamInvitationToJson(_TeamInvitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': instance.role,
      'invited_by_name': instance.invitedByName,
      'expires_at': instance.expiresAt.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

_TeamRoster _$TeamRosterFromJson(Map<String, dynamic> json) => _TeamRoster(
  members:
      (json['members'] as List<dynamic>?)
          ?.map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  invitations:
      (json['invitations'] as List<dynamic>?)
          ?.map((e) => TeamInvitation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$TeamRosterToJson(_TeamRoster instance) =>
    <String, dynamic>{
      'members': instance.members.map((e) => e.toJson()).toList(),
      'invitations': instance.invitations.map((e) => e.toJson()).toList(),
    };

_InviteResult _$InviteResultFromJson(Map<String, dynamic> json) =>
    _InviteResult(
      status: json['status'] as String,
      member: json['member'] == null
          ? null
          : TeamMember.fromJson(json['member'] as Map<String, dynamic>),
      invitation: json['invitation'] == null
          ? null
          : TeamInvitation.fromJson(json['invitation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InviteResultToJson(_InviteResult instance) =>
    <String, dynamic>{
      'status': instance.status,
      'member': instance.member?.toJson(),
      'invitation': instance.invitation?.toJson(),
    };

_JoinLink _$JoinLinkFromJson(Map<String, dynamic> json) => _JoinLink(
  enabled: json['enabled'] as bool,
  token: json['token'] as String?,
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  sharePath: json['share_path'] as String?,
);

Map<String, dynamic> _$JoinLinkToJson(_JoinLink instance) => <String, dynamic>{
  'enabled': instance.enabled,
  'token': instance.token,
  'expires_at': instance.expiresAt?.toIso8601String(),
  'share_path': instance.sharePath,
};

_JoinPreview _$JoinPreviewFromJson(Map<String, dynamic> json) => _JoinPreview(
  workspaceName: json['workspace_name'] as String,
  role: json['role'] as String,
  email: json['email'] as String?,
);

Map<String, dynamic> _$JoinPreviewToJson(_JoinPreview instance) =>
    <String, dynamic>{
      'workspace_name': instance.workspaceName,
      'role': instance.role,
      'email': instance.email,
    };
