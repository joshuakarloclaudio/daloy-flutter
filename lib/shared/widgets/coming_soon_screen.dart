import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/daloy_theme.dart';
import 'daloy_top_bar.dart';

/// Stand-in for screens that aren't built yet, so every route resolves.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, this.icon = TablerIcons.tools, this.note});

  final String title;
  final IconData icon;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: DaloyTopBar(title: title),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(DaloySpace.s8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.xl2)),
                child: Icon(icon, color: c.mutedForeground),
              ),
              const SizedBox(height: DaloySpace.s4),
              Text(title, style: context.text.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: DaloySpace.s2),
              Text(
                note ?? 'This screen is next on the list.',
                style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
