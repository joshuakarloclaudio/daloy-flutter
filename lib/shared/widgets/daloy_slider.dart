import 'package:flutter/cupertino.dart' show CupertinoSlider;
import 'package:flutter/widgets.dart';

import '../../core/theme/daloy_theme.dart';

/// A slider drawn as UIKit's: a [CupertinoSlider] in Daloy's palette.
///
/// `CNSlider` has no end-of-drag callback, which scrubbing needs (seek on
/// release), so this is the Flutter rendering on every platform.
class DaloySlider extends StatelessWidget {
  const DaloySlider({super.key, required this.value, required this.onChanged, this.onChangeEnd, this.activeColor});

  /// 0–1.
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CupertinoSlider(
      value: value,
      onChanged: onChanged,
      onChangeEnd: onChangeEnd,
      activeColor: activeColor ?? c.primary,
      thumbColor: c.card,
    );
  }
}
