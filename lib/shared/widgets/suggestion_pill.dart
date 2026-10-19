import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import 'pressable.dart';

/// A value the user has typed before, offered under a field — tap to use it.
class SuggestionPill extends StatelessWidget {
  const SuggestionPill({super.key, required this.label, required this.onTap, required this.semanticLabel});

  final String label;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onPressed: onTap,
      semanticLabel: semanticLabel,
      child: Container(
        // No `alignment`: it would stretch every pill to maxWidth and stack them.
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2),
        decoration: BoxDecoration(
          color: c.primary.withValues(alpha: 0.08),
          borderRadius: DaloyRadii.all(DaloyRadii.xl),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodyMedium!.copyWith(color: c.primaryInk),
        ),
      ),
    );
  }
}

/// [SuggestionPill]s in a wrap that grows and shrinks smoothly; nothing at
/// all when [labels] is empty.
class SuggestionPills extends StatelessWidget {
  const SuggestionPills({super.key, required this.labels, required this.onSelected, required this.semanticPrefix});

  final List<String> labels;
  final ValueChanged<String> onSelected;

  /// "Use artist" → "Use artist Hillsong" for screen readers.
  final String semanticPrefix;

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: DaloyMotion.fast,
    curve: DaloyMotion.ease,
    alignment: Alignment.topCenter,
    child: labels.isEmpty
        ? const SizedBox(width: double.infinity)
        : Padding(
            padding: const EdgeInsets.only(top: DaloySpace.s2),
            child: Wrap(
              spacing: DaloySpace.s2,
              runSpacing: DaloySpace.s2,
              children: [
                for (final label in labels)
                  SuggestionPill(label: label, semanticLabel: '$semanticPrefix $label', onTap: () => onSelected(label)),
              ],
            ),
          ),
  );
}
