import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/platform.dart';
import 'auth_service.dart';

part 'google_sign_in.g.dart';

/// Google sign-in didn't finish. [message] is safe to show.
class GoogleSignInException implements Exception {
  const GoogleSignInException(this.message);

  final String message;

  /// The API's `google_error` codes (web: `lib/google-oauth-errors.ts`).
  factory GoogleSignInException.fromCode(String code) => GoogleSignInException(switch (code) {
    'no_email' =>
      'Google did not share an email address. Use another sign-in method or pick a different Google account.',
    'account_suspended' => 'Your account has been suspended.',
    _ => _genericMessage,
  });

  static const _genericMessage = 'Google sign-in did not complete. Please try again.';

  @override
  String toString() => 'GoogleSignInException: $message';
}

/// Runs the API's Google OAuth round-trip in a system auth session
/// (ASWebAuthenticationSession / Custom Tab) and returns the one-time
/// exchange key, or `null` if the user closed the sheet.
class GoogleSignIn {
  const GoogleSignIn();

  /// Not on Windows yet: `flutter_web_auth_2` can only return there through
  /// an `http://localhost` callback, which the API doesn't redirect to.
  static bool get available => !isWindows;

  Future<String?> authorize() async {
    final String callback;
    try {
      callback = await FlutterWebAuth2.authenticate(
        url: AuthService.googleRedirectUrl().toString(),
        callbackUrlScheme: AppConfig.oauthCallbackScheme,
      );
    } on PlatformException catch (e) {
      if (e.code == 'CANCELED') return null;
      throw const GoogleSignInException(GoogleSignInException._genericMessage);
    }

    final query = Uri.parse(callback).queryParameters;
    final error = query['google_error'];
    if (error != null) throw GoogleSignInException.fromCode(error);
    final exchange = query['exchange'];
    if (exchange == null || exchange.isEmpty) {
      throw const GoogleSignInException(GoogleSignInException._genericMessage);
    }
    return exchange;
  }
}

@Riverpod(keepAlive: true)
GoogleSignIn googleSignIn(Ref ref) => const GoogleSignIn();
