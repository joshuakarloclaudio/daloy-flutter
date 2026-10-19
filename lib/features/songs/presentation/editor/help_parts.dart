import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_sheet.dart';

/// Opens an editor help sheet (chords, lyrics): a scrolling list under a drag
/// handle, at most 560 wide.
Future<void> showEditorHelpSheet(BuildContext context, {required String title, required List<Widget> children}) =>
    showDaloySheet<void>(
      context: context,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s8),
          children: [
            Text(title, style: context.text.titleLarge),
            const SizedBox(height: DaloySpace.s4),
            ...children,
          ],
        ),
      ),
    );

/// Raw chart text, as you'd type it: monospace in chord ink on a muted well.
class HelpCode extends StatelessWidget {
  const HelpCode(this.code, {super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2),
      decoration: BoxDecoration(color: c.muted.withValues(alpha: 0.6), borderRadius: DaloyRadii.all(DaloyRadii.lg)),
      child: Text(
        code,
        style: context.text.bodyMedium!.copyWith(fontFamily: 'monospace', color: c.chordInk),
      ),
    );
  }
}

/// One example: what it's called, the text you type, what it does.
class HelpRow extends StatelessWidget {
  const HelpRow({super.key, required this.title, required this.code, required this.description});

  final String title;
  final String code;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: DaloySpace.s4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.titleSmall),
        const SizedBox(height: DaloySpace.s1_5),
        HelpCode(code),
        const SizedBox(height: DaloySpace.s1_5),
        Text(description, style: context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground)),
      ],
    ),
  );
}

/// A small spaced-caps heading between groups of help.
class HelpHeading extends StatelessWidget {
  const HelpHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: DaloySpace.s6, bottom: DaloySpace.s2),
    child: Text(
      text.toUpperCase(),
      style: context.text.labelSmall!.copyWith(
        color: context.colors.mutedForeground,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

/// A tip: a bold lead-in, then the rest.
class HelpNote extends StatelessWidget {
  const HelpNote({super.key, required this.lead, required this.body});

  final String lead;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: DaloySpace.s3),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$lead ',
              style: TextStyle(fontWeight: FontWeight.w600, color: c.foreground),
            ),
            TextSpan(text: body),
          ],
        ),
        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
      ),
    );
  }
}
