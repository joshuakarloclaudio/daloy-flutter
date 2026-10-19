import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:daloy_flutter/core/realtime/realtime_client.dart';
import 'package:daloy_flutter/core/storage/session_store.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/live_session.dart';
import 'package:daloy_flutter/features/search/data/os_search_index.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in for the Keychain.
class MemoryStorage extends Fake implements FlutterSecureStorage {
  final values = <String, String>{};

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => Map.of(values);

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => value == null ? values.remove(key) : values[key] = value;

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values.remove(key);
}

/// A canned API response: [body] is sent as JSON with [status].
typedef FakeReply = ({int status, Object? body});

/// Answers Dio requests from a `'METHOD /path'` table, and records them.
class FakeApiAdapter implements HttpClientAdapter {
  FakeApiAdapter(this.routes);

  final Map<String, FakeReply Function(RequestOptions request)> routes;
  final requests = <RequestOptions>[];

  static FakeReply ok(Object? data, {int status = 200}) =>
      (status: status, body: {'success': true, 'data': data, 'message': ''});

  static FakeReply error(int status, String message, {Object? data}) =>
      (status: status, body: {'success': false, 'data': data, 'message': message});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final route = routes['${options.method} ${options.path}'];
    final reply = route?.call(options) ?? error(404, 'No fake for ${options.method} ${options.path}');
    return ResponseBody.fromString(
      jsonEncode(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A Reverb socket that never touches the network: tests push events with
/// [emit] and presence rosters with [setMembers].
class FakeRealtime extends RealtimeClient {
  FakeRealtime() : super(SessionStore(MemoryStorage()));

  final _handlers = <String, List<Map<String, RealtimeHandler>>>{};
  final _members = <String, List<PresenceHandler>>{};
  final _reconnects = StreamController<void>.broadcast();
  final _connection = StreamController<bool>.broadcast();
  bool connected = true;

  /// Channels with a listener right now.
  Set<String> get channels => {..._handlers.keys};

  @override
  bool get isConnected => connected;

  @override
  String? get socketId => connected ? '123.456' : null;

  @override
  Stream<void> get reconnected => _reconnects.stream;

  @override
  Stream<bool> get connectedChanges => _connection.stream;

  @override
  RealtimeSubscription listen(String channelName, Map<String, RealtimeHandler> handlers) {
    _handlers.putIfAbsent(channelName, () => []).add(handlers);
    return RealtimeSubscription(() {
      _handlers[channelName]?.remove(handlers);
      if (_handlers[channelName]?.isEmpty ?? false) _handlers.remove(channelName);
    });
  }

  @override
  RealtimeSubscription join(
    String channelName,
    Map<String, RealtimeHandler> handlers, {
    required PresenceHandler onMembers,
  }) {
    final sub = listen(channelName, handlers);
    _members.putIfAbsent(channelName, () => []).add(onMembers);
    return RealtimeSubscription(() {
      sub.cancel();
      _members[channelName]?.remove(onMembers);
    });
  }

  /// Client events sent, as `channel client-event json`.
  final whispers = <String>[];

  @override
  bool whisper(String channelName, String event, Map<String, dynamic> data) {
    if (!connected || !_handlers.containsKey(channelName)) return false;
    whispers.add('$channelName client-$event ${jsonEncode(data)}');
    return true;
  }

  void emit(String channel, String event, Map<String, dynamic> data) {
    for (final h in [...?_handlers[channel]]) {
      h[event]?.call(data);
    }
  }

  void setMembers(String channel, List<Map<String, dynamic>> members) {
    for (final m in [...?_members[channel]]) {
      m(members);
    }
  }

  void drop() {
    connected = false;
    _connection.add(false);
  }

  void reconnect() {
    connected = true;
    _connection.add(true);
    _reconnects.add(null);
  }

  @override
  void dispose() {}
}

/// The workspace's running session, fixed (no socket, no poll).
class StubLiveSession extends ActiveLiveSession {
  StubLiveSession(this.initial);

  final LiveSession? initial;

  @override
  Future<LiveSession?> build() async => initial;
}

/// The API's per-field song save (`PATCH /api/songs/{id}/changes`): the
/// request's `changes` laid over [server], answered as the server would.
FakeReply songChangeReply(RequestOptions r, Map<String, dynamic> server) {
  final changes = ((r.data as Map)['changes'] as Map).cast<String, dynamic>();
  server.addAll(changes);
  server['version'] = ((server['version'] as int?) ?? 1) + 1;
  return FakeApiAdapter.ok({...server});
}

/// A song as the API returns it, for change fakes.
Map<String, dynamic> serverSongJson(int id, {String title = 'Amazing Grace', String? key = 'G', String? content}) => {
  'id': id,
  'title': title,
  'artist': null,
  'key': key,
  'transposition': 0,
  'bpm': null,
  'time_signature': null,
  'content': content,
  'lyrics': null,
  'youtube_url': null,
  'spotify_url': null,
  'apple_music_url': null,
  'other_url': null,
  'is_public': false,
  'created_at': '2026-10-15T08:00:00+00:00',
  'version': 1,
};

/// Records what would have gone to Spotlight / the launcher, and lets a test
/// play the OS handing back a picked item.
class FakeOsSearchIndex extends OsSearchIndex {
  FakeOsSearchIndex({this.launchPath});

  String? launchPath;
  final replaced = <List<OsSearchItem>>[];
  final shortcutSets = <List<OsSearchItem>>[];
  int clears = 0;
  final _picked = StreamController<String>.broadcast();

  void pick(String path) => _picked.add(path);

  @override
  Stream<String> get opens => _picked.stream;

  @override
  Future<String?> takeLaunchPath() async {
    final path = launchPath;
    launchPath = null;
    return path;
  }

  @override
  Future<void> replaceAll(List<OsSearchItem> items) async => replaced.add(items);

  @override
  Future<void> setShortcuts(List<OsSearchItem> items) async => shortcutSets.add(items);

  @override
  Future<void> clear() async => clears++;
}
