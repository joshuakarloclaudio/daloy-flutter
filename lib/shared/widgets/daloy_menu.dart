import 'dart:async';

import 'package:flutter/cupertino.dart' show CupertinoContextMenu, CupertinoContextMenuAction;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderProxyBox;
import 'package:flutter/semantics.dart' show CustomSemanticsAction;
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/daloy_theme.dart';
import '../../shell/floating_tab_bar.dart' show ShellCover;
import 'daloy_glass.dart';
import 'pressable.dart';

/// One row of a menu.
class DaloyMenuItem {
  const DaloyMenuItem({required this.icon, required this.label, required this.onSelected, this.destructive = false});

  /// Draws a hairline between groups.
  static const divider = DaloyMenuItem._divider();

  const DaloyMenuItem._divider() : icon = Icons.horizontal_rule, label = '', onSelected = _noop, destructive = false;

  final IconData icon;
  final String label;
  final VoidCallback onSelected;
  final bool destructive;

  bool get isDivider => identical(this, divider);

  static void _noop() {}
}

/// Where actions live on iOS. Three shapes, one item list:
///
/// * [DaloyMenuButton]: a ⋯ (or any icon) that pulls a menu down.
/// * [DaloyContextMenu]: touch and hold a row; it lifts, the page blurs and
///   the menu sits beside it.
/// * [showDaloyMenu] / [showDaloyChoiceMenu]: the same pull-down opened from
///   any trigger, and for picking one of several options.
class DaloyMenuButton extends StatelessWidget {
  const DaloyMenuButton({
    super.key,
    required this.items,
    required this.tooltip,
    this.icon = TablerIcons.dots,
    this.size = 40,
  });

  final List<DaloyMenuItem> items;

  /// The accessibility label.
  final String tooltip;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Builder(
      builder: (buttonContext) => Pressable(
        onPressed: () => showDaloyMenu(buttonContext, items: items),
        semanticLabel: tooltip,
        child: SizedBox.square(
          dimension: size < 44 ? 44 : size,
          child: Center(child: Icon(icon, size: 20, color: c.foreground)),
        ),
      ),
    );
  }
}

/// Touch and hold [child] to lift it and open [items] beside it.
///
/// [items] is a builder so the menu reflects state at the moment it opens.
/// Dividers are dropped (the lifted menu has no groups); destructive rows
/// stay last by order. Each item is also exposed to screen readers as a
/// custom action, so the menu is reachable without the gesture.
class DaloyContextMenu extends StatefulWidget {
  const DaloyContextMenu({super.key, required this.items, required this.child, this.previewRadius = 14});

  final List<DaloyMenuItem> Function() items;
  final Widget child;

  /// The corner radius the row takes while lifted.
  final double previewRadius;

  @override
  State<DaloyContextMenu> createState() => _DaloyContextMenuState();
}

class _DaloyContextMenuState extends State<DaloyContextMenu> {
  /// The row's size in the list. The lifted copy is laid out with loose
  /// constraints up to the whole screen, so a row that stretches (a `Row`
  /// with an `Expanded`) would fill it and leave no room for the menu.
  Size? _size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final current = widget.items().where((i) => !i.isDivider).toList();
    if (current.isEmpty) return widget.child;

    return Semantics(
      customSemanticsActions: {for (final item in current) CustomSemanticsAction(label: item.label): item.onSelected},
      // A mouse has no press-and-hold: a right click opens the same actions
      // at the pointer, as a plain pull-down without the lift.
      child: GestureDetector(
        onSecondaryTapUp: (details) => showDaloyMenu(
          context,
          items: widget.items(),
          anchor: Rect.fromLTWH(details.globalPosition.dx, details.globalPosition.dy, 0, 0),
        ),
        child: CupertinoContextMenu.builder(
          enableHapticFeedback: true,
          actions: [
            for (final item in current)
              Builder(
                builder: (menuContext) => CupertinoContextMenuAction(
                  isDestructiveAction: item.destructive,
                  trailingIcon: item.icon,
                  onPressed: () => _closeThen(menuContext, item.onSelected),
                  child: Text(item.label),
                ),
              ),
          ],
          builder: (builderContext, animation) {
            // The same builder draws the row in the list, the copy that rises
            // while the press is held (in the root overlay, outside any route)
            // and the lifted copy (in the menu's own route).
            final route = ModalRoute.of(builderContext);
            if (route != null && route is! PopupRoute) {
              // A Material of its own: the copies are built in the overlay,
              // outside the list's Material.
              return Material(
                type: MaterialType.transparency,
                child: _MeasureSize(onSize: (s) => _size = s, child: widget.child),
              );
            }

            // The copies are laid out in rects that animate (and, lifted, up
            // to the whole screen), so the row is not laid out again in them:
            // it keeps its size in the list and is scaled to fit. Laid out in
            // a rect a fraction shorter than itself, it would overflow.
            final size = _size;
            final row = size == null
                ? widget.child
                : FittedBox(
                    fit: BoxFit.fill,
                    child: SizedBox.fromSize(size: size, child: widget.child),
                  );
            return AnimatedBuilder(
              animation: animation,
              builder: (_, _) {
                // Lifted, the row is a card of its own: it has to look like
                // something once the page behind it blurs.
                final radius = BorderRadius.circular(widget.previewRadius * (animation.value * 3).clamp(0, 1));
                return Material(
                  type: MaterialType.transparency,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: c.card, borderRadius: radius),
                    child: ClipRRect(borderRadius: radius, child: row),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Reports its child's size after layout.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onSize, required Widget super.child});

  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMeasureSize(onSize);

  @override
  void updateRenderObject(BuildContext context, _RenderMeasureSize renderObject) => renderObject.onSize = onSize;
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onSize);

  ValueChanged<Size> onSize;
  Size? _last;

  @override
  void performLayout() {
    super.performLayout();
    if (size != _last) {
      _last = size;
      onSize(size);
    }
  }
}

/// Where the widget [context] belongs to is on screen, for a menu to open from.
Rect anchorOf(BuildContext context) {
  final box = context.findRenderObject();
  if (box is RenderBox && box.attached) return box.localToGlobal(Offset.zero) & box.size;
  return Rect.fromCenter(center: MediaQuery.sizeOf(context).center(Offset.zero), width: 0, height: 0);
}

/// Opens the drawn pull-down for [items] from the widget [context] belongs
/// to (or from [anchor] when given): right-aligned under it (left-aligned if it sits in the left half),
/// or above if there is no room below.
Future<void> showDaloyMenu(BuildContext context, {required List<DaloyMenuItem> items, Rect? anchor}) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await _present<void>(
    context,
    anchor: anchor,
    builder: (_) => _MenuPanel(
      items: items,
      // Runs once the menu has finished closing (see [_closeThen]).
      onPick: (menuContext, item) => _closeThen(menuContext, (item as DaloyMenuItem).onSelected),
    ),
  );
}

/// A drawn pull-down of single-choice rows with a check on [current], from
/// the widget [context] belongs to. Resolves to null when dismissed, and to
/// the choice once the menu has finished closing. Replaces the old choice
/// sheets.
Future<T?> showDaloyChoiceMenu<T>(
  BuildContext context, {
  required String title,
  required List<(T value, String label)> options,
  required T current,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  final result = Completer<T?>();
  var chose = false;
  _present<void>(
    context,
    builder: (_) => _MenuPanel(
      title: title,
      choices: [for (final (v, l) in options) _Choice(v, l, v == current)],
      onPick: (menuContext, value) {
        chose = true;
        _closeThen(menuContext, () => result.complete(value as T));
      },
    ),
  ).whenComplete(() {
    if (!chose && !result.isCompleted) result.complete(null);
  });
  return result.future;
}

class _Choice<T> {
  const _Choice(this.value, this.label, this.selected);

  final T value;
  final String label;
  final bool selected;
}

Future<T?> _present<T>(BuildContext context, {required WidgetBuilder builder, Rect? anchor}) {
  final screen = MediaQuery.sizeOf(context);
  final insets = MediaQuery.paddingOf(context);
  final from = anchor ?? anchorOf(context);
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  final below = from.bottom + 8 + 320 < screen.height || from.top < screen.height / 2;
  final fromRight = from.center.dx > screen.width / 2;
  final origin = Alignment(fromRight ? 1 : -1, below ? -1 : 1);
  HapticFeedback.selectionClick();

  return showGeneralDialog<T>(
    context: context,
    routeSettings: const RouteSettings(name: ShellCover.menuRoute),
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent,
    transitionDuration: reduceMotion ? Duration.zero : DaloyMotion.fast,
    // Full screen, not a SafeArea: [from] is in global coordinates. The
    // layout keeps the panel clear of the insets itself.
    pageBuilder: (dialogContext, _, _) => CustomSingleChildLayout(
      delegate: _MenuLayout(anchor: from, fromRight: fromRight, below: below, insets: insets),
      child: builder(dialogContext),
    ),
    transitionBuilder: (_, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        alignment: origin,
        scale: Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: animation, curve: DaloyMotion.ease)),
        child: child,
      ),
    ),
  );
}

class _MenuLayout extends SingleChildLayoutDelegate {
  const _MenuLayout({required this.anchor, required this.fromRight, required this.below, required this.insets});

  final Rect anchor;
  final bool fromRight;
  final bool below;
  final EdgeInsets insets;

  static const _gap = 8.0;
  static const _margin = 12.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => BoxConstraints(
    minWidth: 220,
    maxWidth: (constraints.maxWidth - insets.horizontal - _margin * 2).clamp(220, 300),
    maxHeight: constraints.maxHeight - insets.vertical - _margin * 2,
  );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final dx = fromRight ? anchor.right - childSize.width : anchor.left;
    final dy = below ? anchor.bottom + _gap : anchor.top - _gap - childSize.height;
    final left = insets.left + _margin, top = insets.top + _margin;
    return Offset(
      dx.clamp(left, (size.width - insets.right - childSize.width - _margin).clamp(left, double.infinity)),
      dy.clamp(top, (size.height - insets.bottom - childSize.height - _margin).clamp(top, double.infinity)),
    );
  }

  @override
  bool shouldRelayout(_MenuLayout old) =>
      anchor != old.anchor || fromRight != old.fromRight || below != old.below || insets != old.insets;
}

/// The drawn menu: frosted panel, radius 14, 44pt rows with the label first
/// and the icon trailing (Apple's order, not Material's).
class _MenuPanel extends StatelessWidget {
  const _MenuPanel({this.items, this.choices, this.title, required this.onPick})
    : assert((items == null) != (choices == null));

  final List<DaloyMenuItem>? items;
  final List<_Choice<Object?>>? choices;
  final String? title;

  /// Called with the tapped [DaloyMenuItem] or choice value.
  final void Function(BuildContext menuContext, Object? picked) onPick;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rows = <Widget>[
      if (title != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s3, DaloySpace.s4, DaloySpace.s1),
          child: Text(
            title!,
            style: context.text.labelMedium?.copyWith(color: c.mutedForeground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      if (items != null)
        for (final item in items!)
          if (item.isDivider)
            const _Hairline()
          else
            _MenuRow(
              label: item.label,
              trailing: Icon(item.icon, size: 18, color: item.destructive ? c.destructive : c.foreground),
              destructive: item.destructive,
              onTap: () => onPick(context, item),
            ),
      if (choices != null)
        for (final choice in choices!)
          _MenuRow(
            label: choice.label,
            trailing: choice.selected ? Icon(TablerIcons.check, size: 18, color: c.primaryInk) : null,
            onTap: () => onPick(context, choice.value),
          ),
    ];

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: title ?? 'Menu',
      explicitChildNodes: true,
      child: DaloyGlass.panel(
        child: Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: DaloySpace.s1),
            child: IntrinsicWidth(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.onTap, this.trailing, this.destructive = false});

  final String label;
  final Widget? trailing;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.text.bodyLarge?.copyWith(color: destructive ? c.destructive : c.foreground),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: DaloySpace.s4), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: DaloySpace.s1),
    child: SizedBox(height: 0.5, child: ColoredBox(color: context.colors.border)),
  );
}

/// Pops the route [context] belongs to and runs [action] once its exit
/// animation is done. Run sooner, an action that pushes a full-screen route
/// would cover the menu mid-exit and freeze it (covered routes stop ticking).
void _closeThen(BuildContext context, VoidCallback action) {
  final animation = ModalRoute.of(context)?.animation;
  Navigator.of(context).pop();
  if (animation == null || animation.isDismissed) {
    action();
    return;
  }
  void onStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed) return;
    animation.removeStatusListener(onStatus);
    action();
  }

  animation.addStatusListener(onStatus);
}
