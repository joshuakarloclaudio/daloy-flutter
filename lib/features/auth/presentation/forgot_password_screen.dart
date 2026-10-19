import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../application/auth_form_controllers.dart';
import 'widgets/auth_layout.dart';

/// Sends the reset email. The link in it opens the web app, which sets the
/// new password; the user then signs in here.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() => ref.read(forgotPasswordFormProvider.notifier).submit(email: _email.text);

  void _backToSignIn() => context.canPop() ? context.pop() : context.go(Routes.signIn);

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(forgotPasswordFormProvider);
    final c = context.colors;

    if (form.sentTo case final email?) {
      return AuthScaffold(
        eyebrow: 'Check your inbox',
        title: 'Reset link sent',
        subtitle: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'If an account exists for '),
              TextSpan(
                text: email,
                style: TextStyle(color: c.foreground, fontWeight: FontWeight.w500),
              ),
              const TextSpan(text: ', we sent a password reset link. The link expires after a short time.'),
            ],
          ),
        ),
        children: [
          DaloyButton.outline(label: 'Back to sign in', size: ControlSize.lg, expand: true, onPressed: _backToSignIn),
          const SizedBox(height: DaloySpace.s3),
          DaloyButton(
            variant: ButtonVariant.ghost,
            label: 'Use a different email',
            expand: true,
            onPressed: ref.read(forgotPasswordFormProvider.notifier).reset,
          ),
        ],
      );
    }

    return AuthScaffold(
      eyebrow: 'Account recovery',
      title: 'Reset password',
      subtitle: const Text("Enter the email for your account and we'll send you a reset link."),
      footer: Center(
        child: DaloyButton(variant: ButtonVariant.link, label: 'Back to sign in', onPressed: _backToSignIn),
      ),
      children: [
        if (form.formError != null) ...[AuthNotice(form.formError!), const SizedBox(height: DaloySpace.s5)],
        DaloyTextField(
          label: 'Email',
          controller: _email,
          hint: 'you@church.ph',
          icon: TablerIcons.mail,
          error: form.fieldErrors['email'],
          enabled: !form.pending,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          autofillHints: const [AutofillHints.email],
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: DaloySpace.s6),
        DaloyButton(
          label: form.pending ? 'Sending…' : 'Send reset link',
          size: ControlSize.lg,
          expand: true,
          loading: form.pending,
          onPressed: form.pending ? null : _submit,
        ),
      ],
    );
  }
}
