import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../songs/chart/nashville.dart';
import '../domain/export_sheet.dart';

typedef ExportChoice = ({ExportFormat format, ChordNotation notation});

/// Chords or lyrics, as a PDF or slides — the web's export sheet. Chords
/// start in the preferred notation and can be switched for this export
/// alone. [anchor] puts it in a popover on a tablet.
Future<ExportChoice?> showExportSheet(
  BuildContext context, {
  required String title,
  required ChordNotation notation,
  required bool canShowNumbers,
  bool isLineUp = false,
  Rect? anchor,
}) => showDaloySheet<ExportChoice>(
  context: context,
  fit: true,
  anchor: anchor,
  builder: (_) => _ExportSheet(
    title: title,
    notation: canShowNumbers ? notation : ChordNotation.letters,
    canShowNumbers: canShowNumbers,
    isLineUp: isLineUp,
  ),
);

class _ExportSheet extends StatefulWidget {
  const _ExportSheet({
    required this.title,
    required this.notation,
    required this.canShowNumbers,
    required this.isLineUp,
  });

  final String title;
  final ChordNotation notation;
  final bool canShowNumbers;
  final bool isLineUp;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  late var _notation = widget.notation;

  void _pick(ExportFormat format) => Navigator.of(context).pop<ExportChoice>((format: format, notation: _notation));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final numbers = _notation == ChordNotation.numbers;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Export', style: context.text.titleMedium),
            const SizedBox(height: DaloySpace.s1),
            Text(
              '${widget.title} — for rehearsal, print or projection. Made on this device, so it works offline.',
              style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
            ),
            const SizedBox(height: DaloySpace.s5),
            const _Label('Chords'),
            if (widget.canShowNumbers) ...[
              SegmentedControl<ChordNotation>(
                value: _notation,
                options: const [(ChordNotation.letters, 'Letters'), (ChordNotation.numbers, 'Numbers')],
                onChanged: (n) => setState(() => _notation = n),
              ),
              const SizedBox(height: DaloySpace.s3),
            ],
            SettingsGroup(
              children: [
                SettingsRow(
                  leading: const SettingsGlyph(TablerIcons.file_type_pdf),
                  title: 'Chord chart',
                  subtitle: numbers ? 'PDF in numbers, with the key' : 'PDF with the key and chords',
                  onTap: () => _pick(ExportFormat.chordsPdf),
                ),
              ],
            ),
            const SizedBox(height: DaloySpace.s5),
            const _Label('Lyrics'),
            SettingsGroup(
              children: [
                SettingsRow(
                  leading: const SettingsGlyph(TablerIcons.file_text),
                  title: 'Lyrics sheet',
                  subtitle: 'PDF, words only',
                  onTap: () => _pick(ExportFormat.lyricsPdf),
                ),
                SettingsRow(
                  leading: const SettingsGlyph(TablerIcons.presentation),
                  title: 'Slides',
                  subtitle: 'PowerPoint, a slide per section',
                  onTap: () => _pick(ExportFormat.lyricsPptx),
                ),
              ],
            ),
            const SizedBox(height: DaloySpace.s5),
            const _Label('ChordPro'),
            SettingsGroup(
              children: [
                SettingsRow(
                  leading: const SettingsGlyph(TablerIcons.file_music),
                  title: 'ChordPro file',
                  subtitle: widget.isLineUp
                      ? 'The whole set in its keys and order, for other chart apps'
                      : 'Chords over lyrics in its key, for other chart apps',
                  onTap: () => _pick(ExportFormat.chordPro),
                ),
                if (!widget.isLineUp)
                  SettingsRow(
                    leading: const SettingsGlyph(TablerIcons.copy),
                    title: 'Copy as ChordPro',
                    subtitle: 'The same text, ready to paste',
                    onTap: () => _pick(ExportFormat.chordProCopy),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: DaloySpace.s2),
    child: Text(text.toUpperCase(), style: context.text.labelSmall!.copyWith(color: context.colors.mutedForeground)),
  );
}
