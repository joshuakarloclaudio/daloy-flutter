import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/workspaces/application/create_workspace_controller.dart';
import 'package:daloy_flutter/features/workspaces/data/workspaces_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

/// Signed in as a user with no workspace yet.
MemoryStorage _signedInWithoutWorkspace() =>
    MemoryStorage()..values.addAll({'daloy.token': 'abc', 'daloy.user': '{"id":1,"name":"Ana","email":"a@b.co"}'});

void main() {
  test('creates the workspace, caches it and switches into it', () async {
    final api = FakeApiAdapter({
      'POST /api/workspaces': (r) => FakeApiAdapter.ok({'id': 42, 'name': 'Grace Church'}, status: 201),
      'PATCH /api/auth/me/last-workspace': (_) => FakeApiAdapter.ok(userJson(lastWorkspaceId: 42)),
      'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson(lastWorkspaceId: null)),
    });
    final storage = _signedInWithoutWorkspace();
    final container = await createTestContainer(api, storage: storage);
    expect((await container.read(sessionControllerProvider.future))?.workspaceId, isNull);
    container.listen(createWorkspaceProvider, (_, _) {});

    final created = await container.read(createWorkspaceProvider.notifier).submit('  Grace Church ');

    expect(created, isTrue);
    expect(api.requests.firstWhere((r) => r.path == '/api/workspaces').data, {'name': 'Grace Church'});
    expect(container.read(activeWorkspaceIdProvider), 42);
    expect(storage.values['daloy.workspace_id'], '42');
    final cached = await container.read(workspacesRepositoryProvider).watch(42).first;
    expect(cached?.role, 'admin');
  });

  test('a blank name never reaches the API', () async {
    final api = FakeApiAdapter({});
    final container = await createTestContainer(api);
    container.listen(createWorkspaceProvider, (_, _) {});

    expect(await container.read(createWorkspaceProvider.notifier).submit('   '), isFalse);
    expect(container.read(createWorkspaceProvider).error, 'Give your workspace a name.');
    expect(api.requests, isEmpty);
  });

  test('shows the API validation message for the name', () async {
    final api = FakeApiAdapter({
      'POST /api/workspaces': (_) => FakeApiAdapter.error(
        422,
        'Invalid',
        data: {
          'errors': {
            'name': ['The name field is required.'],
          },
        },
      ),
      'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson(lastWorkspaceId: null)),
    });
    final container = await createTestContainer(api, storage: _signedInWithoutWorkspace());
    await container.read(sessionControllerProvider.future);
    container.listen(createWorkspaceProvider, (_, _) {});

    expect(await container.read(createWorkspaceProvider.notifier).submit('X'), isFalse);
    expect(container.read(createWorkspaceProvider).error, 'The name field is required.');
    expect(container.read(activeWorkspaceIdProvider), isNull);
  });
}
