import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/sheet_nav_bar.dart';
import '../domain/present_deck.dart';

/// Fixes a section's words mid-service: the whole section (every slide of a
/// split one), and its name where the lyrics give it a header. Resolves to
/// the edit to send, or null when cancelled or unchanged. Saved into the
/// song, so it says so. For a song without lyrics it writes them all.
Future<PresentEditSection?> showPresentSectionEditor(BuildContext context, PresentSectionText section) =>
    showDaloySheet<PresentEditSection>(
      context: context,
      toolbar: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => _SectionEditor(section: section),
    );

class _SectionEditor extends StatefulWidget {
  const _SectionEditor({required this.section});

  final PresentSectionText section;

  @override
  State<_SectionEditor> createState() => _SectionEditorState();
}

class _SectionEditorState extends State<_SectionEditor> {
  late final _label = TextEditingController(text: widget.section.label);
  late final _lines = TextEditingController(text: widget.section.lines.join('\n'));

  @override
  void initState() {
    super.initState();
    _label.addListener(() => setState(() {}));
    _lines.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _label.dispose();
    _lines.dispose();
    super.dispose();
  }

  bool get _blank => widget.section.blank;

  /// One section stays one section: blank lines would split it. A whole
  /// song keeps them, since they're what makes its sections.
  List<String> get _kept => _blank
      ? [for (final l in _lines.text.trim().split('\n')) l.trimRight()]
      : [
          for (final l in _lines.text.split('\n'))
            if (l.trim().isNotEmpty) l.trimRight(),
        ];

  String get _newLabel => _label.text.trim();

  bool get _canSave {
    final lines = _kept;
    if (lines.every((l) => l.isEmpty)) return false;
    final relabelled = widget.section.labelled && _newLabel.isNotEmpty && _newLabel != widget.section.label;
    return relabelled || !listEquals(lines, widget.section.lines);
  }

  void _save() {
    if (!_canSave) return;
    HapticFeedback.lightImpact();
    final s = widget.section;
    Navigator.of(context).pop(
      PresentEditSection(
        songIndex: s.songIndex,
        sectionId: s.sectionId,
        label: s.labelled ? _newLabel : null,
        lines: _kept,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final section = widget.section;
    final name = section.label.isEmpty ? 'section' : section.label;
    final blank = _blank;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetNavBar(
            title: blank ? 'Add lyrics' : 'Edit $name',
            onCancel: () => Navigator.of(context).pop(),
            actionLabel: 'Save',
            onAction: _canSave ? _save : null,
            pending: false,
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s2, DaloySpace.s4, DaloySpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(TablerIcons.music, size: 16, color: c.mutedForeground),
                      const SizedBox(width: DaloySpace.s2),
                      Expanded(
                        child: Text(
                          section.songTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                        ),
                      ),
                    ],
                  ),
                  if (section.labelled) ...[
                    const SizedBox(height: DaloySpace.s3),
                    TextField(
                      controller: _label,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Section name'),
                    ),
                  ],
                  const SizedBox(height: DaloySpace.s3),
                  TextField(
                    controller: _lines,
                    autofocus: true,
                    minLines: blank ? 8 : 4,
                    maxLines: blank ? 16 : 12,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Lyrics'),
                  ),
                  const SizedBox(height: DaloySpace.s2),
                  Text(
                    blank
                        ? 'Saves to the song, so every line-up gets it. A blank line starts a new section; '
                              'a line like “Chorus:” names it.'
                        : 'Saves to the song, so every line-up gets it. Blank lines are left out to keep this one section.',
                    style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
