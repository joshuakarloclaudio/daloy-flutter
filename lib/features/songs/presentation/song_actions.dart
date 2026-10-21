import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/routes.dart';
import '../../../shared/widgets/daloy_alert.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../auth/application/session_controller.dart';
import '../../export/presentation/export_actions.dart';
import '../../line_ups/presentation/widgets/add_to_line_up_sheet.dart';
import '../../search/application/discover_controller.dart';
import '../../search/data/network_songs_repository.dart';
import '../application/song_deletions.dart';
import '../chart/nashville.dart';
import '../data/song_detail_repository.dart';
import '../domain/song.dart';
import 'editor/chart_editor_screen.dart';
import 'editor/lyrics_editor_screen.dart';

/// Straight into the chord editor from wherever the song is (a line-up's
/// setlist), skipping the edit screen; Done saves into the song.
Future<void> editSongChords(BuildContext context, WidgetRef ref, Song song) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final repo = ref.read(songDetailRepositoryProvider);
  final edited = await showChartEditor(
    context,
    content: song.content ?? '',
    musicalKey: song.key,
    notation: ChordNotation.parse(ref.read(sessionControllerProvider).value?.user.chordNotation),
  );
  if (edited == null || edited == (song.content ?? '')) return;
  await repo.setChords(song.id, edited);
  showDaloyToast(messenger, 'Chords saved to “${song.title}”.');
}

/// Straight into the lyrics editor; Done saves into the song.
Future<void> editSongLyrics(BuildContext context, WidgetRef ref, Song song) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final repo = ref.read(songDetailRepositoryProvider);
  final edited = await showLyricsEditor(context, lyrics: song.lyrics ?? '');
  if (edited == null || edited == (song.lyrics ?? '')) return;
  await repo.setLyrics(song.id, edited);
  showDaloyToast(messenger, 'Lyrics saved to “${song.title}”.');
}

/// A song's actions — from a row's touch-and-hold, or the details screen's
/// ⋯ button ([onDetails]: Edit is already a button there).
List<DaloyMenuItem> songMenuItems(BuildContext context, WidgetRef ref, Song song, {bool onDetails = false}) => [
  if (!onDetails)
    DaloyMenuItem(icon: TablerIcons.pencil, label: 'Edit', onSelected: () => context.push(Routes.songEdit(song.id))),
  DaloyMenuItem(
    icon: TablerIcons.playlist_add,
    label: 'Add to line-up',
    onSelected: () => addSongToLineUp(context, ref, song),
  ),
  if (!song.isPending)
    DaloyMenuItem(
      icon: song.isPublic ? TablerIcons.world_off : TablerIcons.world_upload,
      label: song.isPublic ? 'Stop sharing' : 'Share to Discover',
      onSelected: () => setSongShared(context, ref, song, shared: !song.isPublic),
    ),
  DaloyMenuItem.divider,
  DaloyMenuItem(icon: TablerIcons.file_export, label: 'Export…', onSelected: () => exportSong(context, ref, song)),
  DaloyMenuItem.divider,
  DaloyMenuItem(
    icon: TablerIcons.trash,
    label: 'Delete',
    destructive: true,
    onSelected: () => deleteSongWithUndo(context, ref, song, leaveDetails: onDetails),
  ),
];

/// Puts the song on Discover, or takes it off. Sharing is public, so it asks
/// first and needs a connection (like the web).
Future<void> setSongShared(BuildContext context, WidgetRef ref, Song song, {required bool shared}) async {
  final messenger = ScaffoldMessenger.of(context);
  void toast(String message) => showDaloyToast(messenger, message);

  if (!ref.read(isOnlineProvider)) return toast('Connect to the internet to ${shared ? 'share' : 'unshare'} songs.');
  final workspaceId = ref.read(activeWorkspaceIdProvider);
  if (workspaceId == null) return;

  if (shared) {
    final confirmed = await confirmAlert(
      context,
      title: 'Share to Discover?',
      message:
          'Other teams will be able to see and copy the chords, lyrics and links of “${song.title}”. '
          'Your notes and line-ups stay private, and you can stop sharing any time.',
      confirmLabel: 'Share song',
    );
    if (!confirmed) return;
  }

  try {
    final repo = ref.read(networkSongsRepositoryProvider);
    await (shared ? repo.share(song.id, workspaceId) : repo.unshare(song.id, workspaceId));
    unawaited(ref.read(discoverControllerProvider.notifier).refresh());
    unawaited(HapticFeedback.mediumImpact());
    toast(shared ? '“${song.title}” is now on Discover.' : '“${song.title}” is no longer on Discover.');
  } on NetworkException {
    toast("You're offline. Try again when you're connected.");
  } on ApiException catch (e) {
    toast(e.message);
  }
}

/// Removes the song now, with a few seconds to undo before the server hears
/// of it (the web's `deleteSongWithUndo`). Online only, like the web: a
/// delete can't be queued behind a connection you don't have. [leaveDetails]
/// pops the details screen first; Undo brings that screen back.
Future<void> deleteSongWithUndo(BuildContext context, WidgetRef ref, Song song, {bool leaveDetails = false}) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  void toast(String message, {String? actionLabel, VoidCallback? onAction, Duration? duration}) =>
      showDaloyToast(messenger, message, actionLabel: actionLabel, onAction: onAction, duration: duration);

  if (!ref.read(isOnlineProvider)) {
    toast('Connect to the internet to delete songs.');
    return;
  }

  final deletions = ref.read(songDeletionsProvider.notifier);
  if (leaveDetails && router.canPop()) router.pop();
  final started = await deletions.start(
    song.id,
    onFailed: (message) => toast("Couldn't delete “${song.title}”. $message"),
  );
  if (!started) return;
  await HapticFeedback.mediumImpact();

  toast(
    'Deleted “${song.title}”.',
    duration: SongDeletions.undoWindow,
    actionLabel: 'Undo',
    onAction: () async {
      await deletions.undo(song.id);
      if (leaveDetails) unawaited(router.push(Routes.song(song.id)));
    },
  );
}

/// Tapping a song that hasn't synced: it can't be opened yet, only dropped.
Future<void> askDiscardPendingSong(
  BuildContext context,
  Song song, {
  required String? error,
  required VoidCallback onDiscard,
}) async {
  final discard = await confirmDestructive(
    context,
    title: '“${song.title}” is waiting to sync',
    message: error == null ? 'It will open once it has reached the server.' : "It couldn't sync: $error",
    confirmLabel: 'Discard Song',
    cancelLabel: 'Keep Waiting',
  );
  if (discard) onDiscard();
}

/// Actions for a song the server hasn't accepted yet: it can't be opened or
/// edited until it has a real id, but it can be dropped. [error] is why the
/// server last refused it, if it did.
List<DaloyMenuItem> pendingSongMenuItems(
  BuildContext context,
  Song song, {
  required String? error,
  required VoidCallback onDiscard,
}) => [
  if (error != null)
    DaloyMenuItem(
      icon: TablerIcons.alert_circle,
      label: "Why it didn't sync",
      onSelected: () => showDaloyToast(ScaffoldMessenger.of(context), "“${song.title}” couldn't sync: $error"),
    ),
  DaloyMenuItem(icon: TablerIcons.trash, label: 'Discard', destructive: true, onSelected: onDiscard),
];
