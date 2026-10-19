import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../songs/chart/chord_math.dart';
import '../../domain/line_up_draft.dart';

/// One song in the line-up editor: grip, position, title, the key it's
/// played in for this service, and remove. Drag by the grip, or long-press
/// anywhere on the row.
class LineUpEditSongRow extends StatelessWidget {
  const LineUpEditSongRow({
    super.key,
    required this.index,
    required this.entry,
    required this.enabled,
    required this.onPickKey,
    required this.onRemove,
  });

  final int index;
  final LineUpDraftSong entry;
  final bool enabled;
  final VoidCallback onPickKey;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final song = entry.song;
    final original = song.key?.isNotEmpty == true ? song.key : null;
    final playedIn = original == null ? null : transposeKey(original, entry.transposition);
    final transposed = playedIn != null && playedIn != original;
    final subtitle = [
      if (song.artist?.isNotEmpty == true) song.artist!,
      if (transposed) 'Written in $original',
    ].join(' · ');

    final row = Padding(
      padding: const EdgeInsets.only(bottom: DaloySpace.s2),
      child: Material(
        color: c.card,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: c.border),
          borderRadius: DaloyRadii.all(DaloyRadii.xl),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, DaloySpace.s2, DaloySpace.s1, DaloySpace.s2),
          child: Row(
            children: [
              if (enabled)
                ReorderableDragStartListener(
                  index: index,
                  child: Semantics(
                    label: 'Reorder ${song.title}',
                    child: SizedBox(
                      width: 40,
                      height: ControlSize.md.height,
                      child: Icon(TablerIcons.grip_vertical, size: 18, color: c.mutedForeground),
                    ),
                  ),
                )
              else
                const SizedBox(width: DaloySpace.s3),
              SizedBox(
                width: 20,
                child: Text(
                  '${index + 1}',
                  style: context.text.labelMedium!.copyWith(
                    color: c.mutedForeground,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: DaloySpace.s2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleMedium),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: DaloySpace.s2),
              _KeyButton(
                keyName: playedIn,
                transposed: transposed,
                onTap: enabled && playedIn != null ? onPickKey : null,
              ),
              IconButton(
                onPressed: enabled ? onRemove : null,
                tooltip: 'Remove ${song.title}',
                icon: Icon(TablerIcons.x, size: 18, color: c.mutedForeground),
              ),
            ],
          ),
        ),
      ),
    );

    return enabled ? ReorderableDelayedDragStartListener(index: index, child: row) : row;
  }
}

/// The performance key, tappable to change it. "No key" when the song has
/// none — it can't be transposed until one is set on the song.
class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.keyName, required this.transposed, required this.onTap});

  final String? keyName;
  final bool transposed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (keyName == null) {
      return Text('No key', style: context.text.bodySmall!.copyWith(color: c.mutedForeground));
    }
    return Pressable(
      onPressed: onTap,
      semanticLabel: 'Performance key $keyName. Change key',
      child: Container(
        constraints: const BoxConstraints(minWidth: 48),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s2_5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: transposed ? c.primary.withValues(alpha: 0.1) : c.muted.withValues(alpha: 0.7),
          borderRadius: DaloyRadii.all(DaloyRadii.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(keyName!, style: context.text.titleSmall!.copyWith(color: transposed ? c.primaryInk : c.foreground)),
            const SizedBox(width: 2),
            Icon(TablerIcons.chevron_down, size: 14, color: transposed ? c.primaryInk : c.mutedForeground),
          ],
        ),
      ),
    );
  }
}
