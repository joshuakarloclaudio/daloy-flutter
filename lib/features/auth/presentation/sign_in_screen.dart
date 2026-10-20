import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../application/auth_form_controllers.dart';
import '../data/google_sign_in.dart';
import 'widgets/auth_layout.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    TextInput.finishAutofillContext();
    ref.read(signInFormProvider.notifier).submit(email: _email.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(signInFormProvider);
    final controller = ref.read(signInFormProvider.notifier);

    return AuthScaffold(
      eyebrow: 'Maligayang pagdating',
      title: 'Welcome back',
      subtitle: const Text("Sign in to plan this Sunday's worship."),
      footer: AuthSwitchPrompt(
        prompt: 'New to Daloy?',
        action: 'Create an account',
        onPressed: () => context.go(Routes.register),
      ),
      children: [
        if (GoogleSignIn.available) ...[
          GoogleSignInButton(loading: form.googlePending, onPressed: form.busy ? null : controller.continueWithGoogle),
          const SizedBox(height: DaloySpace.s5),
          const AuthDivider(),
          const SizedBox(height: DaloySpace.s5),
        ],
        if (form.formError != null) ...[AuthNotice(form.formError!), const SizedBox(height: DaloySpace.s5)],
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DaloyTextField(
                label: 'Email',
                controller: _email,
                hint: 'you@church.ph',
                icon: TablerIcons.mail,
                error: form.fieldErrors['email'],
                enabled: !form.busy,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
              ),
              const SizedBox(height: DaloySpace.s5),
              DaloyTextField(
                label: 'Password',
                controller: _password,
                hint: 'Enter your password',
                icon: TablerIcons.lock,
                obscure: true,
                error: form.fieldErrors['password'],
                enabled: !form.busy,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                labelTrailing: DaloyButton(
                  variant: ButtonVariant.link,
                  label: 'Forgot password?',
                  onPressed: () => context.push(Routes.forgotPassword),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DaloySpace.s6),
        DaloyButton(
          label: form.pending ? 'Signing in…' : 'Sign in',
          size: ControlSize.lg,
          expand: true,
          loading: form.pending,
          onPressed: form.busy ? null : _submit,
        ),
        const SizedBox(height: DaloySpace.s6),
        const AuthLegalNotice(),
      ],
    );
  }
}
