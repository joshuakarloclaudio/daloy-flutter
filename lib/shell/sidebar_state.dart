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
