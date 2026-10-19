import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_alert.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/sheet_frame.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../application/team_actions.dart';
import '../domain/team_models.dart';

/// A member: who they are, which role they hold (tap the other to change it),
/// and removing them.
Future<void> showMemberSheet(BuildContext context, {required TeamMember member, required bool isMe}) =>
    showDaloySheet<void>(
      context: context,
      fit: true,
      builder: (_) => _MemberSheet(member: member, isMe: isMe),
    );

/// A pending invitation: details and revoking it.
Future<void> showInvitationSheet(BuildContext context, TeamInvitation invitation) => showDaloySheet<void>(
  context: context,
  fit: true,
  builder: (_) => _InvitationSheet(invitation: invitation),
);

class _MemberSheet extends ConsumerStatefulWidget {
  const _MemberSheet({required this.member, required this.isMe});

  final TeamMember member;
  final bool isMe;

  @override
  ConsumerState<_MemberSheet> createState() => _MemberSheetState();
}

class _MemberSheetState extends ConsumerState<_MemberSheet> {
  late String _role = widget.member.role;
  bool _pending = false;
  String? _error;

  Future<void> _run(Future<void> Function() action, {bool closeAfter = false}) async {
    setState(() {
      _pending = true;
      _error = null;
    });
    try {
      await action();
      await HapticFeedback.mediumImpact();
      if (closeAfter && mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      await HapticFeedback.heavyImpact();
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  Future<void> _setRole(String role) async {
    if (role == _role || _pending) return;
    final previous = _role;
    setState(() => _role = role);
    await _run(() => ref.read(teamActionsProvider.notifier).setRole(widget.member, role));
    if (_error != null && mounted) setState(() => _role = previous);
  }

  Future<void> _remove() async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: 'Remove ${widget.member.name}?',
      message:
          'They lose access to this workspace’s songs and line-ups. They can rejoin with an invite or the join link.',
      confirmLabel: 'Remove',
    );
    if (!confirmed || !mounted) return;
    await _run(() => ref.read(teamActionsProvider.notifier).remove(widget.member), closeAfter: true);
    if (_error == null) {
      showDaloyToast(messenger, 'Removed ${widget.member.name}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.muted, shape: BoxShape.circle),
                  child: Text(workspaceInitials(widget.member.name), style: context.text.titleSmall),
                ),
                const SizedBox(width: DaloySpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.member.name,
                        style: context.text.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.member.email,
                        style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DaloySpace.s5),
            for (final role in const [TeamRole.admin, TeamRole.member]) ...[
              _RoleOption(
                role: role,
                selected: _role == role,
                // Your own role can't be lowered here: the server refuses it
                // so a workspace is never left without an admin.
                enabled: !_pending && !(widget.isMe && role != TeamRole.admin),
                onTap: () => _setRole(role),
              ),
              const SizedBox(height: DaloySpace.s2),
            ],
            if (widget.isMe)
              Text(
                'You can’t change your own role or remove yourself. Ask another admin.',
                style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
              ),
            if (_error != null) ...[
              const SizedBox(height: DaloySpace.s2),
              Text(_error!, style: context.text.bodySmall!.copyWith(color: c.destructive)),
            ],
            if (!widget.isMe) ...[
              const SizedBox(height: DaloySpace.s4),
              DaloyButton(
                variant: ButtonVariant.destructive,
                icon: TablerIcons.user_minus,
                label: 'Remove from workspace',
                expand: true,
                size: ControlSize.lg,
                loading: _pending,
                onPressed: _remove,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({required this.role, required this.selected, required this.enabled, required this.onTap});

  final String role;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Opacity(
      opacity: enabled || selected ? 1 : 0.5,
      child: Material(
        color: selected ? c.primary.withValues(alpha: 0.08) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: DaloyRadii.all(DaloyRadii.xl),
          side: BorderSide(color: selected ? c.primary : c.border, width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: DaloyRadii.all(DaloyRadii.xl),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(DaloySpace.s3_5),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(formatRole(role), style: context.text.titleSmall),
                      const SizedBox(height: 2),
                      Text(TeamRole.describe(role), style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
                    ],
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: DaloySpace.s2),
                  Icon(TablerIcons.check, size: 20, color: c.primaryInk),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InvitationSheet extends ConsumerStatefulWidget {
  const _InvitationSheet({required this.invitation});

  final TeamInvitation invitation;

  @override
  ConsumerState<_InvitationSheet> createState() => _InvitationSheetState();
}

class _InvitationSheetState extends ConsumerState<_InvitationSheet> {
  bool _pending = false;
  String? _error;

  Future<void> _revoke() async {
    setState(() {
      _pending = true;
      _error = null;
    });
    try {
      await ref.read(teamActionsProvider.notifier).revokeInvitation(widget.invitation);
      await HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
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
    final invitation = widget.invitation;
    return SheetFrame(
      title: invitation.email,
      description:
          '${formatRole(invitation.role)} · invited by ${invitation.invitedByName}\n'
          'Expires ${formatLineUpDate(isoDate(invitation.expiresAt.toLocal()))}',
      children: [
        if (_error != null) ...[
          const SizedBox(height: DaloySpace.s2),
          Text(_error!, style: context.text.bodySmall!.copyWith(color: c.destructive)),
        ],
        const SizedBox(height: DaloySpace.s5),
        DaloyButton(
          variant: ButtonVariant.destructive,
          icon: TablerIcons.mail_off,
          label: 'Revoke invitation',
          expand: true,
          size: ControlSize.lg,
          loading: _pending,
          onPressed: _revoke,
        ),
      ],
    );
  }
}
