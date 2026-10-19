import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_alert.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/daloy_top_bar.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../sync/workspace_sync_controller.dart';
import '../../workspaces/data/workspaces_repository.dart';
import '../application/device_data.dart';

/// What Daloy keeps on this device so it works offline — how much, and of
/// what — and a way to clear it. The numbers stay live, so after a clear
/// they climb back as the workspace downloads again.
class StorageScreen extends ConsumerWidget {
  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(deviceDataProvider).value;
    final gutter = DaloySpace.gutter(context);

    return Scaffold(
      appBar: const DaloyTopBar(title: 'Storage', largeTitle: true),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, 0, 0, DaloySpace.s10 + MediaQuery.paddingOf(context).bottom),
        children: [
          const LargeTitle('Storage'),
          const SizedBox(height: DaloySpace.s4),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: gutter),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: data == null
                    ? const SizedBox(height: 240, child: Center(child: DaloySpinner()))
                    : StaggeredColumn(
                        children: [
                          _UsageCard(storage: data.storage),
                          const SizedBox(height: DaloySpace.s3),
                          _Counts(data: data),
                          const _SyncStatus(),
                          const SizedBox(height: DaloySpace.s8),
                          const _ClearSection(),
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

/// The flat bordered surface every block here sits on, as [SettingsGroup].
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(DaloySpace.s4)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
        border: Border.all(color: c.border),
      ),
      child: child,
    );
  }
}

typedef _Segment = ({String label, int bytes, Color color});

/// The total in large type, then a bar of where it goes.
class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.storage});

  final StorageBreakdown storage;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final List<_Segment> segments = [
      (label: 'Songs', bytes: storage.songs, color: c.primaryInk),
      (label: 'Line-ups', bytes: storage.lineUps, color: c.chordInk),
      (label: 'Search', bytes: storage.search, color: c.mutedForeground.withValues(alpha: 0.55)),
      (label: 'Other', bytes: storage.other, color: c.mutedForeground.withValues(alpha: 0.22)),
    ];

    return _Card(
      padding: const EdgeInsets.all(DaloySpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(TablerIcons.device_mobile, size: 15, color: c.mutedForeground),
              const SizedBox(width: DaloySpace.s1_5),
              Text('On this device', style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
            ],
          ),
          const SizedBox(height: DaloySpace.s3),
          _CountUp(
            value: storage.total,
            builder: (context, bytes) {
              final (:value, :unit) = bytesParts(bytes);
              const figures = [FontFeature.tabularFigures()];
              return Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: daloyText(
                        DaloyFonts.serif,
                        46,
                        FontWeight.w700,
                        height: 1,
                        letterSpacingEm: -0.03,
                      ).copyWith(color: c.foreground, fontFeatures: figures),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: daloyText(DaloyFonts.serif, 20, FontWeight.w600).copyWith(color: c.mutedForeground),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: DaloySpace.s1_5),
          Text(
            'Saved so Daloy works without internet',
            style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s5),
          _UsageBar(segments: segments, total: storage.total),
          const SizedBox(height: DaloySpace.s4),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - DaloySpace.s5) / 2;
              return Wrap(
                spacing: DaloySpace.s5,
                runSpacing: DaloySpace.s2,
                children: [
                  for (final s in segments)
                    SizedBox(
                      width: width,
                      child: _Legend(segment: s),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// One track, each kind of data a share of it, growing and shrinking in place.
class _UsageBar extends StatelessWidget {
  const _UsageBar({required this.segments, required this.total});

  static const _height = 10.0;
  static const _gap = 2.0;

  final List<_Segment> segments;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final duration = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 600);
    final shown = [
      for (final s in segments)
        if (s.bytes > 0) s,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final room = constraints.maxWidth - _gap * math.max(0, shown.length - 1);
        return ClipRRect(
          borderRadius: DaloyRadii.all(DaloyRadii.full),
          child: Container(
            height: _height,
            color: c.muted,
            child: Row(
              children: [
                for (final (i, s) in shown.indexed) ...[
                  if (i > 0) const SizedBox(width: _gap),
                  AnimatedContainer(
                    duration: duration,
                    curve: DaloyMotion.ease,
                    // A sliver stays visible however small its share.
                    width: total == 0 ? 0 : math.max(3, room * s.bytes / total),
                    color: s.color,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.segment});

  final _Segment segment;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: segment.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: DaloySpace.s2),
        Expanded(
          child: Text(segment.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
        ),
        Text(
          formatBytes(segment.bytes),
          style: context.text.bodySmall!.copyWith(
            color: c.mutedForeground,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Songs, line-ups, workspaces and unsent changes, two by two.
class _Counts extends StatelessWidget {
  const _Counts({required this.data});

  final DeviceData data;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final synced = data.pendingChanges == 0;
    Widget row(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: DaloySpace.s3),
          Expanded(child: b),
        ],
      ),
    );

    return Column(
      children: [
        row(
          _StatTile(icon: TablerIcons.music, tint: c.primaryInk, value: data.songs, label: 'Songs'),
          _StatTile(icon: TablerIcons.list_details, tint: c.chordInk, value: data.lineUps, label: 'Line-ups'),
        ),
        const SizedBox(height: DaloySpace.s3),
        row(
          _StatTile(
            icon: TablerIcons.building_church,
            tint: c.primaryInk,
            value: data.workspaces,
            label: data.workspaces == 1 ? 'Workspace' : 'Workspaces',
          ),
          _StatTile(
            icon: synced ? TablerIcons.cloud_check : TablerIcons.cloud_upload,
            tint: synced ? c.chordInk : c.primaryInk,
            value: data.pendingChanges,
            label: synced ? 'Everything synced' : 'Waiting to sync',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.tint, required this.value, required this.label});

  final IconData icon;
  final Color tint;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      container: true,
      label: '$value $label',
      excludeSemantics: true,
      child: _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsGlyph(icon, color: tint),
            const SizedBox(height: DaloySpace.s4),
            _CountUp(
              value: value,
              builder: (context, n) => Text(
                '$n',
                style: daloyText(
                  DaloyFonts.serif,
                  28,
                  FontWeight.w700,
                  height: 1,
                  letterSpacingEm: -0.02,
                ).copyWith(color: c.foreground, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ),
            const SizedBox(height: DaloySpace.s1_5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

/// A number that counts up from zero when it appears, then rolls to each
/// new value.
class _CountUp extends StatelessWidget {
  const _CountUp({required this.value, required this.builder});

  final int value;
  final Widget Function(BuildContext context, int value) builder;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduceMotion ? value.toDouble() : 0, end: value.toDouble()),
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 700),
      curve: DaloyMotion.ease,
      builder: (context, v, _) => builder(context, v.round()),
    );
  }
}

/// The active workspace's download: under way, failed, or when it landed.
class _SyncStatus extends ConsumerWidget {
  const _SyncStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceProvider).value;
    final sync = ref.watch(workspaceSyncProvider);
    if (workspace == null) return const SizedBox.shrink();
    final c = context.colors;

    final (Widget icon, String text) = switch (sync.status) {
      SyncStatus.syncing => (DaloySpinner(size: 14, color: c.mutedForeground), 'Downloading ${workspace.name}…'),
      SyncStatus.error => (
        Icon(TablerIcons.alert_circle, size: 16, color: c.destructive),
        'Couldn’t sync ${workspace.name}',
      ),
      _ when sync.lastSyncedAt != null => (
        Icon(TablerIcons.circle_check, size: 16, color: c.chordInk),
        '${workspace.name} synced ${formatTimeAgo(sync.lastSyncedAt)}',
      ),
      _ => (Icon(TablerIcons.circle_check, size: 16, color: c.chordInk), '${workspace.name} is on this device'),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(DaloySpace.s1, DaloySpace.s4, DaloySpace.s1, 0),
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : DaloyMotion.medium,
        child: Row(
          key: ValueKey(sync.status),
          children: [
            SizedBox(width: 16, child: Center(child: icon)),
            const SizedBox(width: DaloySpace.s2),
            Expanded(
              child: Text(text, style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clearing, and plainly what it does and doesn't touch.
class _ClearSection extends ConsumerWidget {
  const _ClearSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(deviceDataClearProvider);
    final workspace = ref.watch(activeWorkspaceProvider).value;
    final busy = phase != ClearPhase.idle;
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          children: [
            SettingsRow(
              leading: SettingsGlyph(TablerIcons.trash, color: c.destructive),
              title: 'Clear downloaded data',
              subtitle: switch (phase) {
                ClearPhase.sending => 'Sending changes made here…',
                ClearPhase.clearing => 'Clearing…',
                ClearPhase.idle => null,
              },
              destructive: true,
              trailing: busy ? DaloySpinner(size: 18, color: c.mutedForeground) : null,
              onTap: busy ? null : () => _clear(context, ref),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(DaloySpace.s1, DaloySpace.s2, DaloySpace.s1, 0),
          child: Text(
            'Removes songs, line-ups and search history saved for every workspace. Nothing is deleted from '
            'your account. ${workspace == null ? 'Your workspace' : workspace.name} downloads again right away '
            'so Daloy keeps working; other workspaces download when you switch to them. You stay signed in '
            'and your preferences are kept.',
            style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
          ),
        ),
      ],
    );
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final name = ref.read(activeWorkspaceProvider).value?.name ?? 'Your workspace';
    final clearer = ref.read(deviceDataClearProvider.notifier);
    final confirmed = await confirmDestructive(
      context,
      title: 'Clear downloaded data?',
      message: 'Songs and line-ups are removed from this device. $name downloads again right away.',
      confirmLabel: 'Clear',
    );
    if (!confirmed) return;

    final (:outcome, :pending) = await clearer.clear();
    switch (outcome) {
      case ClearOutcome.cleared:
        await HapticFeedback.mediumImpact();
        showDaloyToast(messenger, 'Cleared. Downloading $name…');
      case ClearOutcome.offline:
        if (!context.mounted) return;
        await _explain(
          context,
          title: 'You’re offline',
          message: 'Connect to the internet first, so changes made here can sync and $name can download again.',
        );
      case ClearOutcome.unsynced:
        await HapticFeedback.heavyImpact();
        if (!context.mounted) return;
        await _explain(
          context,
          title: '${changesLabel(pending)} couldn’t sync',
          message:
              'Clearing now would lose ${pending == 1 ? 'it' : 'them'}, so nothing was cleared. '
              'Try again once you have a steadier connection.',
        );
    }
  }

  Future<void> _explain(BuildContext context, {required String title, required String message}) => showDaloyAlert<bool>(
    context,
    title: title,
    message: message,
    dismissible: true,
    actions: const [DaloyAlertAction('OK', true, style: DaloyAlertStyle.preferred)],
  );
}
