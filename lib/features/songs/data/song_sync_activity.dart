import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'song_sync_activity.g.dart';

/// What the song outboxes report as they push: a request going out, and how
/// it ended. Only this device's memory: it says nothing after a restart,
/// where the outbox tables say what's still waiting.
abstract interface class SongSyncReporter {
  void sending(int songId);

  /// [synced]: the server has it and nothing newer is queued. A new song
  /// lands under its [serverId].
  void finished(int songId, {required bool synced, int? serverId});
}

@immutable
class SongSyncActivityState {
  const SongSyncActivityState({this.sending = const {}, this.syncedAt = const {}});

  /// Songs with a request out right now.
  final Set<int> sending;

  /// When each song last reached the server, for the short "Synced" moment.
  final Map<int, DateTime> syncedAt;
}

/// Songs on the wire and songs that just landed.
@Riverpod(keepAlive: true)
class SongSyncActivity extends _$SongSyncActivity implements SongSyncReporter {
  /// "Synced" times older than this are forgotten on the next change.
  static const _forgetAfter = Duration(minutes: 1);

  @override
  SongSyncActivityState build() => const SongSyncActivityState();

  @override
  void sending(int songId) =>
      state = SongSyncActivityState(sending: {...state.sending, songId}, syncedAt: state.syncedAt);

  @override
  void finished(int songId, {required bool synced, int? serverId}) {
    final now = clock.now();
    state = SongSyncActivityState(
      sending: {...state.sending}..remove(songId),
      syncedAt: {
        for (final MapEntry(:key, :value) in state.syncedAt.entries)
          if (key != songId && now.difference(value) < _forgetAfter) key: value,
        if (synced) serverId ?? songId: now,
      },
    );
  }
}
