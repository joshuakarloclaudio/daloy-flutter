import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/platform.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../line_ups/domain/line_up.dart';
import '../../../songs/domain/song.dart';
import '../../../songs/presentation/widgets/song_artwork.dart';
import '../../domain/network_song.dart';
import '../../domain/search_results.dart';
import 'highlighted_text.dart';

/// A group's label — "Songs", "In lyrics", "Line-ups".
class SearchGroupLabel extends StatelessWidget {
  const SearchGroupLabel(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s5, DaloySpace.s2, DaloySpace.s1),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: context.text.titleSmall!.copyWith(color: c.mutedForeground)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// One result: a 40px leading tile, a title and a line under it. Edge to
/// edge so the press fills the row; [active] is the keyboard's selection.
class SearchRow extends StatelessWidget {
  const SearchRow({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    this.active = false,
    this.semanticLabel,
  });

  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool active;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isApple = Theme.of(context).platform.isApple;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: active ? c.muted : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashFactory: isApple ? NoSplash.splashFactory : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s2_5),
            child: Row(
              children: [
                SizedBox.square(dimension: 40, child: leading),
                const SizedBox(width: DaloySpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      title,
                      if (subtitle != null) ...[const SizedBox(height: 2), subtitle!],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: DaloySpace.s3), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _subtitleStyle(BuildContext context) =>
    context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground, height: 1.3);

/// A song found by title or artist.
class SearchSongRow extends StatelessWidget {
  const SearchSongRow({super.key, required this.song, required this.terms, required this.onTap, this.active = false});

  final Song song;
  final List<String> terms;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final meta = [
      song.artist?.isNotEmpty == true ? song.artist! : 'Unknown artist',
      if (song.bpm != null) '${song.bpm} BPM',
    ].join(' · ');
    return SearchRow(
      active: active,
      onTap: onTap,
      semanticLabel: 'Song, ${song.title}',
      leading: SongArtwork(songId: song.id, keyName: song.key),
      title: HighlightedText(song.title, terms: terms, style: context.text.titleMedium!),
      subtitle: HighlightedText(meta, terms: terms, style: _subtitleStyle(context)),
    );
  }
}

/// A song found by its words: the matched line, in the serif the lyrics are
/// set in, under the title.
class SearchLyricRow extends StatelessWidget {
  const SearchLyricRow({super.key, required this.hit, required this.terms, required this.onTap, this.active = false});

  final LyricHit hit;
  final List<String> terms;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SearchRow(
      active: active,
      onTap: onTap,
      semanticLabel: 'Song, ${hit.song.title}, line: ${hit.text}',
      leading: SongArtwork(songId: hit.song.id, keyName: hit.song.key),
      title: Text(hit.song.title, style: context.text.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: HighlightedText(
        snippetAround(hit.text, terms),
        terms: terms,
        style: context.text.bodyMedium!.copyWith(
          fontFamily: DaloyFonts.serif,
          fontStyle: FontStyle.italic,
          color: c.foreground.withValues(alpha: 0.8),
          height: 1.35,
        ),
      ),
    );
  }
}

/// A line-up, with its date as a small calendar leaf — the date is usually
/// what you're looking for.
class SearchLineUpRow extends StatelessWidget {
  const SearchLineUpRow({
    super.key,
    required this.lineUp,
    required this.terms,
    required this.onTap,
    this.active = false,
    this.now,
  });

  final LineUp lineUp;
  final List<String> terms;
  final VoidCallback onTap;
  final bool active;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final date = DateTime.parse('${lineUp.date}T12:00:00');
    final chip = lineUpDayChip(lineUp.date, now);
    final meta = [
      DateFormat.EEEE().format(date),
      lineUp.leader ?? 'No worship leader',
      lineUpSongsLabel(lineUp.songsCount),
    ].join(' · ');
    return SearchRow(
      active: active,
      onTap: onTap,
      semanticLabel: 'Line-up, ${lineUp.title}, ${formatLineUpDate(lineUp.date)}',
      leading: Container(
        decoration: BoxDecoration(color: chip != null ? c.today : c.muted, borderRadius: DaloyRadii.all(DaloyRadii.lg)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat.MMM().format(date).toUpperCase(),
              style: context.text.labelSmall!.copyWith(
                fontSize: 9,
                color: chip != null ? c.todayInk : c.mutedForeground,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: context.text.titleMedium!.copyWith(height: 1, color: chip != null ? c.todayInk : c.foreground),
            ),
          ],
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: HighlightedText(
              lineUp.title,
              terms: terms,
              style: context.text.titleMedium!.copyWith(fontFamily: DaloyFonts.serif),
            ),
          ),
          if (chip != null) ...[
            const SizedBox(width: DaloySpace.s2),
            StatusChip(label: chip == DayChip.today ? 'Today' : 'Tomorrow', color: c.todayInk, dense: true),
          ],
        ],
      ),
      subtitle: HighlightedText(meta, terms: terms, style: _subtitleStyle(context)),
    );
  }
}

/// A public song from another workspace.
class SearchNetworkRow extends StatelessWidget {
  const SearchNetworkRow({
    super.key,
    required this.song,
    required this.terms,
    required this.onTap,
    this.active = false,
  });

  final NetworkSong song;
  final List<String> terms;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final meta = [if (song.artist?.isNotEmpty == true) song.artist!, 'from ${song.workspaceName}'].join(' · ');
    return SearchRow(
      active: active,
      onTap: onTap,
      semanticLabel: 'Discover, ${song.title}, $meta',
      leading: _IconTile(icon: TablerIcons.world),
      title: HighlightedText(song.title, terms: terms, style: context.text.titleMedium!),
      subtitle: Text(meta, style: _subtitleStyle(context), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: song.alreadyAdded
          ? StatusChip(label: 'Added', color: c.primaryInk, background: c.primary.withValues(alpha: 0.1), dense: true)
          : null,
    );
  }
}

/// A place in the app or a create action.
class SearchDestinationRow extends StatelessWidget {
  const SearchDestinationRow({
    super.key,
    required this.label,
    required this.icon,
    required this.terms,
    required this.onTap,
    this.detail,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final List<String> terms;
  final VoidCallback onTap;
  final String? detail;
  final bool active;

  @override
  Widget build(BuildContext context) => SearchRow(
    active: active,
    onTap: onTap,
    semanticLabel: label,
    leading: _IconTile(icon: icon),
    title: HighlightedText(label, terms: terms, style: context.text.titleMedium!),
    subtitle: detail == null ? null : Text(detail!, style: _subtitleStyle(context)),
  );
}

/// A past search: tap to run it again, swipe it away.
class SearchRecentRow extends StatelessWidget {
  const SearchRecentRow({super.key, required this.query, required this.onTap, required this.onRemove});

  final String query;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Dismissible(
      key: ValueKey('recent-$query'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        color: c.destructive.withValues(alpha: 0.12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s5),
        child: Icon(TablerIcons.trash, size: 20, color: c.destructive),
      ),
      child: Semantics(
        customSemanticsActions: {const CustomSemanticsAction(label: 'Remove'): onRemove},
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s3),
            child: Row(
              children: [
                Icon(TablerIcons.history, size: 18, color: c.mutedForeground),
                const SizedBox(width: DaloySpace.s3),
                Expanded(
                  child: Text(query, style: context.text.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Icon(TablerIcons.arrow_up_left, size: 16, color: c.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.lg)),
      child: Icon(icon, size: 20, color: c.mutedForeground),
    );
  }
}
