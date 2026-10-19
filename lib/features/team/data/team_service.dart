import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';
import '../../auth/application/session_controller.dart';
import '../../workspaces/domain/workspace.dart';
import '../domain/team_models.dart';

part 'team_service.g.dart';

/// Workspace members, invitations and the join link (admin-only except for
/// the previews and accepting). Online-only: the team isn't kept offline.
class TeamService {
  const TeamService(this._api);

  final ApiClient _api;

  Future<TeamRoster> roster() => _api.get('/api/workspace/members', Decode.object(TeamRoster.fromJson));

  Future<TeamMember> setRole(int userId, String role) =>
      _api.patch('/api/workspace/members/$userId', Decode.object(TeamMember.fromJson), body: {'role': role});

  Future<void> remove(int userId) => _api.delete('/api/workspace/members/$userId');

  Future<InviteResult> invite({required String email, required String role}) => _api.post(
    '/api/workspace/invitations',
    Decode.object(InviteResult.fromJson),
    body: {'email': email, 'role': role},
  );

  Future<void> revokeInvitation(int id) => _api.delete('/api/workspace/invitations/$id');

  Future<void> rename(String name) => _api.patch('/api/workspace', (_) {}, body: {'name': name});

  Future<JoinLink> joinLink() => _api.get('/api/workspace/join-link', Decode.object(JoinLink.fromJson));

  Future<JoinLink> enableJoinLink() => _api.post('/api/workspace/join-link', Decode.object(JoinLink.fromJson));

  Future<void> revokeJoinLink() => _api.delete('/api/workspace/join-link');

  // -- Joining (any signed-in user; the previews need no sign-in at all) ---

  Future<JoinPreview> previewInvitation(String token) =>
      _api.get('/api/invitations/${Uri.encodeComponent(token)}', Decode.object(JoinPreview.fromJson));

  Future<Workspace> acceptInvitation(String token) =>
      _api.post('/api/invitations/${Uri.encodeComponent(token)}/accept', Decode.object(Workspace.fromJson));

  Future<JoinPreview> previewJoinLink(String token) =>
      _api.get('/api/join-links/${Uri.encodeComponent(token)}', Decode.object(JoinPreview.fromJson));

  Future<Workspace> joinWithLink(String token) =>
      _api.post('/api/join-links/${Uri.encodeComponent(token)}/accept', Decode.object(Workspace.fromJson));

  /// The address people open, or scan, to join through the link.
  static String joinUrl(JoinLink link) => '${AppConfig.siteUrl}${link.sharePath ?? '/share/j/${link.token}'}';
}

@Riverpod(keepAlive: true)
TeamService teamService(Ref ref) => TeamService(ref.watch(apiClientProvider));

/// Members and pending invitations of the active workspace.
@riverpod
Future<TeamRoster> teamRoster(Ref ref) {
  ref.watch(activeWorkspaceIdProvider);
  return ref.watch(teamServiceProvider).roster();
}

@riverpod
Future<JoinLink> workspaceJoinLink(Ref ref) {
  ref.watch(activeWorkspaceIdProvider);
  return ref.watch(teamServiceProvider).joinLink();
}
