import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'device_prefs.g.dart';

/// Which typeface the app is set in. [daloy] is DM Sans / Merriweather;
/// [system] hands every label to the platform's own font.
enum AppFont { daloy, system }

/// How long the app may sit in the background before the lock asks again.
enum LockDelay {
  immediately(Duration.zero, 'Immediately'),
  oneMinute(Duration(minutes: 1), 'After 1 minute'),
  fiveMinutes(Duration(minutes: 5), 'After 5 minutes');

  const LockDelay(this.duration, this.label);

  final Duration duration;
  final String label;
}

/// How this device looks and guards itself. Never synced: a stage tablet
/// and a phone want different things, and these outlive signing out.
@immutable
class DevicePrefs {
  const DevicePrefs({
    this.themeMode = ThemeMode.system,
    this.font = AppFont.daloy,
    this.lockEnabled = false,
    this.lockDelay = LockDelay.oneMinute,
    this.cuePanelWidth = defaultCuePanelWidth,
  });

  /// Perform's docked cue panel, in logical px; dragged wider or narrower.
  static const defaultCuePanelWidth = 340.0;
  static const minCuePanelWidth = 280.0;
  static const maxCuePanelWidth = 560.0;

  final ThemeMode themeMode;
  final AppFont font;

  /// Face ID / fingerprint is asked for on opening the app.
  final bool lockEnabled;
  final LockDelay lockDelay;
  final double cuePanelWidth;

  DevicePrefs copyWith({
    ThemeMode? themeMode,
    AppFont? font,
    bool? lockEnabled,
    LockDelay? lockDelay,
    double? cuePanelWidth,
  }) => DevicePrefs(
    themeMode: themeMode ?? this.themeMode,
    font: font ?? this.font,
    lockEnabled: lockEnabled ?? this.lockEnabled,
    lockDelay: lockDelay ?? this.lockDelay,
    cuePanelWidth: cuePanelWidth ?? this.cuePanelWidth,
  );

  @override
  bool operator ==(Object other) =>
      other is DevicePrefs &&
      other.themeMode == themeMode &&
      other.font == font &&
      other.lockEnabled == lockEnabled &&
      other.lockDelay == lockDelay &&
      other.cuePanelWidth == cuePanelWidth;

  @override
  int get hashCode => Object.hash(themeMode, font, lockEnabled, lockDelay, cuePanelWidth);
}

/// Loaded in `main()` before the first frame so the theme never flashes.
/// Null in tests, where nothing persists.
@Riverpod(keepAlive: true)
SharedPreferences? sharedPreferences(Ref ref) => null;

@Riverpod(keepAlive: true)
class DevicePrefsController extends _$DevicePrefsController {
  static const _themeKey = 'daloy.theme_mode';
  static const _fontKey = 'daloy.app_font';
  static const _lockKey = 'daloy.lock_enabled';
  static const _lockDelayKey = 'daloy.lock_delay';
  static const _cuePanelWidthKey = 'daloy.cue_panel_width';

  SharedPreferences? get _store => ref.read(sharedPreferencesProvider);

  @override
  DevicePrefs build() {
    final store = ref.watch(sharedPreferencesProvider);
    if (store == null) return const DevicePrefs();
    return DevicePrefs(
      themeMode: ThemeMode.values.asNameMap()[store.getString(_themeKey)] ?? ThemeMode.system,
      font: AppFont.values.asNameMap()[store.getString(_fontKey)] ?? AppFont.daloy,
      lockEnabled: store.getBool(_lockKey) ?? false,
      lockDelay: LockDelay.values.asNameMap()[store.getString(_lockDelayKey)] ?? LockDelay.oneMinute,
      cuePanelWidth: (store.getDouble(_cuePanelWidthKey) ?? DevicePrefs.defaultCuePanelWidth).clamp(
        DevicePrefs.minCuePanelWidth,
        DevicePrefs.maxCuePanelWidth,
      ),
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _store?.setString(_themeKey, mode.name);
  }

  void setFont(AppFont font) {
    state = state.copyWith(font: font);
    _store?.setString(_fontKey, font.name);
  }

  void setLockEnabled(bool on) {
    state = state.copyWith(lockEnabled: on);
    _store?.setBool(_lockKey, on);
  }

  void setCuePanelWidth(double width) {
    state = state.copyWith(cuePanelWidth: width);
    _store?.setDouble(_cuePanelWidthKey, width);
  }

  void setLockDelay(LockDelay delay) {
    state = state.copyWith(lockDelay: delay);
    _store?.setString(_lockDelayKey, delay.name);
  }
}
