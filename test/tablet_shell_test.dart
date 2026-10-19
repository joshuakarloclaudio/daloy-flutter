import 'package:daloy_flutter/core/prefs/device_prefs.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/auth/domain/auth_session.dart';
import 'package:daloy_flutter/features/auth/domain/auth_user.dart';
import 'package:daloy_flutter/features/search/presentation/search_button.dart';
import 'package:daloy_flutter/features/workspaces/data/workspaces_repository.dart';
import 'package:daloy_flutter/features/workspaces/domain/workspace.dart';
import 'package:daloy_flutter/shared/widgets/daloy_top_bar.dart';
import 'package:daloy_flutter/shell/shell_layout.dart';
import 'package:daloy_flutter/shell/tablet_shell.dart';
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

const _landscape = Size(1194, 834);
const _portrait = Size(834, 1194);

Future<(SharedPreferences, List<int>)> _pump(WidgetTester tester, Size size, {Map<String, Object>? stored}) async {
  tester.view
    ..physicalSize = size
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
            builder: (context, setState) => TabletShell(
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

Finder get _sidebarToggle => find.bySemanticsLabel('Show sidebar');
Finder get _hide => find.bySemanticsLabel('Hide sidebar');

void main() {
  testWidgets('landscape starts with the sidebar beside the screen', (tester) async {
    await _pump(tester, _landscape);
    expect(_hide.hitTestable(), findsOneWidget);
    expect(_sidebarToggle.hitTestable(), findsNothing);
    // The screen starts where the docked sidebar ends, and its bar shows its own title.
    expect(tester.getTopLeft(find.byKey(const Key('screen'))).dx, TabletShell.sidebarWidth);
    expect(find.text('Songs').hitTestable(), findsWidgets);
    expect(find.text('Grace Church'), findsOneWidget);
  });

  testWidgets('a phone on its side keeps the phone shell; an iPad gets the tablet one', (tester) async {
    Future<ShellLayout> layoutAt(Size size) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      late ShellLayout layout;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            layout = ShellLayout.of(context);
            return const SizedBox();
          },
        ),
      );
      return layout;
    }

    addTearDown(tester.view.reset);
    expect(await layoutAt(const Size(956, 440)), ShellLayout.phone);
    expect(await layoutAt(const Size(440, 956)), ShellLayout.phone);
    expect(await layoutAt(_landscape), ShellLayout.tablet);
    expect(await layoutAt(_portrait), ShellLayout.tablet);
    // An iPad squeezed narrow in Split View.
    expect(await layoutAt(const Size(375, 1024)), ShellLayout.phone);
  });

  testWidgets('portrait starts with the top tab bar, and the bar keeps clear of it', (tester) async {
    await _pump(tester, _portrait);
    expect(_sidebarToggle.hitTestable(), findsOneWidget);
    expect(find.bySemanticsLabel('Line-ups').hitTestable(), findsOneWidget);
    expect(tester.getTopLeft(find.byKey(const Key('screen'))).dx, 0);
    // The tabs own the bar row: no inline title, no second magnifier.
    expect(find.byType(TopBarSearchButton), findsOneWidget);
    expect(find.byTooltip('Search'), findsNothing);
  });

  testWidgets('a tab in the capsule selects its branch', (tester) async {
    final (_, selected) = await _pump(tester, _portrait);
    await tester.tap(find.bySemanticsLabel('Line-ups').hitTestable());
    await tester.pumpAndSettle();
    expect(selected, [2]);
  });

  testWidgets('in portrait the sidebar floats over the screen and a tap outside closes it', (tester) async {
    final (prefs, selected) = await _pump(tester, _portrait);
    await tester.tap(_sidebarToggle);
    await tester.pumpAndSettle();
    expect(_hide.hitTestable(), findsOneWidget);
    // Over the screen, not beside it.
    expect(tester.getTopLeft(find.byKey(const Key('screen'))).dx, 0);
    expect(prefs.getBool('daloy.sidebar_open_portrait'), isTrue);

    await tester.tapAt(const Offset(700, 600));
    await tester.pumpAndSettle();
    expect(_hide.hitTestable(), findsNothing);
    expect(selected, isEmpty);
    expect(prefs.getBool('daloy.sidebar_open_portrait'), isFalse);
  });

  testWidgets('hiding the sidebar is remembered for the orientation', (tester) async {
    final (prefs, _) = await _pump(tester, _landscape);
    await tester.tap(_hide);
    await tester.pumpAndSettle();
    expect(_sidebarToggle.hitTestable(), findsOneWidget);
    expect(prefs.getBool('daloy.sidebar_open_landscape'), isFalse);
    expect(prefs.getBool('daloy.sidebar_open_portrait'), isNull);
  });

  testWidgets('a closed landscape sidebar stays closed next time', (tester) async {
    await _pump(tester, _landscape, stored: {'daloy.sidebar_open_landscape': false});
    expect(_sidebarToggle.hitTestable(), findsOneWidget);
  });
}
