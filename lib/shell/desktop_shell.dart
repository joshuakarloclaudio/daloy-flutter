import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/theme/daloy_theme.dart';
import '../core/utils/platform.dart';
import '../features/auth/application/session_controller.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/workspaces/data/workspaces_repository.dart';
import '../features/workspaces/presentation/workspace_switcher.dart';
import '../shared/widgets/daloy_icon.dart';
import '../shared/widgets/daloy_top_bar.dart';
import 'sidebar_state.dart';
import 'tablet_shell.dart' show tabletTabs;

const _profileBranch = 3;

/// The desktop's frame (the Mac, Windows), after the web's desktop shell: a
/// flat sidebar on the left (workspace, Search ⌘K, the destinations, you at
/// the bottom) and the screen beside it. ⌘\ (Ctrl+\ on Windows) collapses it
/// to an icon rail; its edge drags to
/// resize, clicks to collapse and double-clicks back to the default width.
/// Search lives here, so tab screens leave out their magnifier
/// ([TabletChrome]), and their bars keep their titles.
class DesktopShell extends ConsumerStatefulWidget {
  const DesktopShell({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.avatar,
    required this.accessory,
    required this.child,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  /// The signed-in person's avatar at a given size, ringed when [active].
  final Widget Function(double size, bool active) avatar;

  /// Docked under the screen (now playing, live now).
  final Widget accessory;
  final Widget child;

  @override
  ConsumerState<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends ConsumerState<DesktopShell> {
  bool _resizing = false;

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
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.backslash) return false;
    final keyboard = HardwareKeyboard.instance;
    if (!(isMacOS ? keyboard.isMetaPressed : keyboard.isControlPressed)) return false;
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    ref.read(desktopSidebarProvider.notifier).toggle();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final sidebar = ref.watch(desktopSidebarProvider);
    final collapsed = sidebar.collapsed;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final notifier = ref.read(desktopSidebarProvider.notifier);
    final width = collapsed ? DesktopSidebar.railWidth : sidebar.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: _resizing || reduceMotion ? Duration.zero : DaloyMotion.medium,
          curve: DaloyMotion.ease,
          width: width,
          child: Stack(
            children: [
              Positioned.fill(
                child: _Sidebar(
                  width: width,
                  collapsed: collapsed,
                  currentIndex: widget.currentIndex,
                  onSelect: widget.onSelect,
                  onToggle: notifier.toggle,
                  avatar: widget.avatar,
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                right: -1,
                width: 7,
                child: _EdgeHandle(
                  onTap: notifier.toggle,
                  onDoubleTap: notifier.reset,
                  onDragStart: () => setState(() => _resizing = true),
                  onDrag: notifier.resizeBy,
                  onDragEnd: () {
                    setState(() => _resizing = false);
                    notifier.save();
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: context.colors.background,
            child: TabletChrome(
              leadingInset: 0,
              trailingInset: 0,
              tabsShowing: false,
              child: Column(
                children: [
                  Expanded(child: widget.child),
                  widget.accessory,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The sidebar's right edge: a resize cursor, a hairline that brightens on
/// hover, drag to resize, click to collapse.
class _EdgeHandle extends StatefulWidget {
  const _EdgeHandle({
    required this.onTap,
    required this.onDoubleTap,
    required this.onDragStart,
    required this.onDrag,
    required this.onDragEnd,
  });

  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onDragStart;
  final ValueChanged<double> onDrag;
  final VoidCallback onDragEnd;

  @override
  State<_EdgeHandle> createState() => _EdgeHandleState();
}

class _EdgeHandleState extends State<_EdgeHandle> {
  bool _hover = false;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      label: 'Resize sidebar',
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          onHorizontalDragStart: (_) {
            setState(() => _dragging = true);
            widget.onDragStart();
          },
          onHorizontalDragUpdate: (details) => widget.onDrag(details.delta.dx),
          onHorizontalDragEnd: (_) {
            setState(() => _dragging = false);
            widget.onDragEnd();
          },
          child: Center(
            child: AnimatedContainer(
              duration: DaloyMotion.fast,
              width: 1,
              color: _hover || _dragging ? c.ring : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.width,
    required this.collapsed,
    required this.currentIndex,
    required this.onSelect,
    required this.onToggle,
    required this.avatar,
  });

  /// Where the width is headed: the rows lay out at it while the sidebar
  /// animates there, clipped, so nothing squeezes on the way.
  final double width;
  final bool collapsed;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onToggle;
  final Widget Function(double size, bool active) avatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final workspace = ref.watch(activeWorkspaceProvider).value;
    final user = ref.watch(sessionControllerProvider).value?.user;
    final workspaceLabel = workspace == null ? 'Switch workspace' : '${workspace.name}, switch workspace';
    final workspaceAvatar = workspace == null
        ? const SizedBox.square(dimension: 22)
        : WorkspaceAvatar(id: workspace.id, name: workspace.name, size: 22);
    final toggle = _SidebarRow(
      icon: collapsed ? TablerIcons.layout_sidebar_left_expand : TablerIcons.layout_sidebar_left_collapse,
      label: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
      shortcut: '$shortcutModifier\\',
      collapsed: true,
      muted: true,
      onTap: onToggle,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        // A light tint over a dark blur averages to grey, so light mode lets
        // far less of the backdrop through than dark mode does.
        color: hasAcrylic
            ? c.sidebar.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.6 : 0.85)
            : c.sidebar,
        border: Border(right: BorderSide(color: c.border, width: 0.5)),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: width,
          maxWidth: width,
          child: Padding(
            padding: const EdgeInsets.all(DaloySpace.s2),
            child: Column(
              crossAxisAlignment: collapsed ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
              children: [
                if (collapsed) ...[
                  _SidebarRow(
                    label: workspaceLabel,
                    collapsed: true,
                    leading: workspaceAvatar,
                    onTap: () => showWorkspaceSwitcher(context),
                  ),
                  toggle,
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: _SidebarRow(
                          label: workspace?.name ?? 'Workspace',
                          semanticLabel: workspaceLabel,
                          collapsed: false,
                          leading: workspaceAvatar,
                          trailing: Icon(TablerIcons.selector, size: 14, color: c.mutedForeground),
                          strong: true,
                          onTap: () => showWorkspaceSwitcher(context),
                        ),
                      ),
                      const SizedBox(width: DaloySpace.s1),
                      toggle,
                    ],
                  ),
                const SizedBox(height: DaloySpace.s1),
                _SidebarRow(
                  icon: TablerIcons.search,
                  label: 'Search',
                  shortcut: '${shortcutModifier}K',
                  collapsed: collapsed,
                  onTap: () => openSearch(context),
                ),
                const SizedBox(height: DaloySpace.s3),
                for (final (i, t) in tabletTabs.indexed)
                  _SidebarRow(
                    icon: i == currentIndex ? t.activeIcon : t.icon,
                    label: t.label,
                    selected: i == currentIndex,
                    collapsed: collapsed,
                    onTap: () => onSelect(i),
                  ),
                const Spacer(),
                _SidebarRow(
                  label: user?.name ?? 'You',
                  semanticLabel: 'You',
                  selected: currentIndex == _profileBranch,
                  collapsed: collapsed,
                  leading: SizedBox.square(dimension: 24, child: avatar(24, false)),
                  onTap: () => onSelect(_profileBranch),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A sidebar row, as on the web: 32 tall, a fill on hover and for the
/// current one, the icon in the accent when current. In the rail it's a
/// 36 square with a tooltip in place of its label.
class _SidebarRow extends StatefulWidget {
  const _SidebarRow({
    required this.label,
    required this.collapsed,
    required this.onTap,
    this.icon,
    this.leading,
    this.trailing,
    this.shortcut,
    this.semanticLabel,
    this.selected = false,
    this.muted = false,
    this.strong = false,
  });

  final String label;
  final bool collapsed;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;

  /// Shown as a key cap when open, and in the tooltip in the rail.
  final String? shortcut;
  final String? semanticLabel;
  final bool selected;

  /// Quieter icon (the collapse button).
  final bool muted;

  /// The label in the title weight (the workspace).
  final bool strong;

  @override
  State<_SidebarRow> createState() => _SidebarRowState();
}

class _SidebarRowState extends State<_SidebarRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = widget.selected;
    final fill = selected
        ? c.foreground.withValues(alpha: 0.08)
        : _hover
        ? c.foreground.withValues(alpha: 0.05)
        : Colors.transparent;
    final iconColor = selected
        ? c.primary
        : widget.muted
        ? c.mutedForeground
        : c.foreground.withValues(alpha: _hover ? 0.9 : 0.75);
    final leading = widget.leading ?? DaloyIcon(widget.icon!, size: 18, color: iconColor);

    final row = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: DaloyMotion.fast,
          curve: DaloyMotion.ease,
          width: widget.collapsed ? 36 : null,
          height: widget.collapsed ? 36 : 32,
          padding: EdgeInsets.symmetric(horizontal: widget.collapsed ? 0 : DaloySpace.s2),
          decoration: BoxDecoration(color: fill, borderRadius: DaloyRadii.all(DaloyRadii.md)),
          child: widget.collapsed
              ? Center(child: leading)
              : Row(
                  children: [
                    SizedBox(width: 22, child: Center(child: leading)),
                    const SizedBox(width: DaloySpace.s2_5),
                    Expanded(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium!.copyWith(
                          fontWeight: widget.strong ? FontWeight.w600 : FontWeight.w500,
                          color: selected || _hover || widget.strong
                              ? c.foreground
                              : c.foreground.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    if (widget.shortcut != null) _KeyCap(widget.shortcut!),
                    ?widget.trailing,
                  ],
                ),
        ),
      ),
    );

    return Semantics(
      selected: selected,
      button: true,
      label: widget.semanticLabel ?? widget.label,
      excludeSemantics: true,
      child: widget.collapsed
          ? Tooltip(
              message: widget.shortcut == null ? widget.label : '${widget.label}  ${widget.shortcut}',
              preferBelow: false,
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 1), child: row),
            )
          : row,
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap(this.keys);

  final String keys;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s1),
      decoration: BoxDecoration(
        color: c.background,
        border: Border.all(color: c.border),
        borderRadius: DaloyRadii.all(4),
      ),
      child: Text(keys, style: context.text.labelSmall!.copyWith(fontSize: 10, color: c.mutedForeground)),
    );
  }
}
