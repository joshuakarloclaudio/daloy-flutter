import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics.dart';
import '../../auth/application/session_controller.dart';
import '../../sync/workspace_realtime.dart';
import '../data/song_detail_repository.dart';
import '../domain/song.dart';
import '../domain/song_field.dart';
import '../domain/song_fields.dart';

part 'song_edit_controller.freezed.dart';
part 'song_edit_controller.g.dart';

/// The edit screen's draft: what was last saved, and what's on screen now.
@freezed
abstract class SongEditState with _$SongEditState {
  const SongEditState._();

  const factory SongEditState({
    required SongFields saved,
    required SongFields fields,

    /// The song as the draft started from it (kept up to date with changes
    /// from elsewhere that the draft took) — [saved] is its fields.
    required Song base,

    /// The key as it was when the screen opened, for the key-change notice.
    String? keyChangedFrom,
    @Default(false) bool saving,

    /// Fields changed here and on another device meanwhile: theirs.
    @Default(<SongField, Object?>{}) Map<SongField, Object?> conflicts,

    /// Bumped when fields follow a change from elsewhere, so the screen
    /// refreshes its text fields.
    @Default(0) int remoteRevision,

    /// Who changed the song elsewhere, for the banner.
    String? changedBy,
  }) = _SongEditState;

  factory SongEditState.from(Song song) {
    final f = SongFields.fromSong(song);
    return SongEditState(saved: f, fields: f, base: song);
  }

  bool get isDirty => !fields.matches(saved);
  bool get canSave => isDirty && fields.isValid && !saving;

  /// Changing the key doesn't move the stored chords (a chart written in
  /// letters is never silently rewritten), so say so.
  bool get showKeyNotice => keyChangedFrom != null && fields.key != keyChangedFrom && fields.chords.trim().isNotEmpty;
}

/// The song couldn't be found on this device.
class SongNotFound implements Exception {
  const SongNotFound();
}

/// Riverpod retries a failing provider by default; a song that isn't on this
/// device won't turn up by asking again.
Duration? _retry(int retryCount, Object error) =>
    error is SongNotFound ? null : ProviderContainer.defaultRetry(retryCount, error);

/// Everything the song edit screen does. Edits a draft in memory and saves
/// through the song outbox, so it works offline; nothing reaches Drift until
/// Save. Last write wins.
@Riverpod(retry: _retry)
class SongEdit extends _$SongEdit {
  @override
  Future<SongEditState> build(int songId) async {
    final song = await ref.read(songDetailRepositoryProvider).loadSong(songId);
    if (song == null) throw const SongNotFound();
    // A newer copy (a teammate's save, or this device's own sync) merges in.
    ref.listen(songByIdProvider(songId), (_, next) {
      if (next.value case final remote?) _merge(remote);
    });
    ref.listen(remoteChangesProvider, (_, next) {
      final change = next.value;
      final s = state.value;
      if (change == null || s == null || change.kind != RemoteKind.song || change.id != songId) return;
      if (change.by case final by?) state = AsyncData(s.copyWith(changedBy: by.firstName));
    });
    return SongEditState.from(song);
  }

  /// Fields left alone here follow [remote]; ones that ended up equal
  /// settle; ones changed on both sides become conflicts (the draft keeps
  /// what's typed).
  void _merge(Song remote) {
    final s = state.value;
    if (s == null || s.saving) return;
    var base = s.base;
    var draft = s.fields.applyTo(s.base);
    final conflicts = {...s.conflicts};
    var followed = false;
    var changed = false;
    for (final f in SongField.values) {
      final theirs = f.read(remote);
      if (sameSongValue(theirs, f.read(base))) continue;
      final mine = f.read(draft);
      if (sameSongValue(mine, f.read(base))) {
        draft = f.write(draft, theirs);
        base = f.write(base, theirs);
        conflicts.remove(f);
        followed = changed = true;
      } else if (sameSongValue(mine, theirs)) {
        base = f.write(base, theirs);
        conflicts.remove(f);
        changed = true;
      } else if (!s.conflicts.containsKey(f) || !sameSongValue(s.conflicts[f], theirs)) {
        conflicts[f] = theirs;
        changed = true;
      }
    }
    if (!changed) return;
    state = AsyncData(
      s.copyWith(
        base: base,
        saved: SongFields.fromSong(base),
        fields: followed ? SongFields.fromSong(draft) : s.fields,
        conflicts: conflicts,
        remoteRevision: followed ? s.remoteRevision + 1 : s.remoteRevision,
      ),
    );
  }

  /// Keep what's typed for a conflicted field: the next save overwrites theirs.
  void keepMine(SongField field) {
    final s = state.value;
    if (s == null || !s.conflicts.containsKey(field)) return;
    final base = field.write(s.base, s.conflicts[field]);
    state = AsyncData(
      s.copyWith(base: base, saved: SongFields.fromSong(base), conflicts: {...s.conflicts}..remove(field)),
    );
  }

  /// Take the other device's value for a conflicted field.
  void takeTheirs(SongField field) {
    final s = state.value;
    if (s == null || !s.conflicts.containsKey(field)) return;
    final theirs = s.conflicts[field];
    final base = field.write(s.base, theirs);
    state = AsyncData(
      s.copyWith(
        base: base,
        saved: SongFields.fromSong(base),
        fields: SongFields.fromSong(field.write(s.fields.applyTo(s.base), theirs)),
        conflicts: {...s.conflicts}..remove(field),
        remoteRevision: s.remoteRevision + 1,
      ),
    );
  }

  void change(SongFields Function(SongFields f) edit) {
    final s = state.value;
    if (s == null || s.saving) return;
    state = AsyncData(s.copyWith(fields: edit(s.fields)));
  }

  void setKey(String? key) {
    final s = state.value;
    if (s == null || s.saving) return;
    state = AsyncData(
      s.copyWith(
        fields: s.fields.copyWith(key: key),
        keyChangedFrom: s.keyChangedFrom ?? s.saved.key,
      ),
    );
  }

  /// Saves to Drift and queues the push. False when there was nothing to save.
  Future<bool> save() async {
    final s = state.value;
    if (s == null || !s.canSave) return false;
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    final repository = ref.read(songDetailRepositoryProvider);
    final analytics = ref.read(analyticsProvider);

    state = AsyncData(s.copyWith(saving: true));
    // Saving with a conflict open keeps this device's value ("Keep mine").
    await repository.saveFields(songId, s.fields);
    if (workspaceId != null) unawaited(repository.flush(workspaceId).catchError((Object _) {}));
    unawaited(analytics.trackAndFlush(AnalyticsEvent.songUpdated));
    if (ref.mounted) {
      final saved = s.fields.applyTo(s.base);
      state = AsyncData(SongEditState.from(saved).copyWith(remoteRevision: s.remoteRevision));
    }
    return true;
  }
}
