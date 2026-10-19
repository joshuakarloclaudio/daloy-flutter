import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/music_player_controller.dart';
import '../domain/player_queue.dart';
import 'player_controls.dart';

/// The queue as a sliver: every song of the set in order. Songs without a
/// link — or with one YouTube won't play here — are dimmed, skipped, and
/// offer to take a link.
class PlayerQueueSliver extends ConsumerWidget {
  const PlayerQueueSliver({super.key, this.padding = EdgeInsets.zero});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(musicPlayerProvider);
    final tracks = player.tracks;
    return SliverPadding(
      padding: padding,
      sliver: SliverList.builder(
        itemCount: tracks.length,
        itemBuilder: (context, i) => _QueueRow(
          track: tracks[i],
          current: i == player.currentIndex,
          playing: i == player.currentIndex && player.isPlaying,
          unavailable: player.isUnavailable(tracks[i]),
        ),
      ),
    );
  }
}

class _QueueRow extends ConsumerWidget {
  const _QueueRow({required this.track, required this.current, required this.playing, required this.unavailable});

  final PlayerTrack track;
  final bool current;
  final bool playing;
  final bool unavailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final playable = track.hasVideo && !unavailable;
    final note = !track.hasVideo
        ? 'No YouTube link'
        : unavailable
        ? 'Won’t play here'
        : [?track.artist, if (track.displayKey case final k?) 'Key of $k'].join(' · ');
    final ink = playable ? c.foreground : c.mutedForeground;

    Widget lead;
    if (current) {
      lead = Icon(playing ? TablerIcons.volume : TablerIcons.player_pause_filled, size: 18, color: c.primaryInk);
    } else if (!playable) {
      lead = Icon(TablerIcons.brand_youtube, size: 18, color: c.mutedForeground.withValues(alpha: 0.6));
    } else {
      lead = Text(
        '${track.number}',
        style: context.text.labelLarge!.copyWith(
          color: c.mutedForeground,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      );
    }

    return Semantics(
      selected: current,
      button: playable,
      label: '${track.number}. ${track.title}${note.isEmpty ? '' : ', $note'}',
      excludeSemantics: playable,
      child: Pressable(
        pressedScale: 0.99,
        onPressed: playable
            ? () {
                HapticFeedback.selectionClick();
                ref.read(musicPlayerProvider.notifier).playTrack(track.index);
              }
            : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2),
          decoration: BoxDecoration(
            color: current ? c.muted : Colors.transparent,
            borderRadius: DaloyRadii.all(DaloyRadii.xl),
          ),
          child: Row(
            children: [
              SizedBox(width: 28, child: Center(child: lead)),
              const SizedBox(width: DaloySpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyLarge!
                          .weight(current ? FontWeight.w600 : FontWeight.w500)
                          .copyWith(color: current ? c.primaryInk : ink),
                    ),
                    if (note.isNotEmpty)
                      Text(
                        note,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                      ),
                  ],
                ),
              ),
              if (!playable)
                DaloyButton(
                  variant: ButtonVariant.plain,
                  size: ControlSize.sm,
                  icon: unavailable ? TablerIcons.refresh : TablerIcons.plus,
                  label: unavailable ? 'Replace' : 'Add link',
                  onPressed: () => showYouTubeLinkSheet(context, track, replacing: unavailable),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
