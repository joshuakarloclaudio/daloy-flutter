import 'package:daloy_flutter/core/prefs/device_prefs.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/auth/domain/auth_session.dart';
import 'package:daloy_flutter/features/auth/domain/auth_user.dart';
import 'package:daloy_flutter/features/search/presentation/search_button.dart';
import 'package:daloy_flutter/features/workspaces/data/workspaces_repository.dart';
import 'package:daloy_flutter/features/workspaces/domain/workspace.dart';
import 'package:daloy_flutter/shared/widgets/daloy_top_bar.dart';
import 'package:daloy_flutter/shell/desktop_shell.dart';
import 'package:daloy_flutter/shell/shell_layout.dart';
import 'package:daloy_flutter/shell/sidebar_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Session extends SessionController {
  @override
  Future<AuthSession?> build() async => const AuthSession(
    token: 't',
    user: AuthUser(id: 1, name: 'Ana Reyes', email: 'ana@example.com'),
    workspaceId: 1,
  );
}

const _window = Size(1280, 820);

Future<(SharedPreferences, List<int>)> _pump(WidgetTester tester, {Map<String, Object>? stored}) async {
  tester.view
    ..physicalSize = _window
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(stored ?? {});
  final prefs = await SharedPreferences.getInstance();
  final selected = <int>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionControllerProvider.overrideWith(_Session.new),
        activeWorkspaceProvider.overrideWith(
          (ref) => Stream.value(const Workspace(id: 1, name: 'Grace Church', role: 'admin')),
        ),
      ],
      child: MaterialApp(
        theme: DaloyTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => DesktopShell(
              currentIndex: selected.isEmpty ? 1 : selected.last,
              onSelect: (i) => setState(() => selected.add(i)),
              avatar: (size, _) => SizedBox.square(dimension: size),
              accessory: const SizedBox.shrink(),
              child: const Scaffold(
                appBar: DaloyTopBar(title: 'Songs', actions: [TopBarSearchButton()]),
                body: SizedBox.expand(key: Key('screen')),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (prefs, selected);
}

double _screenLeft(WidgetTester tester) => tester.getTopLeft(find.byKey(const Key('screen'))).dx;

void main() {
  // Sets the Mac for each test and puts it back before Flutter checks.
  final mac = TargetPlatformVariant.only(TargetPlatform.macOS);

  testWidgets('the Mac is always the desktop shell, however narrow', (tester) async {
    tester.view
      ..physicalSize = const Size(700, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late ShellLayout layout;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          layout = ShellLayout.of(context);
          return const SizedBox();
        },
      ),
    );
    expect(layout, ShellLayout.desktop);
    expect(layout.wide, isTrue);
  }, variant: mac);

  testWidgets('opens with the sidebar beside the screen; Search lives there, not in the bar', (tester) async {
    await _pump(tester);
    expect(_screenLeft(tester), DesktopSidebar.defaultWidth);
    expect(find.text('Grace Church'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Ana Reyes'), findsOneWidget);
    // The bar keeps its title, and leaves out the magnifier.
    expect(find.text('Songs'), findsNWidgets(2));
    expect(find.byIcon(TablerIcons.search), findsOneWidget);
  }, variant: mac);

  testWidgets('a destination selects its branch, and you are at the bottom', (tester) async {
    final (_, selected) = await _pump(tester);
    await tester.tap(find.text('Line-ups'));
    await tester.tap(find.text('Ana Reyes'));
    expect(selected, [2, 3]);
  }, variant: mac);

  testWidgets('⌘\\ collapses to an icon rail, and it is remembered', (tester) async {
    final (prefs, _) = await _pump(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.backslash);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pumpAndSettle();

    expect(_screenLeft(tester), DesktopSidebar.railWidth);
    expect(find.text('Grace Church'), findsNothing);
    expect(find.text('Line-ups'), findsNothing);
    expect(prefs.getBool('daloy.desktop_sidebar_collapsed'), isTrue);

    await tester.tap(find.bySemanticsLabel('Expand sidebar'));
    await tester.pumpAndSettle();
    expect(_screenLeft(tester), DesktopSidebar.defaultWidth);
  }, variant: mac);

  testWidgets('dragging the edge resizes, within limits, and the width is kept', (tester) async {
    final (prefs, _) = await _pump(tester);
    final edge = find.bySemanticsLabel('Resize sidebar');

    await tester.drag(edge, const Offset(60, 0));
    await tester.pumpAndSettle();
    expect(_screenLeft(tester), closeTo(DesktopSidebar.defaultWidth + 60, 20));
    expect(prefs.getDouble('daloy.desktop_sidebar_width'), _screenLeft(tester));

    await tester.drag(edge, const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(_screenLeft(tester), DesktopSidebar.maxWidth);
  }, variant: mac);

  testWidgets('a collapsed sidebar opens collapsed next time', (tester) async {
    await _pump(tester, stored: {'daloy.desktop_sidebar_collapsed': true, 'daloy.desktop_sidebar_width': 300.0});
    expect(_screenLeft(tester), DesktopSidebar.railWidth);
  }, variant: mac);
}
