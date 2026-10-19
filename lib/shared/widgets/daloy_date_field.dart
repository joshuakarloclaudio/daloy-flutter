import 'package:flutter/cupertino.dart' show CupertinoDatePicker, CupertinoDatePickerMode;
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../core/theme/daloy_theme.dart';
import '../../core/utils/formatters.dart';
import 'daloy_menu.dart' show anchorOf;
import 'daloy_sheet.dart';
import 'sheet_nav_bar.dart';

/// A labelled date, drawn like [DaloyTextField], that opens the date picker.
/// [value] and the result are `YYYY-MM-DD`.
class DaloyDateField extends StatelessWidget {
  const DaloyDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final current = DateTime.parse('${value}T12:00:00');
    final now = DateTime.now();
    final picked = await showDaloySheet<DateTime>(
      context: context,
      // A tablet's calendar opens beside the field.
      anchor: anchorOf(context),
      toolbar: true,
      fit: true,
      builder: (_) => _DatePickerSheet(
        initial: current,
        // Past services can be logged too, as on the web.
        min: DateTime(now.year - 5),
        max: DateTime(now.year + 5, 12, 31),
      ),
    );
    if (picked != null) onChanged(isoDate(picked));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final date = DateTime.parse('${value}T12:00:00');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: context.text.labelLarge),
        const SizedBox(height: DaloySpace.s2),
        Semantics(
          button: true,
          label: '$label, ${DateFormat.yMMMMEEEEd().format(date)}',
          excludeSemantics: true,
          child: InkWell(
            onTap: enabled ? () => _pick(context) : null,
            borderRadius: DaloyRadii.all(DaloyRadii.xl),
            child: InputDecorator(
              isEmpty: false,
              decoration: InputDecoration(
                enabled: enabled,
                isDense: true,
                constraints: BoxConstraints(minHeight: ControlSize.lg.height),
                contentPadding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s3_5),
                suffixIcon: Icon(TablerIcons.calendar, size: 18, color: c.mutedForeground),
              ),
              child: Text(DateFormat.yMMMEd().format(date), style: context.text.bodyLarge),
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerSheet extends StatefulWidget {
  const _DatePickerSheet({required this.initial, required this.min, required this.max});

  final DateTime initial;
  final DateTime min;
  final DateTime max;

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _picked = widget.initial;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SheetNavBar(
        title: 'Date',
        onCancel: () => Navigator.of(context).pop(),
        actionLabel: 'Done',
        onAction: () => Navigator.of(context).pop(_picked),
        pending: false,
      ),
      SizedBox(
        height: 216,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: widget.initial,
          minimumDate: widget.min,
          maximumDate: widget.max,
          onDateTimeChanged: (d) => _picked = d,
        ),
      ),
      const SizedBox(height: DaloySpace.s4),
    ],
  );
}
