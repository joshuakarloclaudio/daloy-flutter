import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../songs/domain/song.dart';
import '../../../songs/presentation/widgets/song_key_chip.dart';

/// "Jump back in": songs opened last, newest first, as a shelf of small
/// cards — key up top, title and artist at the foot — scrolling sideways with the
/// platform's own physics. Bleeds to the screen edge while the first card
/// stays aligned with the band's title.
class RecentShelf extends StatelessWidget {
  const RecentShelf({super.key, required this.songs, required this.onOpen});

  final List<Song> songs;
  final ValueChanged<Song> onOpen;

  static const _cardWidth = 148.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (songs.isEmpty) {
      return Text(
        'Songs you open show up here, newest first.',
        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
      );
    }

    final gutter = DaloySpace.gutter(context);
    final scaler = MediaQuery.textScalerOf(context);
    // A horizontal list needs a fixed height; size it to the card's text at
    // the current text scale so large type never clips.
    final height =
        DaloySpace.s3 * 2 +
        SongKeyChip.height(context) +
        DaloySpace.s4 +
        scaler.scale(context.text.titleSmall!.fontSize!) * 1.4 * 2 +
        scaler.scale(context.text.bodySmall!.fontSize!) * 1.4 +
        2;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) => OverflowBox(
          maxWidth: constraints.maxWidth + gutter * 2,
          minWidth: constraints.maxWidth + gutter * 2,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: gutter),
            itemCount: songs.length,
            separatorBuilder: (_, _) => const SizedBox(width: DaloySpace.s3),
            itemBuilder: (context, i) => _RecentSongCard(song: songs[i], onTap: () => onOpen(songs[i])),
          ),
        ),
      ),
    );
  }
}

class _RecentSongCard extends StatelessWidget {
  const _RecentSongCard({required this.song, required this.onTap});

  final Song song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final artist = song.artist?.isNotEmpty == true ? song.artist : null;
    return Pressable(
      onPressed: onTap,
      semanticLabel: song.title,
      child: Container(
        width: RecentShelf._cardWidth,
        padding: const EdgeInsets.all(DaloySpace.s3),
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.border),
          borderRadius: DaloyRadii.all(DaloyRadii.xl2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SongKeyChip(keyName: song.key),
            const Spacer(),
            Text(song.title, style: context.text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            if (artist != null)
              Text(
                artist,
                style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
