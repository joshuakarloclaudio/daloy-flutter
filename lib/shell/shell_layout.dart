import 'package:flutter/widgets.dart';

import '../core/theme/daloy_tokens.dart';
import '../core/utils/platform.dart';

/// Which shell is showing (DESIGN.md → Navigation). A phone gets the docked
/// tab bar, and a tablet at least `md` (768) wide gets the top tab bar ⇄
/// sidebar (`tablet_shell.dart`). A tablet is told by its shortest side, so a
/// phone on its side stays a phone and an iPad squeezed narrow in Split View
/// falls back to the tab bar. The Mac and Windows are always the desktop: a
/// fixed sidebar that collapses to a rail (`desktop_shell.dart`), the window
/// never narrower than a tablet (`MainFlutterWindow.swift`,
/// `windows/runner/flutter_window.cpp`).
enum ShellLayout {
  phone,
  tablet,
  desktop;

  /// Room for split views, popover sheets and the search panel: anything
  /// but a phone.
  bool get wide => this != phone;

  static ShellLayout of(BuildContext context) {
    if (isDesktop) return desktop;
    final size = MediaQuery.sizeOf(context);
    return size.width >= DaloyBreakpoints.tablet && size.shortestSide >= DaloyBreakpoints.tabletShortestSide
        ? tablet
        : phone;
  }
}
