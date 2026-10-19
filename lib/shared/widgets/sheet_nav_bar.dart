import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/daloy_theme.dart';
import 'pressable.dart';

/// A sheet's toolbar: a round ✕ on the left, the title centred, and the one
/// action on the right.
///
/// The action is a teal ✓ when it is just "Save"; any other label is a verb
/// ("Create", "Add 3", "Send") and stays text in a teal capsule. The buttons
/// are flat rather than glass: the sheet under them is already the glass, and
/// glass never nests.
class SheetNavBar extends StatelessWidget {
  const SheetNavBar({
    super.key,
    required this.title,
    required this.onCancel,
    required this.actionLabel,
    required this.onAction,
    required this.pending,
  });

  static const cancelKey = Key('sheet-cancel');
  static const actionKey = Key('sheet-action');

  /// Labels shown as a ✓ instead of text.
  static const _checkLabels = {'Save', 'Done'};

  final String title;
  final VoidCallback? onCancel;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: NavigationToolbar(
        leading: Padding(
          padding: const EdgeInsets.only(left: DaloySpace.s3),
          child: _ToolbarButton(key: cancelKey, icon: TablerIcons.x, label: 'Cancel', onPressed: onCancel),
        ),
        middle: Text(title, style: context.text.titleMedium),
        trailing: Padding(
          padding: const EdgeInsets.only(right: DaloySpace.s3),
          child: pending
              ? const _PendingButton()
              : _checkLabels.contains(actionLabel)
              ? _ToolbarButton(
                  key: actionKey,
                  icon: TablerIcons.check,
                  label: actionLabel,
                  onPressed: onAction,
                  prominent: true,
                )
              : _ToolbarButton(key: actionKey, label: actionLabel, onPressed: onAction, prominent: true),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({super.key, this.icon, required this.label, required this.onPressed, this.prominent = false});

  /// Null draws [label] as text.
  final IconData? icon;
  final String label;
  final VoidCallback? onPressed;
  final bool prominent;

  static const _size = 36.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null;
    final fill = prominent && enabled ? c.primary : c.muted;
    final ink = prominent && enabled
        ? c.primaryForeground
        : enabled
        ? c.foreground
        : c.mutedForeground.withValues(alpha: 0.6);

    return Pressable(
      onPressed: onPressed,
      pressedScale: 0.92,
      semanticLabel: label,
      child: ConstrainedBox(
        // A 44pt target around the 36pt button.
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Container(
            height: _size,
            constraints: const BoxConstraints(minWidth: _size),
            padding: icon == null ? const EdgeInsets.symmetric(horizontal: DaloySpace.s4) : null,
            decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(DaloyRadii.full)),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: ExcludeSemantics(
                child: icon != null
                    ? Icon(icon, size: 18, color: ink)
                    : Text(label, style: context.text.bodyMedium?.weight(FontWeight.w600).copyWith(color: ink)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingButton extends StatelessWidget {
  const _PendingButton();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 44,
    child: Center(
      child: Container(
        width: _ToolbarButton._size,
        height: _ToolbarButton._size,
        decoration: BoxDecoration(color: context.colors.muted, shape: BoxShape.circle),
        child: const CupertinoActivityIndicator(radius: 8),
      ),
    ),
  );
}
