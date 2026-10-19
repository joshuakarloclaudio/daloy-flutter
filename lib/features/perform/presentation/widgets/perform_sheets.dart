import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_button.dart';
import '../../../../shared/widgets/daloy_switch.dart';
import '../../../../shared/widgets/hairline.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/segmented_control.dart';
import '../../../../shared/widgets/sheet_frame.dart';
import '../../../songs/application/song_detail_controller.dart' show maxCapo;
import '../../../songs/chart/nashville.dart';
import '../../../songs/domain/display_prefs.dart';
import '../../../songs/presentation/widgets/stepper_track.dart';
import '../../application/perform_controller.dart';
import '../../domain/perform_sections.dart';
import '../../domain/perform_theme.dart';
import 'perform_themed.dart';

// -- Display -------------------------------------------------------------------

/// How the chart looks, ordered by how often a player reaches for each:
/// what you're reading, how chords are written, how big, notes, the screen,
/// then the theme. Changes apply behind the sheet as you make them.
Future<void> showPerformSettingsSheet(BuildContext context, PerformSource source) => showPerformSheet<void>(
  context,
  title: 'Display',
  description: 'Changes apply as you make them.',
  builder: (_) => _PerformSettings(source: source),
);

class _PerformSettings extends ConsumerWidget {
  const _PerformSettings({required this.source});

  final PerformSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final state = ref.watch(performControllerProvider(source));
    final controller = ref.read(performControllerProvider(source).notifier);
    final current = state.current?.row;
    final canShowNumbers = current?.canShowNumbers ?? true;
    final isChords = state.viewMode == SongViewMode.chords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PerformSheetLabel('Show'),
        SegmentedControl<SongViewMode>(
          value: state.viewMode,
          options: const [(SongViewMode.chords, 'Chords'), (SongViewMode.lyrics, 'Lyrics')],
          onChanged: controller.setViewMode,
        ),
        if (isChords) ...[
          const SizedBox(height: DaloySpace.s5),
          const PerformSheetLabel('Chords as'),
          SegmentedControl<ChordNotation>(
            value: state.notation,
            options: const [(ChordNotation.letters, 'Letters'), (ChordNotation.numbers, 'Numbers')],
            disabled: canShowNumbers ? const {} : const {ChordNotation.numbers},
            onChanged: controller.setNotation,
          ),
          if (!canShowNumbers && current != null)
            Padding(
              padding: const EdgeInsets.only(top: DaloySpace.s2),
              child: Text(
                '“${current.title}” has no key yet, so it stays in letters.',
                style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
              ),
            ),
        ],
        const SizedBox(height: DaloySpace.s5),
        const PerformSheetLabel('Text size'),
        StepperTrack(
          label: '${state.chart.zoom}%',
          decreaseLabel: 'Smaller text',
          increaseLabel: 'Larger text',
          onDecrease: state.chart.canZoomOut ? controller.zoomOut : null,
          onIncrease: state.chart.canZoomIn ? controller.zoomIn : null,
        ),
        const SizedBox(height: DaloySpace.s2),
        Row(
          children: [
            Icon(TablerIcons.hand_two_fingers, size: 14, color: c.mutedForeground),
            const SizedBox(width: DaloySpace.s1_5),
            Text('Or pinch the chart.', style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
          ],
        ),
        const SizedBox(height: DaloySpace.s5),
        const PerformSheetLabel('Screen'),
        PerformSwitchGroup(
          children: [
            PerformSwitchRow(
              label: 'Show team notes',
              value: state.prefs.notesVisible,
              onChanged: controller.setNotesVisible,
            ),
            PerformSwitchRow(
              label: 'Hide controls while playing',
              detail: 'Tap the chart to bring them back.',
              value: state.prefs.autoHide,
              onChanged: controller.setAutoHide,
            ),
          ],
        ),
        const SizedBox(height: DaloySpace.s5),
        const PerformSheetLabel('Theme'),
        _ThemeGrid(value: state.prefs.theme, onChanged: controller.setTheme),
      ],
    );
  }
}

/// The section label every sheet shares.
typedef PerformSheetLabel = SheetSectionLabel;

class PerformSwitchGroup extends StatelessWidget {
  const PerformSwitchGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) Hairline(), children[i]],
        ],
      ),
    );
  }
}

class PerformSwitchRow extends StatelessWidget {
  const PerformSwitchRow({super.key, required this.label, required this.value, required this.onChanged, this.detail});

  final String label;
  final String? detail;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return MergeSemantics(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!value);
        },
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(DaloySpace.s3, DaloySpace.s2, DaloySpace.s2, DaloySpace.s2),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: context.text.bodyMedium),
                      if (detail != null)
                        Text(detail!, style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
                    ],
                  ),
                ),
                DaloySwitch(value: value, onChanged: onChanged, semanticLabel: label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Each theme as a swatch — its page tone with three lines of its ink — so
/// the picker previews the chart rather than naming colours.
class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({required this.value, required this.onChanged});

  final PerformTheme value;
  final ValueChanged<PerformTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        const gap = DaloySpace.s2;
        final width = (box.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final theme in PerformTheme.values)
              Semantics(
                selected: theme == value,
                inMutuallyExclusiveGroup: true,
                child: Pressable(
                  semanticLabel: '${theme.label} theme',
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onChanged(theme);
                  },
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.all(DaloySpace.s1_5),
                    decoration: BoxDecoration(
                      color: theme == value ? c.primary.withValues(alpha: 0.08) : null,
                      border: Border.all(color: theme == value ? c.primary : c.border, width: theme == value ? 2 : 1),
                      borderRadius: DaloyRadii.all(DaloyRadii.xl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Swatch(theme: theme),
                        const SizedBox(height: DaloySpace.s1_5),
                        Text(
                          theme.label,
                          style: context.text.labelMedium!.copyWith(
                            color: theme == value ? c.primaryInk : c.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.theme});

  final PerformTheme theme;

  @override
  Widget build(BuildContext context) {
    // Default is split: half the light page, half the dark one.
    final light = PerformPalette.light.colors;
    final dark = PerformPalette.dark.colors;
    final palette = theme.resolve(Brightness.light).colors;
    final split = theme == PerformTheme.appDefault;
    final ink = split ? const Color(0x61808080) : palette.foreground.withValues(alpha: 0.4);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s2),
      decoration: BoxDecoration(
        color: split ? null : palette.background,
        gradient: split
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.5, 0.5],
                colors: [light.background, dark.background],
              )
            : null,
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        borderRadius: DaloyRadii.all(DaloyRadii.lg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, f) in [1.0, 0.75, 0.85].indexed) ...[
            if (i > 0) const SizedBox(height: 5),
            FractionallySizedBox(
              widthFactor: f,
              child: Container(
                height: i == 0 ? 2 : 1.5,
                decoration: BoxDecoration(
                  color: i == 0 ? ink : ink.withValues(alpha: ink.a * 0.55),
                  borderRadius: DaloyRadii.all(DaloyRadii.full),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -- Setlist -------------------------------------------------------------------

/// The set at a glance: every song with its key; the current one opens to
/// its sections. Tap a song or a section to go there.
Future<void> showPerformSetlistSheet(
  BuildContext context, {
  required PerformSource source,
  required ValueChanged<int> onSong,
  required void Function(int song, String sectionId) onSection,
}) {
  final state = ProviderScope.containerOf(context).read(performControllerProvider(source));
  return showPerformSheet<void>(
    context,
    title: state.title ?? 'Setlist',
    description: '${state.songs.length} ${state.songs.length == 1 ? 'song' : 'songs'}',
    builder: (_) => _Setlist(source: source, onSong: onSong, onSection: onSection),
  );
}

class _Setlist extends ConsumerWidget {
  const _Setlist({required this.source, required this.onSong, required this.onSection});

  final PerformSource source;
  final ValueChanged<int> onSong;
  final void Function(int song, String sectionId) onSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final palette = PerformPaletteScope.of(context);
    final state = ref.watch(performControllerProvider(source));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, song) in state.songs.indexed) ...[
          Pressable(
            pressedScale: 0.99,
            semanticLabel: 'Song ${i + 1}, ${song.row.title}${i == state.songIndex ? ', playing' : ''}',
            onPressed: () {
              Navigator.of(context).pop();
              onSong(i);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2_5),
              decoration: BoxDecoration(
                color: i == state.songIndex ? palette.highlight.withValues(alpha: 0.1) : null,
                borderRadius: DaloyRadii.all(DaloyRadii.xl),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${i + 1}',
                      style: context.text.labelLarge!.copyWith(
                        color: i == state.songIndex ? palette.highlight : c.mutedForeground,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: DaloySpace.s2),
                  Expanded(
                    child: Text(
                      song.row.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall!.weight(i == state.songIndex ? FontWeight.w700 : FontWeight.w500),
                    ),
                  ),
                  if (song.row.displayKey case final key?)
                    Text(key, style: context.text.labelLarge!.copyWith(color: c.mutedForeground)),
                ],
              ),
            ),
          ),
          if (i == state.songIndex && song.sections.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(DaloySpace.s10, DaloySpace.s1, 0, DaloySpace.s2),
              child: Wrap(
                spacing: DaloySpace.s1_5,
                runSpacing: DaloySpace.s1_5,
                children: [
                  for (final (j, section) in song.sections.indexed)
                    PerformChip(
                      label: sectionChipLabel(section, j),
                      active: section.id == state.activeSectionId,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onSection(i, section.id);
                      },
                    ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// A section (or setting) pill. The active one is solid in the theme's
/// highlight, so it reads from a music stand.
class PerformChip extends StatelessWidget {
  const PerformChip({
    super.key,
    required this.label,
    required this.active,
    required this.onPressed,
    this.onLongPress,
    this.looping = false,
    this.floating = false,
  });

  final String label;
  final bool active;
  final VoidCallback onPressed;

  /// Over the chart on its own (the top bar's row), not in a panel: taller,
  /// nearly solid so the chart doesn't read through, and lifted off it.
  /// No blur — a row of them would be a blur each.
  final bool floating;

  /// Practice: loop this section.
  final VoidCallback? onLongPress;

  /// Practice: this section is looping (a loop mark beside the label).
  final bool looping;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final palette = PerformPaletteScope.of(context);
    return Semantics(
      selected: active,
      onLongPressHint: onLongPress == null ? null : (looping ? 'Stop looping' : 'Loop this section'),
      child: GestureDetector(
        onLongPress: onLongPress == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onLongPress!();
              },
        child: Pressable(
          semanticLabel: looping ? '$label, looping' : label,
          onPressed: () {
            HapticFeedback.selectionClick();
            onPressed();
          },
          child: AnimatedContainer(
            duration: palette.flat ? Duration.zero : DaloyMotion.fast,
            height: floating ? 36 : 32,
            padding: EdgeInsets.symmetric(horizontal: floating ? DaloySpace.s3_5 : DaloySpace.s3),
            decoration: BoxDecoration(
              color: active
                  ? palette.highlight
                  : floating
                  ? (Theme.of(context).brightness == Brightness.dark ? c.card : c.background).withValues(
                      alpha: palette.flat ? 1 : 0.94,
                    )
                  : c.muted.withValues(alpha: palette.flat ? 1 : 0.8),
              border: Border.all(color: active ? palette.highlight : c.border),
              borderRadius: DaloyRadii.all(DaloyRadii.full),
              boxShadow: floating && !palette.flat
                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 3))]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (looping) ...[
                  Icon(TablerIcons.repeat, size: 13, color: active ? palette.highlightForeground : palette.highlight),
                  const SizedBox(width: DaloySpace.s1),
                ],
                Text(
                  label,
                  maxLines: 1,
                  style: context.text.labelLarge!
                      .copyWith(color: active ? palette.highlightForeground : c.foreground)
                      .weight(active ? FontWeight.w700 : FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -- Song (key + capo) -------------------------------------------------------------

/// The current song's key for this service (the whole team plays it) and
/// this player's capo (just them).
Future<void> showPerformSongSheet(BuildContext context, PerformSource source) {
  final song = ProviderScope.containerOf(context).read(performControllerProvider(source)).current;
  return showPerformSheet<void>(
    context,
    title: song?.row.title ?? 'Song',
    description: song?.row.originalKey == null ? null : 'Written in ${song!.row.originalKey}',
    builder: (_) => _SongTools(source: source),
  );
}

class _SongTools extends ConsumerWidget {
  const _SongTools({required this.source});

  final PerformSource source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final state = ref.watch(performControllerProvider(source));
    final controller = ref.read(performControllerProvider(source).notifier);
    final current = state.current;
    final song = current?.row;
    if (current == null || song == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (song.canTranspose) ...[
          PerformSheetLabel(state.isSingleSong ? 'Key · saved to the song' : 'Key · for the team'),
          StepperTrack(
            label: 'Key ${song.displayKey}',
            decreaseLabel: 'Transpose down',
            increaseLabel: 'Transpose up',
            onDecrease: controller.transposeDown,
            onIncrease: controller.transposeUp,
          ),
          if (song.isTransposed)
            Align(
              alignment: Alignment.centerLeft,
              child: DaloyButton(
                variant: ButtonVariant.plain,
                label: 'Back to ${song.originalKey}',
                onPressed: controller.resetKey,
              ),
            ),
          const SizedBox(height: DaloySpace.s4),
        ] else
          Padding(
            padding: const EdgeInsets.only(bottom: DaloySpace.s4),
            child: Text(
              'This song has no key yet, so it can’t be transposed here.',
              style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
            ),
          ),
        const PerformSheetLabel('Capo · just you'),
        StepperTrack(
          label: song.capo > 0 ? 'Capo ${song.capo}' : 'No capo',
          decreaseLabel: 'Capo down',
          increaseLabel: 'Capo up',
          onDecrease: current.capoEditable && song.capo > 0 ? controller.capoDown : null,
          onIncrease: current.capoEditable && song.capo < maxCapo ? controller.capoUp : null,
        ),
        if (!current.capoEditable)
          Padding(
            padding: const EdgeInsets.only(top: DaloySpace.s2),
            child: Text(
              'Capo can be set once this line-up has synced.',
              style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
            ),
          ),
      ],
    );
  }
}
