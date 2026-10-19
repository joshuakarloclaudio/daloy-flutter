import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_models.freezed.dart';
part 'team_models.g.dart';

/// Roles a member can hold, as the API names them.
abstract final class TeamRole {
  static const admin = 'admin';
  static const member = 'member';

  /// What each role can do, in the words the picker shows.
  static String describe(String role) => role == admin
      ? 'Manages the team, the join link and workspace settings, on top of everything a member does.'
      : 'Sees and edits songs and line-ups, and plays along live.';
}

/// `WorkspaceMemberData`.
@freezed
abstract class TeamMember with _$TeamMember {
  const factory TeamMember({required int id, required String name, required String email, required String role}) =
      _TeamMember;

  factory TeamMember.fromJson(Map<String, dynamic> json) => _$TeamMemberFromJson(json);
}

/// `WorkspaceInvitationData` — an invite that hasn't been accepted yet.
@freezed
abstract class TeamInvitation with _$TeamInvitation {
  const factory TeamInvitation({
    required int id,
    required String email,
    required String role,
    required String invitedByName,
    required DateTime expiresAt,
    required DateTime createdAt,
  }) = _TeamInvitation;

  factory TeamInvitation.fromJson(Map<String, dynamic> json) => _$TeamInvitationFromJson(json);
}

/// `WorkspaceMembersPageData`.
@freezed
abstract class TeamRoster with _$TeamRoster {
  const factory TeamRoster({@Default([]) List<TeamMember> members, @Default([]) List<TeamInvitation> invitations}) =
      _TeamRoster;

  factory TeamRoster.fromJson(Map<String, dynamic> json) => _$TeamRosterFromJson(json);
}

/// `InviteMemberResultData`. [status] is `added` when that email already had
/// an account (they're in at once) or `invited` (an email with a link went out).
@freezed
abstract class InviteResult with _$InviteResult {
  const factory InviteResult({required String status, TeamMember? member, TeamInvitation? invitation}) = _InviteResult;

  const InviteResult._();

  bool get wasAdded => status == 'added';

  factory InviteResult.fromJson(Map<String, dynamic> json) => _$InviteResultFromJson(json);
}

/// `JoinLinkData`. [sharePath] is relative to the public site (`/share/j/…`).
@freezed
abstract class JoinLink with _$JoinLink {
  const factory JoinLink({required bool enabled, String? token, DateTime? expiresAt, String? sharePath}) = _JoinLink;

  const JoinLink._();

  factory JoinLink.fromJson(Map<String, dynamic> json) => _$JoinLinkFromJson(json);
}

/// What a join link or invitation offers, before it's accepted.
/// `InvitationPreviewData` / `JoinLinkPreviewData`.
@freezed
abstract class JoinPreview with _$JoinPreview {
  const factory JoinPreview({required String workspaceName, required String role, String? email}) = _JoinPreview;

  factory JoinPreview.fromJson(Map<String, dynamic> json) => _$JoinPreviewFromJson(json);
}
