import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/daloy_theme.dart';

/// The filled, borderless search field at the top of a list screen.
class ListSearchField extends StatelessWidget {
  const ListSearchField({super.key, required this.controller, required this.onChanged, required this.hint});

  static const height = 44.0;

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  static final _borderless = OutlineInputBorder(
    borderRadius: DaloyRadii.all(DaloyRadii.xl),
    borderSide: BorderSide.none,
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        autocorrect: false,
        enableSuggestions: false,
        style: context.text.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: c.muted.withValues(alpha: 0.7),
          contentPadding: const EdgeInsets.symmetric(vertical: DaloySpace.s3),
          border: _borderless,
          enabledBorder: _borderless,
          focusedBorder: _borderless,
          prefixIcon: Icon(TablerIcons.search, size: 18, color: c.mutedForeground),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear search',
                    icon: Icon(TablerIcons.circle_x_filled, size: 18, color: c.mutedForeground),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
