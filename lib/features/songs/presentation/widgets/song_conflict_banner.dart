import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_button.dart';
import '../../../../shared/widgets/hairline.dart';
import '../../domain/song_field.dart';

/// One field changed both here and on another device.
class SongConflict {
  const SongConflict({required this.field, required this.theirs, required this.onKeepMine, required this.onTakeTheirs});

  final SongField field;
  final Object? theirs;
  final VoidCallback onKeepMine;
  final VoidCallback onTakeTheirs;
}

/// Fields changed here and elsewhere while editing, each waiting for a
/// choice. Chords and lyrics can be read before choosing.
class SongConflictBanner extends StatelessWidget {
  const SongConflictBanner({super.key, required this.conflicts, this.changedBy});

  final List<SongConflict> conflicts;

  /// First name of who changed it, when known.
  final String? changedBy;

  static const _long = {SongField.content, SongField.lyrics};

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    final names = conflicts.map((x) => 'the ${x.field.label}').join(', ');
    return Container(
      padding: const EdgeInsets.all(DaloySpace.s4),
      decoration: BoxDecoration(
        color: c.primary.withValues(alpha: 0.06),
        border: Border.all(color: c.primary.withValues(alpha: 0.35)),
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(TablerIcons.arrows_diff, size: 18, color: c.primaryInk),
              const SizedBox(width: DaloySpace.s2),
              Expanded(
                child: Text(
                  '${changedBy ?? 'Someone'} changed $names while you were editing. '
                  'Pick which to keep — saving keeps yours.',
                  style: context.text.bodyMedium,
                ),
              ),
            ],
          ),
          for (final x in conflicts) ...[
            const SizedBox(height: DaloySpace.s3),
            Hairline(),
            const SizedBox(height: DaloySpace.s3),
            Text(x.field.label.toUpperCase(), style: context.text.labelSmall!.copyWith(color: c.mutedForeground)),
            const SizedBox(height: DaloySpace.s1),
            if (_long.contains(x.field))
              _Theirs(text: x.theirs == null ? '(empty)' : '${x.theirs}')
            else
              Text.rich(
                TextSpan(
                  text: 'Theirs: ',
                  style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                  children: [
                    TextSpan(
                      text: x.theirs == null || x.theirs == '' ? '(empty)' : '${x.theirs}',
                      style: TextStyle(color: c.foreground, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: DaloySpace.s2),
            Row(
              children: [
                DaloyButton(
                  variant: ButtonVariant.outline,
                  size: ControlSize.sm,
                  label: 'Use theirs',
                  onPressed: x.onTakeTheirs,
                ),
                const SizedBox(width: DaloySpace.s2),
                DaloyButton(size: ControlSize.sm, label: 'Keep mine', onPressed: x.onKeepMine),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Theirs extends StatelessWidget {
  const _Theirs({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        dense: true,
        title: Text('Review theirs', style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(DaloySpace.s2),
            decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.md)),
            child: SingleChildScrollView(
              child: Text(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
