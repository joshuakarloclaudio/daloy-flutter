import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_list_row.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/hairline.dart';
import '../../../shared/widgets/pressable.dart';
import '../../auth/application/session_controller.dart';
import '../../team/presentation/join_scanner_sheet.dart';
import '../data/workspaces_repository.dart';
import '../domain/workspace.dart';
import 'new_workspace_sheet.dart';

/// Workspace avatar colors (`workspaceAvatarClass`). Identity, not accent —
/// the One Accent Rule doesn't apply to an avatar.
const _avatarPalette = [
  Color(0xFF059669), // emerald-600
  Color(0xFF0284C7), // sky-600
  Color(0xFFD97706), // amber-600
  Color(0xFF7C3AED), // violet-600
  Color(0xFFE11D48), // rose-600
  Color(0xFF0D9488), // teal-600
];

class WorkspaceAvatar extends StatelessWidget {
  const WorkspaceAvatar({super.key, required this.id, required this.name, this.size = 28});

  final int id;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: _avatarPalette[id % _avatarPalette.length],
      borderRadius: DaloyRadii.all(DaloyRadii.md),
    ),
    child: Text(
      workspaceInitials(name),
      style: context.text.labelSmall!.copyWith(color: Colors.white, fontSize: size * 0.36, letterSpacing: 0.5),
    ),
  );
}

/// Home's top-bar heading on phones: the active workspace, tap to switch.
class WorkspaceSwitcherHeading extends ConsumerWidget {
  const WorkspaceSwitcherHeading({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider).value;
    final c = context.colors;
    return Pressable(
      onPressed: () => showWorkspaceSwitcher(context),
      pressedScale: 0.98,
      semanticLabel: 'Switch workspace',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (workspace != null) ...[
            WorkspaceAvatar(id: workspace.id, name: workspace.name, size: 26),
            const SizedBox(width: DaloySpace.s2),
          ],
          Flexible(
            child: Text(
              workspace?.name ?? 'Daloy',
              style: context.text.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: DaloySpace.s1),
          Icon(TablerIcons.selector, size: 16, color: c.mutedForeground),
        ],
      ),
    );
  }
}

Future<void> showWorkspaceSwitcher(BuildContext context) => showDaloySheet<void>(
  context: context,
  // Over the tab bar, and allowed to grow tall for long lists.
  builder: (_) => const _WorkspaceSwitcherSheet(),
);

/// Header and "New workspace" stay put; the list between them scrolls.
/// Long lists (superadmins see every workspace) get a filter field.
class _WorkspaceSwitcherSheet extends ConsumerStatefulWidget {
  const _WorkspaceSwitcherSheet();

  @override
  ConsumerState<_WorkspaceSwitcherSheet> createState() => _WorkspaceSwitcherSheetState();
}

class _WorkspaceSwitcherSheetState extends ConsumerState<_WorkspaceSwitcherSheet> {
  static const _rowHeight = 64.0;
  static const _filterThreshold = 8;

  String _query = '';
  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  /// Opens with the active workspace in view.
  ScrollController _scrollFor(List<Workspace> workspaces, int? activeId) {
    final index = workspaces.indexWhere((w) => w.id == activeId);
    return _scroll ??= ScrollController(initialScrollOffset: index <= 2 ? 0 : (index - 2) * _rowHeight);
  }

  void _select(Workspace workspace) {
    Navigator.of(context).pop();
    ref.read(sessionControllerProvider.notifier).selectWorkspace(workspace.id);
  }

  void _newWorkspace() {
    // Swap sheets: the switcher closes as the new one rises.
    final navigator = Navigator.of(context);
    navigator.pop();
    showNewWorkspaceSheet(navigator.context);
  }

  void _joinWithCode() {
    final navigator = Navigator.of(context);
    navigator.pop();
    showJoinScanner(navigator.context);
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(workspacesProvider).value ?? const <Workspace>[];
    final activeId = ref.watch(activeWorkspaceIdProvider);
    final c = context.colors;
    final showFilter = all.length > _filterThreshold;
    final query = _query.trim().toLowerCase();
    final workspaces = query.isEmpty ? all : all.where((w) => w.name.toLowerCase().contains(query)).toList();

    return Padding(
      // Keep the list above the keyboard while filtering.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s3),
              child: Text('Workspaces', style: context.text.titleLarge),
            ),
            if (showFilter)
              Padding(
                padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s1, DaloySpace.s5, DaloySpace.s2),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  style: context.text.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Find a workspace',
                    isDense: true,
                    constraints: BoxConstraints(minHeight: ControlSize.md.height),
                    prefixIcon: Icon(TablerIcons.search, size: 18, color: c.mutedForeground),
                  ),
                ),
              ),
            Flexible(
              child: workspaces.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s5, vertical: DaloySpace.s6),
                      child: Text(
                        'No workspace matches "${_query.trim()}".',
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollFor(all, activeId),
                      shrinkWrap: true,
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      itemExtent: _rowHeight,
                      itemCount: workspaces.length,
                      itemBuilder: (context, i) {
                        final w = workspaces[i];
                        return DaloyListRow(
                          horizontalPadding: DaloySpace.s5,
                          leading: WorkspaceAvatar(id: w.id, name: w.name, size: 32),
                          title: Text(
                            w.name,
                            style: context.text.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            formatRole(w.role),
                            style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                          ),
                          trailing: w.id == activeId ? Icon(TablerIcons.check, color: c.primaryInk, size: 20) : null,
                          onTap: () => _select(w),
                        );
                      },
                    ),
            ),
            Hairline(),
            DaloyListRow(
              minHeight: ControlSize.lg.height + 8,
              horizontalPadding: DaloySpace.s5,
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: DaloyRadii.all(DaloyRadii.md),
                  border: Border.all(color: c.border),
                ),
                child: Icon(TablerIcons.plus, size: 18, color: c.primaryInk),
              ),
              title: Text('New workspace', style: context.text.titleSmall!.copyWith(color: c.primaryInk)),
              onTap: _newWorkspace,
            ),
            DaloyListRow(
              minHeight: ControlSize.lg.height + 8,
              horizontalPadding: DaloySpace.s5,
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: DaloyRadii.all(DaloyRadii.md),
                  border: Border.all(color: c.border),
                ),
                child: Icon(TablerIcons.qrcode, size: 18, color: c.primaryInk),
              ),
              title: Text('Join with a code', style: context.text.titleSmall!.copyWith(color: c.primaryInk)),
              onTap: _joinWithCode,
            ),
          ],
        ),
      ),
    );
  }
}
