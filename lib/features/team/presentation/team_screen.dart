import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_top_bar.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/mode_button.dart';
import '../../../shared/widgets/pull_to_refresh.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/application/session_controller.dart';
import '../../workspaces/data/workspaces_repository.dart';
import '../../workspaces/presentation/workspace_switcher.dart';
import '../data/team_service.dart';
import '../domain/team_models.dart';
import 'invite_sheet.dart';
import 'join_link_card.dart';
import 'member_sheet.dart';
import 'rename_workspace_sheet.dart';

/// The workspace's people: who's in and what they can do, who's been
/// invited, and the link anyone can join through. Admins only — the API
/// won't list members for anyone else.
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider).value;
    final isAdmin = workspace?.role == TeamRole.admin;
    final gutter = DaloySpace.gutter(context);

    return Scaffold(
      appBar: DaloyTopBar(title: 'Team', largeTitle: isAdmin),
      body: workspace == null
          ? const SizedBox.shrink()
          : !isAdmin
          ? Padding(
              padding: EdgeInsets.all(gutter),
              child: const InsetPlaceholder(
                icon: TablerIcons.lock,
                title: 'Only admins manage the team',
                body: 'Ask an admin of this workspace to invite people or change roles.',
              ),
            )
          : PullToRefreshScrollView(
              onRefresh: () async {
                ref.invalidate(teamRosterProvider);
                ref.invalidate(workspaceJoinLinkProvider);
                await Future.wait([
                  ref.read(teamRosterProvider.future).catchError((_) => const TeamRoster()),
                  ref.read(workspaceJoinLinkProvider.future).catchError((_) => const JoinLink(enabled: false)),
                ]);
              },
              slivers: [
                const SliverLargeTitle('Team'),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(gutter, DaloySpace.s4, gutter, DaloySpace.s10),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: _TeamBody(workspaceId: workspace.id, workspaceName: workspace.name),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _TeamBody extends ConsumerWidget {
  const _TeamBody({required this.workspaceId, required this.workspaceName});

  final int workspaceId;
  final String workspaceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final me = ref.watch(sessionControllerProvider.select((s) => s.value?.user.id));
    final roster = ref.watch(teamRosterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(workspaceId: workspaceId, name: workspaceName, memberCount: roster.value?.members.length),
        const SizedBox(height: DaloySpace.s6),
        const Padding(
          padding: EdgeInsets.only(left: DaloySpace.s1, bottom: DaloySpace.s2),
          child: SectionLabel('Members'),
        ),
        roster.when(
          skipLoadingOnRefresh: true,
          loading: () => const ListSkeleton(),
          error: (e, _) => InsetPlaceholder(
            icon: TablerIcons.wifi_off,
            title: "Couldn't load the team",
            body: 'Members are only available online.',
            action: DaloyButton.outline(label: 'Try again', onPressed: () => ref.invalidate(teamRosterProvider)),
          ),
          data: (data) => SettingsGroup(
            children: [
              for (final member in data.members)
                SettingsRow(
                  leading: _MemberAvatar(member: member),
                  title: member.id == me ? '${member.name} (you)' : member.name,
                  subtitle: member.email,
                  trailing: _RoleChip(role: member.role),
                  onTap: () => showMemberSheet(context, member: member, isMe: member.id == me),
                ),
            ],
          ),
        ),
        const SizedBox(height: DaloySpace.s6),
        Padding(
          padding: const EdgeInsets.only(left: DaloySpace.s1, bottom: DaloySpace.s2),
          child: SectionLabel(
            'Invitations',
            trailing: Text('Sent by email', style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
          ),
        ),
        SettingsGroup(
          children: [
            SettingsRow(
              leading: const SettingsGlyph(TablerIcons.user_plus),
              title: 'Invite someone',
              subtitle: 'Add a teammate by email',
              onTap: () => showInviteSheet(context),
            ),
            for (final invitation in roster.value?.invitations ?? const <TeamInvitation>[])
              SettingsRow(
                leading: const SettingsGlyph(TablerIcons.mail),
                title: invitation.email,
                subtitle:
                    'Invited by ${invitation.invitedByName} · expires ${formatLineUpDate(isoDate(invitation.expiresAt.toLocal()))}',
                trailing: _RoleChip(role: invitation.role),
                onTap: () => showInvitationSheet(context, invitation),
              ),
          ],
        ),
        const SizedBox(height: DaloySpace.s6),
        const Padding(
          padding: EdgeInsets.only(left: DaloySpace.s1, bottom: DaloySpace.s2),
          child: SectionLabel('Join link'),
        ),
        const JoinLinkCard(),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.workspaceId, required this.name, required this.memberCount});

  final int workspaceId;
  final String name;
  final int? memberCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Column(
      children: [
        WorkspaceAvatar(id: workspaceId, name: name, size: 72),
        const SizedBox(height: DaloySpace.s4),
        Text(name, textAlign: TextAlign.center, style: context.text.displaySmall!.copyWith(fontSize: 26)),
        const SizedBox(height: DaloySpace.s1),
        Text(
          memberCount == null ? 'Your workspace' : peopleLabel(memberCount!),
          style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
        ),
        const SizedBox(height: DaloySpace.s3),
        DaloyButton.outline(
          label: 'Rename',
          icon: TablerIcons.pencil,
          size: ControlSize.sm,
          onPressed: () => showRenameWorkspaceSheet(context, currentName: name),
        ),
      ],
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final TeamMember member;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: c.muted, shape: BoxShape.circle),
      child: Text(
        workspaceInitials(member.name),
        style: context.text.labelSmall!.copyWith(color: c.mutedForeground, fontSize: 11, letterSpacing: 0.3),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final admin = role == TeamRole.admin;
    return StatusChip(
      label: formatRole(role),
      color: admin ? c.primaryInk : c.mutedForeground,
      background: admin ? c.primary.withValues(alpha: 0.12) : c.muted,
      dense: true,
    );
  }
}
