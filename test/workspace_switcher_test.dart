import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/workspaces/data/workspaces_repository.dart';
import 'package:daloy_flutter/features/workspaces/domain/workspace.dart';
import 'package:daloy_flutter/features/workspaces/presentation/workspace_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a long workspace list scrolls and filters without overflowing', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final workspaces = [
      for (var i = 1; i <= 40; i++)
        Workspace(id: i, name: 'Church ${i.toString().padLeft(2, '0')}', role: 'superadmin'),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workspacesProvider.overrideWith((ref) => Stream.value(workspaces)),
          activeWorkspaceIdProvider.overrideWith((ref) => 30),
        ],
        child: MaterialApp(
          theme: DaloyTheme.light(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(onPressed: () => showWorkspaceSwitcher(context), child: const Text('open')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Opens scrolled to the active workspace; header and action stay pinned.
    expect(find.text('Church 30'), findsOneWidget);
    expect(find.text('Church 01'), findsNothing);
    expect(find.text('Workspaces'), findsOneWidget);
    expect(find.text('New workspace'), findsOneWidget);
    expect(find.text('Platform admin'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'church 0');
    await tester.pumpAndSettle();
    expect(find.text('Church 05'), findsOneWidget);
    expect(find.text('Church 30'), findsNothing);

    await tester.enterText(find.byType(TextField), 'nope');
    await tester.pumpAndSettle();
    expect(find.textContaining('No workspace matches'), findsOneWidget);
  });
}
