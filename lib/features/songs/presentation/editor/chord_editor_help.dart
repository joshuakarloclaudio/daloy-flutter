import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../help/chord_syntax_guide_screen.dart';
import '../../chart/nashville.dart';
import 'help_parts.dart';

/// The chord editor's help sheet: how a chart is written and what the keyboard
/// can do (the web's `HelpOverlay`, with the phone's gestures). The full
/// guide is one tap further.
Future<void> showChordEditorHelp(BuildContext context, {required String? musicalKey}) {
  final numbers = canUseNumbers(musicalKey);
  return showEditorHelpSheet(
    context,
    title: 'Chord notation',
    children: [
      const HelpRow(
        title: 'Basic chords',
        code: '[C] [Am] [F#m] [Bsus4]',
        description: 'Chords sit in square brackets. The Chords tab inserts them for you.',
      ),
      const HelpRow(
        title: 'Bass (slash) chords',
        code: '[G]/[B]  [C]/[E]  [Am]/[C]',
        description: 'The bass note goes in its own bracket. On the keyboard, hold the / key for the bass notes that suit the chord at the cursor.',
      ),
      const HelpRow(
        title: 'Section headers',
        code: 'Intro:\nVerse:\nChorus:',
        description: 'A word and a colon on its own line is a section label. The Sections tab inserts them.',
      ),
      const HelpRow(
        title: 'Repeat markers',
        code: 'Chorus: x2\n[C] [G] | [Am] [F] x4',
        description: 'Add x2, x3, x4… after a section or a bar line to say how many times it repeats.',
      ),
      const HelpRow(
        title: 'Beats and odd bars',
        code: '| [G] . [A] . | [F#m] . [Bm] . . . |\n| 2/4 [Em] [F#m] | [G] . [A] . |',
        description: 'Each . is one more beat of the chord before it, and a bar is as long as its beats add up to. Start a bar with a time signature like 2/4 to change its length — its chords split it evenly. The TIME keys in the Sections tab insert one.',
      ),
      const HelpRow(
        title: 'Separators',
        code: '[C] - [Em] - [Am] | [F]',
        description: 'Use -, |, /, _ or spaces between chords.',
      ),
      const HelpHeading('Chord keys'),
      const HelpNote(
        lead: 'Hold a key:',
        body: 'a grid of qualities opens above it. Slide to the one you want and lift — one gesture instead of picking a quality first. What it offers follows the key. Slide off the grid to cancel.',
      ),
      HelpNote(
        lead: 'Key / All:',
        body: musicalKey == null
            ? "set a song key to get a row of that key's seven chords, quality included."
            : 'Key shows the seven chords of $musicalKey with their qualities already on, one tap each, plus the chords songs borrow most. All gives you the twelve roots.',
      ),
      const HelpNote(
        lead: 'Qualities row:',
        body: 'tap one before a chord to add it to the next chord, or with the cursor on a chord to change that chord.',
      ),
      const HelpNote(
        lead: 'Tap the chart:',
        body: 'to move the cursor. It never sits inside a chord; Backspace removes a chord, or trims its quality one character at a time.',
      ),
      const HelpHeading('Numbers'),
      HelpNote(
        lead: 'ABC / 123:',
        body: numbers
            ? 'type chords as scale degrees in the key of $musicalKey. Chords are always saved as letters.'
            : 'set a song key first, so Daloy knows what 1 is.',
      ),
      const HelpNote(
        lead: 'Paste:',
        body: 'bare chords get brackets. A chart written in numbers asks whether to convert it to chords in this key.',
      ),
      const HelpNote(
        lead: 'Symbols:',
        body: '° dim, ø7 half-diminished, + aug, Δ7 maj7. dim and m7b5 print that way on a number chart.',
      ),
      const SizedBox(height: DaloySpace.s3),
      const _FullGuideLink(),
    ],
  );
}

/// "Chord syntax guide": bars, beats, short bars, %, and the rest.
class _FullGuideLink extends StatelessWidget {
  const _FullGuideLink();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: () => showChordSyntaxGuide(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s3),
          child: Row(
            children: [
              Icon(TablerIcons.book_2, size: 20, color: c.primaryInk),
              const SizedBox(width: DaloySpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chord syntax guide', style: context.text.titleSmall),
                    Text(
                      'Bars, beats, short bars, % and numbers',
                      style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                    ),
                  ],
                ),
              ),
              Icon(TablerIcons.chevron_right, size: 18, color: c.mutedForeground.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
