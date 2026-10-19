import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/hairline.dart';
import '../../../shared/widgets/sheet_nav_bar.dart';
import '../application/create_workspace_controller.dart';

/// Presents the new-workspace sheet. Resolves `true` once the workspace is
/// created and active.
Future<bool> showNewWorkspaceSheet(BuildContext context) async =>
    await showDaloySheet<bool>(
      context: context,
      toolbar: true,
      fit: true,
      builder: (_) => const _NewWorkspaceSheet(),
    ) ??
    false;

/// A page-sheet in the iOS mould: Cancel · title · Create across the top,
/// one autofocused field, and a live preview of the workspace's tile.
class _NewWorkspaceSheet extends ConsumerStatefulWidget {
  const _NewWorkspaceSheet();

  @override
  ConsumerState<_NewWorkspaceSheet> createState() => _NewWorkspaceSheetState();
}

class _NewWorkspaceSheetState extends ConsumerState<_NewWorkspaceSheet> {
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
    if (!CreateWorkspace.isValid(_name.text)) return;
    final created = await ref.read(createWorkspaceProvider.notifier).submit(_name.text);
    if (!created) {
      await HapticFeedback.heavyImpact();
      return;
    }
    await HapticFeedback.mediumImpact();
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createWorkspaceProvider);
    final c = context.colors;
    final canCreate = CreateWorkspace.isValid(_name.text) && !state.pending;

    return PopScope(
      canPop: !state.pending,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetNavBar(
                title: 'New workspace',
                onCancel: state.pending ? null : () => Navigator.of(context).pop(false),
                actionLabel: 'Create',
                onAction: canCreate ? _create : null,
                pending: state.pending,
              ),
              Hairline(),
              Padding(
                padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s8, DaloySpace.s5, DaloySpace.s6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(child: WorkspaceNamePreview(name: _name.text)),
                    const SizedBox(height: DaloySpace.s6),
                    TextField(
                      controller: _name,
                      autofocus: true,
                      enabled: !state.pending,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      maxLength: CreateWorkspace.maxLength,
                      onSubmitted: (_) => _create(),
                      style: context.text.headlineSmall,
                      decoration: InputDecoration(
                        hintText: 'Workspace name',
                        hintStyle: context.text.headlineSmall!.copyWith(color: c.mutedForeground),
                        counterText: '',
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: DaloySpace.s2),
                    AnimatedSwitcher(
                      duration: DaloyMotion.fast,
                      child: Text(
                        state.error ?? 'Usually your church or ministry. Your team will see this name.',
                        key: ValueKey(state.error),
                        textAlign: TextAlign.center,
                        style: context.text.bodySmall!.copyWith(
                          color: state.error == null ? c.mutedForeground : c.destructive,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The tile the workspace will get, drawn from the name as it's typed.
/// The real avatar colour is picked from the id, so the preview stays neutral.
class WorkspaceNamePreview extends StatelessWidget {
  const WorkspaceNamePreview({super.key, required this.name, this.size = 72});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final initials = name.trim().isEmpty ? '' : workspaceInitials(name.trim());
    return AnimatedContainer(
      duration: DaloyMotion.medium,
      curve: DaloyMotion.ease,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: initials.isEmpty ? c.muted : c.primary,
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
      ),
      child: AnimatedSwitcher(
        duration: DaloyMotion.fast,
        child: initials.isEmpty
            ? Icon(
                TablerIcons.building_church,
                key: const ValueKey('icon'),
                size: size * 0.42,
                color: c.mutedForeground,
              )
            : Text(
                initials,
                key: ValueKey(initials),
                style: context.text.headlineSmall!.copyWith(color: c.primaryForeground, fontSize: size * 0.34),
              ),
      ),
    );
  }
}
