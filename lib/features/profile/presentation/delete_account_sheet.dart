import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/sheet_frame.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/domain/account_deletion_preview.dart';
import '../application/account_deletion.dart';

/// Deleting the account for good, as the App Store asks every app that makes
/// accounts to allow. Says what goes with it, and what stands in the way.
Future<void> showDeleteAccountSheet(BuildContext context) =>
    showDaloySheet<void>(context: context, builder: (_) => const _DeleteAccountSheet());

class _DeleteAccountSheet extends ConsumerStatefulWidget {
  const _DeleteAccountSheet();

  @override
  ConsumerState<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends ConsumerState<_DeleteAccountSheet> {
  final _confirm = TextEditingController();
  bool _pending = false;
  String? _error;

  @override
  void dispose() {
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _delete(AccountDeletionPreview preview) async {
    setState(() {
      _pending = true;
      _error = null;
    });
    final value = _confirm.text;
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .deleteAccount(
            password: preview.requiresPassword ? value : null,
            confirmEmail: preview.requiresPassword ? null : value,
          );
      await HapticFeedback.heavyImpact();
      if (mounted) Navigator.of(context).pop();
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
    final preview = ref.watch(accountDeletionPreviewProvider);

    return PopScope(
      canPop: !_pending,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s6),
            child: preview.when(
              loading: () => const SizedBox(height: 160, child: Center(child: DaloySpinner())),
              error: (e, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SheetTitle(
                    title: 'Delete account',
                    description: 'Deleting needs a connection. ${apiErrorMessage(e)}',
                  ),
                  const SizedBox(height: DaloySpace.s5),
                  DaloyButton.outline(
                    label: 'Try again',
                    size: ControlSize.lg,
                    expand: true,
                    onPressed: () => ref.invalidate(accountDeletionPreviewProvider),
                  ),
                ],
              ),
              data: (data) => _Content(
                preview: data,
                controller: _confirm,
                pending: _pending,
                error: _error,
                onChanged: () => setState(() => _error = null),
                onDelete: () => _delete(data),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.preview,
    required this.controller,
    required this.pending,
    required this.error,
    required this.onChanged,
    required this.onDelete,
  });

  final AccountDeletionPreview preview;
  final TextEditingController controller;
  final bool pending;
  final String? error;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final names = preview.blocking.map((w) => w.name).join(', ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetTitle(
          title: 'Delete account',
          description: 'This removes your profile, your capos and your place in every workspace. It can’t be undone.',
        ),
        if (preview.willDelete.isNotEmpty) ...[
          const SizedBox(height: DaloySpace.s4),
          _Callout(
            icon: TablerIcons.trash,
            color: c.destructive,
            text:
                'These workspaces have only you in them, so they go too, with all their songs and line-ups: '
                '${preview.willDelete.map((w) => w.name).join(', ')}.',
          ),
        ],
        if (preview.blocking.isNotEmpty) ...[
          const SizedBox(height: DaloySpace.s4),
          _Callout(
            icon: TablerIcons.shield_lock,
            color: c.primaryInk,
            text:
                'You’re the only admin of $names, and other people still use it. '
                'Make someone else an admin (Team, then tap a member), then come back.',
          ),
        ] else ...[
          const SizedBox(height: DaloySpace.s5),
          DaloyTextField(
            label: preview.requiresPassword ? 'Your password' : 'Type your email to confirm',
            controller: controller,
            obscure: preview.requiresPassword,
            enabled: !pending,
            keyboardType: preview.requiresPassword ? null : TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: preview.requiresPassword ? const [AutofillHints.password] : null,
            error: error,
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => controller.text.isEmpty ? null : onDelete(),
          ),
          const SizedBox(height: DaloySpace.s5),
          DaloyButton(
            variant: ButtonVariant.destructive,
            label: 'Delete my account',
            icon: TablerIcons.user_x,
            size: ControlSize.lg,
            expand: true,
            loading: pending,
            onPressed: pending || controller.text.isEmpty ? null : onDelete,
          ),
        ],
      ],
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(DaloySpace.s3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.06),
      border: Border.all(color: color.withValues(alpha: 0.2)),
      borderRadius: DaloyRadii.all(DaloyRadii.xl),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: DaloySpace.s2_5),
        Expanded(
          child: Text(text, style: context.text.bodyMedium!.copyWith(color: context.colors.foreground)),
        ),
      ],
    ),
  );
}
