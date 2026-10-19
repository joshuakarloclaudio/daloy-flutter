import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';
import '../domain/account_deletion_preview.dart';
import '../domain/auth_user.dart';

part 'auth_service.g.dart';

/// `/api/auth/*` calls. Plain functions over [ApiClient] — no state.
class AuthService {
  const AuthService(this._api);

  final ApiClient _api;

  Future<AuthResult> login({required String email, required String password}) =>
      _api.post('/api/auth/login', Decode.object(AuthResult.fromJson), body: {'email': email, 'password': password});

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) => _api.post(
    '/api/auth/register',
    Decode.object(AuthResult.fromJson),
    body: {'name': name, 'email': email, 'password': password, 'password_confirmation': passwordConfirmation},
  );

  Future<void> forgotPassword({required String email}) =>
      _api.post('/api/auth/forgot-password', (_) {}, body: {'email': email});

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) => _api.post(
    '/api/auth/reset-password',
    (_) {},
    body: {'token': token, 'email': email, 'password': password, 'password_confirmation': passwordConfirmation},
  );

  /// Trades the one-time key from the Google callback for a session.
  Future<AuthResult> exchangeGoogle(String exchange) =>
      _api.post('/api/auth/google/exchange', Decode.object(AuthResult.fromJson), body: {'exchange': exchange});

  Future<AuthUser> me() => _api.get('/api/auth/me', Decode.object(AuthUser.fromJson));

  Future<void> logout() => _api.post('/api/auth/logout', (_) {});

  Future<AuthUser> setLastWorkspace(int workspaceId) =>
      _api.patch('/api/auth/me/last-workspace', Decode.object(AuthUser.fromJson), body: {'workspace_id': workspaceId});

  Future<AuthUser> updateChordNotation(String notation) =>
      _api.patch('/api/auth/me/chord-notation', Decode.object(AuthUser.fromJson), body: {'chord_notation': notation});

  Future<AuthUser> updatePreferredView(String view) =>
      _api.patch('/api/auth/me/preferred-view', Decode.object(AuthUser.fromJson), body: {'preferred_view': view});

  /// What deleting the account would take with it, and whether anything blocks it.
  Future<AccountDeletionPreview> accountDeletionPreview() =>
      _api.get('/api/auth/me/deletion-preview', Decode.object(AccountDeletionPreview.fromJson));

  /// Deletes the account for good. [password] for accounts that have one;
  /// [confirmEmail] for Google-only accounts.
  Future<void> deleteAccount({String? password, String? confirmEmail}) =>
      _api.delete('/api/auth/me', body: {'password': ?password, 'confirm_email': ?confirmEmail});

  /// Opened in a system auth session. `client=mobile` makes the API redirect
  /// back to [AppConfig.oauthCallbackScheme] instead of the web app.
  static Uri googleRedirectUrl() => Uri.parse('${AppConfig.apiBaseUrl}/api/auth/google/redirect?client=mobile');
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => AuthService(ref.watch(apiClientProvider));
