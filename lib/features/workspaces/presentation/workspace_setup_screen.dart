import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_list_row.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../../../shared/widgets/hairline.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/presentation/confirm_sign_out.dart';
import '../../auth/presentation/widgets/auth_layout.dart';
import '../../team/presentation/join_scanner_sheet.dart';
import '../application/create_workspace_controller.dart';
import '../data/workspaces_repository.dart';
import 'new_workspace_sheet.dart';
import 'workspace_switcher.dart';

/// First run for a signed-in user with no active workspace: name one, or
/// open one they've since been invited to. The router keeps them here
/// until a workspace is active.
class WorkspaceSetupScreen extends ConsumerStatefulWidget {
  const WorkspaceSetupScreen({super.key});

  @override
  ConsumerState<WorkspaceSetupScreen> createState() => _WorkspaceSetupScreenState();
}

class _WorkspaceSetupScreenState extends ConsumerState<WorkspaceSetupScreen> {
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.addListener(() {
      setState(() {});
      ref.read(createWorkspaceProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final created = await ref.read(createWorkspaceProvider.notifier).submit(_name.text);
    await (created ? HapticFeedback.mediumImpact() : HapticFeedback.heavyImpact());
  }

  @override
  Widget build(BuildContext context) {
    // Pull the latest list once; failures just leave the cached one.
    ref.watch(refreshWorkspacesProvider);
    final state = ref.watch(createWorkspaceProvider);
    final existing = (ref.watch(workspacesProvider).value ?? const []).where((w) => w.isMember).toList();
    final email = ref.watch(sessionControllerProvider.select((s) => s.value?.user.email));
    final c = context.colors;

    return AuthScaffold(
      eyebrow: 'Isang hakbang na lang',
      title: 'Set up your workspace',
      subtitle: const Text("A workspace holds your team's songs and line-ups. You can invite your team after."),
      footer: Column(
        children: [
          if (email != null)
            Text('Signed in as $email', style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
          DaloyButton(
            variant: ButtonVariant.link,
            label: 'Sign out',
            onPressed: state.pending ? null : () => confirmSignOut(context, ref),
          ),
        ],
      ),
      children: [
        Center(child: WorkspaceNamePreview(name: _name.text)),
        const SizedBox(height: DaloySpace.s6),
        DaloyTextField(
          label: 'Workspace name',
          controller: _name,
          hint: 'e.g. Grace Community Church',
          error: state.error,
          enabled: !state.pending,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _create(),
        ),
        const SizedBox(height: DaloySpace.s6),
        DaloyButton(
          label: state.pending ? 'Creating…' : 'Create workspace',
          size: ControlSize.lg,
          expand: true,
          loading: state.pending,
          onPressed: state.pending || !CreateWorkspace.isValid(_name.text) ? null : _create,
        ),
        const SizedBox(height: DaloySpace.s3),
        DaloyButton(
          variant: ButtonVariant.ghost,
          label: 'Join with a code or link',
          icon: TablerIcons.qrcode,
          size: ControlSize.lg,
          expand: true,
          onPressed: state.pending ? null : () => showJoinScanner(context),
        ),
        if (existing.isNotEmpty) ...[
          const SizedBox(height: DaloySpace.s8),
          Text("Or open one you're in", style: context.text.titleSmall!.copyWith(color: c.mutedForeground)),
          const SizedBox(height: DaloySpace.s2),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: c.border),
              borderRadius: DaloyRadii.all(DaloyRadii.xl2),
            ),
            child: Column(
              children: [
                for (final (i, w) in existing.indexed) ...[
                  if (i > 0) Hairline(indent: 60),
                  DaloyListRow(
                    minHeight: ControlSize.lg.height + 8,
                    leading: WorkspaceAvatar(id: w.id, name: w.name, size: 32),
                    title: Text(w.name, style: context.text.titleSmall),
                    trailing: Icon(TablerIcons.chevron_right, size: 18, color: c.mutedForeground),
                    onTap: state.pending
                        ? null
                        : () => ref.read(sessionControllerProvider.notifier).selectWorkspace(w.id),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
