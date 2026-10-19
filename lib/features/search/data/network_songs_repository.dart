import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';
import '../../auth/application/session_controller.dart';
import '../../songs/data/songs_repository.dart';
import '../../songs/domain/song.dart';
import '../domain/discover_query.dart';
import '../domain/network_song.dart';

part 'network_songs_repository.g.dart';

/// `/api/songs/network` — public songs shared by other workspaces.
class NetworkSongsService {
  const NetworkSongsService(this._api);

  final ApiClient _api;

  Future<NetworkSongPage> search(String search) =>
      _api.get('/api/songs/network', Decode.object(NetworkSongPage.fromJson), query: {'search': search});

  Future<NetworkSongPage> list(DiscoverQuery query, {String? cursor}) => _api.get(
    '/api/songs/network',
    Decode.object(NetworkSongPage.fromJson),
    query: {
      if (query.search.trim().isNotEmpty) 'search': query.search.trim(),
      'sort': query.sort.api,
      'scope': query.scope.api,
      'key': ?query.key,
      'bpm_min': ?query.tempo?.min,
      'bpm_max': ?query.tempo?.max,
      'cursor': ?cursor,
    },
  );

  Future<NetworkSong> show(int id) => _api.get('/api/songs/network/$id', Decode.object(NetworkSong.fromJson));

  /// Copies the song into this workspace; returns the copy.
  Future<Song> import(int id) => _api.post('/api/songs/network/$id/import', Decode.object(Song.fromJson));
}

/// Network-only on purpose: these songs aren't ours until they're added.
class NetworkSongsRepository {
  NetworkSongsRepository(this._service, this._songs, [this._analytics]);

  final NetworkSongsService _service;
  final SongsRepository _songs;
  final Analytics? _analytics;

  /// Matches from other workspaces — ours are already in the library.
  Future<List<NetworkSong>> search(String search) async =>
      (await _service.search(search)).songs.where((s) => !s.isOwnWorkspace).toList();

  Future<NetworkSong> show(int id) => _service.show(id);

  Future<NetworkSongPage> list(DiscoverQuery query, {String? cursor}) => _service.list(query, cursor: cursor);

  /// Takes the song off Discover; returns once this device agrees.
  Future<void> unshare(int songId, int workspaceId) async {
    await _songs.setShared(songId, workspaceId, shared: false);
  }

  /// Puts the song on Discover.
  Future<void> share(int songId, int workspaceId) async {
    await _songs.setShared(songId, workspaceId, shared: true);
  }

  /// Adds the song to [workspaceId]'s library, on the server and on this
  /// device, and returns the new song's id.
  Future<int> addToLibrary(int id, int workspaceId) async {
    final song = await _service.import(id);
    unawaited(_analytics?.trackAndFlush(AnalyticsEvent.networkSongImported));
    await _songs.applyRemote(song, workspaceId);
    return song.id;
  }
}

@Riverpod(keepAlive: true)
NetworkSongsRepository networkSongsRepository(Ref ref) => NetworkSongsRepository(
  NetworkSongsService(ref.watch(apiClientProvider)),
  ref.watch(songsRepositoryProvider),
  ref.watch(analyticsProvider),
);

/// One network song with its chart, for the preview sheet.
@riverpod
Future<NetworkSong> networkSong(Ref ref, int id) {
  ref.watch(activeWorkspaceIdProvider);
  return ref.watch(networkSongsRepositoryProvider).show(id);
}
