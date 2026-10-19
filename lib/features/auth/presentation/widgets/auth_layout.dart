import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_button.dart';
import '../../../../shared/widgets/daloy_top_bar.dart';
import '../../../../shared/widgets/flow_artwork.dart';
import '../../../../shared/widgets/hairline.dart';
import 'google_logo.dart';

/// The centred, single-column frame every auth screen shares
/// (web: `routes/auth/layout.tsx` + each form's header).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
    this.footer,
  });

  final String eyebrow;
  final String title;
  final Widget subtitle;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: Navigator.of(context).canPop() ? const DaloyTopBar(transparent: true) : null,
      body: Stack(
        children: [
          // The flow lines from every cover, faint along the bottom.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 280,
            child: FlowLines(seed: 5, color: c.primaryInk, intensity: 0.7),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(horizontal: DaloySpace.gutter(context), vertical: DaloySpace.s8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        eyebrow.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: context.text.labelMedium!.copyWith(
                          color: c.primaryInk,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.4,
                        ),
                      ),
                      const SizedBox(height: DaloySpace.s4),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: context.text.displaySmall!.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: DaloySpace.s3),
                      DefaultTextStyle.merge(
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                        child: subtitle,
                      ),
                      const SizedBox(height: DaloySpace.s8),
                      ...children,
                      if (footer != null) ...[const SizedBox(height: DaloySpace.s8), footer!],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Form-level message: a destructive wash for errors, a primary wash for
/// confirmations.
class AuthNotice extends StatelessWidget {
  const AuthNotice(this.message, {super.key, this.isError = true});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? context.colors.destructive : context.colors.primaryInk;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          borderRadius: DaloyRadii.all(DaloyRadii.xl),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium!.copyWith(color: color),
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed, this.loading = false});

  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => DaloyButton.outline(
    label: 'Continue with Google',
    leading: const GoogleLogo(),
    size: ControlSize.lg,
    expand: true,
    loading: loading,
    onPressed: onPressed,
  );
}

/// "or continue with email".
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DaloySpace.s1),
      child: Row(
        children: [
          const Expanded(child: Hairline()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
            child: Text('or continue with email', style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
          ),
          const Expanded(child: Hairline()),
        ],
      ),
    );
  }
}

/// "New to Daloy? Create an account" style footer line.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({super.key, required this.prompt, required this.action, required this.onPressed});

  final String prompt;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: DaloySpace.s1,
    children: [
      Text(prompt, style: context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground)),
      DaloyButton(variant: ButtonVariant.link, label: action, onPressed: onPressed),
    ],
  );
}

/// Shown under sign-in and sign-up (web: `AuthLegalNotice`).
class AuthLegalNotice extends StatelessWidget {
  const AuthLegalNotice({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'By continuing, you agree to our Terms of Use and Privacy Policy.',
    textAlign: TextAlign.center,
    style: context.text.bodySmall!.copyWith(color: context.colors.mutedForeground),
  );
}
