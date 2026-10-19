import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/song_detail_repository.dart';
import '../data/song_sync_activity.dart';
import '../data/songs_repository.dart';

part 'song_sync.g.dart';

/// Where a song stands with the server, for songs that aren't simply synced.
enum SongSyncStatus {
  /// Saved here, not sent yet (offline, or waiting its turn).
  onDevice,

  /// A request is out.
  syncing,

  /// Just reached the server. Shown for [SongSync.syncedFor], then gone.
  synced,

  /// The server refused it; retried on the next sync.
  failed,
}

@immutable
class SongSync {
  const SongSync(this.status, {this.isNew = false, this.error, this.syncedAt});

  /// How long "Synced" shows before the song reads as plain synced.
  static const syncedFor = Duration(seconds: 3);

  final SongSyncStatus status;

  /// Never reached the server (a local, negative id), as opposed to an edit.
  final bool isNew;
  final String? error;

  /// When it reached the server, for [SongSyncStatus.synced].
  final DateTime? syncedAt;

  /// How much longer a [SongSyncStatus.synced] state should show.
  Duration syncedRemaining(DateTime now) => syncedAt == null ? Duration.zero : syncedFor - now.difference(syncedAt!);

  @override
  bool operator ==(Object other) =>
      other is SongSync &&
      other.status == status &&
      other.isNew == isNew &&
      other.error == error &&
      other.syncedAt == syncedAt;

  @override
  int get hashCode => Object.hash(status, isNew, error, syncedAt);
}

/// Every song that isn't plainly synced, by id: new songs and edits still on
/// this device, ones on the wire, refused ones, and ones that just landed.
@riverpod
Map<int, SongSync> songSync(Ref ref) {
  final outbox = ref.watch(songOutboxProvider).value ?? const <int, String?>{};
  final edits = ref.watch(pendingSongEditsProvider).value ?? const <int, String?>{};
  final activity = ref.watch(songSyncActivityProvider);
  return songSyncStates(outbox: outbox, edits: edits, activity: activity);
}

/// [songSync]'s rule, apart from Riverpod so it can be tested alone.
Map<int, SongSync> songSyncStates({
  required Map<int, String?> outbox,
  required Map<int, String?> edits,
  required SongSyncActivityState activity,
}) {
  final result = <int, SongSync>{
    for (final MapEntry(:key, :value) in activity.syncedAt.entries)
      key: SongSync(SongSyncStatus.synced, syncedAt: value),
  };
  for (final id in {...outbox.keys, ...edits.keys, ...activity.sending}) {
    final queued = outbox.containsKey(id) || edits.containsKey(id);
    final error = outbox[id] ?? edits[id];
    final isNew = id < 0;
    if (activity.sending.contains(id)) {
      result[id] = SongSync(SongSyncStatus.syncing, isNew: isNew);
    } else if (error != null) {
      result[id] = SongSync(SongSyncStatus.failed, isNew: isNew, error: error);
    } else if (queued) {
      result[id] = SongSync(SongSyncStatus.onDevice, isNew: isNew);
    }
  }
  return result;
}
