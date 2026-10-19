import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/presentation/widgets/auth_layout.dart';
import '../../workspaces/presentation/new_workspace_sheet.dart';
import '../application/join_controller.dart';
import '../application/pending_link.dart';

/// Opens from a join link, a QR code or an invitation email: shows which
/// workspace is asking and joins it. Signed out, it sends the person to
/// sign in or register first, then brings them back here.
class JoinScreen extends ConsumerStatefulWidget {
  const JoinScreen({super.key, required this.kind, required this.token});

  final JoinKind kind;
  final String token;

  @override
  ConsumerState<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends ConsumerState<JoinScreen> {
  bool _pending = false;
  String? _error;

  String get _location => widget.kind == JoinKind.link ? Routes.join(widget.token) : Routes.invite(widget.token);

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.home);
    }
  }

  void _toAuth(String route) {
    ref.read(pendingLinkProvider.notifier).hold(_location);
    context.go(route);
  }

  Future<void> _join() async {
    setState(() {
      _pending = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final workspace = await ref.read(joinActionsProvider.notifier).join(widget.kind, widget.token);
      await HapticFeedback.mediumImpact();
      ref.read(pendingLinkProvider.notifier).take();
      if (!mounted) return;
      context.go(Routes.home);
      showDaloyToast(messenger, 'You joined ${workspace.name}.');
    } on ApiException catch (e) {
      await HapticFeedback.heavyImpact();
      if (mounted) {
        setState(() {
          _pending = false;
          _error = isLinkGone(e) ? 'This link has expired or was turned off.' : apiErrorMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = ref.watch(joinPreviewProvider(widget.kind, widget.token));
    final session = ref.watch(sessionControllerProvider).value;
    final c = context.colors;
    final invitation = widget.kind == JoinKind.invitation;

    return preview.when(
      loading: () => const Scaffold(body: Center(child: DaloySpinner())),
      error: (e, _) => AuthScaffold(
        eyebrow: isLinkGone(e) ? 'Hindi na gumagana' : 'Walang koneksyon',
        title: isLinkGone(e) ? 'This link isn’t valid anymore' : 'Couldn’t open the link',
        subtitle: Text(
          isLinkGone(e)
              ? 'It may have expired or been turned off. Ask an admin of the workspace for a new one.'
              : apiErrorMessage(e),
        ),
        children: [
          if (!isLinkGone(e))
            DaloyButton(
              label: 'Try again',
              size: ControlSize.lg,
              expand: true,
              onPressed: () => ref.invalidate(joinPreviewProvider(widget.kind, widget.token)),
            ),
          if (!isLinkGone(e)) const SizedBox(height: DaloySpace.s3),
          DaloyButton(
            variant: ButtonVariant.ghost,
            label: session == null ? 'Back to sign in' : 'Not now',
            size: ControlSize.lg,
            expand: true,
            onPressed: session == null ? () => context.go(Routes.signIn) : _leave,
          ),
        ],
      ),
      data: (data) {
        final wrongAccount =
            invitation &&
            session != null &&
            data.email != null &&
            data.email!.toLowerCase() != session.user.email.toLowerCase();
        return AuthScaffold(
          eyebrow: invitation ? 'Imbitado ka' : 'Sumali ka',
          title: data.workspaceName,
          subtitle: Text(
            session == null
                ? 'Sign in or create an account to join as ${_article(data.role)} ${data.role}.'
                : 'You’ll join as ${_article(data.role)} ${data.role}.',
          ),
          footer: DaloyButton(
            variant: ButtonVariant.link,
            label: 'Not now',
            onPressed: session == null ? () => context.go(Routes.signIn) : _leave,
          ),
          children: [
            Center(child: WorkspaceNamePreview(name: data.workspaceName, size: 88)),
            const SizedBox(height: DaloySpace.s6),
            if (wrongAccount) ...[
              AuthNotice(
                'This invitation was sent to ${data.email}, but you’re signed in as ${session.user.email}. '
                'Sign out and use that account to accept it.',
                isError: false,
              ),
              const SizedBox(height: DaloySpace.s5),
            ],
            if (_error != null) ...[AuthNotice(_error!), const SizedBox(height: DaloySpace.s5)],
            if (session == null) ...[
              DaloyButton(
                label: 'Sign in',
                size: ControlSize.lg,
                expand: true,
                onPressed: () => _toAuth(Routes.signIn),
              ),
              const SizedBox(height: DaloySpace.s3),
              DaloyButton.outline(
                label: 'Create an account',
                size: ControlSize.lg,
                expand: true,
                onPressed: () => _toAuth(Routes.register),
              ),
              if (data.email != null) ...[
                const SizedBox(height: DaloySpace.s3),
                Text(
                  'Use ${data.email} so the invitation finds you.',
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                ),
              ],
            ] else
              DaloyButton(
                label: _pending ? 'Joining…' : 'Join ${data.workspaceName}',
                icon: TablerIcons.users_plus,
                size: ControlSize.lg,
                expand: true,
                loading: _pending,
                onPressed: _pending || wrongAccount ? null : _join,
              ),
          ],
        );
      },
    );
  }

  static String _article(String role) => role.toLowerCase().startsWith('a') ? 'an' : 'a';
}
