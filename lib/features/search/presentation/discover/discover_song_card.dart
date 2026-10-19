import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_spinner.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../songs/presentation/widgets/song_key_chip.dart';
import '../../domain/network_song.dart';

/// One shared song in Discover: title and key, a two-line taste of the
/// words in the serif the lyrics are set in, and who shared it.
class DiscoverSongCard extends StatelessWidget {
  const DiscoverSongCard({super.key, required this.song, required this.onTap, this.onAdd, this.adding = false});

  final NetworkSong song;
  final VoidCallback onTap;

  /// Quick add; null once the song is in the library.
  final VoidCallback? onAdd;
  final bool adding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final meta = [
      if (song.artist?.isNotEmpty == true) song.artist!,
      if (song.bpm != null) '${song.bpm} BPM',
    ].join(' · ');
    final teaser = song.preview?.trim();

    return Pressable(
      onPressed: onTap,
      pressedScale: 0.985,
      semanticLabel: '${song.title}, shared by ${song.workspaceName}',
      child: Container(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s3_5, DaloySpace.s3, DaloySpace.s3),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.border),
          borderRadius: DaloyRadii.all(DaloyRadii.xl2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: context.text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          meta,
                          style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: DaloySpace.s3),
                // Centred on the title line, whatever the button's 48px does.
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      SongKeyChip(keyName: song.key),
                      _AddButton(song: song, onAdd: onAdd, adding: adding),
                    ],
                  ),
                ),
              ],
            ),
            if (teaser != null && teaser.isNotEmpty) ...[
              const SizedBox(height: DaloySpace.s2_5),
              Container(
                padding: const EdgeInsets.only(left: DaloySpace.s3),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: c.primary.withValues(alpha: 0.35), width: 2)),
                ),
                child: Text(
                  teaser,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium!.copyWith(
                    fontFamily: DaloyFonts.serif,
                    color: c.mutedForeground,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: DaloySpace.s3),
            Padding(
              padding: const EdgeInsets.only(right: DaloySpace.s1),
              child: Row(
                children: [
                  Icon(TablerIcons.building_church, size: 14, color: c.mutedForeground),
                  const SizedBox(width: DaloySpace.s1_5),
                  Flexible(
                    child: Text(
                      song.workspaceName,
                      style: context.text.labelMedium!.copyWith(color: c.mutedForeground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (song.importCount > 0) ...[
                    const SizedBox(width: DaloySpace.s3),
                    Icon(TablerIcons.users, size: 14, color: c.mutedForeground),
                    const SizedBox(width: DaloySpace.s1),
                    Semantics(
                      label: song.importCount == 1 ? 'Added by 1 team' : 'Added by ${song.importCount} teams',
                      excludeSemantics: true,
                      child: Text(
                        song.importCount == 1 ? '1 team' : '${song.importCount} teams',
                        style: context.text.labelMedium!.copyWith(color: c.mutedForeground),
                      ),
                    ),
                  ],
                  if (song.hasMedia) ...[
                    const SizedBox(width: DaloySpace.s3),
                    Icon(TablerIcons.headphones, size: 14, color: c.mutedForeground),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.song, required this.onAdd, required this.adding});

  final NetworkSong song;
  final VoidCallback? onAdd;
  final bool adding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (song.alreadyAdded || song.isOwnWorkspace) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s2, vertical: DaloySpace.s2),
        child: Icon(TablerIcons.circle_check, size: 22, color: c.primary, semanticLabel: 'In your library'),
      );
    }
    return IconButton(
      tooltip: 'Add to library',
      onPressed: adding ? null : onAdd,
      icon: adding ? const DaloySpinner(size: 18) : Icon(TablerIcons.circle_plus, size: 24, color: c.primaryInk),
    );
  }
}
