import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/flow_artwork.dart';
import '../../../shared/widgets/hero_top_bar.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/mode_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import '../../perform/domain/perform_sections.dart';
import '../../songs/presentation/widgets/chart_format.dart';
import '../../songs/presentation/widgets/chord_sheet.dart';
import '../../songs/presentation/widgets/song_artwork.dart';
import '../../sync/realtime_scope.dart';
import '../../sync/workspace_realtime.dart';
import '../application/line_up_prepare_controller.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up.dart';
import '../domain/prep_arrangement.dart';
import 'widgets/line_up_cover.dart';
import 'widgets/line_up_note_sheet.dart';

enum _PrepMode { arrange, notes }

/// Getting a line-up ready: every song in the set, stacked — in Arrange,
/// its sections as cards to drag into this service's order or cut (chords
/// and lyrics separately); in Notes, its chart with the team's notes, where
/// a tap on a line pins a note under it. Dressed like the song pages. Each
/// change saves on the device at once and syncs behind the scenes.
class LineUpPrepareScreen extends ConsumerStatefulWidget {
  const LineUpPrepareScreen({super.key, required this.lineUpId, this.focusSongId, this.notes = false});

  final int lineUpId;

  /// Scrolled to on open.
  final int? focusSongId;

  /// Opens on Notes instead of Arrange.
  final bool notes;

  @override
  ConsumerState<LineUpPrepareScreen> createState() => _LineUpPrepareScreenState();
}

class _LineUpPrepareScreenState extends ConsumerState<LineUpPrepareScreen> {
  final _hero = HeroScrollState();
  final _songKeys = <int, GlobalKey>{};
  late var _mode = widget.notes ? _PrepMode.notes : _PrepMode.arrange;
  var _view = SongArrangementView.chords;
  bool _focused = false;

  /// A drop shown before Drift streams the new order back, so the card
  /// doesn't jump home for a frame.
  final _dropped = <(int, SongArrangementView), List<PrepSection>>{};

  LineUpPrepareControllerProvider get _provider => lineUpPrepareControllerProvider(widget.lineUpId);
  LineUpPrepareController get _controller => ref.read(_provider.notifier);

  @override
  void initState() {
    super.initState();
    ref.listenManual(_provider, (_, _) {
      if (_dropped.isNotEmpty) setState(_dropped.clear);
    });
  }

  @override
  void dispose() {
    _hero.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(int songId) => _songKeys.putIfAbsent(songId, GlobalKey.new);

  void _focusOnce(LineUpPrepareState state) {
    final target = widget.focusSongId;
    if (_focused || target == null || state.songs.isEmpty) return;
    _focused = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _songKeys[target]?.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(ctx, alignment: 0.08, duration: DaloyMotion.medium, curve: Curves.easeOutCubic);
      }
    });
  }

  void _toast(String message, {String? actionLabel, VoidCallback? onAction}) =>
      showDaloyToast(ScaffoldMessenger.of(context), message, actionLabel: actionLabel, onAction: onAction);

  // -- Arrange --------------------------------------------------------------

  void _move(PrepareSong song, List<PrepSection> shown, int from, int to) {
    if (from == to) return;
    HapticFeedback.selectionClick();
    final next = [...shown];
    next.insert(to, next.removeAt(from));
    // Cut sections stay after the kept ones, as the list draws them.
    setState(
      () => _dropped[(song.songId, _view)] = [...next.where((s) => !s.removed), ...next.where((s) => s.removed)],
    );
    _controller.moveSection(song.songId, _view, from, to);
  }

  void _toggle(PrepareSong song, PrepSection section) {
    HapticFeedback.lightImpact();
    _controller.toggleSection(song.songId, _view, section.originalIndex);
  }

  Future<void> _reset(PrepareSong song) async {
    final view = _view;
    final before = await _controller.resetArrangement(song.songId, view);
    if (before == null || !mounted) return;
    await HapticFeedback.mediumImpact();
    _toast(
      '${song.song.title} plays as written.',
      actionLabel: 'Undo',
      onAction: () => _controller.restoreArrangement(song.songId, view, before),
    );
  }

  // -- Notes ----------------------------------------------------------------

  Future<void> _addNote(PrepareSong song, int line, String where) async {
    final result = await showLineUpNoteSheet(context, songTitle: song.song.title, where: where);
    if (result is NoteSaved) await _controller.saveNote(song.songId, line: line, text: result.text);
  }

  Future<void> _editNote(PrepareSong song, LineUpSongNote note) async {
    final result = await showLineUpNoteSheet(context, songTitle: song.song.title, where: 'Team note', note: note);
    switch (result) {
      case NoteSaved(:final text):
        final saved = await _controller.saveNote(song.songId, line: note.line, text: text, existing: note);
        if (!saved && mounted) _toast('Someone deleted this note meanwhile.');
      case NoteDeleted():
        final before = await _controller.deleteNote(song.songId, note);
        if (before == null || !mounted) return;
        _toast('Note deleted.', actionLabel: 'Undo', onAction: () => _controller.restoreNotes(song.songId, before));
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    listenRemoteChanges(ref, context, RemoteKind.lineUp, widget.lineUpId);
    final state = ref.watch(_provider);
    final lineUp = state.lineUp;
    _focusOnce(state);

    final Widget body;
    if (state.isLoading) {
      body = Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + DaloyChrome.topBarHeight),
        child: const ListSkeleton(),
      );
    } else if (lineUp == null) {
      body = const ListEmptyState(
        icon: TablerIcons.layout_list,
        title: 'Line-up not found',
        description: "It may have been deleted, or it hasn't synced to this device yet.",
      );
    } else {
      body = NotificationListener<ScrollNotification>(
        onNotification: (n) => _hero.handle(context, n),
        child: _scroll(context, state, lineUp),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: body),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: HeroTopBar(
              title: 'Prepare',
              scrolled: _hero.scrolled,
              titleHidden: _hero.titleHidden,
              onBack: () {
                final router = GoRouter.of(context);
                router.canPop() ? router.pop() : router.go(Routes.lineUp(widget.lineUpId));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _scroll(BuildContext context, LineUpPrepareState state, LineUp lineUp) => LayoutBuilder(
    builder: (context, box) {
      final gutter = DaloySpace.gutter(context);
      final side = math.max(gutter, (box.maxWidth - 720) / 2);
      final bottom = MediaQuery.paddingOf(context).bottom + DaloySpace.s10;

      final slivers = <Widget>[
        SliverToBoxAdapter(
          child: Entrance(
            index: 0,
            child: _Hero(
              lineUp: lineUp,
              state: state,
              side: side,
              titleKey: _hero.titleKey,
              mode: _mode,
              view: _view,
              onMode: (m) {
                HapticFeedback.selectionClick();
                setState(() => _mode = m);
              },
              onView: (v) {
                HapticFeedback.selectionClick();
                setState(() => _view = v);
              },
            ),
          ),
        ),
      ];

      if (state.songsMissing) {
        slivers.add(
          _box(
            side,
            const _Notice(
              icon: TablerIcons.cloud_off,
              text: "This line-up's songs haven't been downloaded to this device yet. Connect to the internet to prepare them.",
            ),
          ),
        );
      } else if (state.songs.isEmpty) {
        slivers.add(
          _box(
            side,
            _Notice(
              icon: TablerIcons.playlist_add,
              text: 'No songs in this line-up yet.',
              action: DaloyButton(
                variant: ButtonVariant.link,
                size: ControlSize.sm,
                label: 'Add songs',
                onPressed: () => context.push(Routes.lineUpEdit(lineUp.id)),
              ),
            ),
          ),
        );
      }

      // Entrance order down the page: hero, then each song's header and cards.
      var order = 1;
      for (final (i, song) in state.songs.indexed) {
        final header = order++;
        slivers.add(
          _box(
            side,
            Padding(
              key: _keyFor(song.songId),
              padding: EdgeInsets.only(top: i == 0 ? DaloySpace.s6 : DaloySpace.s10),
              child: Entrance(
                index: header,
                child: _SongHeader(song: song, mode: _mode, view: _view, onReset: () => _reset(song)),
              ),
            ),
          ),
        );
        slivers.addAll(switch (_mode) {
          _PrepMode.arrange => _arrange(context, song, side, order),
          _PrepMode.notes => [_box(side, Entrance(index: order, child: _notes(context, song, state)))],
        });
        order += _mode == _PrepMode.arrange ? _sectionsOf(song).length : 1;
      }

      slivers.add(SliverPadding(padding: EdgeInsets.only(bottom: bottom)));
      return EntranceScope(
        child: CustomScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, slivers: slivers),
      );
    },
  );

  static Widget _box(double side, Widget child) => SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: side),
    sliver: SliverToBoxAdapter(child: child),
  );

  List<PrepSection> _sectionsOf(PrepareSong song) => _dropped[(song.songId, _view)] ?? song.sectionsFor(_view);

  /// [firstEntrance] is where this song's cards fall in the page's entrance order.
  List<Widget> _arrange(BuildContext context, PrepareSong song, double side, int firstEntrance) {
    final sections = _sectionsOf(song);
    if (sections.isEmpty) {
      final what = _view == SongArrangementView.chords ? 'chords' : 'lyrics';
      return [
        _box(
          side,
          _EmptySong(text: 'No $what for this song yet.', onEdit: () => context.push(Routes.songEdit(song.songId))),
        ),
      ];
    }
    final canDrag = sections.length > 1;
    return [
      if (canDrag) _box(side, _PlayOrder(sections: sections)),
      SliverPadding(
        padding: EdgeInsets.fromLTRB(side, DaloySpace.s3, side, 0),
        sliver: SliverReorderableList(
          itemCount: sections.length,
          onReorderStart: (_) => HapticFeedback.selectionClick(),
          onReorderItem: (from, to) => _move(song, sections, from, to),
          proxyDecorator: (child, _, animation) => _DragProxy(animation: animation, child: child),
          itemBuilder: (context, i) {
            final section = sections[i];
            final card = _SectionCard(
              index: i,
              section: section,
              place: sections.take(i).where((s) => !s.removed).length,
              canDrag: canDrag && !section.removed,
              onToggle: () => _toggle(song, section),
            );
            return Padding(
              key: ValueKey(section.originalIndex),
              padding: const EdgeInsets.only(bottom: DaloySpace.s2),
              child: Entrance(
                index: firstEntrance + i,
                child: canDrag && !section.removed ? ReorderableDelayedDragStartListener(index: i, child: card) : card,
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _notes(BuildContext context, PrepareSong song, LineUpPrepareState state) {
    final s = song.song;
    if (!s.hasChords) {
      return _EmptySong(
        text: 'No chords for this song yet. Notes pin to the chord chart.',
        onEdit: () => context.push(Routes.songEdit(song.songId)),
      );
    }
    final kept = [
      for (final p in song.chords)
        if (!p.removed) p.block,
    ];
    final zoom = math.min(state.detail.prefs.zoom, 100).toDouble();
    final label = sectionLabelStyle(context);
    final c = context.colors;

    return Container(
      margin: const EdgeInsets.only(top: DaloySpace.s3),
      padding: const EdgeInsets.fromLTRB(DaloySpace.s3, DaloySpace.s3, DaloySpace.s3, DaloySpace.s4),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.border),
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, section) in kept.indexed)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : DaloySpace.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (section.label.isNotEmpty || section.repeat > 1)
                    Pressable(
                      onPressed: () => _addNote(song, section.startLine, 'At the top of ${_sectionName(section, i)}'),
                      semanticLabel: 'Add a note at the top of ${_sectionName(section, i)}',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: DaloySpace.s1),
                        child: Row(
                          children: [
                            Text(sectionLabelText(section.label, section.repeat), style: label),
                            const Spacer(),
                            Icon(TablerIcons.note, size: 14, color: c.mutedForeground.withValues(alpha: 0.6)),
                            const SizedBox(width: 2),
                            Icon(TablerIcons.plus, size: 12, color: c.mutedForeground.withValues(alpha: 0.6)),
                          ],
                        ),
                      ),
                    ),
                  ChordSheet(
                    content: section.body,
                    transposition: s.chartTransposition,
                    zoom: zoom,
                    musicalKey: s.originalKey,
                    notation: s.notation,
                    notes: notesForSection(song.notes, section),
                    lineOffset: section.startLine,
                    onLineTap: (line) {
                      final text = linePreview(section.lines[line - section.startLine]);
                      _addNote(song, line + 1, text.isEmpty ? 'Under this line' : 'Under “$text”');
                    },
                    onNoteTap: (note) => _editNote(song, note),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _sectionName(ChartSection section, int place) =>
      section.label.isEmpty ? 'section ${place + 1}' : section.label;
}

// -- Hero ----------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({
    required this.lineUp,
    required this.state,
    required this.side,
    required this.titleKey,
    required this.mode,
    required this.view,
    required this.onMode,
    required this.onView,
  });

  final LineUp lineUp;
  final LineUpPrepareState state;
  final double side;
  final Key titleKey;
  final _PrepMode mode;
  final SongArrangementView view;
  final ValueChanged<_PrepMode> onMode;
  final ValueChanged<SongArrangementView> onView;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final top = MediaQuery.paddingOf(context).top + DaloyChrome.topBarHeight;
    final wide = MediaQuery.sizeOf(context).width >= DaloyBreakpoints.tablet;
    final meta = [formatLineUpDate(lineUp.date), lineUpSongsLabel(state.songs.length)].join(' · ');

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: top + 260,
          child: ArtworkWash(palette: lineUpPalette(lineUp), background: c.background),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(side, top + DaloySpace.s3, side, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  LineUpCover(lineUp: lineUp, keyFlow: state.detail.keyFlow, size: wide ? 132 : 104, animate: false),
                  const SizedBox(width: DaloySpace.s5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PREPARE', style: context.text.labelSmall!.copyWith(color: c.mutedForeground)),
                        const SizedBox(height: DaloySpace.s1),
                        Text(
                          lineUp.title,
                          key: titleKey,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.displaySmall!.copyWith(fontSize: wide ? 28 : 24),
                        ),
                        const SizedBox(height: DaloySpace.s1),
                        Text(
                          meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                        ),
                        const SizedBox(height: DaloySpace.s2),
                        _SyncLine(pending: state.pendingCount, error: state.error, online: state.detail.isOnline),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DaloySpace.s6),
              SegmentedControl<_PrepMode>(
                value: mode,
                options: const [(_PrepMode.arrange, 'Arrange'), (_PrepMode.notes, 'Notes')],
                onChanged: onMode,
              ),
              const SizedBox(height: DaloySpace.s4),
              Text(
                mode == _PrepMode.arrange
                    ? 'Drag sections into the order you’ll play them, or cut some. Only this line-up changes.'
                    : 'Tap a line to pin a note under it, or a section name to pin one at its top. Notes show in Perform.',
                style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
              ),
              if (mode == _PrepMode.arrange) ...[
                const SizedBox(height: DaloySpace.s3),
                SegmentedControl<SongArrangementView>(
                  size: ControlSize.sm,
                  value: view,
                  options: const [(SongArrangementView.chords, 'Chords'), (SongArrangementView.lyrics, 'Lyrics')],
                  onChanged: onView,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Where the prep stands: all on the server, waiting, or refused.
class _SyncLine extends StatelessWidget {
  const _SyncLine({required this.pending, required this.error, required this.online});

  final int pending;
  final String? error;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (icon, color, text) = switch ((pending, error)) {
      (_, final String e) => (TablerIcons.alert_circle, c.destructive, 'Not synced: $e'),
      (0, _) => (TablerIcons.circle_check, c.mutedForeground, 'Changes save as you go'),
      (_, _) when !online => (TablerIcons.cloud_off, c.mutedForeground, "On this device · syncs when you're online"),
      (_, _) => (TablerIcons.refresh, c.mutedForeground, 'Syncing…'),
    };
    return AnimatedSwitcher(
      duration: DaloyMotion.fast,
      child: Row(
        key: ValueKey(text),
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: DaloySpace.s1_5),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall!.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// -- Songs ---------------------------------------------------------------------

class _SongHeader extends StatelessWidget {
  const _SongHeader({required this.song, required this.mode, required this.view, required this.onReset});

  final PrepareSong song;
  final _PrepMode mode;
  final SongArrangementView view;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = song.song;
    final noteCount = song.notes.length;
    final eyebrow = [
      'Song ${s.number}',
      if (s.displayKey case final key?) 'Key of $key',
      if (mode == _PrepMode.notes && noteCount > 0) noteCount == 1 ? '1 note' : '$noteCount notes',
    ].join(' · ');
    final rearranged = mode == _PrepMode.arrange && song.rearranged(view);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(
          eyebrow,
          trailing: song.pending
              ? Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: song.error == null ? c.primary : c.destructive,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
        const SizedBox(height: DaloySpace.s2),
        Row(
          children: [
            SongArtwork(songId: s.entry.song.id, keyName: s.displayKey, width: 44),
            const SizedBox(width: DaloySpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleMedium),
                  if (s.artist case final artist?)
                    Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                    ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: DaloyMotion.fast,
              child: rearranged
                  ? DaloyButton(
                      key: const ValueKey('reset'),
                      variant: ButtonVariant.ghost,
                      size: ControlSize.sm,
                      icon: TablerIcons.restore,
                      label: 'Reset',
                      onPressed: onReset,
                    )
                  : const SizedBox.shrink(key: ValueKey('none')),
            ),
          ],
        ),
      ],
    );
  }
}

/// The song as this line-up plays it, in short names: V1 · C · V2 · C · B.
class _PlayOrder extends StatelessWidget {
  const _PlayOrder({required this.sections});

  final List<PrepSection> sections;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final kept = sections.where((s) => !s.removed).toList();
    return Padding(
      padding: const EdgeInsets.only(top: DaloySpace.s3),
      child: Semantics(
        label: 'Plays as ${[for (final (i, s) in kept.indexed) _name(s, i)].join(', ')}',
        excludeSemantics: true,
        child: Wrap(
          spacing: DaloySpace.s1,
          runSpacing: DaloySpace.s1,
          children: [
            for (final (i, s) in kept.indexed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s2, vertical: 3),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.10),
                  borderRadius: DaloyRadii.all(DaloyRadii.md),
                ),
                child: Text(
                  s.block.repeat > 1
                      ? '${sectionShortLabel(s.block, i)}×${s.block.repeat}'
                      : sectionShortLabel(s.block, i),
                  style: context.text.labelSmall!.copyWith(color: c.primaryInk, letterSpacing: 0.2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _name(PrepSection s, int i) => s.block.label.isEmpty ? 'section ${i + 1}' : s.block.label;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.index,
    required this.section,
    required this.place,
    required this.canDrag,
    required this.onToggle,
  });

  /// Place in the list (for the drag handle).
  final int index;
  final PrepSection section;

  /// Place among the kept sections, for an unlabelled one's name.
  final int place;
  final bool canDrag;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final block = section.block;
    final name = block.label.isEmpty ? 'Section ${place + 1}' : block.label;
    final preview = sectionPreview(block);
    final removed = section.removed;

    return AnimatedOpacity(
      duration: DaloyMotion.fast,
      opacity: removed ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s1, DaloySpace.s2, DaloySpace.s1, DaloySpace.s2),
        decoration: BoxDecoration(
          color: removed ? null : c.card,
          border: Border.all(color: c.border),
          borderRadius: DaloyRadii.all(DaloyRadii.xl),
        ),
        child: Row(
          children: [
            if (canDrag)
              ReorderableDragStartListener(
                index: index,
                child: Semantics(
                  label: 'Reorder $name',
                  child: SizedBox.square(
                    dimension: 40,
                    child: Icon(TablerIcons.grip_vertical, size: 18, color: c.mutedForeground),
                  ),
                ),
              )
            else
              const SizedBox(width: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall!.copyWith(
                            decoration: removed ? TextDecoration.lineThrough : null,
                            color: removed ? c.mutedForeground : null,
                          ),
                        ),
                      ),
                      if (block.repeat > 1) ...[
                        const SizedBox(width: DaloySpace.s1_5),
                        Text('×${block.repeat}', style: context.text.labelSmall!.copyWith(color: c.mutedForeground)),
                      ],
                      if (removed) ...[
                        const SizedBox(width: DaloySpace.s2),
                        Text('Cut', style: context.text.labelSmall!.copyWith(color: c.mutedForeground)),
                      ],
                    ],
                  ),
                  if (preview.isNotEmpty)
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onToggle,
              tooltip: removed ? 'Bring back $name' : 'Cut $name',
              icon: Icon(
                removed ? TablerIcons.arrow_back_up : TablerIcons.scissors,
                size: 18,
                color: removed ? c.primaryInk : c.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The lifted card while dragging: a little bigger, with a soft shadow.
class _DragProxy extends StatelessWidget {
  const _DragProxy({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = Curves.easeOut.transform(animation.value);
      return Transform.scale(
        scale: 1 + 0.02 * t,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: DaloyRadii.all(DaloyRadii.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12 * t),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(type: MaterialType.transparency, child: child),
        ),
      );
    },
    child: child,
  );
}

class _EmptySong extends StatelessWidget {
  const _EmptySong({required this.text, required this.onEdit});

  final String text;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: DaloySpace.s3),
    child: _Notice(
      icon: TablerIcons.music,
      text: text,
      action: DaloyButton(variant: ButtonVariant.link, size: ControlSize.sm, label: 'Edit song', onPressed: onEdit),
    ),
  );
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(top: DaloySpace.s6),
      padding: const EdgeInsets.all(DaloySpace.s4),
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c.mutedForeground),
          const SizedBox(width: DaloySpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
                ?action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
