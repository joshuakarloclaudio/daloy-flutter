import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics.dart';
import '../../auth/application/session_controller.dart';
import '../data/songs_repository.dart';
import '../domain/new_song.dart';

part 'create_song_controller.g.dart';

/// The new-song sheet's save. The song is written to Drift first, so it is
/// in the library the moment the sheet closes, online or not; the push to the
/// server happens behind it (and again on reconnect, via the workspace sync).
@riverpod
class CreateSong extends _$CreateSong {
  @override
  void build() {}

  /// Returns the new song's local id, or null when there is no active workspace.
  Future<int?> submit(NewSong song) async {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId == null) return null;

    final repository = ref.read(songsRepositoryProvider);
    final analytics = ref.read(analyticsProvider);
    final localId = await repository.createLocal(workspaceId, song);
    // Not awaited: the flush fails quietly when offline and is retried on reconnect.
    unawaited(repository.flushOutbox(workspaceId).catchError((Object _) {}));
    unawaited(analytics.trackAndFlush(AnalyticsEvent.songCreated, properties: {'has_content': song.hasContent}));
    return localId;
  }
}
