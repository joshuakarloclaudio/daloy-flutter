import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_button.dart';
import '../../../../shared/widgets/daloy_sheet.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/segmented_control.dart';
import '../../../songs/application/song_detail_controller.dart' show maxCapo;
import '../../../songs/chart/nashville.dart';
import '../../../songs/domain/display_prefs.dart';
import '../../../songs/presentation/song_actions.dart' show editSongChords, editSongLyrics;
import '../../../songs/presentation/widgets/chord_sheet.dart';
import '../../../songs/presentation/widgets/lyrics_sheet.dart';
import '../../../songs/presentation/widgets/pinch_zoom.dart';
import '../../../songs/presentation/widgets/stepper_track.dart';
import '../../application/line_up_detail_controller.dart';

/// A song from the set, drawn the way this line-up plays it: in its key for
/// the service, with this user's capo. Swipe sideways through the set. The
/// pencil goes straight into the chord or lyrics editor for what's showing.
Future<void> showSetlistSongSheet(BuildContext context, {required int lineUpId, required int position}) =>
    showDaloySheet<void>(
      context: context,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.94,
        child: _SetlistSongSheet(lineUpId: lineUpId, position: position),
      ),
    );

class _SetlistSongSheet extends ConsumerStatefulWidget {
  const _SetlistSongSheet({required this.lineUpId, required this.position});

  final int lineUpId;
  final int position;

  @override
  ConsumerState<_SetlistSongSheet> createState() => _SetlistSongSheetState();
}

class _SetlistSongSheetState extends ConsumerState<_SetlistSongSheet> {
  late final PageController _pages;
  late int _index;

  /// The live zoom while two fingers are down; null otherwise.
  double? _pinchZoom;
  bool _pinching = false;

  LineUpDetailControllerProvider get _provider => lineUpDetailControllerProvider(widget.lineUpId);

  @override
  void initState() {
    super.initState();
    final songs = ref.read(_provider).songs;
    _index = songs.indexWhere((s) => s.position == widget.position).clamp(0, songs.isEmpty ? 0 : songs.length - 1);
    _pages = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _pinchEnd(LineUpDetailController controller) {
    final zoom = _pinchZoom;
    setState(() => _pinchZoom = null);
    if (zoom == null) return;
    HapticFeedback.lightImpact();
    controller.setZoom(ChartPrefs.clampZoom(zoom));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final state = ref.watch(_provider);
    final controller = ref.read(_provider.notifier);
    final songs = state.songs;

    // The set changed under the sheet (deleted elsewhere): nothing to show.
    if (songs.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
      return const SizedBox.shrink();
    }
    final index = _index.clamp(0, songs.length - 1);
    final current = songs[index];
    final chords = state.prefs.viewMode == SongViewMode.chords;
    void edit(SetlistSong song) =>
        chords ? editSongChords(context, ref, song.entry.song) : editSongLyrics(context, ref, song.entry.song);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(DaloySpace.gutter(context), 0, DaloySpace.s3, DaloySpace.s1),
          child: Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: DaloyMotion.fast,
                  child: Text(
                    'SONG ${current.number} OF ${songs.length}',
                    key: ValueKey(current.number),
                    style: context.text.labelSmall!.copyWith(color: c.mutedForeground),
                  ),
                ),
              ),
              TopBarIconButton(
                icon: TablerIcons.pencil,
                tooltip: chords ? 'Edit chords' : 'Edit lyrics',
                onPressed: () => edit(current),
              ),
              TopBarIconButton(
                icon: TablerIcons.music,
                tooltip: 'Open song',
                onPressed: () => context.push(Routes.song(current.entry.song.id)),
              ),
              TopBarIconButton(icon: TablerIcons.x, tooltip: 'Close', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pages,
            physics: _pinching ? const NeverScrollableScrollPhysics() : null,
            itemCount: songs.length,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _index = i);
            },
            itemBuilder: (context, i) => _SongPage(
              song: songs[i],
              state: state,
              controller: controller,
              zoom: _pinchZoom ?? state.prefs.zoom.toDouble(),
              pinching: _pinching,
              onPinchActive: (active) => setState(() => _pinching = active),
              onPinchUpdate: (factor) => setState(
                () => _pinchZoom = (state.prefs.zoom * factor).clamp(
                  ChartPrefs.minZoom.toDouble(),
                  ChartPrefs.maxZoom.toDouble(),
                ),
              ),
              onPinchEnd: () => _pinchEnd(controller),
              onEdit: () => edit(songs[i]),
            ),
          ),
        ),
        if (songs.length > 1)
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: DaloySpace.s2),
            child: _PageDots(
              count: songs.length,
              index: index,
              onSelect: (i) => _pages.animateToPage(i, duration: DaloyMotion.medium, curve: DaloyMotion.ease),
            ),
          ),
      ],
    );
  }
}

class _SongPage extends StatelessWidget {
  const _SongPage({
    required this.song,
    required this.state,
    required this.controller,
    required this.zoom,
    required this.pinching,
    required this.onPinchActive,
    required this.onPinchUpdate,
    required this.onPinchEnd,
    required this.onEdit,
  });

  final SetlistSong song;
  final LineUpDetailState state;
  final LineUpDetailController controller;
  final double zoom;
  final bool pinching;
  final ValueChanged<bool> onPinchActive;
  final ValueChanged<double> onPinchUpdate;
  final VoidCallback onPinchEnd;

  /// Into the editor for what's showing (chords or lyrics).
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final gutter = DaloySpace.gutter(context);
    final subtitle = [?song.artist, ?song.tempo].join(' · ');
    final p = song.position;

    return SingleChildScrollView(
      physics: pinching ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.fromLTRB(gutter, DaloySpace.s1, gutter, DaloySpace.s8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(song.title, style: context.text.displaySmall!.copyWith(fontSize: 24)),
              if (subtitle.isNotEmpty || song.numberingReference != null) ...[
                const SizedBox(height: DaloySpace.s1_5),
                Wrap(
                  spacing: DaloySpace.s2,
                  runSpacing: DaloySpace.s1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
                    if (song.numberingReference != null) _Tag(song.numberingReference!),
                  ],
                ),
              ],
              const SizedBox(height: DaloySpace.s4),
              Row(
                children: [
                  if (song.canTranspose) ...[
                    Expanded(
                      child: StepperTrack(
                        label: 'Key ${song.displayKey}',
                        decreaseLabel: 'Transpose down',
                        increaseLabel: 'Transpose up',
                        onDecrease: () => controller.transposeDown(p),
                        onIncrease: () => controller.transposeUp(p),
                      ),
                    ),
                    const SizedBox(width: DaloySpace.s2),
                  ],
                  Expanded(
                    child: StepperTrack(
                      label: song.capo > 0 ? 'Capo ${song.capo}' : 'No capo',
                      decreaseLabel: 'Capo down',
                      increaseLabel: 'Capo up',
                      onDecrease: song.canEditCapo && song.capo > 0 ? () => controller.capoDown(p) : null,
                      onIncrease: song.canEditCapo && song.capo < maxCapo ? () => controller.capoUp(p) : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DaloySpace.s2),
              _KeyCaption(song: song, onReset: () => controller.resetKey(p)),
              const SizedBox(height: DaloySpace.s4),
              Row(
                children: [
                  Expanded(
                    child: SegmentedControl<SongViewMode>(
                      value: state.prefs.viewMode,
                      options: const [(SongViewMode.chords, 'Chords'), (SongViewMode.lyrics, 'Lyrics')],
                      onChanged: controller.setViewMode,
                    ),
                  ),
                  if (state.prefs.viewMode == SongViewMode.chords && song.canShowNumbers) ...[
                    const SizedBox(width: DaloySpace.s2),
                    SizedBox(
                      width: 128,
                      child: SegmentedControl<ChordNotation>(
                        value: song.notation,
                        options: const [(ChordNotation.letters, 'ABC'), (ChordNotation.numbers, '123')],
                        onChanged: controller.setNotation,
                      ),
                    ),
                  ],
                ],
              ),
              if (song.entry.notes.isNotEmpty) ...[const SizedBox(height: DaloySpace.s4), _TeamNotes(song: song)],
              const SizedBox(height: DaloySpace.s4),
              PinchZoom(
                onActiveChanged: onPinchActive,
                onUpdate: onPinchUpdate,
                onEnd: (_) => onPinchEnd(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s5),
                  decoration: BoxDecoration(
                    color: c.background.withValues(alpha: 0.6),
                    border: Border.all(color: c.border),
                    borderRadius: DaloyRadii.all(DaloyRadii.xl2),
                  ),
                  child: AnimatedSize(
                    duration: DaloyMotion.medium,
                    curve: DaloyMotion.ease,
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: DaloyMotion.medium,
                      layoutBuilder: (current, previous) =>
                          Stack(alignment: Alignment.topLeft, children: [...previous, ?current]),
                      child: KeyedSubtree(
                        key: ValueKey(state.prefs.viewMode),
                        child: switch (state.prefs.viewMode) {
                          SongViewMode.chords =>
                            song.hasChords
                                ? ChordSheet(
                                    content: song.entry.song.content!,
                                    transposition: song.chartTransposition,
                                    zoom: zoom,
                                    musicalKey: song.originalKey,
                                    notation: song.notation,
                                  )
                                : _Empty('No chords added yet.', action: 'Add chords', onAction: onEdit),
                          SongViewMode.lyrics =>
                            song.hasLyrics
                                ? LyricsSheet(lyrics: song.entry.song.lyrics!, zoom: zoom)
                                : _Empty('No lyrics added yet.', action: 'Add lyrics', onAction: onEdit),
                        },
                      ),
                    ),
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

/// Says who a change reaches: the key is the band's, the capo is yours.
class _KeyCaption extends StatelessWidget {
  const _KeyCaption({required this.song, required this.onReset});

  final SetlistSong song;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.text.bodySmall!.copyWith(color: c.mutedForeground);
    final note = Text(
      song.canTranspose ? 'Key changes reach the whole team. Capo is just for you.' : 'Capo is just for you.',
      style: style,
    );
    if (!song.isTransposed) return note;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Written in ${song.originalKey} · ', style: style),
            Pressable(
              onPressed: onReset,
              semanticLabel: 'Reset to ${song.originalKey}',
              child: Text(
                'Reset',
                style: style.copyWith(color: c.primaryInk, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        note,
      ],
    );
  }
}

class _TeamNotes extends StatelessWidget {
  const _TeamNotes({required this.song});

  final SetlistSong song;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final notes = [...song.entry.notes]..sort((a, b) => a.line.compareTo(b.line));
    return Container(
      padding: const EdgeInsets.all(DaloySpace.s4),
      decoration: BoxDecoration(
        color: c.primary.withValues(alpha: 0.06),
        border: Border.all(color: c.primary.withValues(alpha: 0.2)),
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(TablerIcons.notes, size: 16, color: c.primaryInk),
              const SizedBox(width: DaloySpace.s1_5),
              Text('TEAM NOTES', style: context.text.labelSmall!.copyWith(color: c.primaryInk)),
            ],
          ),
          for (final note in notes) ...[
            const SizedBox(height: DaloySpace.s2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Line ${note.line + 1}  ',
                    style: context.text.labelMedium!.copyWith(
                      color: c.mutedForeground,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  TextSpan(text: note.text),
                ],
              ),
              style: context.text.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.1), borderRadius: DaloyRadii.all(DaloyRadii.md)),
      child: Text(
        label,
        style: context.text.labelMedium!.copyWith(color: c.primaryInk, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index, required this.onSelect});

  final int count;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: SizedBox(
        height: 28,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(i),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: count > 12 ? 2 : 3, vertical: 10),
                  child: AnimatedContainer(
                    duration: DaloyMotion.medium,
                    curve: DaloyMotion.ease,
                    width: i == index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == index ? c.foreground : c.mutedForeground.withValues(alpha: 0.35),
                      borderRadius: DaloyRadii.all(DaloyRadii.full),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.message, {required this.action, required this.onAction});

  final String message;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        message,
        style: context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground, fontStyle: FontStyle.italic),
      ),
      const SizedBox(height: DaloySpace.s3),
      DaloyButton.outline(label: action, icon: TablerIcons.plus, size: ControlSize.sm, onPressed: onAction),
    ],
  );
}
