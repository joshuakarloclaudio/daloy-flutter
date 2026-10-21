import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/flow_artwork.dart';
import '../../domain/line_up.dart';

/// A line-up's colours: Today Emerald on the day, quiet grey once it's past,
/// otherwise a teal-family palette that stays the same between visits.
FlowPalette lineUpPalette(LineUp lineUp, [DateTime? now]) => lineUpPaletteFor(lineUp.id, lineUp.date, now);

/// [lineUpPalette] from a line-up's id and `YYYY-MM-DD` date alone.
FlowPalette lineUpPaletteFor(int id, String date, [DateTime? now]) {
  if (lineUpDayChip(date, now) == DayChip.today) return FlowPalette.today;
  if (date.compareTo(isoDate(now ?? DateTime.now())) < 0) return FlowPalette.past;
  return FlowPalette.seeded(id);
}

/// A line-up's generated cover: the day in large serif type on its palette,
/// crossed by slow flow lines, with the set's keys along the bottom.
class LineUpCover extends StatelessWidget {
  const LineUpCover({super.key, required this.lineUp, required this.keyFlow, this.size = 184, this.animate = true});

  final LineUp lineUp;
  final List<String> keyFlow;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final palette = lineUpPalette(lineUp);
    final scale = size / 184;
    return Semantics(
      label: 'Cover for ${lineUp.title}',
      image: true,
      child: FlowArtwork(
        seed: lineUp.id,
        palette: palette,
        width: size,
        radius: 28 * scale,
        animate: animate,
        shadow: true,
        glow: animate && identical(palette, FlowPalette.today),
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: _CoverType(date: DateTime.parse('${lineUp.date}T12:00:00'), keyFlow: keyFlow, scale: scale),
        ),
      ),
    );
  }
}

class _CoverType extends StatelessWidget {
  const _CoverType({required this.date, required this.keyFlow, required this.scale});

  final DateTime date;
  final List<String> keyFlow;
  final double scale;

  @override
  Widget build(BuildContext context) {
    const ink = Colors.white;
    final small = daloyText(DaloyFonts.sans, 11 * scale, FontWeight.w700, height: 1, letterSpacingEm: 0.18);
    const shown = 5;
    final keys = keyFlow.take(shown).join('  ·  ');
    final more = keyFlow.length > shown ? '  +${keyFlow.length - shown}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(DateFormat.E().format(date).toUpperCase(), style: small.copyWith(color: ink.withValues(alpha: 0.85))),
        SizedBox(height: 2 * scale),
        Text(
          DateFormat.d().format(date),
          style: daloyText(
            DaloyFonts.serif,
            64 * scale,
            FontWeight.w700,
            height: 1,
            letterSpacingEm: -0.04,
          ).copyWith(color: ink, fontFeatures: const [FontFeature.liningFigures()]),
        ),
        Text(DateFormat.MMMM().format(date).toUpperCase(), style: small.copyWith(color: ink.withValues(alpha: 0.7))),
        const Spacer(),
        if (keys.isNotEmpty)
          Text(
            '$keys$more',
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: daloyText(
              DaloyFonts.sans,
              12 * scale,
              FontWeight.w600,
              height: 1,
            ).copyWith(color: ink.withValues(alpha: 0.9), fontFeatures: const [FontFeature.tabularFigures()]),
          ),
      ],
    );
  }
}

/// A line-up's date in a list: month over the day, as type on the page
/// rather than a tile. Colour only where it means something — Today Emerald
/// on the day, muted once it's past.
class LineUpDateBlock extends StatelessWidget {
  const LineUpDateBlock({super.key, required this.lineUp, this.width = 40, this.now});

  final LineUp lineUp;
  final double width;

  /// Passed by lists so every row agrees on what "today" is.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final date = DateTime.parse('${lineUp.date}T12:00:00');
    final isToday = lineUpDayChip(lineUp.date, now) == DayChip.today;
    final isPast = !isToday && lineUp.date.compareTo(isoDate(now ?? DateTime.now())) < 0;
    final dayColor = isToday ? c.todayInk : (isPast ? c.mutedForeground : c.foreground);
    final monthColor = isToday ? c.todayInk : c.mutedForeground;

    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        // Large text scales shrink to fit rather than spill out.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat.MMM().format(date).toUpperCase(),
                style: daloyText(
                  DaloyFonts.sans,
                  10.5,
                  FontWeight.w700,
                  height: 1,
                  letterSpacingEm: 0.12,
                ).copyWith(color: monthColor),
              ),
              const SizedBox(height: 3),
              Text(
                '${date.day}',
                style: daloyText(
                  DaloyFonts.serif,
                  21,
                  FontWeight.w700,
                  height: 1,
                ).copyWith(color: dayColor, fontFeatures: const [FontFeature.liningFigures()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
