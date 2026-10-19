import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_sheet.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../domain/song_list_query.dart';

/// Pick a key to filter by. Resolves to a record so "Any key" (`key: null`)
/// can be told apart from a dismissed sheet (null). A tablet shows it as a
/// popover from [anchor].
Future<({String? key})?> showKeySheet(BuildContext context, String? current, {Rect? anchor}) {
  return showDaloySheet<({String? key})>(
    context: context,
    fit: true,
    anchor: anchor,
    builder: (sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key', style: sheetContext.text.titleLarge),
              const SizedBox(height: DaloySpace.s3),
              Wrap(
                spacing: DaloySpace.s2,
                runSpacing: DaloySpace.s2,
                children: [
                  KeyTile(
                    label: 'Any',
                    selected: current == null,
                    onTap: () => Navigator.of(sheetContext).pop((key: null)),
                  ),
                  for (final key in songKeys)
                    KeyTile(
                      label: key,
                      selected: key == current,
                      onTap: () => Navigator.of(sheetContext).pop((key: key)),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// A tappable chip: a key, a time signature.
class KeyTile extends StatelessWidget {
  const KeyTile({super.key, required this.label, required this.selected, required this.onTap, this.width = 56});

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onPressed: onTap,
      semanticLabel: selected ? '$label, selected' : label,
      child: Container(
        width: width,
        height: ControlSize.md.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? c.primary : c.muted.withValues(alpha: 0.7),
          borderRadius: DaloyRadii.all(DaloyRadii.xl),
        ),
        child: Text(
          label,
          style: context.text.titleSmall!.copyWith(color: selected ? c.primaryForeground : c.foreground),
        ),
      ),
    );
  }
}
