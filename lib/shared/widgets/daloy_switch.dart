import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/daloy_theme.dart';

/// An on/off switch: Daloy's teal adaptive switch.
class DaloySwitch extends StatelessWidget {
  const DaloySwitch({super.key, required this.value, required this.onChanged, this.semanticLabel});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final toggle = Switch.adaptive(
      value: value,
      activeTrackColor: c.primary,
      onChanged: (v) {
        HapticFeedback.selectionClick();
        onChanged(v);
      },
    );
    if (semanticLabel == null) return toggle;
    return Semantics(label: semanticLabel, child: toggle);
  }
}
