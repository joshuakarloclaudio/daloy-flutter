import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/application/session_controller.dart';
import '../../songs/chart/chord_math.dart';
import '../../songs/domain/song.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up_draft.dart';

part 'line_up_edit_controller.freezed.dart';
part 'line_up_edit_controller.g.dart';

/// The edit screen's draft: what was last saved, and what's on screen now.
@freezed
abstract class LineUpEditState with _$LineUpEditState {
  const LineUpEditState._();

  const factory LineUpEditState({
    required EditableLineUp saved,
    required String title,

    /// `YYYY-MM-DD`.
    required String date,
    required String worshipLeader,
    required List<LineUpDraftSong> songs,
    @Default(false) bool saving,
  }) = _LineUpEditState;

  factory LineUpEditState.from(EditableLineUp lineUp) => LineUpEditState(
    saved: lineUp,
    title: lineUp.details.title,
    date: lineUp.details.date,
    worshipLeader: lineUp.details.worshipLeader ?? '',
    songs: lineUp.songs,
  );

  LineUpDetails get details => LineUpDetails(title: title, date: date, worshipLeader: worshipLeader).normalized();

  bool get songsKnown => saved.songsKnown;
  bool get songsChanged => !listEquals(songs, saved.songs);
  bool get isDirty => details != saved.details.normalized() || songsChanged;
  bool get canSave => LineUpDetails.isValidTitle(title) && isDirty && !saving;
}

/// The line-up couldn't be found on this device.
class LineUpNotFound implements Exception {
  const LineUpNotFound();
}

/// Everything the edit screen does. Opens from Drift (after a quick refresh
/// when online), edits a draft in memory, and saves through the outbox, so
/// it works offline. Nothing reaches Drift until Save.
@riverpod
class LineUpEdit extends _$LineUpEdit {
  /// Long enough for a normal fetch; past it the cached copy is better than
  /// a spinner, since the screen works from cache anyway.
  static const _refreshBudget = Duration(seconds: 6);

  @override
  Future<LineUpEditState> build(int lineUpId) async {
    final repository = ref.read(lineUpsRepositoryProvider);
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId != null && ref.read(isOnlineProvider)) {
      try {
        await repository.refreshDetail(repository.resolveId(lineUpId), workspaceId).timeout(_refreshBudget);
      } on ApiException {
        // Offline in practice, or gone — the cache below decides.
      } on TimeoutException {
        // Slow network: go with what's cached.
      }
    }
    final lineUp = await repository.loadEditable(lineUpId);
    if (lineUp == null) throw const LineUpNotFound();
    return LineUpEditState.from(lineUp);
  }

  void _update(LineUpEditState Function(LineUpEditState s) change) {
    final current = state.value;
    if (current == null || current.saving) return;
    state = AsyncData(change(current));
  }

  void setTitle(String value) => _update((s) => s.copyWith(title: value));

  void setDate(String isoDate) => _update((s) => s.copyWith(date: isoDate));

  void setWorshipLeader(String value) => _update((s) => s.copyWith(worshipLeader: value));

  /// Appends [songs] not already in the line-up, in their original key.
  void addSongs(List<Song> songs) => _update((s) {
    final have = {for (final d in s.songs) d.songId};
    return s.copyWith(
      songs: [
        ...s.songs,
        for (final song in songs)
          if (!have.contains(song.id)) LineUpDraftSong(song: song),
      ],
    );
  });

  void removeAt(int index) => _update((s) => s.copyWith(songs: [...s.songs]..removeAt(index)));

  /// Puts back a song taken out with [removeAt] (undo).
  void insertAt(int index, LineUpDraftSong song) => _update((s) {
    if (s.songs.any((d) => d.songId == song.songId)) return s;
    return s.copyWith(songs: [...s.songs]..insert(index.clamp(0, s.songs.length), song));
  });

  /// Moves the song at [oldIndex] so it ends up at [newIndex].
  void reorder(int oldIndex, int newIndex) => _update((s) {
    final songs = [...s.songs];
    final moved = songs.removeAt(oldIndex);
    songs.insert(newIndex, moved);
    return s.copyWith(songs: songs);
  });

  /// Plays the song at [index] in [targetKey] for this line-up only.
  void setPerformanceKey(int index, String targetKey) => _update((s) {
    final draft = s.songs[index];
    final original = draft.song.key;
    if (original == null || original.isEmpty) return s;
    final songs = [...s.songs];
    songs[index] = draft.withTransposition(transpositionBetweenKeys(original, targetKey));
    return s.copyWith(songs: songs);
  });

  /// Saves to Drift and queues the push. Returns false if there was nothing
  /// to save. Never waits on the network.
  Future<bool> save() async {
    final current = state.value;
    if (current == null || !current.canSave) return false;
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId == null) return false;

    state = AsyncData(current.copyWith(saving: true));
    final repository = ref.read(lineUpsRepositoryProvider);
    final id = await repository.save(
      current.saved.id,
      current.details,
      songs: current.songsKnown && current.songsChanged ? current.songs : null,
    );
    unawaited(repository.flushOutbox(workspaceId).catchError((Object _) {}));

    if (ref.mounted) {
      final saved = EditableLineUp(
        id: id,
        details: current.details,
        songs: current.songs,
        songsKnown: current.songsKnown,
      );
      state = AsyncData(LineUpEditState.from(saved));
    }
    return true;
  }
}
