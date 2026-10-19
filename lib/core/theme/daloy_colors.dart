import 'package:flutter/material.dart';

/// Daloy's color tokens — the `:root` / `.dark` variables in
/// `frontend/app/app.css`, converted from OKLCH to sRGB.
///
/// The rules from DESIGN.md carry over:
/// - **One accent.** [primary] (Confident Teal) is the only brand hue. Use it
///   as a wash (`primary.withValues(alpha: .10–.30)`) on badges, borders and
///   gradients; solid only for primary buttons, the active tab, and live dots.
/// - **Today Emerald** ([today]) answers one question ("is this happening
///   today?") and never appears anywhere else.
@immutable
class DaloyColors extends ThemeExtension<DaloyColors> {
  const DaloyColors({
    required this.background,
    required this.foreground,
    required this.card,
    required this.primary,
    required this.primaryForeground,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.border,
    required this.ring,
    required this.destructive,
    required this.sidebar,
    required this.sidebarPrimary,
    required this.chordInk,
    required this.today,
    required this.todayInk,
    required this.todayBorder,
    required this.todayWashFrom,
    required this.todayWashTo,
    required this.todayOrb,
    required this.todayOrbAlt,
  });

  /// Canvas White / near-charcoal.
  final Color background;

  /// Ink Charcoal — primary text.
  final Color foreground;
  final Color card;

  /// Confident Teal (light) / Deep Teal (dark).
  final Color primary;

  /// Foam Mint — text on [primary].
  final Color primaryForeground;
  final Color secondaryForeground;

  /// Quiet Mist — hover fills, troughs, skeletons.
  final Color muted;

  /// Soft Slate — metadata, timestamps, helper copy.
  final Color mutedForeground;

  /// Hairline Gray — every border and input stroke.
  final Color border;
  final Color ring;

  /// Alert Red. A wash before it's a fill.
  final Color destructive;

  /// Docked chrome surface (tab bar).
  final Color sidebar;

  /// Active-destination icon in the tab bar / sidebar.
  final Color sidebarPrimary;

  /// `--chart-4`: chord color; brighter on dark grounds for contrast.
  final Color chordInk;

  /// Today Emerald (`emerald-600`) — the Perform button on a "Today" card.
  final Color today;

  /// Today chip text.
  final Color todayInk;
  final Color todayBorder;
  final Color todayWashFrom;
  final Color todayWashTo;
  final Color todayOrb;
  final Color todayOrbAlt;

  static const light = DaloyColors(
    background: Color(0xFFFFFFFF),
    foreground: Color(0xFF09090B),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF007A55),
    primaryForeground: Color(0xFFECFDF5),
    secondaryForeground: Color(0xFF18181B),
    muted: Color(0xFFF4F4F5),
    mutedForeground: Color(0xFF71717B),
    border: Color(0xFFE4E4E7),
    ring: Color(0xFF9F9FA9),
    destructive: Color(0xFFE7000B),
    sidebar: Color(0xFFFAFAFA),
    sidebarPrimary: Color(0xFF009966),
    chordInk: Color(0xFF007A55),
    today: Color(0xFF059669),
    todayInk: Color(0xFF047857),
    todayBorder: Color(0xCC6EE7B7),
    todayWashFrom: Color(0xFFECFDF5),
    todayWashTo: Color(0x99F0FDFA),
    todayOrb: Color(0x4034D399),
    todayOrbAlt: Color(0x332DD4BF),
  );

  static const dark = DaloyColors(
    background: Color(0xFF09090B),
    foreground: Color(0xFFFAFAFA),
    card: Color(0xFF18181B),
    primary: Color(0xFF006045),
    primaryForeground: Color(0xFFECFDF5),
    secondaryForeground: Color(0xFFFAFAFA),
    muted: Color(0xFF27272A),
    mutedForeground: Color(0xFF9F9FA9),
    border: Color(0x1AFFFFFF),
    ring: Color(0xFF71717B),
    destructive: Color(0xFFFF6467),
    sidebar: Color(0xFF18181B),
    sidebarPrimary: Color(0xFF00BC7D),
    chordInk: Color(0xFF4FCB9C),
    today: Color(0xFF059669),
    todayInk: Color(0xFF34D399),
    todayBorder: Color(0x80047857),
    todayWashFrom: Color(0x80022C22),
    todayWashTo: Color(0x4D042F2E),
    todayOrb: Color(0x2610B981),
    todayOrbAlt: Color(0x1F14B8A6),
  );

  /// The "Live now" / "Tomorrow" chip text. Deep Teal is too dim to read as
  /// text on dark grounds, so dark mode borrows the brighter sidebar mint.
  Color get primaryInk => primary == dark.primary ? sidebarPrimary : primary;

  @override
  DaloyColors copyWith({Color? background, Color? foreground, Color? primary}) => DaloyColors(
    background: background ?? this.background,
    foreground: foreground ?? this.foreground,
    card: card,
    primary: primary ?? this.primary,
    primaryForeground: primaryForeground,
    secondaryForeground: secondaryForeground,
    muted: muted,
    mutedForeground: mutedForeground,
    border: border,
    ring: ring,
    destructive: destructive,
    sidebar: sidebar,
    sidebarPrimary: sidebarPrimary,
    chordInk: chordInk,
    today: today,
    todayInk: todayInk,
    todayBorder: todayBorder,
    todayWashFrom: todayWashFrom,
    todayWashTo: todayWashTo,
    todayOrb: todayOrb,
    todayOrbAlt: todayOrbAlt,
  );

  @override
  DaloyColors lerp(DaloyColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return DaloyColors(
      background: l(background, other.background),
      foreground: l(foreground, other.foreground),
      card: l(card, other.card),
      primary: l(primary, other.primary),
      primaryForeground: l(primaryForeground, other.primaryForeground),
      secondaryForeground: l(secondaryForeground, other.secondaryForeground),
      muted: l(muted, other.muted),
      mutedForeground: l(mutedForeground, other.mutedForeground),
      border: l(border, other.border),
      ring: l(ring, other.ring),
      destructive: l(destructive, other.destructive),
      sidebar: l(sidebar, other.sidebar),
      sidebarPrimary: l(sidebarPrimary, other.sidebarPrimary),
      chordInk: l(chordInk, other.chordInk),
      today: l(today, other.today),
      todayInk: l(todayInk, other.todayInk),
      todayBorder: l(todayBorder, other.todayBorder),
      todayWashFrom: l(todayWashFrom, other.todayWashFrom),
      todayWashTo: l(todayWashTo, other.todayWashTo),
      todayOrb: l(todayOrb, other.todayOrb),
      todayOrbAlt: l(todayOrbAlt, other.todayOrbAlt),
    );
  }
}
