import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/hairline.dart';
import '../../../shared/widgets/sheet_nav_bar.dart';
import '../application/team_actions.dart';

Future<void> showRenameWorkspaceSheet(BuildContext context, {required String currentName}) => showDaloySheet<void>(
  context: context,
  toolbar: true,
  fit: true,
  builder: (_) => _RenameSheet(currentName: currentName),
);

class _RenameSheet extends ConsumerStatefulWidget {
  const _RenameSheet({required this.currentName});

  final String currentName;

  @override
  ConsumerState<_RenameSheet> createState() => _RenameSheetState();
}

class _RenameSheetState extends ConsumerState<_RenameSheet> {
  late final _name = TextEditingController(text: widget.currentName);
  bool _pending = false;
  String? _error;

  bool get _valid => _name.text.trim().isNotEmpty && _name.text.trim() != widget.currentName;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_valid) return;
    setState(() {
      _pending = true;
      _error = null;
    });
    try {
      await ref.read(teamActionsProvider.notifier).rename(_name.text);
      await HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      await HapticFeedback.heavyImpact();
      if (mounted) {
        setState(() {
          _pending = false;
          _error = apiErrorMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PopScope(
      canPop: !_pending,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetNavBar(
                title: 'Rename workspace',
                onCancel: _pending ? null : () => Navigator.of(context).pop(),
                actionLabel: 'Save',
                onAction: _valid && !_pending ? _save : null,
                pending: _pending,
              ),
              Hairline(),
              Padding(
                padding: const EdgeInsets.all(DaloySpace.s5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _name,
                      autofocus: true,
                      enabled: !_pending,
                      maxLength: 255,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.center,
                      onChanged: (_) => setState(() => _error = null),
                      onSubmitted: (_) => _save(),
                      style: context.text.headlineSmall,
                      decoration: const InputDecoration(counterText: '', hintText: 'Workspace name'),
                    ),
                    const SizedBox(height: DaloySpace.s2),
                    Text(
                      _error ?? 'Everyone on the team sees the new name.',
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall!.copyWith(
                        color: _error == null ? c.mutedForeground : c.destructive,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
