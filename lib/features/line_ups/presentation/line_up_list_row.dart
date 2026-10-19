import 'package:flutter/material.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/status_chip.dart';
import '../domain/line_up.dart';
import 'widgets/line_up_cover.dart';

/// One line-up in a list (`LineUpListRow`): its date, then
/// date · leader · song count. Long-press for actions.
class LineUpListRow extends StatelessWidget {
  const LineUpListRow({super.key, required this.lineUp, required this.onTap, required this.menu});

  final LineUp lineUp;
  final VoidCallback onTap;
  final List<DaloyMenuItem> Function() menu;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subtitle = [
      formatLineUpDate(lineUp.date),
      lineUp.leader ?? 'No worship leader',
      lineUpSongsLabel(lineUp.songsCount),
    ].join(' · ');

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    // No overflow button: touch and hold opens the actions, and screen readers
    // get each one as a custom action.
    return DaloyContextMenu(
      items: menu,
      child: InkWell(
        onTap: onTap,
        // iOS cells highlight on press; Android ripples.
        splashFactory: isIOS ? NoSplash.splashFactory : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s3),
          child: Row(
            children: [
              LineUpDateBlock(lineUp: lineUp),
              const SizedBox(width: DaloySpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            lineUp.title,
                            style: context.text.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lineUp.isEmpty) ...[
                          const SizedBox(width: DaloySpace.s2),
                          StatusChip.muted(context, 'Empty'),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.text.bodyMedium!.copyWith(color: c.mutedForeground, height: 1.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
