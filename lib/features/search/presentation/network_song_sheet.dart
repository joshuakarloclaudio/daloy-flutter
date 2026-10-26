import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_alert.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../auth/application/session_controller.dart';
import '../../songs/domain/song.dart';
import '../../songs/presentation/widgets/chord_sheet.dart';
import '../../songs/presentation/widgets/lyrics_sheet.dart';
import '../../songs/presentation/widgets/song_streaming_links.dart';
import '../application/discover_controller.dart';
import '../data/network_songs_repository.dart';
import '../domain/network_song.dart';

/// A shared song from Discover, previewed before it's added: who shared it,
/// how often it's been added, its links and its chart, read-only. Adding
/// copies it into this workspace and opens the copy. For one of our own,
/// the button is "Stop sharing".
Future<void> showNetworkSongSheet(BuildContext context, NetworkSong song) => showDaloySheet<void>(
  context: context,
  constraints: const BoxConstraints(maxWidth: 640),
  builder: (_) => _NetworkSongSheet(song: song),
);

class _NetworkSongSheet extends StatelessWidget {
  const _NetworkSongSheet({required this.song});

  final NetworkSong song;

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.85,
    maxChildSize: 1,
    minChildSize: 0.4,
    builder: (context, scroll) => NetworkSongPanel(
      song: song,
      scroll: scroll,
      // Adding opens the copy.
      onAdded: (id) {
        final router = GoRouter.of(context);
        Navigator.of(context).pop();
        unawaited(router.push(Routes.song(id)));
      },
      onUnshared: () => Navigator.of(context).pop(),
    ),
  );
}

/// The shared song itself — chart, links and the add / stop-sharing button —
/// in the sheet on a phone and in Discover's detail pane on the desktop.
class NetworkSongPanel extends ConsumerStatefulWidget {
  const NetworkSongPanel({super.key, required this.song, required this.onAdded, required this.onUnshared, this.scroll});

  final NetworkSong song;
  final ScrollController? scroll;

  /// The song was added; [id] is the copy in this workspace.
  final ValueChanged<int> onAdded;
  final VoidCallback onUnshared;

  @override
  ConsumerState<NetworkSongPanel> createState() => _NetworkSongPanelState();
}

class _NetworkSongPanelState extends ConsumerState<NetworkSongPanel> {
  bool _adding = false;
  bool _unsharing = false;
  String? _error;

  Future<void> _unshare() async {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId == null) return;
    final confirmed = await confirmDestructive(
      context,
      title: 'Stop sharing?',
      message:
          '“${widget.song.title}” leaves Discover. Teams that already added it keep their copy; yours stays in your library.',
      confirmLabel: 'Stop sharing',
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _unsharing = true;
      _error = null;
    });
    try {
      await ref.read(networkSongsRepositoryProvider).unshare(widget.song.id, workspaceId);
      unawaited(ref.read(discoverControllerProvider.notifier).refresh());
      if (!mounted) return;
      unawaited(HapticFeedback.mediumImpact());
      widget.onUnshared();
    } on NetworkException {
      if (mounted) setState(() => _error = "You're offline. Connect to stop sharing.");
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _unsharing = false);
    }
  }

  Future<void> _add() async {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId == null) return;
    setState(() {
      _adding = true;
      _error = null;
    });
    try {
      final id = await ref.read(networkSongsRepositoryProvider).addToLibrary(widget.song.id, workspaceId);
      ref.read(discoverControllerProvider.notifier).markAdded(widget.song.id);
      if (!mounted) return;
      unawaited(HapticFeedback.mediumImpact());
      widget.onAdded(id);
    } on NetworkException {
      if (mounted) setState(() => _error = "You're offline. Connect to add this song.");
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final detail = ref.watch(networkSongProvider(widget.song.id));
    final song = detail.value ?? widget.song;
    final added = widget.song.alreadyAdded || song.alreadyAdded;
    final meta = [
      if (song.artist?.isNotEmpty == true) song.artist!,
      if (song.key?.isNotEmpty == true) 'Key of ${song.key}',
    ].join(' · ');

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: widget.scroll,
            padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s2, DaloySpace.s5, DaloySpace.s6),
            children: [
              Row(
                children: [
                  Icon(TablerIcons.world, size: 16, color: c.mutedForeground),
                  const SizedBox(width: DaloySpace.s1_5),
                  Expanded(
                    child: Text(
                      song.isOwnWorkspace
                          ? 'Discover · shared by your team'
                          : 'Discover · shared by ${song.workspaceName}',
                      style: context.text.labelLarge!.copyWith(color: c.mutedForeground),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DaloySpace.s3),
              Text(song.title, style: context.text.displaySmall),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: DaloySpace.s1),
                Text(meta, style: context.text.bodyLarge!.copyWith(color: c.mutedForeground)),
              ],
              if (song.importCount > 0) ...[
                const SizedBox(height: DaloySpace.s1),
                Text(
                  song.importCount == 1 ? 'Added by 1 workspace' : 'Added by ${song.importCount} workspaces',
                  style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                ),
              ],
              if (detail.value case final d? when _hasLinks(d)) ...[
                const SizedBox(height: DaloySpace.s4),
                SongStreamingLinks(song: _asSong(d)),
              ],
              const SizedBox(height: DaloySpace.s6),
              switch (detail) {
                AsyncData(:final value) => _Chart(song: value),
                AsyncError() => InsetPlaceholder(
                  icon: TablerIcons.cloud_off,
                  title: "Couldn't load the chart",
                  body: 'Check your connection and try again.',
                  action: DaloyButton.outline(
                    label: 'Try again',
                    size: ControlSize.sm,
                    onPressed: () => ref.invalidate(networkSongProvider(widget.song.id)),
                  ),
                ),
                _ => SkeletonPulse(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 8; i++) ...[
                        SkeletonBox(widthFactor: i.isEven ? 0.7 : 0.5, height: 14, radius: DaloyRadii.md),
                        const SizedBox(height: DaloySpace.s3),
                      ],
                    ],
                  ),
                ),
              },
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomSheetTheme.backgroundColor ?? c.background,
            border: Border(top: BorderSide(color: c.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s3, DaloySpace.s5, DaloySpace.s3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: context.text.bodyMedium!.copyWith(color: c.destructive),
                    ),
                    const SizedBox(height: DaloySpace.s2),
                  ],
                  if (song.isOwnWorkspace)
                    DaloyButton.outline(
                      label: 'Stop sharing',
                      icon: TablerIcons.world_off,
                      expand: true,
                      loading: _unsharing,
                      onPressed: _unshare,
                    )
                  else
                    DaloyButton(
                      label: added ? 'Already in your library' : 'Add to library',
                      icon: added ? TablerIcons.check : TablerIcons.plus,
                      expand: true,
                      loading: _adding,
                      onPressed: added ? null : _add,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

bool _hasLinks(NetworkSong s) =>
    [s.youtubeUrl, s.spotifyUrl, s.appleMusicUrl, s.otherUrl].any((u) => (u ?? '').trim().isNotEmpty);

/// Just enough of a [Song] for the shared links row.
Song _asSong(NetworkSong s) => Song(
  id: s.id,
  title: s.title,
  youtubeUrl: s.youtubeUrl,
  spotifyUrl: s.spotifyUrl,
  appleMusicUrl: s.appleMusicUrl,
  otherUrl: s.otherUrl,
);

class _Chart extends StatelessWidget {
  const _Chart({required this.song});

  final NetworkSong song;

  @override
  Widget build(BuildContext context) {
    final content = song.content?.trim() ?? '';
    final lyrics = song.lyrics?.trim() ?? '';
    if (content.isNotEmpty) {
      return ChordSheet(content: content, transposition: 0, zoom: 100, musicalKey: song.key);
    }
    if (lyrics.isNotEmpty) return LyricsSheet(lyrics: lyrics, zoom: 100);
    return const InsetPlaceholder(
      icon: TablerIcons.music_off,
      title: 'No chart yet',
      body: 'This song has no chords or lyrics.',
    );
  }
}
