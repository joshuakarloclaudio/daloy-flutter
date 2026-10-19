/// Compile-time configuration, set with `--dart-define`.
///
/// ```sh
/// flutter run                                                  # iOS simulator → host
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000  # Android emulator → host
/// ```
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');

  /// The public web app, for links people open in a browser (share links).
  static const siteUrl = String.fromEnvironment('SITE_URL', defaultValue: 'https://daloy.pro');

  /// Custom URL scheme the API redirects to after Google sign-in
  /// (`MOBILE_OAUTH_CALLBACK_URL` on the API). Registered in
  /// AndroidManifest.xml; iOS needs no registration for an auth session.
  static const oauthCallbackScheme = 'daloy';

  static const requestTimeout = Duration(seconds: 30);

  /// How long an unused connection to the API stays open for the next request.
  static const httpIdleTimeout = Duration(seconds: 60);

  /// Plays YouTube with the sound off — for checking the player on a
  /// simulator without it playing out loud (`--dart-define=PLAYER_MUTED=true`).
  static const playerMuted = bool.fromEnvironment('PLAYER_MUTED');

  /// Safety-net poll for a live performance, used only while the realtime
  /// socket is down (web: LIVE_SESSION_POLL_MS). Updates normally arrive over
  /// Reverb in about a second.
  static const liveSessionFallbackPollInterval = Duration(seconds: 60);

  /// Laravel Reverb (WebSocket). Defaults to the API host with Reverb's dev
  /// port, so only the Android emulator needs `REVERB_HOST=10.0.2.2` —
  /// unless `API_BASE_URL` already points there.
  static const _reverbHost = String.fromEnvironment('REVERB_HOST');
  static const reverbPort = int.fromEnvironment('REVERB_PORT', defaultValue: 8080);
  static const reverbKey = String.fromEnvironment('REVERB_APP_KEY', defaultValue: 'local-reverb-key');
  static const reverbUseTls = bool.fromEnvironment('REVERB_TLS');

  static String get reverbHost => _reverbHost.isNotEmpty ? _reverbHost : Uri.parse(apiBaseUrl).host;
}
