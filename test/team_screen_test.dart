import 'package:daloy_flutter/core/network/api_client.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/auth/domain/auth_session.dart';
import 'package:daloy_flutter/features/auth/domain/auth_user.dart';
import 'package:daloy_flutter/features/team/application/join_controller.dart';
import 'package:daloy_flutter/features/team/data/team_service.dart';
import 'package:daloy_flutter/features/team/domain/team_models.dart';
import 'package:daloy_flutter/features/team/presentation/join_screen.dart';
import 'package:daloy_flutter/features/team/presentation/team_screen.dart';
import 'package:daloy_flutter/features/workspaces/data/workspaces_repository.dart';
import 'package:daloy_flutter/features/workspaces/domain/workspace.dart';
import 'package:daloy_flutter/shared/widgets/daloy_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

class _Session extends SessionController {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    token: 't',
    user: AuthUser(id: 1, name: 'Ana Reyes', email: 'ana@example.com'),
    workspaceId: 1,
  );
}

class _SignedOut extends SessionController {
  @override
  Future<AuthSession?> build() async => null;
}

final _roster = TeamRoster(
  members: const [
    TeamMember(id: 1, name: 'Ana Reyes', email: 'ana@example.com', role: 'admin'),
    TeamMember(id: 2, name: 'Ben Cruz', email: 'ben@example.com', role: 'member'),
  ],
  invitations: [
    TeamInvitation(
      id: 9,
      email: 'cara@example.com',
      role: 'member',
      invitedByName: 'Ana Reyes',
      expiresAt: _expires,
      createdAt: _expires,
    ),
  ],
);
final _expires = DateTime.utc(2026, 10, 30);

Future<void> _pumpTeam(
  WidgetTester tester, {
  String role = 'admin',
  JoinLink link = const JoinLink(enabled: false),
}) async {
  tester.view
    ..physicalSize = const Size(390, 1400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionControllerProvider.overrideWith(_Session.new),
        activeWorkspaceProvider.overrideWith((ref) => Stream.value(Workspace(id: 1, name: 'Grace Church', role: role))),
        teamRosterProvider.overrideWith((ref) async => _roster),
        workspaceJoinLinkProvider.overrideWith((ref) async => link),
      ],
      child: MaterialApp(theme: DaloyTheme.light(), home: const TeamScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('an admin sees the people, their roles and the pending invitation', (tester) async {
    await _pumpTeam(tester);

    expect(find.text('Grace Church'), findsOneWidget);
    expect(find.text('2 people'), findsOneWidget);
    expect(find.text('Ana Reyes (you)'), findsOneWidget);
    expect(find.text('Ben Cruz'), findsOneWidget);
    expect(find.text('ADMIN'), findsOneWidget);
    expect(find.text('MEMBER'), findsNWidgets(2)); // Ben and the invitation to Cara
    expect(find.text('cara@example.com'), findsOneWidget);
    expect(find.text('Let people join with a link'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a member is told only admins manage the team', (tester) async {
    await _pumpTeam(tester, role: 'member');

    expect(find.text('Only admins manage the team'), findsOneWidget);
    expect(find.text('Ben Cruz'), findsNothing);
  });

  testWidgets('with the link on it shows the address, how long it works, and the ways to share it', (tester) async {
    await _pumpTeam(
      tester,
      link: JoinLink(enabled: true, token: 'tok', expiresAt: _expires, sharePath: '/share/j/tok'),
    );

    expect(find.text('daloy.pro/share/j/tok'), findsOneWidget);
    expect(find.textContaining('Works until'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
    expect(find.text('QR code'), findsOneWidget);
    expect(find.text('Turn off'), findsOneWidget);
  });

  testWidgets('tapping a member offers both roles, and yourself cannot be demoted or removed', (tester) async {
    await _pumpTeam(tester);

    await tester.tap(find.text('Ana Reyes (you)'));
    await tester.pumpAndSettle();

    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Member'), findsOneWidget);
    expect(find.textContaining('can’t change your own role'), findsOneWidget);
    expect(find.text('Remove from workspace'), findsNothing);
  });

  testWidgets('removing someone asks first and sends the request', (tester) async {
    final api = FakeApiAdapter({'DELETE /api/workspace/members/2': (_) => FakeApiAdapter.ok(null)});
    final dio = Dio()..httpClientAdapter = api;
    tester.view
      ..physicalSize = const Size(390, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith(_Session.new),
          activeWorkspaceProvider.overrideWith(
            (ref) => Stream.value(const Workspace(id: 1, name: 'Grace', role: 'admin')),
          ),
          teamRosterProvider.overrideWith((ref) async => _roster),
          workspaceJoinLinkProvider.overrideWith((ref) async => const JoinLink(enabled: false)),
          teamServiceProvider.overrideWithValue(TeamService(ApiClient(dio))),
        ],
        child: MaterialApp(theme: DaloyTheme.light(), home: const TeamScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ben Cruz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from workspace'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Ben Cruz?'), findsOneWidget);
    expect(api.requests, isEmpty);

    await tester.tap(find.text('Remove'));
    // The request runs on the real event loop, so alternate with frames.
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();

    expect(api.requests.single.method, 'DELETE');
    expect(api.requests.single.path, '/api/workspace/members/2');
  });

  group('join screen', () {
    Future<void> pumpJoin(WidgetTester tester, {required bool signedIn, JoinKind kind = JoinKind.link}) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionControllerProvider.overrideWith(signedIn ? _Session.new : _SignedOut.new),
            joinPreviewProvider.overrideWith((ref, arg) async {
              final (kind, _) = arg;
              return JoinPreview(
                workspaceName: 'Riverside Youth',
                role: kind == JoinKind.link ? 'member' : 'admin',
                email: kind == JoinKind.invitation ? 'ana@example.com' : null,
              );
            }),
          ],
          child: MaterialApp(
            theme: DaloyTheme.light(),
            home: JoinScreen(kind: kind, token: 'tok12345'),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('signed in: names the workspace and offers to join', (tester) async {
      await pumpJoin(tester, signedIn: true);

      expect(find.text('Riverside Youth'), findsWidgets);
      expect(find.text('You’ll join as a member.'), findsOneWidget);
      expect(find.text('Join Riverside Youth'), findsOneWidget);
    });

    testWidgets('signed out: asks to sign in or create an account first', (tester) async {
      await pumpJoin(tester, signedIn: false);

      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
      expect(find.text('Join Riverside Youth'), findsNothing);
    });

    testWidgets('an invitation for another email cannot be accepted from this account', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionControllerProvider.overrideWith(_Session.new),
            joinPreviewProvider.overrideWith(
              (ref, arg) async =>
                  const JoinPreview(workspaceName: 'Riverside Youth', role: 'admin', email: 'someone.else@example.com'),
            ),
          ],
          child: MaterialApp(
            theme: DaloyTheme.light(),
            home: const JoinScreen(kind: JoinKind.invitation, token: 'tok12345'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('someone.else@example.com'), findsOneWidget);
      final join = tester.widget<DaloyButton>(find.widgetWithText(DaloyButton, 'Join Riverside Youth'));
      expect(join.onPressed, isNull);
    });
  });
}
