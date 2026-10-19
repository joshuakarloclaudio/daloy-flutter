import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/hairline.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/sheet_nav_bar.dart';
import '../application/team_actions.dart';
import '../domain/team_models.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Invite by email, as a member or an admin. If that email already has an
/// account they're added at once; otherwise a link goes out.
Future<void> showInviteSheet(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final result = await showDaloySheet<InviteResult>(
    context: context,
    toolbar: true,
    fit: true,
    builder: (_) => const _InviteSheet(),
  );
  if (result == null) return;
  final who = result.member?.name ?? result.invitation?.email ?? 'They';
  showDaloyToast(messenger, result.wasAdded ? '$who is on the team now.' : 'Invitation sent to $who.');
}

class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet();

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final _email = TextEditingController();
  String _role = TeamRole.member;
  bool _pending = false;
  String? _error;

  bool get _valid => _emailPattern.hasMatch(_email.text.trim());

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_valid || _pending) return;
    setState(() {
      _pending = true;
      _error = null;
    });
    try {
      final result = await ref.read(teamActionsProvider.notifier).invite(email: _email.text.trim(), role: _role);
      await HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop(result);
    } on ApiException catch (e) {
      await HapticFeedback.heavyImpact();
      if (mounted) {
        setState(() {
          _pending = false;
          _error = apiErrorMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PopScope(
      canPop: !_pending,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SheetNavBar(
                  title: 'Invite someone',
                  onCancel: _pending ? null : () => Navigator.of(context).pop(),
                  actionLabel: 'Send',
                  onAction: _valid && !_pending ? _send : null,
                  pending: _pending,
                ),
                Hairline(),
                Padding(
                  padding: const EdgeInsets.all(DaloySpace.s5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DaloyTextField(
                        label: 'Email',
                        controller: _email,
                        hint: 'name@church.org',
                        autofocus: true,
                        enabled: !_pending,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.send,
                        autofillHints: const [AutofillHints.email],
                        error: _error,
                        onChanged: (_) => setState(() => _error = null),
                        onSubmitted: (_) => _send(),
                      ),
                      const SizedBox(height: DaloySpace.s4),
                      SegmentedControl<String>(
                        value: _role,
                        options: const [(TeamRole.member, 'Member'), (TeamRole.admin, 'Admin')],
                        onChanged: (r) => setState(() => _role = r),
                      ),
                      const SizedBox(height: DaloySpace.s2),
                      Text(TeamRole.describe(_role), style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
