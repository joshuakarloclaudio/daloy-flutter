import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_date_field.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../../../shared/widgets/hairline.dart';
import '../../../shared/widgets/sheet_nav_bar.dart';
import '../../../shared/widgets/suggestion_pill.dart';
import '../application/create_line_up_controller.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up.dart';
import '../domain/line_up_draft.dart';
import 'widgets/line_up_cover.dart';

/// Presents the new-line-up sheet, then opens the new line-up's editor so
/// songs can go in straight away.
Future<void> startNewLineUp(BuildContext context) async {
  final id = await showNewLineUpSheet(context);
  if (id != null && context.mounted) await context.push(Routes.lineUpEdit(id));
}

/// Resolves to the new line-up's local id once it is saved on this device,
/// or null if dismissed.
Future<int?> showNewLineUpSheet(BuildContext context) => showDaloySheet<int>(
  context: context,
  toolbar: true,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (_) => const _NewLineUpSheet(),
);

/// Cancel · New line-up · Create, then what a line-up needs to exist, laid
/// out like its edit screen: the cover as it will look (it follows the date),
/// a title, a date (the coming Sunday unless changed) and, optionally, who's
/// leading. Saving never waits on the network.
class _NewLineUpSheet extends ConsumerStatefulWidget {
  const _NewLineUpSheet();

  @override
  ConsumerState<_NewLineUpSheet> createState() => _NewLineUpSheetState();
}

class _NewLineUpSheetState extends ConsumerState<_NewLineUpSheet> {
  static const _suggestionLimit = 5;

  /// The new line-up has no id yet, so the cover borrows a fixed pattern.
  static const _previewId = 0;

  final _title = TextEditingController();
  final _leader = TextEditingController();
  final _leaderFocus = FocusNode();

  String _date = isoDate(nextSunday());
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    _leader.addListener(() => setState(() {}));
    _leaderFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _leader.dispose();
    _leaderFocus.dispose();
    super.dispose();
  }

  bool get _canSave => LineUpDetails.isValidTitle(_title.text) && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    final id = await ref
        .read(createLineUpProvider.notifier)
        .submit(LineUpDetails(title: _title.text, date: _date, worshipLeader: _leader.text));
    await HapticFeedback.mediumImpact();
    if (mounted) Navigator.of(context).pop(id);
  }

  void _fill(TextEditingController controller, String value) => controller.value = TextEditingValue(
    text: value,
    selection: TextSelection.collapsed(offset: value.length),
  );

  /// Leaders from earlier line-ups — most recent first while the field is
  /// empty, then whoever matches what's typed.
  List<String> _leaderSuggestions(List<String> leaders) {
    if (!_leaderFocus.hasFocus) return const [];
    final typed = _leader.text.trim().toLowerCase();
    return [
      for (final l in leaders)
        if (l.toLowerCase() != typed && (typed.isEmpty || l.toLowerCase().contains(typed))) l,
    ].take(_suggestionLimit).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final leaders = _leaderSuggestions(ref.watch(worshipLeadersProvider).value ?? const []);
    final titleSuggestion = _title.text.trim().isEmpty ? [suggestedLineUpTitle(_date)] : const <String>[];

    return PopScope(
      canPop: !_saving,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetNavBar(
                title: 'New line-up',
                onCancel: _saving ? null : () => Navigator.of(context).pop(),
                actionLabel: 'Create',
                onAction: _canSave ? _save : null,
                pending: _saving,
              ),
              Hairline(),
              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s5, DaloySpace.s5, DaloySpace.s6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: LineUpCover(
                          lineUp: LineUp(id: _previewId, title: _title.text, date: _date),
                          keyFlow: const [],
                          size: 112,
                          animate: false,
                        ),
                      ),
                      const SizedBox(height: DaloySpace.s6),
                      DaloyTextField(
                        label: 'Title',
                        hint: 'Eg. Sunday Morning Worship',
                        controller: _title,
                        enabled: !_saving,
                        autofocus: true,
                        maxLength: LineUpDetails.maxTextLength,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      SuggestionPills(
                        labels: titleSuggestion,
                        semanticPrefix: 'Use title',
                        onSelected: (title) => _fill(_title, title),
                      ),
                      const SizedBox(height: DaloySpace.s4),
                      DaloyDateField(
                        label: 'Date',
                        value: _date,
                        enabled: !_saving,
                        onChanged: (date) => setState(() => _date = date),
                      ),
                      const SizedBox(height: DaloySpace.s4),
                      DaloyTextField(
                        label: 'Worship leader',
                        hint: 'Optional',
                        controller: _leader,
                        focusNode: _leaderFocus,
                        enabled: !_saving,
                        maxLength: LineUpDetails.maxTextLength,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _save(),
                      ),
                      SuggestionPills(
                        labels: leaders,
                        semanticPrefix: 'Use worship leader',
                        onSelected: (leader) {
                          _fill(_leader, leader);
                          _leaderFocus.unfocus();
                        },
                      ),
                      const SizedBox(height: DaloySpace.s4),
                      Text(
                        'You can add songs next.',
                        style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
