import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/daloy_theme.dart';

/// Tap target with Daloy's press feedback: a slight scale-down on press
/// (the web's `active:scale-[0.998]` / `translate-y-px`), with no ripple.
/// Wrap cards and buttons in this instead of an `InkWell`.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.pressedScale = 0.97,
    this.pressedOpacity = 1,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double pressedScale;

  /// Opacity while pressed. Text-only controls dim instead of scaling.
  final double pressedOpacity;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null || widget.onLongPress != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _set(true) : null,
          onTapUp: enabled ? (_) => _set(false) : null,
          onTapCancel: enabled ? () => _set(false) : null,
          onTap: widget.onPressed,
          onLongPress: widget.onLongPress == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  widget.onLongPress!();
                },
          child: AnimatedScale(
            scale: _pressed ? widget.pressedScale : 1,
            duration: DaloyMotion.fast,
            curve: DaloyMotion.ease,
            child: widget.pressedOpacity == 1
                ? widget.child
                : AnimatedOpacity(
                    opacity: _pressed ? widget.pressedOpacity : 1,
                    duration: DaloyMotion.fast,
                    curve: DaloyMotion.ease,
                    child: widget.child,
                  ),
          ),
        ),
      ),
    );
  }
}
