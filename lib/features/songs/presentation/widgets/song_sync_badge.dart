import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_spinner.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../application/song_sync.dart';

/// Hands [builder] the sync state to draw, dropping a [SongSyncStatus.synced]
/// one once its moment has passed (the song then reads as plainly synced).
class SongSyncBuilder extends StatefulWidget {
  const SongSyncBuilder({super.key, required this.sync, required this.builder});

  final SongSync? sync;
  final Widget Function(BuildContext context, SongSync? sync) builder;

  @override
  State<SongSyncBuilder> createState() => _SongSyncBuilderState();
}

class _SongSyncBuilderState extends State<SongSyncBuilder> {
  Timer? _expiry;

  @override
  void dispose() {
    _expiry?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _expiry?.cancel();
    var sync = widget.sync;
    if (sync?.status == SongSyncStatus.synced) {
      final left = sync!.syncedRemaining(clock.now());
      if (left <= Duration.zero) {
        sync = null;
      } else {
        _expiry = Timer(left, () {
          if (mounted) setState(() {});
        });
      }
    }
    return widget.builder(context, sync);
  }
}

/// A small spinner sized for a chip or a line of small text.
class _Spinner extends StatelessWidget {
  const _Spinner({required this.color, this.size = 9});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => DaloySpinner(size: size, color: color);
}

/// The chip beside a song's title in lists: On device → Syncing → Synced
/// (fades after a moment), or Not synced when the server refused it.
class SongSyncBadge extends StatelessWidget {
  const SongSyncBadge({super.key, required this.sync});

  final SongSync? sync;

  @override
  Widget build(BuildContext context) => SongSyncBuilder(
    sync: sync,
    builder: (context, sync) => AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : DaloyMotion.medium,
      child: sync == null
          ? const SizedBox.shrink(key: ValueKey('none'))
          : Padding(
              key: ValueKey(sync.status),
              padding: const EdgeInsets.only(left: DaloySpace.s2),
              child: _chip(context, sync),
            ),
    ),
  );

  Widget _chip(BuildContext context, SongSync sync) {
    final c = context.colors;
    Icon icon(IconData i, Color color) => Icon(i, size: 11, color: color);
    return switch (sync.status) {
      SongSyncStatus.onDevice => StatusChip(
        label: 'On device',
        color: c.mutedForeground,
        background: c.muted,
        dense: true,
        leading: icon(TablerIcons.cloud_off, c.mutedForeground),
      ),
      SongSyncStatus.syncing => StatusChip(
        label: 'Syncing',
        color: c.mutedForeground,
        background: c.muted,
        dense: true,
        leading: _Spinner(color: c.mutedForeground),
      ),
      SongSyncStatus.synced => StatusChip(
        label: 'Synced',
        color: c.primaryInk,
        background: c.primary.withValues(alpha: 0.1),
        dense: true,
        leading: icon(TablerIcons.check, c.primaryInk),
      ),
      SongSyncStatus.failed => StatusChip(
        label: 'Not synced',
        color: c.destructive,
        background: c.destructive.withValues(alpha: 0.1),
        dense: true,
        leading: icon(TablerIcons.alert_circle, c.destructive),
      ),
    };
  }
}

/// One line on the song page saying where the song's changes stand.
/// Nothing at all once they're synced and the moment has passed.
class SongSyncLine extends StatelessWidget {
  const SongSyncLine({super.key, required this.sync, required this.isOnline});

  final SongSync? sync;
  final bool isOnline;

  @override
  Widget build(BuildContext context) => SongSyncBuilder(
    sync: sync,
    builder: (context, sync) => AnimatedSize(
      duration: DaloyMotion.medium,
      curve: DaloyMotion.ease,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : DaloyMotion.medium,
        child: sync == null
            ? const SizedBox(key: ValueKey('none'), width: double.infinity)
            : Padding(
                key: ValueKey(sync.status),
                padding: const EdgeInsets.only(top: DaloySpace.s2),
                child: _line(context, sync),
              ),
      ),
    ),
  );

  Widget _line(BuildContext context, SongSync sync) {
    final c = context.colors;
    final (Widget lead, String text, Color color) = switch (sync.status) {
      SongSyncStatus.onDevice => (
        Icon(TablerIcons.cloud_off, size: 14, color: c.mutedForeground),
        isOnline
            ? 'Changes saved on this device. Syncing soon.'
            : "Changes saved on this device. They'll sync when you're back online.",
        c.mutedForeground,
      ),
      SongSyncStatus.syncing => (
        _Spinner(color: c.mutedForeground, size: 12),
        'Syncing your changes…',
        c.mutedForeground,
      ),
      SongSyncStatus.synced => (
        Icon(TablerIcons.check, size: 14, color: c.primaryInk),
        'Changes synced.',
        c.primaryInk,
      ),
      SongSyncStatus.failed => (
        Icon(TablerIcons.alert_circle, size: 14, color: c.destructive),
        "Couldn't sync your changes: ${sync.error}",
        c.destructive,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: lead),
          const SizedBox(width: DaloySpace.s1_5),
          Expanded(
            child: Text(text, style: context.text.bodySmall!.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
