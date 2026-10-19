import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/network/api_exception.dart';
import '../data/songs_repository.dart';

part 'song_deletions.g.dart';

/// Deletes that can still be undone. Kept alive: the window outlasts the
/// screen the delete started on.
@Riverpod(keepAlive: true)
class SongDeletions extends _$SongDeletions {
  static const undoWindow = Duration(seconds: 5);

  final _pending = <int, ({RemovedSong removed, Timer timer})>{};

  @override
  void build() {
    ref.onDispose(() {
      for (final p in _pending.values) {
        p.timer.cancel();
      }
    });
  }

  /// Takes the song off this device now and deletes it on the server once
  /// [undoWindow] passes. [onFailed] runs if the server refuses; the song is
  /// back by then.
  Future<bool> start(int songId, {required void Function(String message) onFailed}) async {
    final repo = ref.read(songsRepositoryProvider);
    final removed = await repo.removeLocal(songId);
    if (removed == null) return false;
    _pending[songId]?.timer.cancel();
    _pending[songId] = (
      removed: removed,
      timer: Timer(undoWindow, () async {
        _pending.remove(songId);
        unawaited(ref.read(analyticsProvider).trackAndFlush(AnalyticsEvent.songDeleted));
        try {
          await repo.deleteRemote(removed);
        } on ApiException catch (e) {
          onFailed(e is NetworkException ? "Couldn't reach the server. The song is back." : e.message);
        }
      }),
    );
    return true;
  }

  Future<void> undo(int songId) async {
    final pending = _pending.remove(songId);
    if (pending == null) return;
    pending.timer.cancel();
    await ref.read(songsRepositoryProvider).restore(pending.removed);
  }
}
