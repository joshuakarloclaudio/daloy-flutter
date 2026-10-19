import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/network/network_providers.dart';
import 'core/prefs/device_prefs.dart';
import 'core/storage/session_store.dart';
import 'features/present/presentation/present_output_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Credentials are read once up front so every request — and the router's
  // first redirect — sees them synchronously.
  final sessionStore = SessionStore();
  await sessionStore.load();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sessionStoreProvider.overrideWithValue(sessionStore),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const DaloyApp(),
    ),
  );
}

/// Present's external screen (HDMI, AirPlay, Miracast): a second engine the
/// native side starts with this entry point, drawing only the slides.
@pragma('vm:entry-point')
void presentOutputMain() => runPresentOutput();
