import 'package:flutter/cupertino.dart' show cupertinoTextSelectionControls;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/daloy_theme.dart';

/// Labelled text input (`components/ui/input.tsx` + `Label`), with the
/// label above, an optional leading icon, and the error underneath.
///
/// [obscure] fields get a show/hide toggle. Height is [ControlSize.lg].
class DaloyTextField extends StatefulWidget {
  const DaloyTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.error,
    this.obscure = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.onChanged,
    this.labelTrailing,
    this.focusNode,
    this.autofocus = false,
    this.maxLength,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final String? error;
  final bool obscure;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  /// Sits at the end of the label row — "Forgot password?" on sign-in.
  final Widget? labelTrailing;

  @override
  State<DaloyTextField> createState() => _DaloyTextFieldState();
}

class _DaloyTextFieldState extends State<DaloyTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError = widget.error != null;
    final iconColor = c.mutedForeground;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(widget.label, style: context.text.labelLarge)),
            ?widget.labelTrailing,
          ],
        ),
        const SizedBox(height: DaloySpace.s2),
        TextField(
          selectionControls: cupertinoTextSelectionControls,
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _hidden,
          enableSuggestions: !widget.obscure,
          autocorrect: !widget.obscure && widget.keyboardType != TextInputType.emailAddress,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.autofillHints,
          onSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          maxLength: widget.maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          inputFormatters: widget.inputFormatters,
          style: context.text.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            isDense: true,
            constraints: BoxConstraints(minHeight: ControlSize.lg.height),
            contentPadding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s3_5),
            prefixIcon: widget.icon == null ? null : Icon(widget.icon, size: 18, color: iconColor),
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _hidden = !_hidden),
                    tooltip: _hidden ? 'Show password' : 'Hide password',
                    icon: Icon(_hidden ? TablerIcons.eye : TablerIcons.eye_off, size: 18, color: iconColor),
                  )
                : null,
            // The error is rendered below so it can wrap; this only reddens the border.
            errorText: hasError ? '' : null,
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: DaloySpace.s1_5),
          Text(widget.error!, style: context.text.bodySmall!.copyWith(color: c.destructive)),
        ],
      ],
    );
  }
}
