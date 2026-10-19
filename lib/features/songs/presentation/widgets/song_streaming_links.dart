import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/widgets/daloy_toast.dart';
import '../../../../shared/widgets/filter_pill.dart';
import '../../domain/song.dart';
import '../../domain/youtube_link.dart';

/// "Listen" links — YouTube, Spotify, Apple Music and one free-form link —
/// each opening in its own app or the browser. With [onPlayYouTube], a
/// playable YouTube link plays in the app's player instead.
class SongStreamingLinks extends StatelessWidget {
  const SongStreamingLinks({super.key, required this.song, this.onPlayYouTube});

  final Song song;
  final VoidCallback? onPlayYouTube;

  @override
  Widget build(BuildContext context) {
    final links = [
      (TablerIcons.brand_youtube, 'YouTube', song.youtubeUrl),
      (TablerIcons.brand_spotify, 'Spotify', song.spotifyUrl),
      (TablerIcons.brand_apple, 'Apple Music', song.appleMusicUrl),
      (TablerIcons.link, 'Link', song.otherUrl),
    ].where((l) => (l.$3 ?? '').trim().isNotEmpty).toList();

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: links.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (icon, label, url) = links[i];
          final play = onPlayYouTube != null && icon == TablerIcons.brand_youtube && songYouTubeVideoId(url) != null;
          return FilterPill(
            label: play ? 'Play' : label,
            icon: play ? TablerIcons.player_play_filled : icon,
            onTap: play ? onPlayYouTube! : () => _open(context, url!),
          );
        },
      ),
    );
  }

  Future<void> _open(BuildContext context, String raw) async {
    final trimmed = raw.trim();
    final uri = Uri.tryParse(
      RegExp(r'^[a-z][a-z0-9+.-]*:', caseSensitive: false).hasMatch(trimmed) ? trimmed : 'https://$trimmed',
    );
    final opened = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      showDaloyToast(ScaffoldMessenger.of(context), "Couldn't open that link.");
    }
  }
}
