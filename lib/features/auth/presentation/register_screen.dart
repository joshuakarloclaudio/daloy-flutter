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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    TextInput.finishAutofillContext();
    ref
        .read(registerFormProvider.notifier)
        .submit(
          name: _name.text,
          email: _email.text,
          password: _password.text,
          passwordConfirmation: _confirmation.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(registerFormProvider);
    final controller = ref.read(registerFormProvider.notifier);

    return AuthScaffold(
      eyebrow: 'Simulan natin',
      title: 'Create an account',
      subtitle: const Text('Join your team and plan worship together.'),
      footer: AuthSwitchPrompt(
        prompt: 'Already have an account?',
        action: 'Sign in',
        onPressed: () => context.go(Routes.signIn),
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
                label: 'Full name',
                controller: _name,
                hint: 'Your name',
                icon: TablerIcons.user,
                error: form.fieldErrors['name'],
                enabled: !form.busy,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
              ),
              const SizedBox(height: DaloySpace.s5),
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
                hint: 'At least 8 characters',
                icon: TablerIcons.lock,
                obscure: true,
                error: form.fieldErrors['password'],
                enabled: !form.busy,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: DaloySpace.s5),
              DaloyTextField(
                label: 'Confirm password',
                controller: _confirmation,
                hint: 'Re-enter your password',
                icon: TablerIcons.lock_check,
                obscure: true,
                error: form.fieldErrors['password_confirmation'],
                enabled: !form.busy,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: DaloySpace.s6),
        DaloyButton(
          label: form.pending ? 'Creating account…' : 'Create account',
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
