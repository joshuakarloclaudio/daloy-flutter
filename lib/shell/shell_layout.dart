import 'package:flutter/widgets.dart';

import '../core/theme/daloy_tokens.dart';

/// Which shell is showing (DESIGN.md → Navigation). Every target here is a
/// touch device: a phone gets the docked tab bar, and a tablet at least `md`
/// (768) wide gets the top tab bar ⇄ sidebar (`tablet_shell.dart`). A tablet
/// is told by its shortest side, so a phone on its side stays a phone and an
/// iPad squeezed narrow in Split View falls back to the tab bar. The web's
/// desktop sidebar has no counterpart here.
enum ShellLayout {
  phone,
  tablet;

  static ShellLayout of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width >= DaloyBreakpoints.tablet && size.shortestSide >= DaloyBreakpoints.tabletShortestSide
        ? tablet
        : phone;
  }
}
