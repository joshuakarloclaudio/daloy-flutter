import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/theme/daloy_theme.dart';
import '../features/auth/application/session_controller.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/workspaces/data/workspaces_repository.dart';
import '../features/workspaces/presentation/workspace_switcher.dart';
import '../shared/widgets/daloy_glass.dart';
import '../shared/widgets/daloy_icon.dart';
import '../shared/widgets/daloy_top_bar.dart';
import '../shared/widgets/glass_buttons.dart';
import '../shared/widgets/pressable.dart';
import 'sidebar_state.dart';

/// One tablet destination. Its index is its `StatefulShellRoute` branch.
class TabletTab {
  const TabletTab(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const tabletTabs = [
  TabletTab('Home', TablerIcons.home, TablerIcons.home_filled),
  TabletTab('Songs', TablerIcons.music, TablerIcons.music),
  TabletTab('Line-ups', TablerIcons.layout_list, TablerIcons.layout_list_filled),
];
const _profileBranch = 3;

/// The tablet frame, after iPadOS: a floating glass tab bar at the top centre
/// (with the sidebar button and the workspace at the leading end, you at the
/// trailing end) that opens into a glass sidebar docked to the left edge, top
/// to bottom. Where there is room the sidebar sits beside the screen; where
/// there isn't (portrait), it slides over a dimmed screen and closes on a tap
/// outside. Open or closed is kept
/// per orientation ([sidebarOpenProvider]). ⌃⌘S toggles it from a keyboard.
class TabletShell extends ConsumerStatefulWidget {
  const TabletShell({
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

  static const sidebarWidth = 272.0;

  /// The screen keeps at least this much beside an open sidebar; narrower, the
  /// sidebar floats over it instead.
  static const _minContentBeside = 600.0;

  @override
  ConsumerState<TabletShell> createState() => _TabletShellState();
}

class _TabletShellState extends ConsumerState<TabletShell> {
  bool _landscape = true;

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
    if (event is! KeyDownEvent || event.logicalKey != LogicalKeyboardKey.keyS) return false;
    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isMetaPressed || !keyboard.isControlPressed) return false;
    if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) return false;
    _toggle();
    return true;
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    ref.read(sidebarOpenProvider.notifier).toggle(landscape: _landscape);
  }

  void _close() => ref.read(sidebarOpenProvider.notifier).set(landscape: _landscape, open: false);

  void _select(int index, {required bool beside}) {
    widget.onSelect(index);
    // A sidebar floating over the screen has done its job.
    if (!beside) _close();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    _landscape = size.width > size.height;
    final open = ref.watch(sidebarOpenProvider.select((s) => _landscape ? s.landscape : s.portrait));
    // The left inset (a notch in landscape) is the sidebar's to pad.
    final span = media.padding.left + TabletShell.sidebarWidth;
    final beside = size.width - span >= TabletShell._minContentBeside;
    final docked = open && beside;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : DaloyMotion.medium;

    final content = TabletChrome(
      leadingInset: docked ? 0 : _TopRow.leadingWidth,
      trailingInset: docked ? 0 : _TopRow.trailingWidth,
      tabsShowing: !docked,
      child: Column(
        children: [
          Expanded(child: widget.child),
          widget.accessory,
        ],
      ),
    );

    return Stack(
      children: [
        AnimatedPositioned(
          duration: duration,
          curve: DaloyMotion.ease,
          left: docked ? span : 0,
          top: 0,
          right: 0,
          bottom: 0,
          // Beside the sidebar, the screen is clear of the left edge's notch.
          child: docked ? MediaQuery.removePadding(context: context, removeLeft: true, child: content) : content,
        ),
        Positioned(
          left: 0,
          right: 0,
          top: media.padding.top,
          height: DaloyChrome.topBarHeight,
          child: IgnorePointer(
            ignoring: docked,
            child: AnimatedOpacity(
              opacity: docked ? 0 : 1,
              duration: duration,
              child: _TopRow(
                currentIndex: widget.currentIndex,
                onSelect: widget.onSelect,
                onShowSidebar: _toggle,
                avatar: widget.avatar,
              ),
            ),
          ),
        ),
        // Over a screen too narrow to share: dim it, and a tap outside closes.
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !(open && !beside),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
              child: AnimatedOpacity(
                opacity: open && !beside ? 1 : 0,
                duration: duration,
                child: ColoredBox(color: Colors.black.withValues(alpha: 0.22)),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: duration,
          curve: DaloyMotion.ease,
          left: open ? 0 : -(span + 40),
          top: 0,
          bottom: 0,
          width: span,
          child: IgnorePointer(
            ignoring: !open,
            child: _Sidebar(
              overlay: !beside,
              currentIndex: widget.currentIndex,
              onSelect: (i) => _select(i, beside: beside),
              onHide: _toggle,
              onSearch: () {
                if (!beside) _close();
                openSearch(context);
              },
              avatar: widget.avatar,
            ),
          ),
        ),
      ],
    );
  }
}

/// The collapsed chrome on the bar row: sidebar button and workspace at the
/// leading end, the tab capsule centred, your avatar at the trailing end.
class _TopRow extends ConsumerWidget {
  const _TopRow({
    required this.currentIndex,
    required this.onSelect,
    required this.onShowSidebar,
    required this.avatar,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onShowSidebar;
  final Widget Function(double size, bool active) avatar;

  static const _side = DaloySpace.s2;

  /// What the leading and trailing clusters take from the bar row.
  static const leadingWidth = _side + 44 + 44 + DaloySpace.s1;
  static const trailingWidth = 44 + DaloySpace.s1;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider).value;
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: MediaQuery.paddingOf(context).left + _side),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassIconButton(
                  icon: TablerIcons.layout_sidebar_left_expand,
                  label: 'Show sidebar',
                  onPressed: onShowSidebar,
                ),
                _GlassAvatarButton(
                  label: workspace == null ? 'Switch workspace' : '${workspace.name}, switch workspace',
                  onPressed: () => showWorkspaceSwitcher(context),
                  child: workspace == null
                      ? const SizedBox.shrink()
                      : WorkspaceAvatar(id: workspace.id, name: workspace.name, size: 30),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: _TabCapsule(currentIndex: currentIndex, onSelect: onSelect),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: MediaQuery.paddingOf(context).right + DaloySpace.s1),
            child: _GlassAvatarButton(
              label: 'You',
              selected: currentIndex == _profileBranch,
              onPressed: () => onSelect(_profileBranch),
              child: avatar(30, false),
            ),
          ),
        ),
      ],
    );
  }
}

/// The tabs as words on a glass capsule (iPadOS' top tab bar), the current
/// one on a soft pill, and Search as a magnifier at the end.
class _TabCapsule extends StatelessWidget {
  const _TabCapsule({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  static const height = 44.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: height,
      child: DaloyGlass.capsule(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, t) in tabletTabs.indexed)
                _CapsuleTab(
                  label: t.label,
                  selected: i == currentIndex,
                  onTap: () => onSelect(i),
                  child: Text(t.label),
                ),
              _CapsuleTab(
                label: 'Search',
                selected: false,
                onTap: () => openSearch(context),
                child: DaloyIcon(TablerIcons.search, size: 19, color: c.foreground.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapsuleTab extends StatelessWidget {
  const _CapsuleTab({required this.label, required this.selected, required this.onTap, required this.child});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: DaloyMotion.fast,
          curve: DaloyMotion.ease,
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.foreground.withValues(alpha: 0.07) : Colors.transparent,
            borderRadius: DaloyRadii.all(DaloyRadii.full),
          ),
          // One weight whatever the state, so the capsule never changes width.
          child: DefaultTextStyle(
            style: context.text.labelLarge!.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? c.primaryInk : c.foreground.withValues(alpha: 0.85),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// An avatar on the bar row, in the same frosted circle as [GlassIconButton].
class _GlassAvatarButton extends StatelessWidget {
  const _GlassAvatarButton({required this.label, required this.onPressed, required this.child, this.selected = false});

  final String label;
  final VoidCallback onPressed;
  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      selected: selected,
      child: Pressable(
        onPressed: onPressed,
        semanticLabel: label,
        pressedScale: 0.92,
        child: SizedBox.square(
          dimension: 44,
          child: Center(
            child: SizedBox.square(
              dimension: 36,
              child: DaloyGlass.circle(
                border: selected ? Border.all(color: c.primary, width: 2) : null,
                child: Center(
                  child: ClipOval(child: SizedBox.square(dimension: 30, child: child)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The open sidebar: a glass column docked to the left edge, the workspace
/// at the top, the tabs and Search as rows, and you at the bottom. It pads
/// itself clear of the status bar, notch and home indicator.
class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.overlay,
    required this.currentIndex,
    required this.onSelect,
    required this.onHide,
    required this.onSearch,
    required this.avatar,
  });

  final int currentIndex;

  /// Over the screen rather than beside it: lifted by a shadow.
  final bool overlay;
  final ValueChanged<int> onSelect;
  final VoidCallback onHide;
  final VoidCallback onSearch;
  final Widget Function(double size, bool active) avatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final workspace = ref.watch(activeWorkspaceProvider).value;
    final user = ref.watch(sessionControllerProvider).value?.user;
    final safe = MediaQuery.paddingOf(context);

    return DaloyGlass(
      borderRadius: BorderRadius.zero,
      // Rows of text, so it frosts like a menu; a rule for an edge.
      tintAlpha: 0.62,
      sheen: false,
      border: Border(right: BorderSide(color: c.border, width: 0.5)),
      shadow: overlay,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          safe.left + DaloySpace.s2,
          safe.top,
          DaloySpace.s2,
          math.max(safe.bottom, DaloySpace.s2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: DaloyChrome.topBarHeight,
              child: Row(
                children: [
                  Expanded(
                    child: Pressable(
                      onPressed: () => showWorkspaceSwitcher(context),
                      semanticLabel: workspace == null ? 'Switch workspace' : '${workspace.name}, switch workspace',
                      pressedScale: 0.98,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s2),
                        child: Row(
                          children: [
                            if (workspace != null) ...[
                              WorkspaceAvatar(id: workspace.id, name: workspace.name, size: 28),
                              const SizedBox(width: DaloySpace.s2_5),
                              Flexible(
                                child: Text(
                                  workspace.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleSmall!.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                            const SizedBox(width: DaloySpace.s1),
                            Icon(TablerIcons.selector, size: 16, color: c.mutedForeground),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Pressable(
                    onPressed: onHide,
                    semanticLabel: 'Hide sidebar',
                    pressedScale: 0.9,
                    child: SizedBox.square(
                      dimension: 44,
                      child: Icon(TablerIcons.layout_sidebar_left_collapse, size: 22, color: c.foreground),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DaloySpace.s2),
            for (final (i, t) in tabletTabs.indexed)
              _SidebarRow(
                icon: i == currentIndex ? t.activeIcon : t.icon,
                label: t.label,
                selected: i == currentIndex,
                onTap: () => onSelect(i),
              ),
            _SidebarRow(
              icon: TablerIcons.search,
              label: 'Search',
              selected: false,
              onTap: onSearch,
              trailing: Text('⌘K', style: context.text.labelMedium!.copyWith(color: c.mutedForeground)),
            ),
            const Spacer(),
            _SidebarRow(
              label: user?.name ?? 'You',
              semanticLabel: 'You',
              selected: currentIndex == _profileBranch,
              onTap: () => onSelect(_profileBranch),
              leading: SizedBox.square(dimension: 26, child: avatar(26, false)),
            ),
          ],
        ),
      ),
    );
  }
}

/// A sidebar row: icon and label, the current one tinted with the accent.
class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.leading,
    this.trailing,
    this.semanticLabel,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = selected ? c.primaryInk : c.foreground;
    return Semantics(
      selected: selected,
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: DaloyMotion.fast,
          curve: DaloyMotion.ease,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
          decoration: BoxDecoration(
            color: selected ? c.primary.withValues(alpha: 0.13) : Colors.transparent,
            borderRadius: DaloyRadii.all(DaloyRadii.xl),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 26,
                child: Center(child: leading ?? DaloyIcon(icon!, size: 21, color: color)),
              ),
              const SizedBox(width: DaloySpace.s3),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyLarge!.copyWith(fontWeight: FontWeight.w500, color: color),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
