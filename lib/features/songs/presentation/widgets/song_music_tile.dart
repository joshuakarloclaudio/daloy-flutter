import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/pressable.dart';

/// Key / Tempo / Time: a card with a small label over a big value, opening
/// its picker.
class SongMusicTile extends StatelessWidget {
  const SongMusicTile({
    super.key,
    required this.label,
    required this.value,
    required this.enabled,
    required this.onTap,
    this.unit,
    this.error = false,
  });

  final String label;
  final String? value;
  final String? unit;
  final bool enabled;
  final bool error;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final v = value;
    return Pressable(
      onPressed: enabled ? onTap : null,
      pressedScale: 0.97,
      semanticLabel: '$label: ${v == null ? 'not set' : [v, ?unit].join(' ')}',
      child: ExcludeSemantics(
        child: Container(
          height: 76,
          padding: const EdgeInsets.fromLTRB(DaloySpace.s3, DaloySpace.s2_5, DaloySpace.s2, DaloySpace.s2_5),
          decoration: BoxDecoration(
            color: c.card,
            border: Border.all(color: error ? c.destructive : c.border),
            borderRadius: DaloyRadii.all(DaloyRadii.xl2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label.toUpperCase(),
                      style: context.text.labelSmall!.copyWith(color: c.mutedForeground),
                    ),
                  ),
                  Icon(TablerIcons.chevron_down, size: 14, color: c.mutedForeground),
                ],
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: v == null
                    ? Text('Add', style: context.text.titleMedium!.copyWith(color: c.primaryInk))
                    : Text.rich(
                        TextSpan(
                          text: v,
                          children: [
                            if (unit != null)
                              TextSpan(
                                text: ' $unit',
                                style: context.text.labelMedium!.copyWith(color: c.mutedForeground),
                              ),
                          ],
                        ),
                        style: context.text.titleLarge!.copyWith(
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
