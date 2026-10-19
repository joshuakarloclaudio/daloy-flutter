import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import 'daloy_spinner.dart';
import 'pressable.dart';

enum ButtonVariant { primary, outline, ghost, destructive, link, plain }

/// What a primary button is filled with. [today] is the Today Emerald fill,
/// used only for "Go live" on a line-up happening today.
enum ButtonTone { brand, today }

/// The Daloy button (`components/ui/button.tsx`).
///
/// Heights come from [ControlSize] only — pick one per toolbar and never
/// override it. [ButtonVariant.plain] is tinted text that dims on press. Destructive is a red *wash*, never a solid fill.
class DaloyButton extends StatelessWidget {
  const DaloyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.leading,
    this.variant = ButtonVariant.primary,
    this.size = ControlSize.md,
    this.tone = ButtonTone.brand,
    this.expand = false,
    this.loading = false,
  });

  const DaloyButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.leading,
    this.size = ControlSize.md,
    this.expand = false,
    this.loading = false,
  }) : variant = ButtonVariant.outline,
       tone = ButtonTone.brand;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// A custom glyph in [icon]'s slot, e.g. a brand logo. Sized by the caller.
  final Widget? leading;
  final ButtonVariant variant;
  final ControlSize size;
  final ButtonTone tone;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null && !loading;
    final fill = tone == ButtonTone.today ? c.today : c.primary;

    final (Color bg, Color fg, BoxBorder? border) = switch (variant) {
      ButtonVariant.primary => (fill, tone == ButtonTone.today ? Colors.white : c.primaryForeground, null),
      ButtonVariant.outline => (c.background, c.foreground, Border.all(color: c.border)),
      ButtonVariant.ghost => (Colors.transparent, c.foreground, null),
      ButtonVariant.destructive => (c.destructive.withValues(alpha: 0.1), c.destructive, null),
      ButtonVariant.link => (Colors.transparent, c.primary, null),
      ButtonVariant.plain => (Colors.transparent, c.primaryInk, null),
    };

    final textStyle = (size == ControlSize.sm ? context.text.labelMedium : context.text.labelLarge)!.copyWith(
      color: fg,
      fontSize: size == ControlSize.sm ? 13 : 14,
    );
    final iconSize = size == ControlSize.sm ? 16.0 : 18.0;
    final isLink = variant == ButtonVariant.link;
    final isPlain = variant == ButtonVariant.plain;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          DaloySpinner(size: iconSize, color: fg)
        else if (leading != null)
          leading!
        else if (icon != null)
          Icon(icon, size: iconSize, color: fg),
        if (loading || leading != null || icon != null) const SizedBox(width: DaloySpace.s1_5),
        Flexible(
          child: Text(label, style: textStyle, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Pressable(
        onPressed: enabled ? onPressed : null,
        pressedScale: isPlain ? 1 : 0.98,
        pressedOpacity: isPlain ? 0.5 : 1,
        child: Container(
          height: isLink || isPlain ? null : size.height,
          padding: isPlain
              ? const EdgeInsets.symmetric(vertical: DaloySpace.s2)
              : isLink
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(horizontal: size == ControlSize.sm ? 12 : 16),
          decoration: BoxDecoration(
            color: bg,
            border: border,
            borderRadius: DaloyRadii.all(DaloyRadii.xl),
            boxShadow: variant == ButtonVariant.primary && tone == ButtonTone.today
                ? [
                    BoxShadow(
                      color: c.today.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Round, flat icon button for top bars and card overflow menus
/// (`TopBarIconButton`). 40px, 44px hit area.
class TopBarIconButton extends StatelessWidget {
  const TopBarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.size = 40,
    this.spinning = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  /// Spins the icon — for refresh while a sync runs.
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget glyph = Icon(icon, size: 20, color: c.foreground);
    if (spinning) glyph = _Spin(child: glyph);

    return Pressable(
      onPressed: onPressed,
      semanticLabel: tooltip,
      child: SizedBox.square(
        dimension: size < 44 ? 44 : size,
        child: Center(
          child: Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Center(child: glyph),
          ),
        ),
      ),
    );
  }
}

class _Spin extends StatefulWidget {
  const _Spin({required this.child});

  final Widget child;

  @override
  State<_Spin> createState() => _SpinState();
}

class _SpinState extends State<_Spin> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(turns: _controller, child: widget.child);
}
