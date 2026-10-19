import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/daloy_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/daloy_sheet.dart';
import '../../../../shared/widgets/daloy_toast.dart';
import '../../../../shared/widgets/hairline.dart';
import '../../../../shared/widgets/list_search_field.dart';
import '../../../../shared/widgets/list_states.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/sheet_nav_bar.dart';
import '../../../songs/domain/song.dart';
import '../../application/add_song_to_line_up.dart';
import '../../data/line_ups_repository.dart';
import '../../domain/line_up.dart';
import '../new_line_up_sheet.dart';
import 'line_up_cover.dart';

/// "Add to line-up" from a song: pick a line-up (or make one) and the song
/// goes at the end of its set, with a toast to open it.
Future<void> addSongToLineUp(BuildContext context, WidgetRef ref, Song song) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  void toast(String message, {String? actionLabel, VoidCallback? onAction}) =>
      showDaloyToast(messenger, message, actionLabel: actionLabel, onAction: onAction);

  if (song.isPending) {
    toast('This song is still syncing. Add it to a line-up once it has.');
    return;
  }

  final pick = await showDaloySheet<_Pick>(
    context: context,
    toolbar: true,
    constraints: const BoxConstraints(maxWidth: 560),
    builder: (_) => _AddToLineUpSheet(song: song),
  );
  if (pick == null || !context.mounted) return;

  final int lineUpId;
  final String title;
  switch (pick) {
    case _PickLineUp(:final lineUp):
      lineUpId = lineUp.id;
      title = lineUp.title;
    case _PickNew():
      final id = await showNewLineUpSheet(context);
      if (id == null || !context.mounted) return;
      lineUpId = id;
      title = (await ref.read(lineUpsRepositoryProvider).watchLineUp(id).first)?.title ?? 'the new line-up';
  }

  final outcome = await ref.read(songLineUpAdderProvider).add(lineUpId, song.id);
  switch (outcome) {
    case AddToLineUpOutcome.added:
      unawaited(HapticFeedback.mediumImpact());
      toast(
        'Added to “$title”.',
        actionLabel: 'View',
        onAction: () {
          final id = ref.read(lineUpsRepositoryProvider).resolveId(lineUpId);
          router.push(id < 0 ? Routes.lineUpEdit(id) : Routes.lineUp(id));
        },
      );
    case AddToLineUpOutcome.alreadyIn:
      toast('Already in “$title”.');
    case AddToLineUpOutcome.needsConnection:
      toast("“$title” hasn't downloaded to this device yet. Connect to the internet to add to it.");
  }
}

sealed class _Pick {
  const _Pick();
}

class _PickLineUp extends _Pick {
  const _PickLineUp(this.lineUp);

  final LineUp lineUp;
}

class _PickNew extends _Pick {
  const _PickNew();
}

class _AddToLineUpSheet extends ConsumerStatefulWidget {
  const _AddToLineUpSheet({required this.song});

  final Song song;

  @override
  ConsumerState<_AddToLineUpSheet> createState() => _AddToLineUpSheetState();
}

class _AddToLineUpSheetState extends ConsumerState<_AddToLineUpSheet> {
  final _search = TextEditingController();
  String _query = '';
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _pick(LineUp lineUp, bool inSet) {
    // The row already says so; nothing to add.
    if (inSet) {
      HapticFeedback.lightImpact();
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(_PickLineUp(lineUp));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final all = ref.watch(workspaceLineUpsProvider).value;
    final inSet = ref.watch(lineUpsWithSongProvider(widget.song.id)).value ?? const {};
    final groups = all == null ? null : groupLineUpsForPicker(all, search: _query);
    final searching = _query.trim().isNotEmpty;
    final showPast = _showPast || searching;

    Widget row(LineUp l) =>
        _LineUpPickRow(lineUp: l, inSet: inSet.contains(l.id), onTap: () => _pick(l, inSet.contains(l.id)));

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetNavBar(
            title: 'Add to line-up',
            onCancel: () => Navigator.of(context).pop(),
            actionLabel: 'New',
            onAction: () => Navigator.of(context).pop(const _PickNew()),
            pending: false,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(DaloySpace.s4, 0, DaloySpace.s4, DaloySpace.s1),
            child: Text(
              widget.song.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s2, DaloySpace.s4, DaloySpace.s3),
            child: ListSearchField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              hint: 'Search line-ups',
            ),
          ),
          Hairline(),
          Expanded(
            child: groups == null
                // Clipped, not scrolled, when the keyboard leaves less room.
                ? const SingleChildScrollView(physics: NeverScrollableScrollPhysics(), child: ListSkeleton())
                : ListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + DaloySpace.s4),
                    children: [
                      if (!searching) _NewLineUpRow(onTap: () => Navigator.of(context).pop(const _PickNew())),
                      for (final g in groups.coming) ...[_GroupLabel(g.label), for (final l in g.lineUps) row(l)],
                      if (groups.past.isNotEmpty) ...[
                        if (showPast) ...[
                          const _GroupLabel('Past'),
                          for (final l in groups.past) row(l),
                        ] else
                          _ShowPastRow(count: groups.past.length, onTap: () => setState(() => _showPast = true)),
                      ],
                      if (groups.coming.isEmpty && (groups.past.isEmpty || !showPast) && searching)
                        Padding(
                          padding: const EdgeInsets.all(DaloySpace.s8),
                          child: Text(
                            'No line-ups match "$_query".',
                            textAlign: TextAlign.center,
                            style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                          ),
                        ),
                      if (groups.coming.isEmpty && !searching)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(DaloySpace.s6, DaloySpace.s4, DaloySpace.s6, 0),
                          child: Text(
                            'No upcoming line-ups. Start a new one for this song.',
                            textAlign: TextAlign.center,
                            style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s5, DaloySpace.s4, DaloySpace.s1),
    child: Text(label.toUpperCase(), style: context.text.labelSmall!.copyWith(color: context.colors.mutedForeground)),
  );
}

class _NewLineUpRow extends StatelessWidget {
  const _NewLineUpRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s3),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.primary.withValues(alpha: 0.12),
                borderRadius: DaloyRadii.all(DaloyRadii.lg),
              ),
              child: Icon(TablerIcons.plus, size: 20, color: c.primaryInk),
            ),
            const SizedBox(width: DaloySpace.s3),
            Expanded(
              child: Text('New line-up', style: context.text.titleMedium!.copyWith(color: c.primaryInk)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowPastRow extends StatelessWidget {
  const _ShowPastRow({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s4, DaloySpace.s4, 0),
      child: Pressable(
        onPressed: onTap,
        semanticLabel: 'Show past line-ups',
        child: Container(
          height: ControlSize.md.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: c.border),
            borderRadius: DaloyRadii.all(DaloyRadii.xl),
          ),
          child: Text(
            count == 1 ? 'Show 1 past line-up' : 'Show $count past line-ups',
            style: context.text.labelLarge!.copyWith(color: c.mutedForeground),
          ),
        ),
      ),
    );
  }
}

class _LineUpPickRow extends StatelessWidget {
  const _LineUpPickRow({required this.lineUp, required this.inSet, required this.onTap});

  final LineUp lineUp;

  /// The song is already in this line-up.
  final bool inSet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subtitle = [formatLineUpDate(lineUp.date), lineUpSongsLabel(lineUp.songsCount)].join(' · ');
    return Semantics(
      selected: inSet,
      hint: inSet ? 'Already has this song' : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s3),
          child: Opacity(
            opacity: inSet ? 0.6 : 1,
            child: Row(
              children: [
                LineUpDateBlock(lineUp: lineUp),
                const SizedBox(width: DaloySpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lineUp.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground, height: 1.3),
                      ),
                    ],
                  ),
                ),
                if (inSet) ...[
                  const SizedBox(width: DaloySpace.s2),
                  Icon(TablerIcons.circle_check_filled, size: 18, color: c.primaryInk),
                  const SizedBox(width: DaloySpace.s1),
                  Text('In set', style: context.text.labelMedium!.copyWith(color: c.mutedForeground)),
                ] else
                  Icon(TablerIcons.plus, size: 18, color: c.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
