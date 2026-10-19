import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_sheet.dart';
import '../../../songs/chart/chord_math.dart';
import '../../../songs/presentation/widgets/song_list_sheets.dart';

/// Picks the key a song is played in for one line-up. Resolves to the chosen
/// key, or null if dismissed.
Future<String?> showPerformanceKeySheet(
  BuildContext context, {
  required String songTitle,
  required String originalKey,
  required String currentKey,
}) => showDaloySheet<String>(
  context: context,
  fit: true,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (sheetContext) {
    final c = sheetContext.colors;
    final keys = transposedKeys(originalKey);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Performance key', style: sheetContext.text.titleMedium),
            const SizedBox(height: DaloySpace.s1),
            Text(
              '$songTitle · written in $originalKey',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: sheetContext.text.bodyMedium!.copyWith(color: c.mutedForeground),
            ),
            const SizedBox(height: DaloySpace.s4),
            // Six to a row: the twelve keys sit in two even rows.
            LayoutBuilder(
              builder: (context, box) {
                const columns = 6;
                const gap = DaloySpace.s2;
                final width = ((box.maxWidth - gap * (columns - 1)) / columns).floorToDouble();
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final key in keys)
                      KeyTile(
                        label: key,
                        width: width,
                        selected: key == currentKey,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.of(sheetContext).pop(key);
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  },
);
