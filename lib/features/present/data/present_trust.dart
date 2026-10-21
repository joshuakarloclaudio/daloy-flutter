import 'dart:convert';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/prefs/device_prefs.dart';

part 'present_trust.g.dart';

/// Devices paired over the local network, kept so the code is only typed
/// once: a key per device id, with the name it had. A presenter keeps the
/// keys it handed out ("may drive me"); a controller keeps the keys it was
/// given ("I may drive it"). Until forgotten. In memory when [store] is null
/// (tests).
class PresentKeys {
  PresentKeys(this._store, this._key) {
    final raw = _store?.getString(_key);
    if (raw == null) return;
    try {
      for (final MapEntry(:key, :value) in (jsonDecode(raw) as Map).entries) {
        if (value case {'token': final String token, 'name': final String name}) {
          _keys['$key'] = (token: token, name: name);
        }
      }
    } on Object {
      // Unreadable: start over; they pair again with the code.
    }
  }

  final SharedPreferences? _store;
  final String _key;
  final _keys = <String, ({String token, String name})>{};

  String? tokenFor(String deviceId) => _keys[deviceId]?.token;

  /// Every remembered device, by id.
  List<({String id, String name})> get all => [for (final e in _keys.entries) (id: e.key, name: e.value.name)];

  void remember(String deviceId, {required String token, required String name}) {
    _keys[deviceId] = (token: token, name: name);
    _save();
  }

  void forget(String deviceId) {
    if (_keys.remove(deviceId) != null) _save();
  }

  void _save() => _store?.setString(
    _key,
    jsonEncode({
      for (final e in _keys.entries) e.key: {'token': e.value.token, 'name': e.value.name},
    }),
  );
}

/// A long random key for a newly paired device.
String newPresentToken([Random? random]) {
  final r = random ?? Random.secure();
  return base64Url.encode([for (var i = 0; i < 24; i++) r.nextInt(256)]).replaceAll('=', '');
}

/// This install's id on the network, so paired devices know each other
/// again tomorrow, under whatever name or address.
@Riverpod(keepAlive: true)
String presentDeviceId(Ref ref) {
  const key = 'daloy.present.device_id';
  final store = ref.watch(sharedPreferencesProvider);
  final saved = store?.getString(key);
  if (saved != null) return saved;
  final id = newPresentToken().substring(0, 16);
  store?.setString(key, id);
  return id;
}

/// Devices allowed to drive this one's presentation.
@Riverpod(keepAlive: true)
PresentKeys presentTrustedControllers(Ref ref) =>
    PresentKeys(ref.watch(sharedPreferencesProvider), 'daloy.present.trusted');

/// Keys this device was given to drive others' presentations.
@Riverpod(keepAlive: true)
PresentKeys presentPresenterKeys(Ref ref) => PresentKeys(ref.watch(sharedPreferencesProvider), 'daloy.present.keys');

/// Whether this device looks for presentations nearby in the background (the
/// pill above the tab bar). Off until it has opened Present or Remote once,
/// so the system's Local Network prompt comes up where it makes sense.
@Riverpod(keepAlive: true)
class PresentDiscovery extends _$PresentDiscovery {
  static const _key = 'daloy.present.discovery';

  @override
  bool build() => ref.watch(sharedPreferencesProvider)?.getBool(_key) ?? false;

  void enable() {
    if (state) return;
    state = true;
    ref.read(sharedPreferencesProvider)?.setBool(_key, true);
  }
}
