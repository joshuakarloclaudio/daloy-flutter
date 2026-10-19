import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_date_field.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/daloy_top_bar.dart';
import '../../../shared/widgets/discard_changes_dialog.dart';
import '../../../shared/widgets/glass_buttons.dart';
import '../../../shared/widgets/list_states.dart';
import '../../songs/chart/chord_math.dart';
import '../application/line_up_edit_controller.dart';
import '../domain/line_up.dart';
import '../domain/line_up_draft.dart';
import 'widgets/add_songs_sheet.dart';
import 'widgets/line_up_cover.dart';
import 'widgets/line_up_edit_song_row.dart';
import 'widgets/performance_key_sheet.dart';

/// Edit a line-up: title, date and leader, then its songs — add, drag to
/// reorder, remove, and pick each one's key for this service. Works on a
/// draft; Save writes it on this device and syncs it behind the scenes.
/// Leaving with unsaved edits asks first.
class LineUpEditScreen extends ConsumerStatefulWidget {
  const LineUpEditScreen({super.key, required this.lineUpId});

  final int lineUpId;

  @override
  ConsumerState<LineUpEditScreen> createState() => _LineUpEditScreenState();
}

class _LineUpEditScreenState extends ConsumerState<LineUpEditScreen> {
  final _title = TextEditingController();
  final _leader = TextEditingController();
  bool _filled = false;

  LineUpEditProvider get _provider => lineUpEditProvider(widget.lineUpId);
  LineUpEdit get _controller => ref.read(_provider.notifier);

  @override
  void initState() {
    super.initState();
    // The text fields own their text; seed them once, when the draft loads.
    ref.listenManual(_provider, (_, next) {
      final draft = next.value;
      if (draft == null || _filled) return;
      _filled = true;
      _title.text = draft.title;
      _leader.text = draft.worshipLeader;
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _title.dispose();
    _leader.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!await _controller.save() || !mounted) return;
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    if (!ref.read(isOnlineProvider)) {
      showDaloyToast(ScaffoldMessenger.of(context), "Saved on this device. It'll sync when you're back online.");
    }
    Navigator.of(context).pop();
  }

  Future<void> _addSongs(LineUpEditState draft) async {
    FocusScope.of(context).unfocus();
    final picked = await showAddSongsSheet(context, existing: {for (final s in draft.songs) s.songId});
    if (picked != null && picked.isNotEmpty) _controller.addSongs(picked);
  }

  Future<void> _pickKey(int index, LineUpDraftSong entry) async {
    final original = entry.song.key!;
    final key = await showPerformanceKeySheet(
      context,
      songTitle: entry.song.title,
      originalKey: original,
      currentKey: transposeKey(original, entry.transposition),
    );
    if (key != null) _controller.setPerformanceKey(index, key);
  }

  void _remove(int index, LineUpDraftSong entry) {
    HapticFeedback.lightImpact();
    _controller.removeAt(index);
    showDaloyToast(
      ScaffoldMessenger.of(context),
      'Removed ${entry.song.title}.',
      actionLabel: 'Undo',
      onAction: () => _controller.insertAt(index, entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_provider);
    final draft = state.value;
    final dirty = draft?.isDirty ?? false;

    return PopScope(
      canPop: !dirty || (draft?.saving ?? false),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmDiscardChanges(context) && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: DaloyTopBar(
          title: 'Edit line-up',
          actions: [
            if (draft != null)
              draft.saving
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: DaloySpace.s4),
                      child: DaloySpinner(size: 18),
                    )
                  : GlassTextButton(label: 'Save', prominent: true, onPressed: draft.canSave ? _save : null),
          ],
        ),
        body: switch (state) {
          AsyncData(:final value) => _EditBody(
            draft: value,
            title: _title,
            leader: _leader,
            controller: _controller,
            onAddSongs: () => _addSongs(value),
            onPickKey: _pickKey,
            onRemove: _remove,
          ),
          AsyncError(:final error) => _Missing(notFound: error is LineUpNotFound),
          _ => const ListSkeleton(),
        },
      ),
    );
  }
}

class _EditBody extends StatelessWidget {
  const _EditBody({
    required this.draft,
    required this.title,
    required this.leader,
    required this.controller,
    required this.onAddSongs,
    required this.onPickKey,
    required this.onRemove,
  });

  final LineUpEditState draft;
  final TextEditingController title;
  final TextEditingController leader;
  final LineUpEdit controller;
  final VoidCallback onAddSongs;
  final void Function(int index, LineUpDraftSong entry) onPickKey;
  final void Function(int index, LineUpDraftSong entry) onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final gutter = DaloySpace.gutter(context);
    final songs = draft.songs;
    final editable = draft.songsKnown && !draft.saving;

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The cover as it will look — it follows the date and the keys as
        // you change them, so the page you came from stays in view.
        Center(
          child: LineUpCover(
            lineUp: LineUp(id: draft.saved.id, title: draft.title, date: draft.date),
            keyFlow: [
              for (final s in songs)
                if (s.song.key case final key? when key.isNotEmpty) transposeKey(key, s.transposition),
            ],
            size: 128,
            animate: false,
          ),
        ),
        const SizedBox(height: DaloySpace.s6),
        DaloyTextField(
          label: 'Title',
          hint: 'Eg. Sunday Morning Worship',
          controller: title,
          enabled: !draft.saving,
          maxLength: LineUpDetails.maxTextLength,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onChanged: controller.setTitle,
          error: LineUpDetails.isValidTitle(draft.title) ? null : 'Give the line-up a title.',
        ),
        const SizedBox(height: DaloySpace.s4),
        DaloyDateField(label: 'Date', value: draft.date, enabled: !draft.saving, onChanged: controller.setDate),
        const SizedBox(height: DaloySpace.s4),
        DaloyTextField(
          label: 'Worship leader',
          hint: 'Optional',
          controller: leader,
          enabled: !draft.saving,
          maxLength: LineUpDetails.maxTextLength,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          onChanged: controller.setWorshipLeader,
        ),
        const SizedBox(height: DaloySpace.s8),
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'Songs',
                  style: context.text.titleMedium,
                  children: [
                    if (songs.isNotEmpty)
                      TextSpan(
                        text: '  ${lineUpSongsLabel(songs.length)}',
                        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (songs.isNotEmpty && editable)
              DaloyButton(
                variant: ButtonVariant.ghost,
                size: ControlSize.sm,
                icon: TablerIcons.plus,
                label: 'Add songs',
                onPressed: onAddSongs,
              ),
          ],
        ),
        const SizedBox(height: DaloySpace.s2),
      ],
    );

    final Widget? footer = !draft.songsKnown
        ? _Notice(
            icon: TablerIcons.cloud_off,
            text: "This line-up's songs haven't been downloaded to this device yet. Connect to the internet to edit them.",
          )
        : songs.isEmpty
        ? _EmptySongs(onAdd: draft.saving ? null : onAddSongs)
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        // A readable column on wide tablets.
        final side = math.max(gutter, (constraints.maxWidth - DaloyBreakpoints.contentMaxWidth * 0.66) / 2);
        return ReorderableListView.builder(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(side, DaloySpace.s5, side, DaloySpace.s8 + MediaQuery.paddingOf(context).bottom),
          buildDefaultDragHandles: false,
          header: details,
          footer: footer,
          itemCount: songs.length,
          onReorderStart: (_) => HapticFeedback.selectionClick(),
          onReorderItem: controller.reorder,
          itemBuilder: (context, i) {
            final entry = songs[i];
            return LineUpEditSongRow(
              key: ValueKey(entry.songId),
              index: i,
              entry: entry,
              enabled: editable,
              onPickKey: () => onPickKey(i, entry),
              onRemove: () => onRemove(i, entry),
            );
          },
        );
      },
    );
  }
}

class _EmptySongs extends StatelessWidget {
  const _EmptySongs({required this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(DaloySpace.s6),
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
      ),
      child: Column(
        children: [
          Text('No songs yet', style: context.text.titleSmall),
          const SizedBox(height: DaloySpace.s1),
          Text(
            'Pick songs from your library to build the set.',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s4),
          DaloyButton(icon: TablerIcons.plus, label: 'Add songs', onPressed: onAdd),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(DaloySpace.s4),
      decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.xl)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c.mutedForeground),
          const SizedBox(width: DaloySpace.s3),
          Expanded(
            child: Text(text, style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
          ),
        ],
      ),
    );
  }
}

class _Missing extends StatelessWidget {
  const _Missing({required this.notFound});

  final bool notFound;

  @override
  Widget build(BuildContext context) => ListEmptyState(
    icon: TablerIcons.layout_list,
    title: notFound ? 'Line-up not found' : "Couldn't open this line-up",
    description: notFound
        ? "It may have been deleted, or it hasn't synced to this device yet."
        : 'Something went wrong loading it. Try again in a moment.',
  );
}
