import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/connectivity/online_status.dart';
import '../../core/network/api_exception.dart';
import '../../core/realtime/realtime_client.dart';
import '../auth/application/session_controller.dart';
import '../line_ups/data/line_ups_repository.dart';
import '../songs/data/song_detail_repository.dart';
import '../songs/data/songs_repository.dart';
import 'workspace_sync_controller.dart';

part 'workspace_realtime.g.dart';

/// Who made a change elsewhere (`by` on a ping).
@immutable
class ChangeAuthor {
  const ChangeAuthor({required this.id, required this.name});

  final int id;
  final String name;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;

  static ChangeAuthor? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['id'];
    final name = json['name'];
    return id is int && name is String ? ChangeAuthor(id: id, name: name) : null;
  }
}

enum RemoteKind { song, lineUp }

/// A change from another device that has landed on this one — for screens
/// that announce it ("Ana changed a key.").
@immutable
class RemoteChange {
  const RemoteChange({required this.kind, required this.id, this.deleted = false, this.what = const [], this.by});

  final RemoteKind kind;
  final int id;
  final bool deleted;

  /// For line-ups: details, set, key, notes, arrangement.
  final List<String> what;
  final ChangeAuthor? by;

  static const _nouns = {
    'details': 'the details',
    'set': 'the set',
    'key': 'a key',
    'notes': 'the notes',
    'arrangement': 'the arrangement',
  };

  String get message {
    final who = by?.firstName ?? 'Someone';
    if (kind == RemoteKind.song) return deleted ? '$who deleted this song.' : '$who updated this song.';
    if (deleted) return '$who deleted this line-up.';
    final parts = [for (final w in what) ?_nouns[w]];
    if (parts.isEmpty) return '$who updated this line-up.';
    final list = parts.length == 1
        ? parts.single
        : '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
    return '$who changed $list.';
  }
}

/// Where [WorkspaceRealtime] announces what it applied.
class RemoteChangeBus {
  final _controller = StreamController<RemoteChange>.broadcast();

  Stream<RemoteChange> get changes => _controller.stream;

  void emit(RemoteChange change) {
    if (!_controller.isClosed) _controller.add(change);
  }

  void close() => _controller.close();
}

@Riverpod(keepAlive: true)
RemoteChangeBus remoteChangeBus(Ref ref) {
  final bus = RemoteChangeBus();
  ref.onDispose(bus.close);
  return bus;
}

/// Keeps this device in step with the workspace in real time: the
/// workspace channel's pings (`song.changed`, `song.deleted`,
/// `line-up.changed`, `line-up.deleted`) and my own channel's
/// `capo.changed`. A ping carries no content: the item is fetched when its
/// version is newer than this device's copy, and written to Drift through the
/// same paths a sync uses — so unsent changes made here still win, and every
/// screen watching the item redraws. After a reconnect (and, from the shell,
/// on return to the app) a sync catches up on pings missed meanwhile.
///
/// Kept alive; the shell starts it.
@Riverpod(keepAlive: true)
class WorkspaceRealtime extends _$WorkspaceRealtime {
  /// Pings are handled one at a time, in order.
  Future<void> _queue = Future.value();

  @override
  void build() {
    final workspaceId = ref.watch(activeWorkspaceIdProvider);
    final online = ref.watch(isOnlineProvider);
    final userId = ref.watch(sessionControllerProvider).value?.user.id;
    if (workspaceId == null || !online) return;

    final realtime = ref.watch(realtimeClientProvider);
    void on(Future<void> Function(Map<String, dynamic> data) handle, Map<String, dynamic> data) {
      _queue = _queue.then((_) => handle(data)).catchError((Object error) {
        // A ping is a hint: a failed fetch is caught up on the next sync.
        debugPrint('[realtime] $error');
      });
    }

    final subscriptions = [
      realtime.listen('private-workspace.$workspaceId', {
        'song.changed': (data) => on((d) => _songChanged(workspaceId, d), data),
        'song.deleted': (data) => on(_songDeleted, data),
        'line-up.changed': (data) => on((d) => _lineUpChanged(workspaceId, d), data),
        'line-up.deleted': (data) => on(_lineUpDeleted, data),
      }),
      if (userId != null) realtime.listen('private-user.$userId', {'capo.changed': (data) => on(_capoChanged, data)}),
    ];
    final reconnected = realtime.reconnected.listen((_) => catchUp());
    ref.onDispose(() {
      for (final s in subscriptions) {
        s.cancel();
      }
      reconnected.cancel();
    });
  }

  /// Pulls what pings may have missed (the socket was down, or the app was
  /// in the background).
  Future<void> catchUp() => ref.read(workspaceSyncProvider.notifier).refresh();

  RemoteChangeBus get _bus => ref.read(remoteChangeBusProvider);

  static int? _int(Object? v) => v is int ? v : null;

  Future<void> _songChanged(int workspaceId, Map<String, dynamic> data) async {
    final id = _int(data['id']);
    if (id == null) return;
    final songs = ref.read(songsRepositoryProvider);
    final local = await songs.localVersion(id);
    final version = _int(data['version']);
    if (local != null && version != null && local >= version) return;

    final song = await songs.service.show(id);
    await songs.applyRemote(song, workspaceId);
    _bus.emit(RemoteChange(kind: RemoteKind.song, id: id, by: ChangeAuthor.fromJson(data['by'])));
  }

  Future<void> _songDeleted(Map<String, dynamic> data) async {
    final id = _int(data['id']);
    if (id == null) return;
    await ref.read(songsRepositoryProvider).applyRemoteDelete(id);
    _bus.emit(RemoteChange(kind: RemoteKind.song, id: id, deleted: true, by: ChangeAuthor.fromJson(data['by'])));
  }

  Future<void> _lineUpChanged(int workspaceId, Map<String, dynamic> data) async {
    final id = _int(data['id']);
    if (id == null) return;
    final lineUps = ref.read(lineUpsRepositoryProvider);
    final local = await lineUps.localSongsVersion(id);
    final version = _int(data['version']);
    if (local != null && version != null && local >= version) return;

    try {
      await lineUps.refreshDetail(id, workspaceId);
    } on ApiHttpException catch (e) {
      if (e.status != 404) rethrow;
      await lineUps.applyRemoteDelete(id);
    }
    _bus.emit(
      RemoteChange(
        kind: RemoteKind.lineUp,
        id: id,
        what: [for (final w in (data['what'] as List? ?? const [])) '$w'],
        by: ChangeAuthor.fromJson(data['by']),
      ),
    );
  }

  Future<void> _lineUpDeleted(Map<String, dynamic> data) async {
    final id = _int(data['id']);
    if (id == null) return;
    await ref.read(lineUpsRepositoryProvider).applyRemoteDelete(id);
    _bus.emit(RemoteChange(kind: RemoteKind.lineUp, id: id, deleted: true, by: ChangeAuthor.fromJson(data['by'])));
  }

  Future<void> _capoChanged(Map<String, dynamic> data) async {
    final capo = _int(data['capo']);
    if (capo == null) return;
    if (_int(data['song_id']) case final songId?) {
      await ref.read(songDetailRepositoryProvider).applyRemoteCapo(songId, capo);
    }
    if ((_int(data['line_up_id']), _int(data['line_up_song_id'])) case (final lineUpId?, final pivot?)) {
      await ref.read(lineUpsRepositoryProvider).applyRemoteCapo(lineUpId, pivot, capo);
    }
  }
}

/// Changes from other devices as they land, for screens to announce.
@Riverpod(keepAlive: true)
Stream<RemoteChange> remoteChanges(Ref ref) => ref.watch(remoteChangeBusProvider).changes;
