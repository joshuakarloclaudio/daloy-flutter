import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/daloy_theme.dart';
import 'daloy_glass.dart';
import 'pressable.dart';

/// A short-lived glass capsule above the tab bar, in place of a SnackBar.
/// Every message in the app goes through here.
///
/// Pass `ScaffoldMessenger.of(context)`, taken before any `await` so it
/// survives the screen going away. A null [messenger] (from `maybeOf`) shows
/// nothing. With [actionLabel] and [onAction] the capsule carries a trailing
/// action such as **Undo**; tapping it runs [onAction] and dismisses. The
/// toast lasts 3s, or 5s with an action, unless [duration] says otherwise;
/// swiping it down dismisses it early.
void showDaloyToast(
  ScaffoldMessengerState? messenger,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) {
  if (messenger == null) return;
  final action = actionLabel != null && onAction != null;
  final reduceMotion = MediaQuery.maybeDisableAnimationsOf(messenger.context) ?? false;
  if (action) HapticFeedback.lightImpact();
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        persist: false,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        // The capsule draws its own shape and shadow.
        shape: const RoundedRectangleBorder(),
        dismissDirection: DismissDirection.down,
        duration: duration ?? Duration(seconds: action ? 5 : 3),
        content: _ToastCapsule(
          message: message,
          actionLabel: action ? actionLabel : null,
          onAction: action
              ? () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                }
              : null,
        ),
      ),
      // No slide for people who asked for less motion.
      snackBarAnimationStyle: reduceMotion ? AnimationStyle.noAnimation : null,
    );
}

/// Placeholder for actions not built yet.
void showComingSoon(BuildContext context, String what) =>
    showDaloyToast(ScaffoldMessenger.of(context), '$what is coming soon.');

class _ToastCapsule extends StatelessWidget {
  const _ToastCapsule({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final media = MediaQuery.of(context);
    // Inside the Scaffold, so this already counts the tab bar and any
    // now-playing bar the shell floats at the bottom.
    final bottom = (media.viewInsets.bottom > 0 ? media.viewInsets.bottom : media.padding.bottom) + DaloySpace.s3;

    return Padding(
      padding: EdgeInsets.fromLTRB(DaloySpace.s4, 0, DaloySpace.s4, bottom),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: media.size.width * 0.9),
          child: DaloyGlass.capsule(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                DaloySpace.s4,
                DaloySpace.s3,
                actionLabel == null ? DaloySpace.s4 : DaloySpace.s2,
                DaloySpace.s3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(message, style: context.text.bodyMedium?.copyWith(color: c.foreground)),
                  ),
                  if (actionLabel != null)
                    Pressable(
                      onPressed: onAction,
                      pressedScale: 0.94,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s1),
                        child: Text(
                          actionLabel!,
                          style: context.text.bodyMedium?.weight(FontWeight.w600).copyWith(color: c.primaryInk),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
