import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/daloy_theme.dart';

/// A short row of mutually exclusive options. The active one is a lifted chip
/// riding on a muted trough that slides between options (DESIGN.md → Segmented
/// Controls): separated by lift, not fill, with the weight constant so labels
/// never reflow. Tap, or drag a finger across it like a native switch.
/// Not for navigation.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.disabled = const {},
    this.size = ControlSize.md,
    this.onGlass = false,
  });

  static const _inset = 3.0;

  final T value;
  final List<(T value, String label)> options;
  final ValueChanged<T> onChanged;

  /// Options that show but can't be chosen.
  final Set<T> disabled;
  final ControlSize size;

  /// Sitting on a glass capsule that is already the trough: no trough of its
  /// own, a capsule chip, and whatever height it is given.
  final bool onGlass;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final index = options.indexWhere((o) => o.$1 == value);
    final duration = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 240);

    return LayoutBuilder(
      builder: (context, box) {
        final segment = (box.maxWidth - _inset * 2) / options.length;

        int? at(double dx) {
          final i = ((dx - _inset) / segment).floor().clamp(0, options.length - 1);
          return disabled.contains(options[i].$1) ? null : i;
        }

        void choose(int? i) {
          if (i == null || options[i].$1 == value) return;
          HapticFeedback.selectionClick();
          onChanged(options[i].$1);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => choose(at(d.localPosition.dx)),
          onHorizontalDragUpdate: (d) => choose(at(d.localPosition.dx)),
          child: Container(
            height: onGlass ? null : size.height,
            decoration: onGlass ? null : BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.xl)),
            child: Stack(
              children: [
                // The chip. Lighter than the trough in dark mode, as in light.
                AnimatedPositioned(
                  duration: duration,
                  curve: DaloyMotion.ease,
                  left: _inset + (index < 0 ? 0 : index) * segment,
                  top: _inset,
                  bottom: _inset,
                  width: segment,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: dark
                          ? Color.alphaBlend(Colors.white.withValues(alpha: onGlass ? 0.14 : 0.09), c.muted)
                          : c.background,
                      border: onGlass
                          ? null
                          : Border.all(color: dark ? Colors.white.withValues(alpha: 0.06) : c.border),
                      borderRadius: DaloyRadii.all(onGlass ? DaloyRadii.full : DaloyRadii.lg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                        if (onGlass)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: dark ? 0.3 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  left: _inset,
                  right: _inset,
                  child: Row(
                    children: [
                      for (final (option, label) in options)
                        Expanded(
                          child: Semantics(
                            button: true,
                            selected: option == value,
                            enabled: !disabled.contains(option),
                            label: label,
                            excludeSemantics: true,
                            onTap: disabled.contains(option)
                                ? null
                                : () => choose(options.indexWhere((o) => o.$1 == option)),
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: duration,
                                curve: DaloyMotion.ease,
                                style: context.text.labelLarge!.copyWith(
                                  color: disabled.contains(option)
                                      ? c.mutedForeground.withValues(alpha: 0.45)
                                      : (option == value ? c.foreground : c.mutedForeground),
                                ),
                                child: Text(label, maxLines: 1),
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
        );
      },
    );
  }
}
