import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../core/prefs/device_prefs.dart';
import '../../core/router/routes.dart';
import '../../core/theme/daloy_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/platform.dart';
import '../../shared/widgets/daloy_top_bar.dart';
import '../../shared/widgets/flow_artwork.dart';
import '../../shared/widgets/mode_button.dart';
import '../../shared/widgets/settings_group.dart';
import '../../shared/widgets/staggered_entrance.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/daloy_spinner.dart';
import '../app_update/application/app_update_controller.dart';
import '../app_update/data/app_update_service.dart';
import '../app_update/presentation/app_update_sheet.dart';
import '../auth/application/session_controller.dart';
import '../home_screen_widget/home_screen_widget.dart';
import '../auth/presentation/confirm_sign_out.dart';
import '../lock/lock_settings_rows.dart';
import '../search/presentation/search_button.dart';
import '../songs/chart/nashville.dart';
import '../songs/data/song_detail_repository.dart';
import '../songs/domain/display_prefs.dart';
import '../team/domain/team_models.dart';
import '../team/presentation/join_scanner_sheet.dart';
import '../workspaces/data/workspaces_repository.dart';
import '../workspaces/presentation/new_workspace_sheet.dart';
import '../workspaces/presentation/workspace_switcher.dart';
import 'application/device_data.dart';
import 'presentation/delete_account_sheet.dart';
import 'presentation/preferences_sheets.dart';

/// You: your avatar — drawn like a line-up's cover, in your own palette —
/// name and email, the workspace you're in, help, and signing out.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionControllerProvider).value?.user;
    final workspace = ref.watch(activeWorkspaceProvider).value;
    final c = context.colors;
    final gutter = DaloySpace.gutter(context);
    final device = ref.watch(devicePrefsControllerProvider);
    final chart = ref.watch(chartPrefsProvider).value;
    final storage = ref.watch(deviceDataProvider).value?.storage;
    final installed = ref.watch(installedVersionProvider).value;
    final update = ref.watch(appUpdateProvider);
    final canPinWidget = ref.watch(canPinHomeWidgetProvider).value ?? false;

    return Scaffold(
      appBar: const DaloyTopBar(title: 'You', largeTitle: true, actions: [TopBarSearchButton()]),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, 0, 0, DaloySpace.s10 + MediaQuery.paddingOf(context).bottom),
        children: [
          const LargeTitle('You'),
          const SizedBox(height: DaloySpace.s4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: StaggeredColumn(
                  children: [
                    if (user != null)
                      Column(
                        children: [
                          FlowArtwork(
                            seed: user.id * 31 + 7,
                            palette: FlowPalette.seeded(user.id),
                            width: 104,
                            circle: true,
                            shadow: true,
                            child: Center(
                              child: Text(
                                workspaceInitials(user.name),
                                style: daloyText(
                                  DaloyFonts.serif,
                                  38,
                                  FontWeight.w700,
                                  height: 1,
                                  letterSpacingEm: -0.02,
                                ).copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: DaloySpace.s5),
                          Text(
                            user.name,
                            textAlign: TextAlign.center,
                            style: context.text.displaySmall!.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: DaloySpace.s1),
                          Text(
                            user.email,
                            textAlign: TextAlign.center,
                            style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                          ),
                          if (user.isSuperadmin) ...[
                            const SizedBox(height: DaloySpace.s2),
                            StatusChip(
                              label: 'Platform admin',
                              color: c.primaryInk,
                              background: c.primary.withValues(alpha: 0.12),
                            ),
                          ],
                        ],
                      ),
                    _Section(
                      top: DaloySpace.s8,
                      label: 'Workspace',
                      children: [
                        SettingsRow(
                          leading: workspace == null
                              ? const SettingsGlyph(TablerIcons.building_church)
                              : WorkspaceAvatar(id: workspace.id, name: workspace.name, size: 32),
                          title: workspace?.name ?? 'No workspace',
                          subtitle: workspace == null ? null : formatRole(workspace.role),
                          trailing: Text('Switch', style: context.text.bodyMedium!.copyWith(color: c.primaryInk)),
                          onTap: () => showWorkspaceSwitcher(context),
                        ),
                        if (workspace?.role == TeamRole.admin)
                          SettingsRow(
                            leading: const SettingsGlyph(TablerIcons.users),
                            title: 'Team',
                            subtitle: 'Members, invitations and the join link',
                            onTap: () => context.push(Routes.team),
                          ),
                        SettingsRow(
                          leading: const SettingsGlyph(TablerIcons.plus),
                          title: 'New workspace',
                          onTap: () => showNewWorkspaceSheet(context),
                        ),
                        SettingsRow(
                          leading: const SettingsGlyph(TablerIcons.qrcode),
                          title: 'Join a workspace',
                          subtitle: isMacOS ? 'Paste a join link' : 'Scan a code or paste a link',
                          onTap: () => showJoinScanner(context),
                        ),
                      ],
                    ),
                    _Section(
                      label: 'Preferences',
                      children: [
                        SettingsRow(
                          leading: SettingsGlyph(kPrefIcons.appearance),
                          title: 'Appearance',
                          trailing: _Value(themeModeLabel(device.themeMode)),
                          onTap: () => showAppearanceSheet(context),
                        ),
                        SettingsRow(
                          leading: SettingsGlyph(kPrefIcons.typeface),
                          title: 'Typeface',
                          trailing: _Value(appFontLabel(device.font)),
                          onTap: () => showTypefaceSheet(context),
                        ),
                        SettingsRow(
                          leading: SettingsGlyph(kPrefIcons.view),
                          title: 'Default view',
                          subtitle: 'What a song shows first',
                          trailing: _Value(chart?.viewMode == SongViewMode.lyrics ? 'Lyrics' : 'Chords'),
                          onTap: () => showDefaultViewSheet(context),
                        ),
                        SettingsRow(
                          leading: SettingsGlyph(kPrefIcons.notation),
                          title: 'Chord notation',
                          trailing: _Value(chart?.notation == ChordNotation.numbers ? 'Numbers' : 'Letters'),
                          onTap: () => showNotationSheet(context),
                        ),
                      ],
                    ),
                    // The Mac has its own login, so no app lock there.
                    if (!isMacOS) const _Section(label: 'Privacy', children: [LockSettingsRows()]),
                    _Section(
                      label: 'This device',
                      children: [
                        SettingsRow(
                          leading: const SettingsGlyph(TablerIcons.database),
                          title: 'Storage',
                          subtitle: 'Songs and line-ups saved for offline',
                          trailing: storage == null ? null : _Value(formatBytes(storage.total)),
                          onTap: () => context.push(Routes.storage),
                        ),
                        if (canPinWidget)
                          SettingsRow(
                            leading: const SettingsGlyph(TablerIcons.layout_dashboard),
                            title: 'Add home screen widget',
                            subtitle: 'Your next line-up at a glance',
                            onTap: requestPinHomeWidget,
                          ),
                      ],
                    ),
                    _Section(
                      label: 'Help',
                      children: [
                        SettingsRow(
                          leading: const SettingsGlyph(TablerIcons.book_2),
                          title: 'Chord syntax guide',
                          subtitle: 'How to write a chord chart',
                          onTap: () => context.push(Routes.chordSyntaxGuide),
                        ),
                      ],
                    ),
                    _Section(
                      label: 'About',
                      children: [
                        // The App Store updates the Mac app.
                        if (isMacOS)
                          SettingsRow(
                            leading: const SettingsGlyph(TablerIcons.info_circle),
                            title: 'Version',
                            trailing: installed == null ? null : _Value(installed.label),
                          )
                        else
                          SettingsRow(
                            leading: const SettingsGlyph(TablerIcons.refresh),
                            title: 'Check for updates',
                            subtitle: switch (update.status) {
                              AppUpdateStatus.available when update.latestVersion != null =>
                                'Daloy ${update.latestVersion} is available',
                              AppUpdateStatus.available => 'An update is available',
                              AppUpdateStatus.downloading => 'Downloading the update…',
                              AppUpdateStatus.readyToInstall => 'Ready — restart to update',
                              _ => installed == null ? null : 'You have ${installed.label}',
                            },
                            trailing: update.busy
                                ? const DaloySpinner(size: 16)
                                : update.status == AppUpdateStatus.available ||
                                      update.status == AppUpdateStatus.readyToInstall
                                ? Text('Update', style: context.text.bodyMedium!.copyWith(color: c.primaryInk))
                                : null,
                            onTap: update.status == AppUpdateStatus.checking
                                ? null
                                : () => checkForUpdates(context, ref),
                          ),
                      ],
                    ),
                    _Section(
                      label: 'Account',
                      children: [
                        SettingsRow(
                          leading: SettingsGlyph(TablerIcons.logout, color: c.destructive),
                          title: 'Sign out',
                          destructive: true,
                          onTap: () => confirmSignOut(context, ref),
                        ),
                        SettingsRow(
                          leading: SettingsGlyph(TablerIcons.user_x, color: c.destructive),
                          title: 'Delete account',
                          destructive: true,
                          onTap: () => showDeleteAccountSheet(context),
                        ),
                      ],
                    ),
                    if (installed != null)
                      Padding(
                        padding: const EdgeInsets.only(top: DaloySpace.s6),
                        child: Text(
                          'Daloy ${installed.label}',
                          textAlign: TextAlign.center,
                          style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled group on the You screen.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.children, this.top = DaloySpace.s6});

  final String label;
  final List<Widget> children;
  final double top;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: top),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: DaloySpace.s1, bottom: DaloySpace.s2),
          child: SectionLabel(label),
        ),
        SettingsGroup(children: children),
      ],
    ),
  );
}

/// The current choice, shown at the end of a preference row.
class _Value extends StatelessWidget {
  const _Value(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground));
}
