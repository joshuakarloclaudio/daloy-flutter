// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_form_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sign-in screen (web: `use-login.ts` + `login-form.tsx`).

@ProviderFor(SignInForm)
final signInFormProvider = SignInFormProvider._();

/// Sign-in screen (web: `use-login.ts` + `login-form.tsx`).
final class SignInFormProvider
    extends $NotifierProvider<SignInForm, AuthFormState> {
  /// Sign-in screen (web: `use-login.ts` + `login-form.tsx`).
  SignInFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInFormHash();

  @$internal
  @override
  SignInForm create() => SignInForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthFormState>(value),
    );
  }
}

String _$signInFormHash() => r'1683e0ce8a74ce9c52a91a7a39a568a8ab24f40e';

/// Sign-in screen (web: `use-login.ts` + `login-form.tsx`).

abstract class _$SignInForm extends $Notifier<AuthFormState> {
  AuthFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthFormState, AuthFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthFormState, AuthFormState>,
              AuthFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Create-account screen (web: `use-register.ts` + `register-form.tsx`).

@ProviderFor(RegisterForm)
final registerFormProvider = RegisterFormProvider._();

/// Create-account screen (web: `use-register.ts` + `register-form.tsx`).
final class RegisterFormProvider
    extends $NotifierProvider<RegisterForm, AuthFormState> {
  /// Create-account screen (web: `use-register.ts` + `register-form.tsx`).
  RegisterFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerFormHash();

  @$internal
  @override
  RegisterForm create() => RegisterForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthFormState>(value),
    );
  }
}

String _$registerFormHash() => r'febccd0fc3ac4446a243cb08c7138c226b6654d3';

/// Create-account screen (web: `use-register.ts` + `register-form.tsx`).

abstract class _$RegisterForm extends $Notifier<AuthFormState> {
  AuthFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthFormState, AuthFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthFormState, AuthFormState>,
              AuthFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Forgot-password screen. The reset link in the email opens the app when it
/// is installed (see `ResetPasswordScreen`), the web app otherwise.

@ProviderFor(ForgotPasswordForm)
final forgotPasswordFormProvider = ForgotPasswordFormProvider._();

/// Forgot-password screen. The reset link in the email opens the app when it
/// is installed (see `ResetPasswordScreen`), the web app otherwise.
final class ForgotPasswordFormProvider
    extends $NotifierProvider<ForgotPasswordForm, AuthFormState> {
  /// Forgot-password screen. The reset link in the email opens the app when it
  /// is installed (see `ResetPasswordScreen`), the web app otherwise.
  ForgotPasswordFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordFormHash();

  @$internal
  @override
  ForgotPasswordForm create() => ForgotPasswordForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthFormState>(value),
    );
  }
}

String _$forgotPasswordFormHash() =>
    r'3ea34d2fd7c7e8ce98bb5d386ff99b168ac64e06';

/// Forgot-password screen. The reset link in the email opens the app when it
/// is installed (see `ResetPasswordScreen`), the web app otherwise.

abstract class _$ForgotPasswordForm extends $Notifier<AuthFormState> {
  AuthFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthFormState, AuthFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthFormState, AuthFormState>,
              AuthFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Choosing a new password from the emailed link. [AuthFormState.sentTo]
/// holds the address once it's been changed.

@ProviderFor(ResetPasswordForm)
final resetPasswordFormProvider = ResetPasswordFormProvider._();

/// Choosing a new password from the emailed link. [AuthFormState.sentTo]
/// holds the address once it's been changed.
final class ResetPasswordFormProvider
    extends $NotifierProvider<ResetPasswordForm, AuthFormState> {
  /// Choosing a new password from the emailed link. [AuthFormState.sentTo]
  /// holds the address once it's been changed.
  ResetPasswordFormProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetPasswordFormProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetPasswordFormHash();

  @$internal
  @override
  ResetPasswordForm create() => ResetPasswordForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthFormState>(value),
    );
  }
}

String _$resetPasswordFormHash() => r'189dab4d36329af093f9e782c05a0454b99ca0bb';

/// Choosing a new password from the emailed link. [AuthFormState.sentTo]
/// holds the address once it's been changed.

abstract class _$ResetPasswordForm extends $Notifier<AuthFormState> {
  AuthFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthFormState, AuthFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthFormState, AuthFormState>,
              AuthFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
