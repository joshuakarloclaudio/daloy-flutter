import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';

/// The title block every content sheet opens with: a `titleLarge` heading
/// over an optional muted description. Use it on its own where a sheet lays
/// out its own body; [SheetFrame] adds the padding, safe area and scrolling.
class SheetTitle extends StatelessWidget {
  const SheetTitle({super.key, required this.title, this.description, this.centered = false});

  final String title;
  final String? description;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(title, textAlign: align, style: context.text.titleMedium),
        if (description != null) ...[
          const SizedBox(height: 2),
          Text(
            description!,
            textAlign: align,
            style: context.text.bodySmall!.copyWith(color: context.colors.mutedForeground),
          ),
        ],
      ],
    );
  }
}

/// A small uppercase label above one group of controls in a sheet
/// ("Beats per minute", "Time signature"). Sections are separated by
/// [DaloySpace.s5].
class SheetSectionLabel extends StatelessWidget {
  const SheetSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: DaloySpace.s2),
    child: Text(text.toUpperCase(), style: context.text.labelSmall!.copyWith(color: context.colors.mutedForeground)),
  );
}

/// The body of a `showDaloySheet` that has no toolbar: [SheetTitle], then
/// [children] 20px below it, in a scroll view that clears the home indicator.
class SheetFrame extends StatelessWidget {
  const SheetFrame({
    super.key,
    required this.title,
    required this.children,
    this.description,
    this.centeredTitle = false,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final String title;
  final String? description;
  final List<Widget> children;
  final bool centeredTitle;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          SheetTitle(title: title, description: description, centered: centeredTitle),
          const SizedBox(height: DaloySpace.s4),
          ...children,
        ],
      ),
    ),
  );
}
