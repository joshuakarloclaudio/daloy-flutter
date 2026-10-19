import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_alert.dart';
import '../../chart/nashville.dart';
import '../../editor/nashville_paste.dart';

enum PasteChoice { asChords, asIs }

/// "This looks like a number chart" — asked before pasting, because the
/// detection is a heuristic and its failure mode is a chart of wrong chords
/// that looks perfectly normal. Dismissing counts as "as-is".
Future<PasteChoice> showNashvillePastePrompt(
  BuildContext context, {
  required String text,
  required String? musicalKey,
}) async {
  final canConvert = canUseNumbers(musicalKey);
  final choice = await showDaloyAlert<PasteChoice>(
    context,
    title: 'This looks like a number chart',
    // Dismissing counts as "as-is".
    dismissible: true,
    content: _PasteDetail(text: text, musicalKey: musicalKey),
    actions: [
      if (canConvert) const DaloyAlertAction('Paste as chords', PasteChoice.asChords, style: DaloyAlertStyle.preferred),
      DaloyAlertAction(
        'Paste as-is',
        PasteChoice.asIs,
        style: canConvert ? DaloyAlertStyle.normal : DaloyAlertStyle.preferred,
      ),
    ],
  );
  return choice ?? PasteChoice.asIs;
}

class _PasteDetail extends StatelessWidget {
  const _PasteDetail({required this.text, required this.musicalKey});

  final String text;
  final String? musicalKey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final canConvert = canUseNumbers(musicalKey);
    final numbersLine = firstNashvilleLine(text);
    final converted = canConvert && numbersLine != null
        ? normalizePastedNashvilleContent(numbersLine, musicalKey)
        : null;
    final lettersLine = converted == null ? null : lettersOf(converted);
    final mono = context.text.bodyMedium!.copyWith(fontFamily: 'monospace');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (canConvert) ...[
          Text.rich(
            TextSpan(
              text: 'Daloy can convert it to chords in the key of ',
              children: [
                TextSpan(
                  text: musicalKey,
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.foreground),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          if (numbersLine != null && lettersLine != null) ...[
            const SizedBox(height: DaloySpace.s4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s3),
              decoration: BoxDecoration(
                color: c.muted.withValues(alpha: 0.6),
                borderRadius: DaloyRadii.all(DaloyRadii.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(numbersLine, style: mono.copyWith(color: c.mutedForeground)),
                  const SizedBox(height: 4),
                  Text(
                    lettersLine,
                    style: mono.copyWith(color: c.chordInk, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ] else
          Text.rich(
            TextSpan(
              text: "Set the song's key first, so Daloy knows what ",
              children: [
                TextSpan(
                  text: '1',
                  style: mono.copyWith(fontWeight: FontWeight.w700, color: c.foreground),
                ),
                const TextSpan(text: ' is. There is nothing to infer it from.'),
              ],
            ),
          ),
      ],
    );
  }
}
