import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_button.dart';
import '../../../../shared/widgets/daloy_sheet.dart';
import '../../../../shared/widgets/sheet_nav_bar.dart';
import '../../application/line_up_prepare_controller.dart' show noteMaxLength;
import '../../domain/line_up.dart';

/// What the note sheet ended with.
sealed class NoteSheetResult {
  const NoteSheetResult();
}

class NoteSaved extends NoteSheetResult {
  const NoteSaved(this.text);

  final String text;
}

class NoteDeleted extends NoteSheetResult {
  const NoteDeleted();
}

/// Writes a team note for one line of a song in this line-up — or edits
/// [note]. [context] names where it goes ("Under “Amazing grace…”").
/// Resolves to null when dismissed.
Future<NoteSheetResult?> showLineUpNoteSheet(
  BuildContext context, {
  required String songTitle,
  required String where,
  LineUpSongNote? note,
}) => showDaloySheet<NoteSheetResult>(
  context: context,
  toolbar: true,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (_) => _NoteSheet(songTitle: songTitle, where: where, note: note),
);

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({required this.songTitle, required this.where, this.note});

  final String songTitle;
  final String where;
  final LineUpSongNote? note;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final _text = TextEditingController(text: widget.note?.text ?? '');

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _canSave {
    final t = _text.text.trim();
    return t.isNotEmpty && t.length <= noteMaxLength && t != widget.note?.text;
  }

  void _save() {
    if (!_canSave) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(NoteSaved(_text.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final editing = widget.note != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetNavBar(
            title: editing ? 'Edit note' : 'Add note',
            onCancel: () => Navigator.of(context).pop(),
            actionLabel: 'Save',
            onAction: _canSave ? _save : null,
            pending: false,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s2, DaloySpace.s4, DaloySpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(TablerIcons.note, size: 16, color: c.mutedForeground),
                    const SizedBox(width: DaloySpace.s2),
                    Expanded(
                      child: Text(
                        '${widget.songTitle} · ${widget.where}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DaloySpace.s3),
                TextField(
                  controller: _text,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: noteMaxLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'E.g. Hold 2 bars, band enters softly…'),
                ),
                const SizedBox(height: DaloySpace.s1),
                Text(
                  'Only this line-up shows it. The song itself stays as it is.',
                  style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                ),
                if (editing) ...[
                  const SizedBox(height: DaloySpace.s4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DaloyButton(
                      variant: ButtonVariant.destructive,
                      size: ControlSize.sm,
                      icon: TablerIcons.trash,
                      label: 'Delete note',
                      onPressed: () => Navigator.of(context).pop(const NoteDeleted()),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
