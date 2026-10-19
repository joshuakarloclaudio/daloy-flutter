import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../workspaces/data/workspaces_repository.dart';
import '../data/team_service.dart';
import '../domain/team_models.dart';

part 'team_actions.g.dart';

/// Changes to the team. Each throws `ApiException` for the screen to show,
/// and refreshes what the screen is looking at when it succeeds.
@Riverpod(keepAlive: true)
class TeamActions extends _$TeamActions {
  @override
  void build() {}

  TeamService get _service => ref.read(teamServiceProvider);

  Future<void> setRole(TeamMember member, String role) async {
    await _service.setRole(member.id, role);
    ref.invalidate(teamRosterProvider);
  }

  Future<void> remove(TeamMember member) async {
    await _service.remove(member.id);
    ref.invalidate(teamRosterProvider);
  }

  Future<InviteResult> invite({required String email, required String role}) async {
    final result = await _service.invite(email: email, role: role);
    ref.invalidate(teamRosterProvider);
    return result;
  }

  Future<void> revokeInvitation(TeamInvitation invitation) async {
    await _service.revokeInvitation(invitation.id);
    ref.invalidate(teamRosterProvider);
  }

  Future<void> rename(String name) async {
    await _service.rename(name.trim());
    await ref.read(workspacesRepositoryProvider).sync();
  }

  Future<void> enableJoinLink() async {
    await _service.enableJoinLink();
    ref.invalidate(workspaceJoinLinkProvider);
  }

  Future<void> revokeJoinLink() async {
    await _service.revokeJoinLink();
    ref.invalidate(workspaceJoinLinkProvider);
  }
}
