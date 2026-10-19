import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_sheet.dart';
import '../../../../shared/widgets/hairline.dart';
import '../../../../shared/widgets/list_search_field.dart';
import '../../../../shared/widgets/list_states.dart';
import '../../../../shared/widgets/sheet_nav_bar.dart';
import '../../../songs/data/songs_repository.dart';
import '../../../songs/domain/song.dart';
import '../../../songs/presentation/widgets/song_key_chip.dart';

/// Picks songs from the library to add to a line-up, in the order tapped.
/// Songs already in it ([existing]) show as added. Resolves to the picked
/// songs, or null if dismissed.
Future<List<Song>?> showAddSongsSheet(BuildContext context, {required Set<int> existing}) => showDaloySheet<List<Song>>(
  context: context,
  toolbar: true,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (_) => _AddSongsSheet(existing: existing),
);

class _AddSongsSheet extends ConsumerStatefulWidget {
  const _AddSongsSheet({required this.existing});

  final Set<int> existing;

  @override
  ConsumerState<_AddSongsSheet> createState() => _AddSongsSheetState();
}

class _AddSongsSheetState extends ConsumerState<_AddSongsSheet> {
  static const _searchDebounce = Duration(milliseconds: 200);

  final _search = TextEditingController();
  Timer? _debounce;
  String _query = '';

  /// Insertion-ordered, so songs land in the line-up in the order picked.
  final _picked = <int, Song>{};

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.isEmpty) {
      setState(() => _query = '');
      return;
    }
    _debounce = Timer(_searchDebounce, () => setState(() => _query = value));
  }

  void _toggle(Song song) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_picked.remove(song.id) == null) _picked[song.id] = song;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Songs still waiting on the server can't be in a line-up yet.
    final songs = ref.watch(songSearchProvider(_query)).value?.where((s) => !s.isPending).toList();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetNavBar(
            title: 'Add songs',
            onCancel: () => Navigator.of(context).pop(),
            actionLabel: _picked.isEmpty ? 'Add' : 'Add ${_picked.length}',
            onAction: _picked.isEmpty ? null : () => Navigator.of(context).pop(_picked.values.toList()),
            pending: false,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s1, DaloySpace.s4, DaloySpace.s3),
            child: ListSearchField(controller: _search, onChanged: _onSearchChanged, hint: 'Search songs'),
          ),
          Hairline(),
          Expanded(
            child: songs == null
                // Clipped, not scrolled, when the keyboard leaves less room.
                ? const SingleChildScrollView(physics: NeverScrollableScrollPhysics(), child: ListSkeleton())
                : songs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(DaloySpace.s8),
                      child: Text(
                        _query.isEmpty ? 'No songs in the library yet.' : 'No songs match "$_query".',
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                      ),
                    ),
                  )
                : ListView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom + DaloySpace.s4),
                    itemCount: songs.length,
                    itemBuilder: (context, i) {
                      final song = songs[i];
                      final added = widget.existing.contains(song.id);
                      return _PickRow(
                        song: song,
                        added: added,
                        picked: _picked.containsKey(song.id),
                        onTap: added ? null : () => _toggle(song),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PickRow extends StatelessWidget {
  const _PickRow({required this.song, required this.added, required this.picked, required this.onTap});

  final Song song;

  /// Already in the line-up.
  final bool added;
  final bool picked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final checked = added || picked;
    return Semantics(
      checked: checked,
      enabled: !added,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s3),
          child: Opacity(
            opacity: added ? 0.5 : 1,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        added ? 'In this line-up' : (song.subtitle ?? 'Unknown artist'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DaloySpace.s3),
                SongKeyChip(keyName: song.key),
                const SizedBox(width: DaloySpace.s4),
                Icon(
                  checked ? TablerIcons.circle_check_filled : TablerIcons.circle,
                  size: 22,
                  color: checked ? c.primaryInk : c.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
