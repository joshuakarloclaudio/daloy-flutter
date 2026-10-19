import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import '../../shell/shell_layout.dart';

/// Every modal sheet in the app goes through here, never
/// `showModalBottomSheet`, and it is the same sheet Perform and Practice
/// open: a card that rises from the bottom with rounded top corners and a
/// small grabber, over a dimmed page, dragged or tapped away.
///
/// Short choices do not belong here: they are menus (`DaloyMenuButton`), and
/// confirmations are alerts.
///
/// [builder] draws the content only. The surface is the card colour; the
/// content pads for the keyboard and the home indicator itself (the surface
/// hands it the device's bottom inset, not the shell's tab-bar padding). [constraints]
/// caps the width on a tablet.
///
/// A sheet that leads with a `SheetNavBar` passes [toolbar], since the bar
/// brings its own room below the grabber.
///
/// By default the sheet takes the height [sheetMaxHeightFactor] of the
/// screen, for lists and forms. With [fit] it is only as tall as its content
/// (up to that), for simple, static content.
///
/// A tablet presents the same content the iPad way: a centred form sheet
/// over the dimmed page, or, given the [anchor] (the trigger's rect on
/// screen, `anchorOf`), a popover beside the control that opened it.
Future<T?> showDaloySheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  BoxConstraints? constraints,
  bool enableDrag = true,
  bool toolbar = false,
  bool fit = false,
  Rect? anchor,
}) {
  if (ShellLayout.of(context) == ShellLayout.tablet) {
    return _showTabletSheet<T>(
      context: context,
      builder: builder,
      maxWidth: constraints?.maxWidth,
      toolbar: toolbar,
      fit: fit,
      anchor: anchor,
    );
  }
  final screen = MediaQuery.sizeOf(context);
  final maxHeight = screen.height * sheetMaxHeightFactor;
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    enableDrag: enableDrag,
    // The surface draws itself.
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: BoxConstraints(
      maxHeight: maxHeight,
      maxWidth: math.min(screen.width, constraints?.maxWidth ?? screen.width),
    ),
    builder: (_) => DaloySheetSurface(
      height: fit ? null : maxHeight,
      topInset: toolbar ? 0 : DaloySpace.s3,
      child: Builder(builder: builder),
    ),
  );
}

/// How much of the screen a full-height sheet covers.
const sheetMaxHeightFactor = 0.86;

/// The form sheet's width when the caller doesn't cap it, and its tallest.
const _formSheetWidth = 560.0;
const _formSheetMaxHeight = 760.0;

/// A popover's width range and tallest.
const _popoverMinWidth = 320.0;
const _popoverMaxWidth = 420.0;
const _popoverMaxHeight = 600.0;

Future<T?> _showTabletSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  required double? maxWidth,
  required bool toolbar,
  required bool fit,
  required Rect? anchor,
}) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  final popover = anchor != null;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    // A popover leaves the page as it is; a form sheet dims it.
    barrierColor: popover
        ? Colors.black.withValues(alpha: 0.06)
        : Theme.of(context).bottomSheetTheme.modalBarrierColor!,
    transitionDuration: reduceMotion ? Duration.zero : DaloyMotion.medium,
    pageBuilder: (dialogContext, _, _) {
      final media = MediaQuery.of(dialogContext);
      final surface = DaloySheetSurface(
        shape: _TabletSheetShape.all,
        grabber: false,
        height: fit || popover
            ? null
            : math.min(_formSheetMaxHeight, (media.size.height - media.viewInsets.bottom) * 0.82),
        topInset: toolbar ? 0 : DaloySpace.s5,
        // Floating clear of every edge: no home indicator or keyboard to pad
        // for inside the card.
        bottomInset: 0,
        child: Builder(builder: builder),
      );
      if (popover) {
        return CustomSingleChildLayout(
          delegate: _PopoverLayout(
            anchor: anchor,
            insets: media.padding + EdgeInsets.only(bottom: media.viewInsets.bottom),
          ),
          child: _Lifted(child: surface),
        );
      }
      return Padding(
        // Rides up with the keyboard.
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(DaloySpace.s6),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth ?? _formSheetWidth),
                child: _Lifted(child: surface),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: DaloyMotion.ease);
      return FadeTransition(
        opacity: curved,
        child: popover
            ? ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(curved), child: child)
            : SlideTransition(
                position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
                child: child,
              ),
      );
    },
  );
}

abstract final class _TabletSheetShape {
  static const all = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(26)));
}

/// The soft shadow under a floating sheet or popover.
class _Lifted extends StatelessWidget {
  const _Lifted({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.45 : 0.14),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Below the anchor when it fits, otherwise above; lined up with the anchor's
/// nearer side, and kept on screen.
class _PopoverLayout extends SingleChildLayoutDelegate {
  const _PopoverLayout({required this.anchor, required this.insets});

  final Rect anchor;
  final EdgeInsets insets;

  static const _gap = 8.0;
  static const _margin = 16.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final room =
        math.max(constraints.maxHeight - insets.bottom - anchor.bottom, anchor.top - insets.top) - _gap - _margin;
    return BoxConstraints(
      minWidth: _popoverMinWidth,
      maxWidth: _popoverMaxWidth,
      maxHeight: room.clamp(200.0, _popoverMaxHeight),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final fromRight = anchor.center.dx > size.width / 2;
    final fitsBelow = anchor.bottom + _gap + childSize.height <= size.height - insets.bottom - _margin;
    final dx = fromRight ? anchor.right - childSize.width : anchor.left;
    final dy = fitsBelow ? anchor.bottom + _gap : anchor.top - _gap - childSize.height;
    final left = insets.left + _margin, top = insets.top + _margin;
    return Offset(
      dx.clamp(left, math.max(left, size.width - insets.right - childSize.width - _margin)),
      dy.clamp(top, math.max(top, size.height - insets.bottom - childSize.height - _margin)),
    );
  }

  @override
  bool shouldRelayout(_PopoverLayout old) => anchor != old.anchor || insets != old.insets;
}

/// The card every sheet is drawn on: rounded top corners, the grabber, and a
/// Material under the content so fields and highlights have somewhere to
/// paint. [height] null sizes it to its content.
class DaloySheetSurface extends StatelessWidget {
  const DaloySheetSurface({
    super.key,
    required this.child,
    this.height,
    this.topInset = DaloySpace.s3,
    this.grabber = true,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(DaloyRadii.xl3)),
    ),
    this.bottomInset,
  });

  final Widget child;
  final double? height;
  final double topInset;

  /// Off for a tablet's form sheet or popover, which aren't dragged.
  final bool grabber;
  final ShapeBorder shape;

  /// The bottom inset the content pads for; the device's when null. A
  /// tablet's floating sheet passes 0, and takes the keyboard out too.
  final double? bottomInset;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // The shell pads everything under it for its floating tab bar. A sheet
    // covers that bar, so it pads for the device's own inset only.
    final media = MediaQuery.of(context);
    final device = MediaQueryData.fromView(View.of(context));
    final floating = bottomInset != null;
    final body = MediaQuery(
      data: media.copyWith(
        padding: media.padding.copyWith(bottom: bottomInset ?? device.padding.bottom, top: floating ? 0 : null),
        viewPadding: media.viewPadding.copyWith(
          bottom: bottomInset ?? device.viewPadding.bottom,
          top: floating ? 0 : null,
        ),
        viewInsets: floating ? EdgeInsets.zero : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: child,
      ),
    );
    return Material(
      color: c.card,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: Column(
          mainAxisSize: height == null ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (grabber)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: DaloySpace.s2),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: c.border, borderRadius: DaloyRadii.all(DaloyRadii.full)),
                ),
              ),
            if (height == null) Flexible(child: body) else Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
