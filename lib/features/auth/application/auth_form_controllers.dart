import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_service.dart';
import '../data/google_sign_in.dart';
import 'session_controller.dart';

part 'auth_form_controllers.freezed.dart';
part 'auth_form_controllers.g.dart';

/// State of one auth form. Field keys match the API's (`email`,
/// `password`, `password_confirmation`, `name`), so 422s map straight on.
@freezed
abstract class AuthFormState with _$AuthFormState {
  const AuthFormState._();

  const factory AuthFormState({
    @Default(false) bool pending,
    @Default(false) bool googlePending,
    String? formError,
    @Default(<String, String>{}) Map<String, String> fieldErrors,

    /// Forgot password: the address the reset link went to.
    String? sentTo,
  }) = _AuthFormState;

  bool get busy => pending || googlePending;
}

/// Sign-in screen (web: `use-login.ts` + `login-form.tsx`).
@riverpod
class SignInForm extends _$SignInForm {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> submit({required String email, required String password}) async {
    if (state.busy) return;
    final errors = {..._emailErrors(email), if (password.isEmpty) 'password': 'Password is required'};
    if (errors.isNotEmpty) {
      state = AuthFormState(fieldErrors: errors);
      return;
    }

    state = const AuthFormState(pending: true);
    try {
      await ref.read(sessionControllerProvider.notifier).signIn(email: email.trim(), password: password);
      if (ref.mounted) state = const AuthFormState();
    } on ApiException catch (e) {
      if (ref.mounted) state = _failed(e);
    }
  }

  Future<void> continueWithGoogle() async => _google(ref, () => state, (s) => state = s);
}

/// Create-account screen (web: `use-register.ts` + `register-form.tsx`).
@riverpod
class RegisterForm extends _$RegisterForm {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> submit({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (state.busy) return;
    final errors = {
      if (name.trim().isEmpty) 'name': 'Full name is required',
      if (name.trim().length > 255) 'name': 'Name must be at most 255 characters',
      ..._emailErrors(email),
      if (password.length < 8) 'password': 'Password must be at least 8 characters',
      if (passwordConfirmation.isEmpty)
        'password_confirmation': 'Please confirm your password'
      else if (password != passwordConfirmation)
        'password_confirmation': 'Passwords do not match',
    };
    if (errors.isNotEmpty) {
      state = AuthFormState(fieldErrors: errors);
      return;
    }

    state = const AuthFormState(pending: true);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .register(
            name: name.trim(),
            email: email.trim(),
            password: password,
            passwordConfirmation: passwordConfirmation,
          );
      if (ref.mounted) state = const AuthFormState();
    } on ApiException catch (e) {
      if (ref.mounted) state = _failed(e, fields: const {'name', 'email', 'password', 'password_confirmation'});
    }
  }

  Future<void> continueWithGoogle() async => _google(ref, () => state, (s) => state = s);
}

/// Forgot-password screen. The reset link in the email opens the app when it
/// is installed (see `ResetPasswordScreen`), the web app otherwise.
@riverpod
class ForgotPasswordForm extends _$ForgotPasswordForm {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> submit({required String email}) async {
    if (state.busy) return;
    final errors = _emailErrors(email);
    if (errors.isNotEmpty) {
      state = AuthFormState(fieldErrors: errors);
      return;
    }

    state = const AuthFormState(pending: true);
    try {
      await ref.read(authServiceProvider).forgotPassword(email: email.trim());
      if (ref.mounted) state = AuthFormState(sentTo: email.trim());
    } on ApiException catch (e) {
      if (ref.mounted) state = _failed(e, fields: const {'email'});
    }
  }

  void reset() => state = const AuthFormState();
}

/// Choosing a new password from the emailed link. [AuthFormState.sentTo]
/// holds the address once it's been changed.
@riverpod
class ResetPasswordForm extends _$ResetPasswordForm {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> submit({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (state.busy) return;
    final errors = {
      if (password.length < 8) 'password': 'Password must be at least 8 characters',
      if (passwordConfirmation.isEmpty)
        'password_confirmation': 'Please confirm your password'
      else if (password != passwordConfirmation)
        'password_confirmation': 'Passwords do not match',
    };
    if (errors.isNotEmpty) {
      state = AuthFormState(fieldErrors: errors);
      return;
    }

    state = const AuthFormState(pending: true);
    try {
      await ref
          .read(authServiceProvider)
          .resetPassword(token: token, email: email, password: password, passwordConfirmation: passwordConfirmation);
      if (ref.mounted) state = AuthFormState(sentTo: email);
    } on ApiException catch (e) {
      if (ref.mounted) state = _failed(e, fields: const {'password', 'password_confirmation'});
    }
  }
}

Future<void> _google(Ref ref, AuthFormState Function() read, void Function(AuthFormState) write) async {
  if (read().busy) return;
  write(const AuthFormState(googlePending: true));
  try {
    await ref.read(sessionControllerProvider.notifier).signInWithGoogle();
    if (ref.mounted) write(const AuthFormState());
  } on GoogleSignInException catch (e) {
    if (ref.mounted) write(AuthFormState(formError: e.message));
  } on ApiException catch (e) {
    if (ref.mounted) write(AuthFormState(formError: e.message));
  }
}

/// Field errors when the API names a field the form shows; otherwise one
/// form-level message.
AuthFormState _failed(ApiException error, {Set<String> fields = const {'email', 'password'}}) {
  if (error case ApiValidationException(:final errors)) {
    final shown = {
      for (final MapEntry(:key, :value) in errors.entries)
        if (fields.contains(key) && value.isNotEmpty) key: value.first,
    };
    if (shown.isNotEmpty) return AuthFormState(fieldErrors: shown);
    final first = errors.values.expand((m) => m).firstOrNull;
    return AuthFormState(formError: first ?? error.message);
  }
  return AuthFormState(formError: error.message);
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

Map<String, String> _emailErrors(String raw) {
  final email = raw.trim();
  if (email.isEmpty) return {'email': 'Email is required'};
  if (!_emailPattern.hasMatch(email)) return {'email': 'Enter a valid email address'};
  if (email.length > 255) return {'email': 'Email must be at most 255 characters'};
  return const {};
}
