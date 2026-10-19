import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import 'glass_buttons.dart';

/// A screen's one create action. iOS has no floating action button: with a
/// tab bar, Apple's apps (Music, Photos, Files) put it in the top bar's
/// trailing slot, so that is where this lives. Pass it as the last of
/// `DaloyTopBar.actions`; screens never place it themselves.
///
/// On iOS 26+ it is UIKit's prominent glass button tinted with the accent,
/// and a platform view like the other chrome controls. Everywhere else it is
/// a frosted 36pt circle, teal with a white glyph, in the same slot.
class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({super.key, required this.icon, required this.label, required this.onPressed});

  final IconData icon;

  /// Spoken label; the button itself is icon-only.
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: DaloySpace.s1),
      child: GlassIconButton(icon: icon, label: label, onPressed: onPressed, prominent: true),
    );
  }
}
