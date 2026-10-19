import 'package:daloy_flutter/core/prefs/device_prefs.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/auth/domain/auth_session.dart';
import 'package:daloy_flutter/features/auth/domain/auth_user.dart';
import 'package:daloy_flutter/features/auth/presentation/reset_password_screen.dart';
import 'package:daloy_flutter/features/lock/app_lock.dart';
import 'package:daloy_flutter/features/lock/lock_authenticator.dart';
import 'package:daloy_flutter/features/profile/profile_screen.dart';
import 'package:daloy_flutter/features/songs/data/song_detail_repository.dart';
import 'package:daloy_flutter/features/songs/domain/display_prefs.dart';
import 'package:daloy_flutter/features/workspaces/data/workspaces_repository.dart';
import 'package:daloy_flutter/features/workspaces/domain/workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Session extends SessionController {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    token: 't',
    user: AuthUser(id: 1, name: 'Ana Reyes', email: 'ana@example.com'),
    workspaceId: 1,
  );
}

class _FakeAuthenticator implements LockAuthenticator {
  _FakeAuthenticator({this.supported = true, this.succeeds = true});

  bool supported;
  bool succeeds;
  int asked = 0;

  @override
  Future<bool> authenticate(String reason) async {
    asked++;
    return succeeds;
  }

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<String> label() async => 'Face ID';
}

Future<ProviderContainer> _pumpProfile(
  WidgetTester tester, {
  String role = 'admin',
  _FakeAuthenticator? authenticator,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view
    ..physicalSize = const Size(390, 2000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      sessionControllerProvider.overrideWith(_Session.new),
      activeWorkspaceProvider.overrideWith((ref) => Stream.value(Workspace(id: 1, name: 'Grace Church', role: role))),
      chartPrefsProvider.overrideWith((ref) => Stream.value(const ChartPrefs())),
      lockAuthenticatorProvider.overrideWithValue(authenticator ?? _FakeAuthenticator()),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: DaloyTheme.light(), home: const ProfileScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  group('You screen', () {
    testWidgets('lists workspace, preferences, privacy, help and account', (tester) async {
      await _pumpProfile(tester);

      for (final text in [
        'Team',
        'Join a workspace',
        'Appearance',
        'Typeface',
        'Default view',
        'Chord notation',
        'Lock with Face ID',
        'Chord syntax guide',
        'Sign out',
        'Delete account',
      ]) {
        await tester.scrollUntilVisible(find.text(text), 200, scrollable: find.byType(Scrollable).first);
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });

    testWidgets('Team is for admins only', (tester) async {
      await _pumpProfile(tester, role: 'member');

      expect(find.text('Team'), findsNothing);
      expect(find.text('Join a workspace'), findsOneWidget);
    });

    testWidgets('Appearance shows each choice and changing it is remembered at once', (tester) async {
      final container = await _pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Appearance'), 200, scrollable: find.byType(Scrollable).first);

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsWidgets);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(container.read(devicePrefsControllerProvider).themeMode, ThemeMode.dark);
      final stored = await SharedPreferences.getInstance();
      expect(stored.getString('daloy.theme_mode'), 'dark');
    });

    testWidgets('Typeface can be set to the system font', (tester) async {
      final container = await _pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Typeface'), 200, scrollable: find.byType(Scrollable).first);

      await tester.tap(find.text('Typeface'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('System').last /* the sheet is the topmost route */);
      await tester.pumpAndSettle();

      expect(container.read(devicePrefsControllerProvider).font, AppFont.system);
    });

    testWidgets('Chord notation shows the same four chords in both notations', (tester) async {
      await _pumpProfile(tester);
      await tester.scrollUntilVisible(find.text('Chord notation'), 200, scrollable: find.byType(Scrollable).first);

      await tester.tap(find.text('Chord notation'));
      await tester.pumpAndSettle();

      expect(find.text('G'), findsWidgets);
      expect(find.text('Cmaj7'), findsOneWidget);
      expect(find.text('F#dim'), findsOneWidget);
    });
  });

  group('lock switch', () {
    testWidgets('turning it on proves it works first', (tester) async {
      final auth = _FakeAuthenticator();
      final container = await _pumpProfile(tester, authenticator: auth);
      await tester.scrollUntilVisible(find.text('Lock with Face ID'), 200, scrollable: find.byType(Scrollable).first);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(auth.asked, 1);
      expect(container.read(devicePrefsControllerProvider).lockEnabled, isTrue);
      expect(find.text('Ask again'), findsOneWidget);
    });

    testWidgets('a failed check leaves it off', (tester) async {
      final auth = _FakeAuthenticator(succeeds: false);
      final container = await _pumpProfile(tester, authenticator: auth);
      await tester.scrollUntilVisible(find.text('Lock with Face ID'), 200, scrollable: find.byType(Scrollable).first);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(container.read(devicePrefsControllerProvider).lockEnabled, isFalse);
    });

    testWidgets('a phone with no biometrics or passcode says why', (tester) async {
      final auth = _FakeAuthenticator(supported: false);
      final container = await _pumpProfile(tester, authenticator: auth);
      await tester.scrollUntilVisible(find.text('Lock with Face ID'), 200, scrollable: find.byType(Scrollable).first);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(auth.asked, 0);
      expect(container.read(devicePrefsControllerProvider).lockEnabled, isFalse);
      expect(find.textContaining('Set up Face ID'), findsOneWidget);
    });
  });

  group('app lock', () {
    Future<_FakeAuthenticator> pumpLocked(WidgetTester tester, {required bool succeeds, bool signedIn = true}) async {
      SharedPreferences.setMockInitialValues({'daloy.lock_enabled': true});
      final prefs = await SharedPreferences.getInstance();
      final auth = _FakeAuthenticator(succeeds: succeeds);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            sessionControllerProvider.overrideWith(signedIn ? _Session.new : _SignedOut.new),
            lockAuthenticatorProvider.overrideWithValue(auth),
          ],
          child: MaterialApp(
            theme: DaloyTheme.light(),
            home: const AppLock(
              child: Scaffold(body: Center(child: Text('Songs'))),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return auth;
    }

    testWidgets('opens locked, asks at once, and unlocks on success', (tester) async {
      final auth = await pumpLocked(tester, succeeds: true);

      expect(auth.asked, 1);
      expect(find.text('Daloy is locked'), findsNothing);
      expect(find.text('Songs'), findsOneWidget);
    });

    testWidgets('stays locked after a failed check, and can be tried again', (tester) async {
      final auth = await pumpLocked(tester, succeeds: false);

      expect(find.text('Daloy is locked'), findsOneWidget);
      expect(find.text('Unlock with Face ID'), findsOneWidget);

      auth.succeeds = true;
      await tester.tap(find.text('Unlock with Face ID'));
      await tester.pumpAndSettle();

      expect(find.text('Daloy is locked'), findsNothing);
    });

    testWidgets('nobody to protect when signed out', (tester) async {
      final auth = await pumpLocked(tester, succeeds: false, signedIn: false);

      expect(auth.asked, 0);
      expect(find.text('Daloy is locked'), findsNothing);
    });
  });

  group('reset password screen', () {
    Future<void> pumpReset(WidgetTester tester, {String? token, String? email}) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionControllerProvider.overrideWith(_SignedOut.new)],
          child: MaterialApp(
            theme: DaloyTheme.light(),
            home: ResetPasswordScreen(token: token, email: email),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a complete link asks for the new password for that address', (tester) async {
      await pumpReset(tester, token: 'tok', email: 'ana@example.com');

      expect(find.text('Choose a new password'), findsOneWidget);
      expect(find.textContaining('ana@example.com', findRichText: true), findsOneWidget);
      expect(find.text('Update password'), findsOneWidget);
    });

    testWidgets('a broken link offers a new one instead of a form', (tester) async {
      await pumpReset(tester, token: 'tok');

      expect(find.text('This link isn’t complete'), findsOneWidget);
      expect(find.text('Get a new link'), findsOneWidget);
      expect(find.text('Update password'), findsNothing);
    });
  });
}

class _SignedOut extends SessionController {
  @override
  Future<AuthSession?> build() async => null;
}
