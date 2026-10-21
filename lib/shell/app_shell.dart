import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/daloy_theme.dart';
import '../features/app_update/presentation/app_update_sheet.dart';
import '../features/auth/application/session_controller.dart';
import '../features/player/presentation/mini_player.dart';
import '../features/search/presentation/os_search_scope.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/sync/realtime_scope.dart';
import '../features/workspaces/presentation/workspace_switcher.dart';
import 'desktop_menu_bar.dart';
import 'desktop_shell.dart';
import 'floating_tab_bar.dart';
import 'live_session_bar.dart';
import 'nearby_presentation_bar.dart';
import 'primary_action.dart';
import 'shell_layout.dart';
import 'tablet_shell.dart';

const _homeBranch = 0;
const _profileBranch = 3;

/// The app frame around the tab screens: a floating glass tab bar on phones
/// (that folds on scroll, see `floating_tab_bar.dart`), a top tab bar that
/// opens into a sidebar on tablets (`tablet_shell.dart`), and a fixed
/// sidebar on the Mac (`desktop_shell.dart`).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _go(int index) => navigationShell.goBranch(
    index,
    // Tapping the active tab returns to its root.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) => AppUpdateScope(child: _frame(context));

  Widget _frame(BuildContext context) {
    final layout = ShellLayout.of(context);
    // What's playing plays on from tab to tab; a running performance is
    // joinable from every tab (Home has its own card), and so is a
    // teammate's presentation on this Wi-Fi.
    final accessory = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A tablet or the Mac leaves the bottom edge to the bar.
        MiniPlayerBar(safeBottom: layout.wide),
        LiveSessionBar(hidden: navigationShell.currentIndex == _homeBranch),
        const NearbyPresentationBar(),
      ],
    );

    if (layout == ShellLayout.desktop) {
      return _SearchShortcut(
        child: DesktopMenuBar(
          currentIndex: navigationShell.currentIndex,
          child: Scaffold(
            body: RealtimeScope(
              child: OsSearchScope(
                child: DesktopShell(
                  currentIndex: navigationShell.currentIndex,
                  onSelect: _go,
                  avatar: (size, active) => _UserAvatar(active: active, size: size),
                  accessory: accessory,
                  child: navigationShell,
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (layout == ShellLayout.tablet) {
      return _SearchShortcut(
        child: Scaffold(
          body: RealtimeScope(
            child: OsSearchScope(
              child: TabletShell(
                currentIndex: navigationShell.currentIndex,
                onSelect: _go,
                avatar: (size, active) => _UserAvatar(active: active, size: size),
                accessory: accessory,
                child: navigationShell,
              ),
            ),
          ),
        ),
      );
    }
    // The bar steps aside for anything covering the shell: a screen pushed
    // over it (this route no longer current) or a sheet inside a tab.
    final shellOnTop = ModalRoute.isCurrentOf(context) ?? true;
    return _SearchShortcut(
      child: Scaffold(
        // Each tab screen meets the keyboard itself.
        resizeToAvoidBottomInset: false,
        body: RealtimeScope(
          child: OsSearchScope(
            child: ValueListenableBuilder(
              valueListenable: ShellCover.covered,
              builder: (context, covered, _) => Consumer(
                builder: (context, ref, _) => FloatingTabBarScope(
                  currentIndex: navigationShell.currentIndex,
                  visible: shellOnTop && covered == 0,
                  onSelect: _go,
                  onReselect: _go,
                  action: ref.watch(primaryActionsProvider)[navigationShell.currentIndex],
                  youAvatar: _UserAvatar(active: navigationShell.currentIndex == _profileBranch),
                  accessory: accessory,
                  child: navigationShell,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ⌘K / Ctrl+K from anywhere in the shell, as on the web — for an iPad or a
/// tablet with a keyboard. Listens to the hardware keyboard directly, so it
/// works whatever has focus.
class _SearchShortcut extends StatefulWidget {
  const _SearchShortcut({required this.child});

  final Widget child;

  @override
  State<_SearchShortcut> createState() => _SearchShortcutState();
}

class _SearchShortcutState extends State<_SearchShortcut> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.keyK) return false;
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isMetaPressed && !keyboard.isControlPressed) return false;
    // Only while the shell is the top route — not under a song page.
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    openSearch(context);
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _UserAvatar extends ConsumerWidget {
  const _UserAvatar({required this.active, this.size = 24});

  final bool active;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).value?.user;
    final c = context.colors;
    if (user == null) return Icon(TablerIcons.user, size: 22, color: active ? c.primary : c.mutedForeground);
    return Container(
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: active ? c.primary : Colors.transparent, width: 2),
      ),
      child: ClipOval(
        child: SizedBox.square(
          dimension: size - 4,
          child: FittedBox(
            child: WorkspaceAvatar(id: user.id, name: user.name, size: size),
          ),
        ),
      ),
    );
  }
}
