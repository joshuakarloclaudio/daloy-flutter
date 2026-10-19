import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/segmented_control.dart';
import '../../application/discover_controller.dart';

/// "Library | Discover", on both halves of the Songs tab. It rides in the tab
/// bar (above it when open, beside the folded circle), so it is drawn, not
/// UIKit's control, and takes the width it is given up to 232 and the height
/// the bar gives it.
class SongsSegmentSwitch extends ConsumerWidget {
  const SongsSegmentSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 232),
    child: SegmentedControl<SongsSegment>(
      onGlass: true,
      value: ref.watch(songsSegmentControllerProvider),
      options: const [(SongsSegment.library, 'Library'), (SongsSegment.discover, 'Discover')],
      onChanged: ref.read(songsSegmentControllerProvider.notifier).select,
    ),
  );
}
