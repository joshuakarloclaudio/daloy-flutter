import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/routes.dart';
import '../core/utils/platform.dart';
import '../features/search/presentation/search_screen.dart';
import 'primary_action.dart';
import 'sidebar_state.dart';

/// The Mac's menu bar while signed in: Settings ⌘, in the app menu, the
/// current tab's create action as File → New ⌘N, the sidebar and full
/// screen under View, and the destinations and Search under Go. Signed
/// out, the default menu from `MainMenu.xib` stands.
///
/// Windows has no menu bar: the same commands are Ctrl shortcuts there
/// (Ctrl+N, Ctrl+1–3, Ctrl+F, Ctrl+,; Ctrl+\ is the shell's).
class DesktopMenuBar extends ConsumerWidget {
  const DesktopMenuBar({super.key, required this.currentIndex, required this.child});

  /// The current tab's `StatefulShellRoute` branch, for its create action.
  final int currentIndex;
  final Widget child;

  static const _destinations = [
    ('Home', Routes.home, LogicalKeyboardKey.digit1),
    ('Songs', Routes.songs, LogicalKeyboardKey.digit2),
    ('Line-ups', Routes.lineUps, LogicalKeyboardKey.digit3),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(primaryActionsProvider)[currentIndex];
    final collapsed = ref.watch(desktopSidebarProvider.select((s) => s.collapsed));
    final router = GoRouter.of(context);
    // Where a create sheet anchors when it comes from the menu bar.
    final top = Rect.fromLTWH(MediaQuery.sizeOf(context).width / 2, 0, 0, 0);

    if (!isMacOS) {
      return _ControlShortcuts(
        bindings: {
          LogicalKeyboardKey.comma: () => router.go(Routes.profile),
          if (action != null) LogicalKeyboardKey.keyN: () => action.onPressed(top),
          for (final (_, route, key) in _destinations) key: () => router.go(route),
          LogicalKeyboardKey.keyF: () => openSearch(context),
        },
        child: child,
      );
    }

    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'Daloy',
          menus: [
            const PlatformMenuItemGroup(members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.about)]),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Settings…',
                  shortcut: const SingleActivator(LogicalKeyboardKey.comma, meta: true),
                  onSelected: () => router.go(Routes.profile),
                ),
              ],
            ),
            const PlatformMenuItemGroup(
              members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.servicesSubmenu)],
            ),
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hide),
                PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.hideOtherApplications),
                PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.showAllApplications),
              ],
            ),
            const PlatformMenuItemGroup(members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit)]),
          ],
        ),
        PlatformMenu(
          label: 'File',
          menus: [
            PlatformMenuItem(
              label: action?.label ?? 'New',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyN, meta: true),
              onSelected: action == null ? null : () => action.onPressed(top),
            ),
          ],
        ),
        PlatformMenu(
          label: 'View',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: collapsed ? 'Show Sidebar' : 'Hide Sidebar',
                  shortcut: const SingleActivator(LogicalKeyboardKey.backslash, meta: true),
                  onSelected: ref.read(desktopSidebarProvider.notifier).toggle,
                ),
              ],
            ),
            const PlatformMenuItemGroup(
              members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.toggleFullScreen)],
            ),
          ],
        ),
        PlatformMenu(
          label: 'Go',
          menus: [
            PlatformMenuItemGroup(
              members: [
                for (final (label, route, key) in _destinations)
                  PlatformMenuItem(
                    label: label,
                    shortcut: SingleActivator(key, meta: true),
                    onSelected: () => router.go(route),
                  ),
              ],
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'Search…',
                  shortcut: const SingleActivator(LogicalKeyboardKey.keyF, meta: true),
                  onSelected: () => openSearch(context),
                ),
              ],
            ),
          ],
        ),
        const PlatformMenu(
          label: 'Window',
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.minimizeWindow),
                PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.zoomWindow),
              ],
            ),
            PlatformMenuItemGroup(
              members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.arrangeWindowsInFront)],
            ),
          ],
        ),
      ],
      child: child,
    );
  }
}

/// Ctrl+[key] from anywhere in the shell, whatever has focus, while the
/// shell is the top route (not under a song page).
class _ControlShortcuts extends StatefulWidget {
  const _ControlShortcuts({required this.bindings, required this.child});

  final Map<LogicalKeyboardKey, VoidCallback> bindings;
  final Widget child;

  @override
  State<_ControlShortcuts> createState() => _ControlShortcutsState();
}

class _ControlShortcutsState extends State<_ControlShortcuts> {
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
    if (event is! KeyDownEvent || !HardwareKeyboard.instance.isControlPressed) return false;
    final command = widget.bindings[event.logicalKey];
    if (command == null || !mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    command();
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
