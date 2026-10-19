import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';

/// A tappable row: leading, title, optional subtitle, trailing. Replaces
/// `ListTile`. Pressing sets the background to `muted`, with no ripple.
class DaloyListRow extends StatefulWidget {
  const DaloyListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.minHeight = 56,
    this.horizontalPadding = DaloySpace.s4,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  /// Null disables the row and dims it.
  final VoidCallback? onTap;
  final double minHeight;
  final double horizontalPadding;

  @override
  State<DaloyListRow> createState() => _DaloyListRowState();
}

class _DaloyListRowState extends State<DaloyListRow> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: enabled ? () => _set(false) : null,
        onTap: widget.onTap,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: ColoredBox(
            color: _pressed ? context.colors.muted : Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding, vertical: DaloySpace.s2),
                child: Row(
                  children: [
                    if (widget.leading != null) ...[widget.leading!, const SizedBox(width: DaloySpace.s3)],
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [widget.title, ?widget.subtitle],
                      ),
                    ),
                    if (widget.trailing != null) ...[const SizedBox(width: DaloySpace.s2), widget.trailing!],
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
