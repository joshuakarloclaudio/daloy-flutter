import 'package:daloy_flutter/core/network/api_exception.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/team/application/join_controller.dart';
import 'package:daloy_flutter/features/team/application/team_actions.dart';
import 'package:daloy_flutter/features/team/data/team_service.dart';
import 'package:daloy_flutter/features/team/domain/team_models.dart';
import 'package:daloy_flutter/features/workspaces/data/workspaces_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

Map<String, dynamic> _member(int id, String name, String role) => {
  'id': id,
  'name': name,
  'email': '${name.toLowerCase()}@example.com',
  'role': role,
};

Map<String, dynamic> _invitation(int id, String email) => {
  'id': id,
  'email': email,
  'role': 'member',
  'invited_by_name': 'Ana',
  'expires_at': '2026-10-30T00:00:00+00:00',
  'created_at': '2026-10-16T00:00:00+00:00',
};

MemoryStorage _signedIn() => MemoryStorage()
  ..values.addAll({
    'daloy.token': 'abc',
    'daloy.workspace_id': '1',
    'daloy.user': '{"id":1,"name":"Ana","email":"ana@example.com"}',
  });

void main() {
  group('roster', () {
    test('lists members and pending invitations in the API shape', () async {
      final api = FakeApiAdapter({
        'GET /api/workspace/members': (_) => FakeApiAdapter.ok({
          'members': [_member(1, 'Ana', 'admin'), _member(2, 'Ben', 'member')],
          'invitations': [_invitation(9, 'cara@example.com')],
        }),
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);

      final roster = await container.read(teamRosterProvider.future);

      expect(roster.members.map((m) => (m.name, m.role)), [('Ana', 'admin'), ('Ben', 'member')]);
      expect(roster.invitations.single.email, 'cara@example.com');
      expect(roster.invitations.single.invitedByName, 'Ana');
      expect(api.requests.firstWhere((r) => r.path == '/api/workspace/members').headers['X-Workspace-ID'], '1');
    });

    test('changing a role and removing a member go to the right endpoints and refresh the roster', () async {
      var loads = 0;
      final api = FakeApiAdapter({
        'GET /api/workspace/members': (_) {
          loads++;
          return FakeApiAdapter.ok({
            'members': [_member(2, 'Ben', 'member')],
            'invitations': [],
          });
        },
        'PATCH /api/workspace/members/2': (_) => FakeApiAdapter.ok(_member(2, 'Ben', 'admin')),
        'DELETE /api/workspace/members/2': (_) => FakeApiAdapter.ok(null),
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);
      container.listen(teamRosterProvider, (_, _) {});
      final ben = (await container.read(teamRosterProvider.future)).members.single;

      await container.read(teamActionsProvider.notifier).setRole(ben, TeamRole.admin);
      await container.read(teamRosterProvider.future);
      await container.read(teamActionsProvider.notifier).remove(ben);
      await container.read(teamRosterProvider.future);

      expect(api.requests.firstWhere((r) => r.method == 'PATCH').data, {'role': 'admin'});
      expect(api.requests.where((r) => r.method == 'DELETE'), hasLength(1));
      expect(loads, 3);
    });

    test('the server refusing to demote the last admin surfaces its message', () async {
      final api = FakeApiAdapter({
        'PATCH /api/workspace/members/1': (_) => FakeApiAdapter.error(
          422,
          'Invalid',
          data: {
            'errors': {
              'member': ['The workspace must have at least one admin.'],
            },
          },
        ),
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);

      Object? error;
      try {
        await container
            .read(teamActionsProvider.notifier)
            .setRole(TeamMember.fromJson(_member(1, 'Ana', 'admin')), TeamRole.member);
      } on ApiException catch (e) {
        error = e;
      }

      expect(apiErrorMessage(error!), 'The workspace must have at least one admin.');
    });
  });

  group('invitations', () {
    test('inviting by email tells apart "invited" from "added straight away"', () async {
      final api = FakeApiAdapter({
        'POST /api/workspace/invitations': (r) {
          final email = (r.data as Map)['email'];
          return email == 'ben@example.com'
              ? FakeApiAdapter.ok({'status': 'added', 'member': _member(2, 'Ben', 'member')}, status: 201)
              : FakeApiAdapter.ok({'status': 'invited', 'invitation': _invitation(9, email as String)}, status: 201);
        },
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);
      final actions = container.read(teamActionsProvider.notifier);

      final added = await actions.invite(email: 'ben@example.com', role: TeamRole.member);
      final invited = await actions.invite(email: 'cara@example.com', role: TeamRole.admin);

      expect(added.wasAdded, isTrue);
      expect(added.member?.name, 'Ben');
      expect(invited.wasAdded, isFalse);
      expect(invited.invitation?.email, 'cara@example.com');
      expect(api.requests.where((r) => r.method == 'POST').last.data, {'email': 'cara@example.com', 'role': 'admin'});
    });

    test('revoking deletes the invitation', () async {
      final api = FakeApiAdapter({
        'DELETE /api/workspace/invitations/9': (_) => FakeApiAdapter.ok(null),
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);

      await container
          .read(teamActionsProvider.notifier)
          .revokeInvitation(TeamInvitation.fromJson(_invitation(9, 'cara@example.com')));

      expect(api.requests.where((r) => r.method == 'DELETE').single.path, '/api/workspace/invitations/9');
    });
  });

  group('join link', () {
    test('off, then on with a shareable address, then off again', () async {
      var enabled = false;
      Map<String, dynamic> link() => enabled
          ? {'enabled': true, 'token': 'tok', 'expires_at': '2026-10-23T00:00:00+00:00', 'share_path': '/share/j/tok'}
          : {'enabled': false, 'token': null, 'expires_at': null, 'share_path': null};
      final api = FakeApiAdapter({
        'GET /api/workspace/join-link': (_) => FakeApiAdapter.ok(link()),
        'POST /api/workspace/join-link': (_) {
          enabled = true;
          return FakeApiAdapter.ok(link());
        },
        'DELETE /api/workspace/join-link': (_) {
          enabled = false;
          return FakeApiAdapter.ok(link());
        },
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);
      container.listen(workspaceJoinLinkProvider, (_, _) {});
      final actions = container.read(teamActionsProvider.notifier);

      expect((await container.read(workspaceJoinLinkProvider.future)).enabled, isFalse);

      await actions.enableJoinLink();
      final on = await container.read(workspaceJoinLinkProvider.future);
      expect(on.enabled, isTrue);
      expect(TeamService.joinUrl(on), 'https://daloy.pro/share/j/tok');

      await actions.revokeJoinLink();
      expect((await container.read(workspaceJoinLinkProvider.future)).enabled, isFalse);
    });
  });

  group('joining', () {
    test('previews a join link without signing in, and an invitation with its email', () async {
      final api = FakeApiAdapter({
        'GET /api/join-links/tok': (_) => FakeApiAdapter.ok({'workspace_name': 'Grace', 'role': 'member'}),
        'GET /api/invitations/inv': (_) =>
            FakeApiAdapter.ok({'workspace_name': 'Grace', 'role': 'admin', 'email': 'ana@example.com'}),
      });
      final container = await createTestContainer(api);

      final link = await container.read(joinPreviewProvider(JoinKind.link, 'tok').future);
      final invite = await container.read(joinPreviewProvider(JoinKind.invitation, 'inv').future);

      expect((link.workspaceName, link.role, link.email), ('Grace', 'member', null));
      expect((invite.role, invite.email), ('admin', 'ana@example.com'));
    });

    test('an expired link is reported as gone', () async {
      final api = FakeApiAdapter({
        'GET /api/join-links/old': (_) => FakeApiAdapter.error(404, 'Join link not found or expired.'),
      });
      final container = await createTestContainer(api);

      Object? error;
      try {
        await container.read(joinPreviewProvider(JoinKind.link, 'old').future);
      } on Object catch (e) {
        error = e;
      }

      expect(isLinkGone(error!), isTrue);
    });

    test('joining switches into the workspace', () async {
      final api = FakeApiAdapter({
        'POST /api/join-links/tok/accept': (_) =>
            FakeApiAdapter.ok({'id': 7, 'name': 'Grace', 'role': 'member', 'is_member': true}),
        'GET /api/workspaces': (_) => FakeApiAdapter.ok([
          {'id': 1, 'name': 'Home', 'role': 'admin', 'is_member': true},
          {'id': 7, 'name': 'Grace', 'role': 'member', 'is_member': true},
        ]),
        'PATCH /api/auth/me/last-workspace': (_) => FakeApiAdapter.ok(userJson(lastWorkspaceId: 7)),
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);

      final workspace = await container.read(joinActionsProvider.notifier).join(JoinKind.link, 'tok');

      expect(workspace.name, 'Grace');
      expect(container.read(activeWorkspaceIdProvider), 7);
      expect((await container.read(workspacesRepositoryProvider).watch(7).first)?.role, 'member');
    });
  });
}
