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
import '../application/session_controller.dart';
import 'widgets/auth_layout.dart';

/// Where the link in the reset email lands: pick a new password. Works signed
/// out (the usual case) and signed in.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.token, required this.email});

  final String? token;
  final String? email;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  bool get _linkOk => (widget.token ?? '').isNotEmpty && (widget.email ?? '').isNotEmpty;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() {
    TextInput.finishAutofillContext();
    ref
        .read(resetPasswordFormProvider.notifier)
        .submit(
          token: widget.token ?? '',
          email: widget.email ?? '',
          password: _password.text,
          passwordConfirmation: _confirmation.text,
        );
  }

  void _leave() {
    final signedIn = ref.read(sessionControllerProvider).value != null;
    context.go(signedIn ? Routes.home : Routes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(resetPasswordFormProvider);
    final c = context.colors;

    if (!_linkOk) {
      return AuthScaffold(
        eyebrow: 'Hindi ito gumana',
        title: 'This link isn’t complete',
        subtitle: const Text('Open the link from your email again, or ask for a new reset link.'),
        children: [
          DaloyButton(
            label: 'Get a new link',
            size: ControlSize.lg,
            expand: true,
            onPressed: () => context.go(Routes.forgotPassword),
          ),
          const SizedBox(height: DaloySpace.s3),
          DaloyButton(
            variant: ButtonVariant.ghost,
            label: 'Back',
            size: ControlSize.lg,
            expand: true,
            onPressed: _leave,
          ),
        ],
      );
    }

    if (form.sentTo != null) {
      return AuthScaffold(
        eyebrow: 'Tapos na',
        title: 'Password updated',
        subtitle: const Text('You can sign in with your new password.'),
        children: [DaloyButton(label: 'Continue', size: ControlSize.lg, expand: true, onPressed: _leave)],
      );
    }

    return AuthScaffold(
      eyebrow: 'Bagong password',
      title: 'Choose a new password',
      subtitle: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'For '),
            TextSpan(
              text: widget.email,
              style: TextStyle(color: c.foreground, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      footer: DaloyButton(variant: ButtonVariant.link, label: 'Back', onPressed: _leave),
      children: [
        if (form.formError != null) ...[AuthNotice(form.formError!), const SizedBox(height: DaloySpace.s5)],
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DaloyTextField(
                label: 'New password',
                controller: _password,
                hint: 'At least 8 characters',
                icon: TablerIcons.lock,
                obscure: true,
                autofocus: true,
                error: form.fieldErrors['password'],
                enabled: !form.pending,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: DaloySpace.s5),
              DaloyTextField(
                label: 'Confirm password',
                controller: _confirmation,
                hint: 'Type it again',
                icon: TablerIcons.lock,
                obscure: true,
                error: form.fieldErrors['password_confirmation'],
                enabled: !form.pending,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                onSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
        const SizedBox(height: DaloySpace.s6),
        DaloyButton(
          label: form.pending ? 'Saving…' : 'Update password',
          size: ControlSize.lg,
          expand: true,
          loading: form.pending,
          onPressed: form.pending ? null : _submit,
        ),
      ],
    );
  }
}
