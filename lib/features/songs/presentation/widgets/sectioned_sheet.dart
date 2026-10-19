import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../chart/chart_sections.dart';
import '../../chart/nashville.dart';
import 'chart_format.dart';
import 'chord_sheet.dart';
import 'lyrics_sheet.dart';

/// A song's chords or lyrics laid out the way Perform and Practice show them:
/// cut into sections ([groupBySections]), each headed by its label and
/// repeat count, its lines drawn by [ChordSheet] or [LyricsSheet]. For places
/// that show the song as it will play without Perform's interactions — the
/// song editor's previews.
class SectionedSheet extends StatelessWidget {
  const SectionedSheet.chords({
    super.key,
    required this.text,
    required this.zoom,
    this.musicalKey,
    this.notation = ChordNotation.letters,
  }) : lyrics = false;

  const SectionedSheet.lyrics({super.key, required this.text, required this.zoom})
    : lyrics = true,
      musicalKey = null,
      notation = ChordNotation.letters;

  final String text;
  final bool lyrics;
  final double zoom;
  final String? musicalKey;
  final ChordNotation notation;

  @override
  Widget build(BuildContext context) {
    final sections = groupBySections(text, 'preview');
    final label = sectionLabelStyle(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, s) in sections.indexed)
          Padding(
            // Perform's block spacing, without its tap target and outline.
            padding: EdgeInsets.only(top: i == 0 ? 0 : DaloySpace.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.label.isNotEmpty || s.repeat > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DaloySpace.s1_5),
                    child: Text(sectionLabelText(s.label, s.repeat), style: label),
                  ),
                if (lyrics)
                  LyricsSheet(lyrics: s.body, zoom: zoom)
                else
                  ChordSheet(content: s.body, transposition: 0, zoom: zoom, musicalKey: musicalKey, notation: notation),
              ],
            ),
          ),
      ],
    );
  }
}
