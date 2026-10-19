import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/theme/daloy_theme.dart';
import '../shared/widgets/daloy_glass.dart';
import '../shared/widgets/daloy_icon.dart';
import '../shared/widgets/pressable.dart';
import 'primary_action.dart';

/// One phone tab. Its index in [phoneTabs] is its `StatefulShellRoute`
/// branch in `app_router.dart`.
class PhoneTab {
  const PhoneTab(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const phoneTabs = [
  PhoneTab('Home', TablerIcons.home, TablerIcons.home_filled),
  PhoneTab('Songs', TablerIcons.music, TablerIcons.music),
  PhoneTab('Line-ups', TablerIcons.layout_list, TablerIcons.layout_list_filled),
  PhoneTab('You', TablerIcons.user, TablerIcons.user),
];

/// How many tab navigators have something over their screen (a sheet, a
/// dialog, a page), so the bar can step aside. Screens pushed on the root
/// navigator are caught by the shell's own `ModalRoute` instead.
class ShellCover {
  ShellCover._();

  static final covered = ValueNotifier<int>(0);

  /// The route name of a menu. A menu is a moment, not a place: it opens over
  /// the tab you are on, and the bar (whose `+` or ⋯ you just pressed) stays.
  static const menuRoute = 'daloy-menu';

  /// One per branch: a `NavigatorObserver` serves a single navigator.
  static NavigatorObserver observer() => _CoverObserver();
}

/// Asks its navigator rather than counting pushes and pops: go_router swaps
/// branch navigators out (sign-in, workspace switch) without popping their
/// routes, which would leave a count stuck above zero and the bar hidden.
class _CoverObserver extends NavigatorObserver {
  bool _covered = false;

  /// Menus opened straight over the tab's own page, which do not cover it.
  final _menus = <Route<dynamic>>{};

  void _track(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == ShellCover.menuRoute && previousRoute?.isFirst == true) _menus.add(route);
  }

  void _update() {
    // Menus and nothing else on top: the tab is still the whole screen.
    final covered = (navigator?.canPop() ?? false) && _menus.isEmpty;
    if (covered == _covered) return;
    _covered = covered;
    ShellCover.covered.value = math.max(0, ShellCover.covered.value + (covered ? 1 : -1));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _track(route, previousRoute);
    _update();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _menus.remove(route);
    _update();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _menus.remove(route);
    _update();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _menus.remove(oldRoute);
    _update();
  }
}

/// The phone tab bar, drawn in Flutter (like Photos on iOS 26): a floating
/// glass capsule of tabs with the tab's create action detached at its end.
/// Scroll down, on any tab, and it shrinks: the same four tabs as icons only,
/// a smaller `+`. Scroll up and it is full size again, with labels.
///
/// A tab with an inline control (Songs: Library | Discover) folds differently,
/// to leave that control room: the capsule becomes one circle holding the
/// current tab's icon, with the control centred beside it on the same row. Tap
/// the circle and the capsule opens again.
///
/// It floats over the tab screens, which get its height as bottom padding, so
/// lists scroll under the glass. The screens' scrolling is how it knows when
/// to fold: it listens for their vertical scroll notifications.
class FloatingTabBarScope extends StatefulWidget {
  const FloatingTabBarScope({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.onReselect,
    required this.visible,
    required this.accessory,
    required this.child,
    this.youAvatar,
    this.action,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onReselect;

  /// False while a screen or sheet covers the shell.
  final bool visible;

  /// Docked above the bar (now playing, live now).
  final Widget accessory;

  /// The tab screens.
  final Widget child;

  /// The account avatar on "You".
  final Widget? youAvatar;

  /// The current tab's create action (the detached `+`) and inline control;
  /// null for a tab with neither.
  final PrimaryAction? action;

  @override
  State<FloatingTabBarScope> createState() => _FloatingTabBarScopeState();
}

class _FloatingTabBarScopeState extends State<FloatingTabBarScope> {
  /// Scrolled this far down (and past the top) before the bar folds, and this
  /// far back up before it opens: enough that a flick or a bounce doesn't.
  static const _foldAfter = 28.0;
  static const _openAfter = 20.0;
  static const _clearOfTop = 48.0;

  bool _minimized = false;
  double _travel = 0;
  double _accessory = 0;

  /// A list is coasting on its own momentum (a fling), not under a finger.
  bool _coasting = false;

  @override
  void didUpdateWidget(FloatingTabBarScope old) {
    super.didUpdateWidget(old);
    // A new tab starts open.
    if (old.currentIndex != widget.currentIndex) _setMinimized(false);
  }

  void _setMinimized(bool value) {
    _travel = 0;
    if (value != _minimized) setState(() => _minimized = value);
  }

  /// A touch while the list coasts is a tap to stop it: the bar opens and stays
  /// open until the finger scrolls again.
  void _onPointerDown(PointerDownEvent event) {
    if (_coasting) {
      _coasting = false;
      _setMinimized(false);
    }
  }

  bool _onScroll(ScrollNotification notification) {
    // The screen's own list, not a shelf inside it or a sheet over it.
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) return false;
    if (notification is ScrollEndNotification) _coasting = false;
    if (notification is! ScrollUpdateNotification) return false;
    final metrics = notification.metrics;
    if (metrics.outOfRange) return false;

    // Momentum after a release never folds the bar; only a finger does.
    _coasting = notification.dragDetails == null;
    if (_coasting) {
      if (_minimized && metrics.pixels <= metrics.minScrollExtent + 8) _setMinimized(false);
      return false;
    }

    final delta = notification.scrollDelta ?? 0;
    // A change of direction starts the count again.
    if (delta != 0 && (delta > 0) != (_travel > 0)) _travel = 0;
    _travel += delta;

    if (!_minimized && _travel > _foldAfter && metrics.pixels > _clearOfTop) {
      _setMinimized(true);
    } else if (_minimized && (_travel < -_openAfter || metrics.pixels <= metrics.minScrollExtent + 8)) {
      _setMinimized(false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final safeBottom = media.padding.bottom;
    final barInset = FloatingGlassTabBar.insetFor(safeBottom);
    final keyboard = media.viewInsets.bottom > 0;
    final inline = widget.action?.inline;
    // Open, the inline control rides above the bar (like a bottom accessory);
    // folded, it moves into the bar's own row.
    final pill = inline != null && !_minimized ? FloatingGlassTabBar.pillHeight + FloatingGlassTabBar.pillGap : 0.0;
    final reach = keyboard ? safeBottom : barInset + pill + _accessory;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: Listener(
        onPointerDown: _onPointerDown,
        child: Stack(
          children: [
            Positioned.fill(
              child: MediaQuery(
                data: media.copyWith(
                  padding: media.padding.copyWith(bottom: math.max(safeBottom, reach)),
                  viewPadding: media.viewPadding.copyWith(bottom: math.max(media.viewPadding.bottom, reach)),
                ),
                child: widget.child,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: keyboard ? 0 : barInset + pill,
              child: _ReportHeight(
                onHeight: (h) {
                  if (mounted && h != _accessory) setState(() => _accessory = h);
                },
                child: widget.accessory,
              ),
            ),
            if (!keyboard)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FloatingGlassTabBar(
                  currentIndex: widget.currentIndex,
                  visible: widget.visible,
                  minimized: _minimized,
                  youAvatar: widget.youAvatar,
                  action: widget.action,
                  onTap: (i) => i == widget.currentIndex ? widget.onReselect(i) : widget.onSelect(i),
                  onExpand: () => _setMinimized(false),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The bar itself: a capsule of tabs, labelled when open and icons only when
/// folded. The tab's create action is detached at the end either way. Its
/// inline control sits above the open capsule; folded, it takes the capsule's
/// place beside a circle holding the current tab's icon.
class FloatingGlassTabBar extends StatelessWidget {
  const FloatingGlassTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onExpand,
    this.visible = true,
    this.minimized = false,
    this.youAvatar,
    this.action,
  });

  static const height = 62.0;

  /// The folded bar: the tab capsule, the inline control and the `+`, all a
  /// notch smaller so the bar gets out of the way.
  static const foldedHeight = 48.0;
  static const _foldedTabWidth = 52.0;

  /// The inline control above the open bar, and the room between them.
  static const pillHeight = 50.0;
  static const pillGap = 8.0;
  static const side = 20.0;

  /// The widest the bar gets, `+` included: a phone on its side keeps a
  /// portrait-sized bar, centred clear of the notch.
  static const maxWidth = 440.0;
  static const _gap = 10.0;

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Opens the folded bar (a tap on its circle).
  final VoidCallback? onExpand;
  final bool visible;
  final bool minimized;
  final Widget? youAvatar;

  /// The detached `+` and the inline control; null slides the `+` away.
  final PrimaryAction? action;

  /// Taller than any home indicator or gesture handle (iPhone 34, Android
  /// ~24): Android's three-button bar (~48), which is tappable to its top
  /// edge and drawn over the app with a scrim.
  static const _buttonNavInset = 40.0;

  /// The bar dips a little into a thin home indicator, as iOS's does, but
  /// sits clear above the buttons.
  static double _bottomFor(double safeBottom) =>
      safeBottom > _buttonNavInset ? safeBottom + 8 : math.max(12, safeBottom - 6);

  /// How far the bar reaches up from the bottom edge.
  static double insetFor(double safeBottom) => _bottomFor(safeBottom) + height;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottom = _bottomFor(media.padding.bottom);
    final inset = side + math.max(media.padding.left, media.padding.right);
    final horizontal = math.max(inset, (media.size.width - maxWidth) / 2);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : DaloyMotion.medium;
    final inline = action?.inline;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 1.6),
        duration: duration,
        curve: DaloyMotion.ease,
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Open: the inline control above the tabs.
              AnimatedSize(
                duration: duration,
                curve: DaloyMotion.ease,
                alignment: Alignment.bottomCenter,
                child: inline != null && !minimized
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: pillGap),
                        // Left-aligned with the tab capsule, which stops short of the `+`.
                        child: Padding(
                          padding: EdgeInsets.only(right: action == null ? 0 : _gap + height),
                          child: SizedBox(
                            height: pillHeight,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _InlinePill(child: inline),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              SizedBox(
                height: height,
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: duration,
                        switchInCurve: DaloyMotion.ease,
                        switchOutCurve: DaloyMotion.ease,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.96, end: 1.0).animate(animation),
                            alignment: Alignment.centerLeft,
                            child: child,
                          ),
                        ),
                        layoutBuilder: (current, previous) =>
                            Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
                        // The capsule shrinks in place; only a tab with an inline
                        // control swaps it for the circle and that control.
                        child: minimized && inline != null
                            ? _Folded(
                                key: const ValueKey('folded'),
                                currentIndex: currentIndex,
                                youAvatar: youAvatar,
                                inline: inline,
                                onExpand: onExpand,
                              )
                            : _Open(
                                key: const ValueKey('open'),
                                currentIndex: currentIndex,
                                compact: minimized,
                                youAvatar: youAvatar,
                                onTap: onTap,
                                duration: duration,
                              ),
                      ),
                    ),
                    // Not clipped while it opens or closes: a clip would square
                    // off the circle's shadow.
                    AnimatedContainer(
                      duration: duration,
                      curve: DaloyMotion.ease,
                      width: action == null ? 0 : _gap + (minimized ? foldedHeight : height),
                      child: OverflowBox(
                        alignment: Alignment.centerRight,
                        minWidth: 0,
                        maxWidth: _gap + height,
                        child: AnimatedSwitcher(
                          duration: duration,
                          switchInCurve: DaloyMotion.ease,
                          switchOutCurve: DaloyMotion.ease,
                          transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(scale: Tween(begin: 0.6, end: 1.0).animate(animation), child: child),
                          ),
                          child: action == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  // One key for every action: switching tabs swaps the
                                  // glyph in place; only the `+` arriving or leaving animates.
                                  key: const ValueKey('action'),
                                  padding: const EdgeInsets.only(left: _gap),
                                  child: _ActionCircle(action: action!, compact: minimized),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The tab capsule: every tab, the current one lit. Compact, it shrinks to
/// icons only and hugs them, at the leading edge.
class _Open extends StatelessWidget {
  const _Open({
    super.key,
    required this.currentIndex,
    required this.compact,
    required this.onTap,
    required this.duration,
    this.youAvatar,
  });

  final int currentIndex;
  final bool compact;
  final ValueChanged<int> onTap;
  final Duration duration;
  final Widget? youAvatar;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final hug = phoneTabs.length * FloatingGlassTabBar._foldedTabWidth + 8;
      return Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          key: const Key('tab-capsule'),
          duration: duration,
          curve: DaloyMotion.ease,
          width: compact ? math.min(box.maxWidth, hug) : box.maxWidth,
          height: compact ? FloatingGlassTabBar.foldedHeight : FloatingGlassTabBar.height,
          child: DaloyGlass.capsule(
            child: Padding(
              padding: EdgeInsets.all(compact ? 3 : 4),
              child: Row(
                children: [
                  for (final (i, t) in phoneTabs.indexed)
                    Expanded(
                      child: _GlassTab(
                        tab: t,
                        active: i == currentIndex,
                        compact: compact,
                        duration: duration,
                        avatar: t.label == 'You' ? youAvatar : null,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// The folded bar on a tab with an inline control: the current tab's icon in
/// a circle at the leading edge, and the control centred in the rest of the
/// row, between the circle and the `+`.
class _Folded extends StatelessWidget {
  const _Folded({super.key, required this.currentIndex, required this.inline, this.youAvatar, this.onExpand});

  final int currentIndex;
  final Widget inline;
  final Widget? youAvatar;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tab = phoneTabs[currentIndex];
    return Row(
      children: [
        Semantics(
          button: true,
          label: '${tab.label}, show the tab bar',
          excludeSemantics: true,
          child: Pressable(
            pressedScale: 0.92,
            onPressed: () {
              HapticFeedback.selectionClick();
              onExpand?.call();
            },
            child: SizedBox.square(
              dimension: FloatingGlassTabBar.foldedHeight,
              child: DaloyGlass.circle(
                child: Center(
                  child: youAvatar != null && tab.label == 'You'
                      ? SizedBox.square(dimension: 24, child: youAvatar)
                      : DaloyIcon(tab.activeIcon, size: 22, color: c.primaryInk),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: FloatingGlassTabBar._gap),
        Expanded(
          child: Center(
            child: _InlinePill(height: FloatingGlassTabBar.foldedHeight, child: inline),
          ),
        ),
      ],
    );
  }
}

/// A tab's inline control (Library | Discover) on a glass capsule. The glass
/// is the control's trough: it hugs the control, inset evenly all round, and
/// the control fills its height.
class _InlinePill extends StatelessWidget {
  const _InlinePill({required this.child, this.height = FloatingGlassTabBar.pillHeight});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) => DaloyGlass.capsule(
    child: AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : DaloyMotion.medium,
      curve: DaloyMotion.ease,
      height: height,
      padding: const EdgeInsets.all(4),
      child: child,
    ),
  );
}

/// The detached `+`: a teal glass circle, the bar's height. Nearly opaque, so
/// the white glyph holds its contrast over any content.
class _ActionCircle extends StatelessWidget {
  const _ActionCircle({required this.action, required this.compact});

  final PrimaryAction action;

  /// Folded: a smaller circle with a smaller glyph.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: action.label,
      excludeSemantics: true,
      child: Builder(
        builder: (circleContext) => Pressable(
          pressedScale: 0.9,
          onPressed: () {
            HapticFeedback.selectionClick();
            final box = circleContext.findRenderObject() as RenderBox;
            action.onPressed(box.localToGlobal(Offset.zero) & box.size);
          },
          child: AnimatedContainer(
            duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : DaloyMotion.medium,
            curve: DaloyMotion.ease,
            width: compact ? FloatingGlassTabBar.foldedHeight : FloatingGlassTabBar.height,
            height: compact ? FloatingGlassTabBar.foldedHeight : FloatingGlassTabBar.height,
            child: DaloyGlass.circle(
              tint: c.primary,
              tintAlpha: 0.94,
              child: Center(
                child: DaloyIcon(action.icon, size: compact ? 20 : 26, color: c.primaryForeground),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Active: a soft capsule behind the tab, primary icon and label. The label
/// weight never changes, so the tabs don't twitch.
class _GlassTab extends StatelessWidget {
  const _GlassTab({
    required this.tab,
    required this.active,
    required this.compact,
    required this.duration,
    required this.onTap,
    this.avatar,
  });

  final PhoneTab tab;
  final bool active;

  /// Icon only: the label folds away.
  final bool compact;
  final Duration duration;
  final VoidCallback onTap;
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = active ? c.primaryInk : c.foreground.withValues(alpha: 0.85);
    final icon = AnimatedContainer(
      duration: duration,
      curve: DaloyMotion.ease,
      width: compact ? 24 : 26,
      height: compact ? 24 : 26,
      child: Center(child: avatar ?? DaloyIcon(active ? tab.activeIcon : tab.icon, size: 22, color: color)),
    );
    return Semantics(
      selected: active,
      button: true,
      label: tab.label,
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
          decoration: BoxDecoration(
            color: active ? c.foreground.withValues(alpha: 0.06) : Colors.transparent,
            borderRadius: const BorderRadius.all(Radius.circular(FloatingGlassTabBar.height / 2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              // The label folds away to nothing, and fades as it goes.
              TweenAnimationBuilder<double>(
                tween: Tween(end: compact ? 0 : 1),
                duration: duration,
                curve: DaloyMotion.ease,
                builder: (context, t, label) => ClipRect(
                  child: Align(
                    heightFactor: t,
                    child: Opacity(opacity: t, child: label),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    tab.label,
                    maxLines: 1,
                    style: context.text.labelMedium!.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tells [onHeight] its child's height after each layout that changes it.
class _ReportHeight extends SingleChildRenderObjectWidget {
  const _ReportHeight({required this.onHeight, super.child});

  final ValueChanged<double> onHeight;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderReportHeight(onHeight);

  @override
  void updateRenderObject(BuildContext context, _RenderReportHeight renderObject) => renderObject.onHeight = onHeight;
}

class _RenderReportHeight extends RenderProxyBox {
  _RenderReportHeight(this.onHeight);

  ValueChanged<double> onHeight;
  double? _last;

  @override
  void performLayout() {
    super.performLayout();
    final height = size.height;
    if (height == _last) return;
    _last = height;
    WidgetsBinding.instance.addPostFrameCallback((_) => onHeight(height));
  }
}
