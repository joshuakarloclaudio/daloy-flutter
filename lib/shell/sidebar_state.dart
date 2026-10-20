import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/prefs/device_prefs.dart';

/// Whether the tablet sidebar is open, kept apart for each orientation: it
/// starts open in landscape (there is room) and collapsed to the top tab bar in
/// portrait, then remembers what was last chosen in each. Per device, like the
/// other `DevicePrefs`.
final sidebarOpenProvider = NotifierProvider<SidebarOpen, ({bool landscape, bool portrait})>(SidebarOpen.new);

class SidebarOpen extends Notifier<({bool landscape, bool portrait})> {
  static const _landscapeKey = 'daloy.sidebar_open_landscape';
  static const _portraitKey = 'daloy.sidebar_open_portrait';

  @override
  ({bool landscape, bool portrait}) build() {
    final store = ref.watch(sharedPreferencesProvider);
    return (landscape: store?.getBool(_landscapeKey) ?? true, portrait: store?.getBool(_portraitKey) ?? false);
  }

  bool isOpen({required bool landscape}) => landscape ? state.landscape : state.portrait;

  void set({required bool landscape, required bool open}) {
    state = landscape ? (landscape: open, portrait: state.portrait) : (landscape: state.landscape, portrait: open);
    ref.read(sharedPreferencesProvider)?.setBool(landscape ? _landscapeKey : _portraitKey, open);
  }

  void toggle({required bool landscape}) => set(
    landscape: landscape,
    open: !isOpen(landscape: landscape),
  );
}

/// The Mac's sidebar: collapsed to an icon rail or not, and how wide it is
/// open (dragged from its edge). Starts open at [defaultWidth]; per device.
final desktopSidebarProvider = NotifierProvider<DesktopSidebar, ({bool collapsed, double width})>(DesktopSidebar.new);

class DesktopSidebar extends Notifier<({bool collapsed, double width})> {
  static const _collapsedKey = 'daloy.desktop_sidebar_collapsed';
  static const _widthKey = 'daloy.desktop_sidebar_width';

  static const defaultWidth = 240.0;
  static const minWidth = 200.0;
  static const maxWidth = 360.0;
  static const railWidth = 56.0;

  @override
  ({bool collapsed, double width}) build() {
    final store = ref.watch(sharedPreferencesProvider);
    return (
      collapsed: store?.getBool(_collapsedKey) ?? false,
      width: (store?.getDouble(_widthKey) ?? defaultWidth).clamp(minWidth, maxWidth),
    );
  }

  void toggle() {
    state = (collapsed: !state.collapsed, width: state.width);
    ref.read(sharedPreferencesProvider)?.setBool(_collapsedKey, state.collapsed);
  }

  /// While the edge is dragged (a rail opens up); [save] once it's let go.
  void resizeBy(double dx) {
    final from = state.collapsed ? railWidth : state.width;
    state = (collapsed: false, width: (from + dx).clamp(minWidth, maxWidth));
  }

  void save() {
    final store = ref.read(sharedPreferencesProvider);
    store?.setDouble(_widthKey, state.width);
    store?.setBool(_collapsedKey, state.collapsed);
  }

  void reset() {
    state = (collapsed: false, width: defaultWidth);
    save();
  }
}
