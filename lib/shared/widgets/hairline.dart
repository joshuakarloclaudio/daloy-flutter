import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';

/// A 0.5 logical px rule, in place of `Divider`. [indent] insets the start
/// edge to the text, as iOS lists do.
class Hairline extends StatelessWidget {
  const Hairline({super.key, this.indent = 0, this.color});

  final double indent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent),
      child: SizedBox(
        height: 0.5,
        width: double.infinity,
        child: ColoredBox(color: color ?? context.colors.border),
      ),
    );
  }
}
