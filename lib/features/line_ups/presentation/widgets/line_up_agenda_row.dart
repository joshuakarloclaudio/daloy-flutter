import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../../../core/theme/daloy_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/platform.dart';
import '../../../../shared/widgets/daloy_menu.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../domain/line_up.dart';
import 'line_up_cover.dart';

/// Where a line-up saved on this device stands with the server.
enum LineUpSyncState { waiting, failed }

/// One line-up in the agenda: its date (month over day), the title,
/// and "Sun · Leader · 5 songs". Today / Tomorrow / Live ride at the end.
/// Fixed height ([extent]) so the list can use fixed-extent slivers.
class LineUpAgendaRow extends StatelessWidget {
  const LineUpAgendaRow({
    super.key,
    required this.lineUp,
    required this.today,
    required this.isLive,
    required this.onTap,
    required this.menu,
    this.sync,
  });

  static const _tile = 48.0;

  final LineUp lineUp;

  /// `YYYY-MM-DD`, passed in so every row agrees on what "today" is.
  final String today;
  final bool isLive;
  final VoidCallback onTap;
  final List<DaloyMenuItem> Function() menu;

  /// Set only for line-ups with changes the server hasn't accepted yet.
  final LineUpSyncState? sync;

  /// Pins every line to the primary font's metrics, so fallback-font glyphs
  /// (emoji, bullets) can't push a row past its fixed extent.
  static StrutStyle _strut(TextStyle style) => StrutStyle(
    fontFamily: style.fontFamily,
    fontSize: style.fontSize,
    height: style.height,
    leadingDistribution: style.leadingDistribution,
    forceStrutHeight: true,
  );

  static TextStyle _subtitleStyle(BuildContext context) =>
      context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground, height: 1.3);

  /// The height a row lays out to at the current text scale.
  static double extent(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: 'Ag', style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        strutStyle: _strut(style),
        maxLines: 1,
      )..layout();
      final height = painter.height;
      painter.dispose();
      return height;
    }

    final text = context.text;
    return math.max(_tile, line(text.titleMedium!) + 2 + line(_subtitleStyle(context))) + DaloySpace.s3 * 2;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final date = DateTime.parse('${lineUp.date}T12:00:00');
    final dayChip = lineUpDayChip(lineUp.date, DateTime.parse('${today}T12:00:00'));

    final subtitle = [
      DateFormat.E().format(date),
      lineUp.leader ?? 'No worship leader',
      lineUp.isEmpty ? 'No songs yet' : lineUpSongsLabel(lineUp.songsCount),
    ].join(' · ');

    final isApple = Theme.of(context).platform.isApple;
    // No overflow button: touch and hold opens the actions, and screen readers
    // get each one as a custom action.
    return DaloyContextMenu(
      items: menu,
      child: InkWell(
        onTap: onTap,
        splashFactory: isApple ? NoSplash.splashFactory : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s3),
          child: Row(
            children: [
              _DateTile(lineUp: lineUp, today: today, isLive: isLive),
              const SizedBox(width: DaloySpace.s3_5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lineUp.title,
                      style: context.text.titleMedium,
                      strutStyle: _strut(context.text.titleMedium!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: _subtitleStyle(context),
                      strutStyle: _strut(_subtitleStyle(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isLive || sync != null || dayChip != null) ...[
                const SizedBox(width: DaloySpace.s2),
                if (isLive)
                  StatusChip(
                    label: 'Live',
                    color: c.primaryInk,
                    background: c.primary.withValues(alpha: 0.12),
                    pulse: true,
                  )
                else if (sync == LineUpSyncState.failed)
                  StatusChip(
                    label: 'Not synced',
                    color: c.destructive,
                    background: c.destructive.withValues(alpha: 0.1),
                    dense: true,
                  )
                else if (sync == LineUpSyncState.waiting)
                  StatusChip.muted(context, 'Syncing')
                else if (dayChip == DayChip.today)
                  StatusChip(label: 'Today', color: c.todayInk, background: c.today.withValues(alpha: 0.15))
                else
                  StatusChip(label: 'Tomorrow', color: c.primaryInk, background: c.primary.withValues(alpha: 0.12)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The line-up's date — emerald today, muted once past. A teal ring marks
/// one being performed right now.
class _DateTile extends StatelessWidget {
  const _DateTile({required this.lineUp, required this.today, required this.isLive});

  final LineUp lineUp;
  final String today;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.parse('${today}T12:00:00');
    const tile = LineUpAgendaRow._tile;
    if (!isLive) return LineUpDateBlock(lineUp: lineUp, width: tile, now: now);
    return Container(
      width: tile,
      height: tile,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.primaryInk, width: 2),
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
      ),
      child: LineUpDateBlock(lineUp: lineUp, width: tile - 12, now: now),
    );
  }
}
