import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/widgets.dart';

/// The one spinner: UIKit's activity indicator on every platform, never
/// Material's ring. [size] is the diameter; use ~14 inline, ~20 standalone.
class DaloySpinner extends StatelessWidget {
  const DaloySpinner({super.key, this.size = 20, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CupertinoActivityIndicator(radius: size / 2, color: color),
  );
}
