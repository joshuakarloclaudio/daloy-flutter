import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/daloy_theme.dart';
import 'daloy_glass.dart';
import 'pressable.dart';

/// How an alert button looks (and, natively, behaves).
enum DaloyAlertStyle {
  normal,

  /// The default action: bold.
  preferred,

  /// Red. Also what [confirmDestructive] uses for its confirm.
  destructive,

  /// Dismisses without doing anything. Sits first of two.
  cancel,
}

class DaloyAlertAction<T> {
  const DaloyAlertAction(this.label, this.value, {this.style = DaloyAlertStyle.normal});

  final String label;
  final T value;
  final DaloyAlertStyle style;
}

const _channel = MethodChannel('pro.daloy.app/alert');

/// A blocking question. On iOS it is a real `UIAlertController` (Liquid Glass
/// on 26+, through `ios/Runner/AlertPlugin.swift`); elsewhere the same shape
/// drawn in Flutter: frosted, left-aligned, full-width capsule buttons, side
/// by side for two and stacked for three or more.
///
/// Resolves to the tapped action's value, or null if dismissed (only possible
/// with [dismissible], or the system back gesture). Labels should be verbs:
/// "Discard" / "Keep Editing", not "OK" / "Cancel", when a verb fits.
///
/// [content] replaces [message] with a widget and is always drawn in Flutter,
/// since UIKit can't show it. [wrap] re-themes the Flutter rendering (Perform
/// wraps it in its own palette); pass `native: false` with it so the iOS alert
/// doesn't ignore that palette.
Future<T?> showDaloyAlert<T>(
  BuildContext context, {
  required String title,
  String? message,
  Widget? content,
  required List<DaloyAlertAction<T>> actions,
  bool dismissible = false,
  bool native = true,
  Widget Function(Widget child)? wrap,
}) async {
  if (native && content == null && wrap == null) {
    final index = await _showNative(context, title: title, message: message, actions: actions, sheet: false);
    if (index != _unavailable) return index == null ? null : actions[index].value;
  }
  if (!context.mounted) return null;
  return _showFlutter<T>(
    context,
    title: title,
    message: message,
    content: content,
    actions: actions,
    dismissible: dismissible,
    wrap: wrap,
  );
}

/// "Discard?" / "Delete?": a yes/no whose confirm is the point of the screen.
/// True only when [confirmLabel] is chosen.
///
/// iOS shows a `UIAlertController` action sheet (a popover from [context]'s
/// widget on iPad). Elsewhere it's the same alert as [showDaloyAlert].
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
}) async {
  final actions = [
    DaloyAlertAction(confirmLabel, true, style: DaloyAlertStyle.destructive),
    DaloyAlertAction(cancelLabel, false, style: DaloyAlertStyle.cancel),
  ];
  final index = await _showNative(context, title: title, message: message, actions: actions, sheet: true);
  if (index != _unavailable) return index != null && actions[index].value;
  if (!context.mounted) return false;
  return await _showFlutter<bool>(context, title: title, message: message, actions: [actions[1], actions[0]]) ?? false;
}

/// A plain yes/no. [destructive] colours the confirm red; otherwise it is the
/// bold default. True only when [confirmLabel] is chosen.
Future<bool> confirmAlert(
  BuildContext context, {
  required String title,
  String? message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
  bool native = true,
  Widget Function(Widget child)? wrap,
}) async {
  final confirmed = await showDaloyAlert<bool>(
    context,
    title: title,
    message: message,
    native: native,
    wrap: wrap,
    actions: [
      DaloyAlertAction(cancelLabel, false, style: DaloyAlertStyle.cancel),
      DaloyAlertAction(
        confirmLabel,
        true,
        style: destructive ? DaloyAlertStyle.destructive : DaloyAlertStyle.preferred,
      ),
    ],
  );
  return confirmed ?? false;
}

/// Returned by [_showNative] when there is no native rendering to use.
const _unavailable = -1;

/// The tapped index, null if dismissed, or [_unavailable].
Future<int?> _showNative(
  BuildContext context, {
  required String title,
  required String? message,
  required List<DaloyAlertAction<Object?>> actions,
  required bool sheet,
}) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return _unavailable;
  List<double>? anchor;
  final box = context.findRenderObject();
  if (sheet && box is RenderBox && box.attached) {
    final rect = box.localToGlobal(Offset.zero) & box.size;
    anchor = [rect.left, rect.top, rect.width, rect.height];
  }
  try {
    return await _channel.invokeMethod<int>('show', {
      'title': title,
      'message': message,
      'style': sheet ? 'actionSheet' : 'alert',
      'actions': [
        for (final a in actions) {'title': a.label, 'style': a.style.name},
      ],
      'anchor': ?anchor,
    });
  } on MissingPluginException {
    return _unavailable;
  } on PlatformException catch (e) {
    debugPrint('Alert: native show failed: $e');
    return _unavailable;
  }
}

Future<T?> _showFlutter<T>(
  BuildContext context, {
  required String title,
  String? message,
  Widget? content,
  required List<DaloyAlertAction<T>> actions,
  bool dismissible = false,
  Widget Function(Widget child)? wrap,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: dark ? 0.4 : 0.2),
    transitionDuration: reduceMotion ? Duration.zero : DaloyMotion.fast,
    pageBuilder: (dialogContext, _, _) {
      final panel = _AlertPanel<T>(title: title, message: message, content: content, actions: actions);
      return SafeArea(child: Center(child: wrap == null ? panel : wrap(panel)));
    },
    transitionBuilder: (_, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 1.06, end: 1.0).animate(CurvedAnimation(parent: animation, curve: DaloyMotion.ease)),
        child: child,
      ),
    ),
  );
}

class _AlertPanel<T> extends StatelessWidget {
  const _AlertPanel({required this.title, this.message, this.content, required this.actions});

  final String title;
  final String? message;
  final Widget? content;
  final List<DaloyAlertAction<T>> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Two side by side; three or more stacked, as UIKit does.
    final sideBySide = actions.length == 2;
    final buttons = [for (final a in actions) _AlertButton<T>(action: a)];

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: title,
      explicitChildNodes: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: DaloyGlass.panel(
            radius: 28,
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.all(DaloySpace.s5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: context.text.titleMedium?.copyWith(color: c.foreground)),
                    if (message != null) ...[
                      const SizedBox(height: DaloySpace.s2),
                      Text(message!, style: context.text.bodyMedium?.copyWith(color: c.mutedForeground)),
                    ],
                    if (content != null) ...[
                      const SizedBox(height: DaloySpace.s3),
                      DefaultTextStyle.merge(
                        style: context.text.bodyMedium?.copyWith(color: c.mutedForeground),
                        child: content!,
                      ),
                    ],
                    const SizedBox(height: DaloySpace.s5),
                    if (sideBySide)
                      Row(
                        children: [
                          Expanded(child: buttons[0]),
                          const SizedBox(width: DaloySpace.s2),
                          Expanded(child: buttons[1]),
                        ],
                      )
                    else
                      for (final (i, b) in buttons.indexed) ...[if (i > 0) const SizedBox(height: DaloySpace.s2), b],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertButton<T> extends StatelessWidget {
  const _AlertButton({required this.action});

  final DaloyAlertAction<T> action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = switch (action.style) {
      DaloyAlertStyle.destructive => c.destructive,
      DaloyAlertStyle.preferred => c.primaryInk,
      _ => c.foreground,
    };
    final bold = action.style == DaloyAlertStyle.preferred || action.style == DaloyAlertStyle.destructive;
    return Pressable(
      onPressed: () => Navigator.of(context).pop(action.value),
      semanticLabel: action.label,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
        decoration: BoxDecoration(
          color: c.muted.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(DaloyRadii.full),
        ),
        child: Text(
          action.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodyLarge?.weight(bold ? FontWeight.w600 : FontWeight.w400).copyWith(color: color),
        ),
      ),
    );
  }
}
