import 'package:daloy_flutter/core/network/network_providers.dart';
import 'package:daloy_flutter/features/auth/application/auth_form_controllers.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/auth/data/google_sign_in.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

class _FakeGoogle implements GoogleSignIn {
  _FakeGoogle(this.result);

  final Future<String?> Function() result;

  @override
  Future<String?> authorize() => result();
}

final _workspaces = [
  {'id': 7, 'name': 'Riverside Youth', 'role': 'member', 'is_member': true},
];

void main() {
  test('starts signed out with nothing stored', () async {
    final container = await createTestContainer(FakeApiAdapter({}));
    expect(await container.read(sessionControllerProvider.future), isNull);
  });

  test('sign-in persists the session into the store', () async {
    final api = FakeApiAdapter({
      'POST /api/auth/login': (_) => FakeApiAdapter.ok({'user': userJson(), 'token': 'abc'}),
      'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
    });
    final storage = MemoryStorage();
    final container = await createTestContainer(api, storage: storage);
    await container.read(sessionControllerProvider.future);
    container.listen(signInFormProvider, (_, _) {});

    await container.read(signInFormProvider.notifier).submit(email: ' ana@example.com ', password: 'secret');

    final session = container.read(sessionControllerProvider).value!;
    expect(session.token, 'abc');
    expect(session.workspaceId, 1);
    expect(storage.values['daloy.token'], 'abc');
    expect(api.requests.single.data, {'email': 'ana@example.com', 'password': 'secret'});
  });

  test('bad credentials show the API message and stay signed out', () async {
    final api = FakeApiAdapter({'POST /api/auth/login': (_) => FakeApiAdapter.error(401, 'Invalid credentials.')});
    final container = await createTestContainer(api);
    await container.read(sessionControllerProvider.future);
    container.listen(signInFormProvider, (_, _) {});

    await container.read(signInFormProvider.notifier).submit(email: 'ana@example.com', password: 'wrong');

    expect(container.read(signInFormProvider).formError, 'Invalid credentials.');
    expect(container.read(sessionControllerProvider).value, isNull);
  });

  test('sign-in validates before calling the API', () async {
    final api = FakeApiAdapter({});
    final container = await createTestContainer(api);
    container.listen(signInFormProvider, (_, _) {});

    await container.read(signInFormProvider.notifier).submit(email: 'nope', password: '');

    expect(container.read(signInFormProvider).fieldErrors, {
      'email': 'Enter a valid email address',
      'password': 'Password is required',
    });
    expect(api.requests, isEmpty);
  });

  test('register maps 422 field errors onto the form', () async {
    final api = FakeApiAdapter({
      'POST /api/auth/register': (_) => FakeApiAdapter.error(
        422,
        'The email has already been taken.',
        data: {
          'errors': {
            'email': ['The email has already been taken.'],
          },
        },
      ),
    });
    final container = await createTestContainer(api);
    container.listen(registerFormProvider, (_, _) {});

    await container
        .read(registerFormProvider.notifier)
        .submit(name: 'Ana', email: 'ana@example.com', password: 'password1', passwordConfirmation: 'password1');

    expect(container.read(registerFormProvider).fieldErrors, {'email': 'The email has already been taken.'});
  });

  test('a new account without a last workspace lands in its first workspace', () async {
    final api = FakeApiAdapter({
      'POST /api/auth/register': (_) =>
          FakeApiAdapter.ok({'user': userJson(lastWorkspaceId: null), 'token': 'new'}, status: 201),
      'GET /api/workspaces': (_) => FakeApiAdapter.ok(_workspaces),
      'PATCH /api/auth/me/last-workspace': (_) => FakeApiAdapter.ok(userJson(lastWorkspaceId: 7)),
      'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson(lastWorkspaceId: 7)),
    });
    final container = await createTestContainer(api);
    await container.read(sessionControllerProvider.future);
    container.listen(registerFormProvider, (_, _) {});

    await container
        .read(registerFormProvider.notifier)
        .submit(name: 'Ana', email: 'ana@example.com', password: 'password1', passwordConfirmation: 'password1');

    expect(container.read(sessionControllerProvider).value?.workspaceId, 7);
    final workspacesRequest = api.requests.firstWhere((r) => r.path == '/api/workspaces');
    expect(workspacesRequest.headers['Authorization'], 'Bearer new');
  });

  test('Google sign-in trades the exchange key for a session', () async {
    final api = FakeApiAdapter({
      'POST /api/auth/google/exchange': (_) => FakeApiAdapter.ok({'user': userJson(), 'token': 'g-token'}),
      'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
    });
    final container = await createTestContainer(
      api,
      overrides: [googleSignInProvider.overrideWithValue(_FakeGoogle(() async => 'x' * 64))],
    );
    await container.read(sessionControllerProvider.future);
    container.listen(signInFormProvider, (_, _) {});

    await container.read(signInFormProvider.notifier).continueWithGoogle();

    expect(container.read(sessionControllerProvider).value?.token, 'g-token');
    expect(api.requests.first.data, {'exchange': 'x' * 64});
  });

  test('closing the Google sheet is not an error', () async {
    final container = await createTestContainer(
      FakeApiAdapter({}),
      overrides: [googleSignInProvider.overrideWithValue(_FakeGoogle(() async => null))],
    );
    await container.read(sessionControllerProvider.future);
    container.listen(signInFormProvider, (_, _) {});

    await container.read(signInFormProvider.notifier).continueWithGoogle();

    expect(container.read(signInFormProvider), const AuthFormState());
    expect(container.read(sessionControllerProvider).value, isNull);
  });

  test('Google errors from the API callback are shown', () async {
    final container = await createTestContainer(
      FakeApiAdapter({}),
      overrides: [
        googleSignInProvider.overrideWithValue(
          _FakeGoogle(() async => throw GoogleSignInException.fromCode('no_email')),
        ),
      ],
    );
    container.listen(signInFormProvider, (_, _) {});

    await container.read(signInFormProvider.notifier).continueWithGoogle();

    expect(container.read(signInFormProvider).formError, startsWith('Google did not share an email'));
  });

  test('forgot password confirms the address it sent to', () async {
    final api = FakeApiAdapter({'POST /api/auth/forgot-password': (_) => FakeApiAdapter.ok(null)});
    final container = await createTestContainer(api);
    container.listen(forgotPasswordFormProvider, (_, _) {});

    await container.read(forgotPasswordFormProvider.notifier).submit(email: 'ana@example.com');

    expect(container.read(forgotPasswordFormProvider).sentTo, 'ana@example.com');
  });

  test('sign-out clears the store even when the API is unreachable', () async {
    final storage = MemoryStorage()
      ..values.addAll({'daloy.token': 'abc', 'daloy.user': '{"id":1,"name":"Ana","email":"a@b.co"}'});
    final container = await createTestContainer(
      FakeApiAdapter({'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson())}),
      storage: storage,
    );
    expect(await container.read(sessionControllerProvider.future), isNotNull);

    await container.read(sessionControllerProvider.notifier).signOut();

    expect(container.read(sessionControllerProvider).value, isNull);
    expect(storage.values, isEmpty);
    expect(container.read(sessionStoreProvider).token, isNull);
  });
}
