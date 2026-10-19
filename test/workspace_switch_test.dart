import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/workspaces/data/workspaces_repository.dart';
import 'package:daloy_flutter/features/workspaces/presentation/workspace_switcher.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

void main() {
  test('switching workspace updates the active workspace', () async {
    final storage = MemoryStorage()
      ..values.addAll({
        'daloy.token': 'abc',
        'daloy.workspace_id': '1',
        'daloy.user': '{"id":1,"name":"Ana","email":"a@b.co"}',
      });
    final container = await createTestContainer(
      FakeApiAdapter({'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson())}),
      storage: storage,
    );
    final db = container.read(appDatabaseProvider);
    for (final (id, name) in [(1, 'First Church'), (2, 'Second Church')]) {
      await db.into(db.workspaces).insert(WorkspacesCompanion.insert(id: Value(id), name: name, role: 'admin'));
    }
    await container.read(sessionControllerProvider.future);

    final names = <String?>[];
    container.listen(activeWorkspaceProvider, (_, next) => names.add(next.value?.name), fireImmediately: true);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(container.read(activeWorkspaceProvider).value?.name, 'First Church');

    await container.read(sessionControllerProvider.notifier).selectWorkspace(2);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(container.read(activeWorkspaceIdProvider), 2);
    expect(container.read(activeWorkspaceProvider).value?.name, 'Second Church', reason: 'emitted: $names');
  });

  testWidgets('the heading shows the workspace picked in the switcher', (tester) async {
    final container = await tester.runAsync(() async {
      final storage = MemoryStorage()
        ..values.addAll({
          'daloy.token': 'abc',
          'daloy.workspace_id': '1',
          'daloy.user': '{"id":1,"name":"Ana","email":"a@b.co"}',
        });
      final container = await createTestContainer(
        FakeApiAdapter({'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson())}),
        storage: storage,
      );
      final db = container.read(appDatabaseProvider);
      for (final (id, name) in [(1, 'First Church'), (2, 'Second Church')]) {
        await db.into(db.workspaces).insert(WorkspacesCompanion.insert(id: Value(id), name: name, role: 'admin'));
      }
      await container.read(sessionControllerProvider.future);
      return container;
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container!,
        child: MaterialApp(
          theme: DaloyTheme.light(),
          home: Scaffold(appBar: AppBar(title: const WorkspaceSwitcherHeading())),
        ),
      ),
    );
    Future<void> settle() async {
      for (var i = 0; i < 5; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pumpAndSettle();
      }
    }

    await settle();
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('First Church')), findsOneWidget);

    await tester.tap(find.byType(WorkspaceSwitcherHeading));
    await settle();
    await tester.tap(find.text('Second Church'));
    await settle();

    expect(container.read(activeWorkspaceIdProvider), 2);
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Second Church')), findsOneWidget);
  });
}
