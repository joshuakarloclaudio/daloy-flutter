import '../config/app_config.dart';
import 'routes.dart';

final _token = RegExp(r'^[A-Za-z0-9_-]{8,128}$');
final _appPath = RegExp(r'^/(songs|line-ups)/\d+$');

/// The in-app location for something the OS handed the app, or null when
/// it isn't ours to open. Two kinds arrive:
///
///  * an app path (`/songs/12`) from a Spotlight hit or launcher shortcut;
///  * a link on the public site (Universal / App Links): `/share/j/<token>`
///    to join through a join link, `/auth/register?invite=<token>` from an
///    invitation email, `/auth/reset-password?token=…&email=…` from a reset
///    email.
String? routeForIncomingLink(String raw, {String? siteHost}) {
  if (raw.startsWith('/')) return _appPath.hasMatch(raw) || raw == Routes.newLineUp ? raw : null;

  final uri = Uri.tryParse(raw);
  if (uri == null) return null;
  final host = siteHost ?? Uri.parse(AppConfig.siteUrl).host;

  String? join(String? token) => token != null && _token.hasMatch(token) ? '/join/$token' : null;
  String? invite(String? token) => token != null && _token.hasMatch(token) ? '/invite/$token' : null;
  String? reset(Map<String, String> query) {
    final token = query['token'];
    final email = query['email'];
    if (token == null || token.isEmpty || email == null || email.isEmpty) return null;
    return Uri(path: '/reset-password', queryParameters: {'token': token, 'email': email}).toString();
  }

  if (uri.scheme == 'https' || uri.scheme == 'http') {
    if (uri.host != host && uri.host != 'www.$host') return null;
    final segments = uri.pathSegments;
    if (segments.length == 3 && segments[0] == 'share' && segments[1] == 'j') return join(segments[2]);
    if (segments.length == 2 && segments[0] == 'auth') {
      if (segments[1] == 'register') return invite(uri.queryParameters['invite']);
      if (segments[1] == 'reset-password') return reset(uri.queryParameters);
    }
    return null;
  }

  // The launcher shortcuts on Android: daloy://open/songs/12.
  if (uri.scheme == AppConfig.oauthCallbackScheme && uri.host == 'open') {
    if (uri.path == Routes.lineUps && uri.queryParameters['new'] == '1') return Routes.newLineUp;
    return _appPath.hasMatch(uri.path) ? uri.path : null;
  }
  return null;
}
