import 'package:flutter/widgets.dart';

import '../utils/platform.dart';

/// Corner radii (DESIGN.md `rounded`). Cards are [xl2]; buttons and inputs [xl].
abstract final class DaloyRadii {
  static const sm = 6.0;
  static const md = 8.0;
  static const lg = 10.0;
  static const xl = 14.0;
  static const xl2 = 18.0;
  static const xl3 = 22.0;
  static const full = 9999.0;

  static BorderRadius all(double r) => BorderRadius.all(Radius.circular(r));
}

/// Spacing on Tailwind's 4px grid, named by the class it replaces
/// (`s5` = `p-5` = 20px).
abstract final class DaloySpace {
  static const s1 = 4.0;
  static const s1_5 = 6.0;
  static const s2 = 8.0;
  static const s2_5 = 10.0;
  static const s3 = 12.0;
  static const s3_5 = 14.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s9 = 36.0;
  static const s10 = 40.0;

  /// Side gutter of a screen's content column (`px-5` phone / `md:px-8`).
  static double gutter(BuildContext context) => MediaQuery.sizeOf(context).width >= DaloyBreakpoints.tablet ? s8 : s5;
}

abstract final class DaloyBreakpoints {
  /// `md` — touch tablet (top tab bar ⇄ sidebar) from here up; phone (tab bar) below.
  static const tablet = 768.0;

  /// A screen's shortest side from here up is a tablet's; phones top out
  /// near 440.
  static const tabletShortestSide = 600.0;

  /// `lg` — Home's two lists sit side by side from here.
  static const wide = 1024.0;

  /// `max-w-5xl` — content column cap.
  static const contentMaxWidth = 1024.0;
}

/// One height scale for every control: the web's `pointer-coarse` values
/// on touch screens, one notch down (32/36/40) on the desktop, where a
/// pointer does the aiming. Never override a height at the call site.
enum ControlSize {
  sm(40, 32),
  md(44, 36),
  lg(48, 40);

  const ControlSize(this._touch, this._pointer);
  final double _touch;
  final double _pointer;

  double get height => isDesktop ? _pointer : _touch;
}

/// Shell chrome dimensions.
abstract final class DaloyChrome {
  static const topBarHeight = 48.0;
  static const tabBarHeight = 56.0;
  static const fabSize = 56.0;
}

abstract final class DaloyMotion {
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const pulse = Duration(milliseconds: 1400);
  static const ease = Curves.easeOutCubic;
}
