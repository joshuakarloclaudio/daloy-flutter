import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_sheet.dart';
import '../../../../shared/widgets/segmented_control.dart';
import '../../application/song_detail_controller.dart';
import '../../chart/nashville.dart';
import 'stepper_track.dart';

/// How this device draws the chart: chords or lyrics, letters or numbers, and
/// text size. Changes apply live behind the sheet (beside it, in a tablet's
/// popover from [anchor]).
Future<void> showSongDisplaySheet(BuildContext context, int songId, {Rect? anchor}) => showDaloySheet<void>(
  context: context,
  fit: true,
  anchor: anchor,
  builder: (_) => _SongDisplaySheet(songId: songId),
);

class _SongDisplaySheet extends ConsumerWidget {
  const _SongDisplaySheet({required this.songId});

  final int songId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final state = ref.watch(songDetailControllerProvider(songId));
    final controller = ref.read(songDetailControllerProvider(songId).notifier);
    final prefs = state.prefs;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Display', style: context.text.titleMedium),
            const SizedBox(height: DaloySpace.s1),
            Text(
              'How chords are written and how large the chart is, on this device.',
              style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
            ),
            const SizedBox(height: DaloySpace.s5),
            _Label('Chords as'),
            SegmentedControl<ChordNotation>(
              value: state.notation,
              options: const [(ChordNotation.letters, 'Letters'), (ChordNotation.numbers, 'Numbers')],
              disabled: state.canShowNumbers ? const {} : const {ChordNotation.numbers},
              onChanged: controller.setNotation,
            ),
            if (!state.canShowNumbers)
              Padding(
                padding: const EdgeInsets.only(top: DaloySpace.s2),
                child: Text(
                  'Numbers need a key. Set one on this song to turn them on.',
                  style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                ),
              ),
            const SizedBox(height: DaloySpace.s5),
            _Label('Text size'),
            StepperTrack(
              label: '${prefs.zoom}%',
              decreaseLabel: 'Smaller text',
              increaseLabel: 'Larger text',
              onDecrease: prefs.canZoomOut ? controller.zoomOut : null,
              onIncrease: prefs.canZoomIn ? controller.zoomIn : null,
            ),
            const SizedBox(height: DaloySpace.s2),
            Row(
              children: [
                Icon(TablerIcons.hand_two_fingers, size: 14, color: c.mutedForeground),
                const SizedBox(width: DaloySpace.s1_5),
                Text('Or pinch the chart.', style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: DaloySpace.s2),
    child: Text(text.toUpperCase(), style: context.text.labelSmall!.copyWith(color: context.colors.mutedForeground)),
  );
}
