import 'package:daloy_flutter/core/network/api_exception.dart';
import 'package:daloy_flutter/core/prefs/device_prefs.dart';
import 'package:daloy_flutter/features/auth/application/auth_form_controllers.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/profile/application/account_deletion.dart';
import 'package:daloy_flutter/features/profile/application/preferences_actions.dart';
import 'package:daloy_flutter/features/songs/chart/nashville.dart';
import 'package:daloy_flutter/features/songs/data/song_detail_repository.dart';
import 'package:daloy_flutter/features/songs/domain/display_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

MemoryStorage _signedIn() => MemoryStorage()
  ..values.addAll({
    'daloy.token': 'abc',
    'daloy.workspace_id': '1',
    'daloy.user': '{"id":1,"name":"Ana","email":"ana@example.com"}',
  });

void main() {
  group('preferences that follow the account', () {
    test('default view changes the device at once and then the account', () async {
      final api = FakeApiAdapter({
        'PATCH /api/auth/me/preferred-view': (_) => FakeApiAdapter.ok({...userJson(), 'preferred_view': 'lyrics'}),
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);
      container.listen(chartPrefsProvider, (_, _) {});

      await container.read(preferencesActionsProvider.notifier).setDefaultView(SongViewMode.lyrics);

      expect((await container.read(chartPrefsProvider.future)).viewMode, SongViewMode.lyrics);
      expect(api.requests.firstWhere((r) => r.method == 'PATCH').data, {'preferred_view': 'lyrics'});
      expect(container.read(sessionControllerProvider).value!.user.preferredView, 'lyrics');
    });

    test('offline, the device still changes and nothing throws', () async {
      final api = FakeApiAdapter({
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
        'PATCH /api/auth/me/chord-notation': (_) => FakeApiAdapter.error(503, 'Down'),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);
      container.listen(chartPrefsProvider, (_, _) {});

      await container.read(preferencesActionsProvider.notifier).setNotation(ChordNotation.numbers);

      expect((await container.read(chartPrefsProvider.future)).notation, ChordNotation.numbers);
    });
  });

  group('device preferences', () {
    test('start from the defaults', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = await createTestContainer(
        FakeApiAdapter({}),
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      expect(container.read(devicePrefsControllerProvider), const DevicePrefs());
    });

    test('theme, typeface and lock survive a restart', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final first = await createTestContainer(
        FakeApiAdapter({}),
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      first.read(devicePrefsControllerProvider.notifier)
        ..setThemeMode(ThemeMode.dark)
        ..setFont(AppFont.system)
        ..setLockEnabled(true)
        ..setLockDelay(LockDelay.immediately);

      final second = await createTestContainer(
        FakeApiAdapter({}),
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );

      final restored = second.read(devicePrefsControllerProvider);
      expect(restored.themeMode, ThemeMode.dark);
      expect(restored.font, AppFont.system);
      expect(restored.lockEnabled, isTrue);
      expect(restored.lockDelay, LockDelay.immediately);
    });

    test('they are not wiped by signing out', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final api = FakeApiAdapter({
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
        'POST /api/auth/logout': (_) => FakeApiAdapter.ok(null),
      });
      final container = await createTestContainer(
        api,
        storage: _signedIn(),
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      await container.read(sessionControllerProvider.future);
      container.read(devicePrefsControllerProvider.notifier).setThemeMode(ThemeMode.light);

      await container.read(sessionControllerProvider.notifier).signOut();

      expect(container.read(devicePrefsControllerProvider).themeMode, ThemeMode.light);
    });
  });

  group('reset password', () {
    test('sends the emailed token and the new password', () async {
      final api = FakeApiAdapter({'POST /api/auth/reset-password': (_) => FakeApiAdapter.ok(null)});
      final container = await createTestContainer(api);
      container.listen(resetPasswordFormProvider, (_, _) {});

      await container
          .read(resetPasswordFormProvider.notifier)
          .submit(
            token: 'tok',
            email: 'ana@example.com',
            password: 'new-secret-1',
            passwordConfirmation: 'new-secret-1',
          );

      expect(container.read(resetPasswordFormProvider).sentTo, 'ana@example.com');
      expect(api.requests.single.data, {
        'token': 'tok',
        'email': 'ana@example.com',
        'password': 'new-secret-1',
        'password_confirmation': 'new-secret-1',
      });
    });

    test('checks length and match before calling the API', () async {
      final api = FakeApiAdapter({});
      final container = await createTestContainer(api);
      container.listen(resetPasswordFormProvider, (_, _) {});

      await container
          .read(resetPasswordFormProvider.notifier)
          .submit(token: 'tok', email: 'a@b.co', password: 'short', passwordConfirmation: 'different');

      expect(
        container.read(resetPasswordFormProvider).fieldErrors.keys,
        containsAll(['password', 'password_confirmation']),
      );
      expect(api.requests, isEmpty);
    });

    test('an expired link shows the server message', () async {
      final api = FakeApiAdapter({
        'POST /api/auth/reset-password': (_) =>
            FakeApiAdapter.error(422, 'This password reset link is invalid or has expired.'),
      });
      final container = await createTestContainer(api);
      container.listen(resetPasswordFormProvider, (_, _) {});

      await container
          .read(resetPasswordFormProvider.notifier)
          .submit(token: 'old', email: 'a@b.co', password: 'new-secret-1', passwordConfirmation: 'new-secret-1');

      expect(
        container.read(resetPasswordFormProvider).formError,
        'This password reset link is invalid or has expired.',
      );
      expect(container.read(resetPasswordFormProvider).sentTo, isNull);
    });
  });

  group('delete account', () {
    test('the preview says what goes and what blocks', () async {
      final api = FakeApiAdapter({
        'GET /api/auth/me/deletion-preview': (_) => FakeApiAdapter.ok({
          'requires_password': true,
          'can_delete': false,
          'blocking': [
            {'id': 3, 'name': 'Grace'},
          ],
          'will_delete': [
            {'id': 9, 'name': 'Solo'},
          ],
        }),
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);

      final preview = await container.read(accountDeletionPreviewProvider.future);

      expect(preview.canDelete, isFalse);
      expect(preview.requiresPassword, isTrue);
      expect(preview.blocking.single.name, 'Grace');
      expect(preview.willDelete.single.name, 'Solo');
    });

    test('deleting sends the password, then leaves like a sign-out and clears local data', () async {
      final api = FakeApiAdapter({
        'DELETE /api/auth/me': (_) => FakeApiAdapter.ok(null),
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final storage = _signedIn();
      final osIndex = FakeOsSearchIndex();
      final container = await createTestContainer(api, storage: storage, osSearchIndex: osIndex);
      await container.read(sessionControllerProvider.future);

      await container.read(sessionControllerProvider.notifier).deleteAccount(password: 'secret-pass-1');

      expect(api.requests.firstWhere((r) => r.method == 'DELETE').data, {'password': 'secret-pass-1'});
      expect(container.read(sessionControllerProvider).value, isNull);
      expect(storage.values['daloy.token'], isNull);
      expect(osIndex.clears, 1);
    });

    test('a Google-only account confirms with its email instead', () async {
      final api = FakeApiAdapter({
        'DELETE /api/auth/me': (_) => FakeApiAdapter.ok(null),
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final container = await createTestContainer(api, storage: _signedIn());
      await container.read(sessionControllerProvider.future);

      await container.read(sessionControllerProvider.notifier).deleteAccount(confirmEmail: 'ana@example.com');

      expect(api.requests.firstWhere((r) => r.method == 'DELETE').data, {'confirm_email': 'ana@example.com'});
    });

    test('a wrong password keeps the account and the session', () async {
      final api = FakeApiAdapter({
        'DELETE /api/auth/me': (_) => FakeApiAdapter.error(
          422,
          'Invalid',
          data: {
            'errors': {
              'password': ['That password is not correct.'],
            },
          },
        ),
        'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      });
      final storage = _signedIn();
      final container = await createTestContainer(api, storage: storage);
      await container.read(sessionControllerProvider.future);

      Object? error;
      try {
        await container.read(sessionControllerProvider.notifier).deleteAccount(password: 'nope');
      } on ApiException catch (e) {
        error = e;
      }

      expect(apiErrorMessage(error!), 'That password is not correct.');
      expect(container.read(sessionControllerProvider).value, isNotNull);
      expect(storage.values['daloy.token'], 'abc');
    });
  });
}
