import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart' as reverb;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/app_config.dart';
import '../network/network_providers.dart';
import '../storage/session_store.dart';

part 'realtime_client.g.dart';

typedef RealtimeHandler = void Function(Map<String, dynamic> data);

/// Who is on a presence channel: each member's `user_info` from the
/// channel's authorization (`routes/channels.php`).
typedef PresenceHandler = void Function(List<Map<String, dynamic>> members);

/// Handle returned by [RealtimeClient.listen]; cancelling releases the channel
/// once nobody else is on it.
class RealtimeSubscription {
  RealtimeSubscription(this._cancel);

  final void Function() _cancel;
  bool _done = false;

  void cancel() {
    if (_done) return;
    _done = true;
    _cancel();
  }
}

/// The Flutter twin of `lib/echo.ts`: one shared Reverb socket, private
/// channels authorized against `/api/broadcasting/auth` with the same bearer
/// token and `X-Workspace-ID` as every other request.
///
/// The socket opens with the first listener and closes with the last. The
/// package reconnects with backoff and resubscribes on its own; [reconnected]
/// tells listeners to refetch whatever they may have missed while it was down.
class RealtimeClient {
  RealtimeClient(this._store);

  final SessionStore _store;
  final _reconnectedController = StreamController<void>.broadcast();
  final _connectedController = StreamController<bool>.broadcast();
  StreamSubscription<reverb.ConnectionState>? _stateSubscription;
  final _registrations = <String, _Registration>{};
  reverb.ReverbClient? _client;
  bool _hasConnectedBefore = false;

  /// Fires each time the socket (re)connects after the first time.
  Stream<void> get reconnected => _reconnectedController.stream;

  /// Whether the socket is up, each time that changes.
  Stream<bool> get connectedChanges => _connectedController.stream.distinct();

  bool get isConnected => _client?.connectionState == reverb.ConnectionState.connected;

  /// This socket's id once connected. Sent as `X-Socket-ID` so a broadcast
  /// the server sends `toOthers()` doesn't echo back to the device that caused it.
  String? get socketId => isConnected ? _client?.socketId : null;

  /// Listens on a private channel (`private-…`).
  RealtimeSubscription listen(String channelName, Map<String, RealtimeHandler> handlers) =>
      _listen(channelName, _Listener(handlers));

  /// Joins a presence channel (`presence-…`): the same events as [listen],
  /// plus [onMembers] with everyone on it each time someone comes or goes.
  RealtimeSubscription join(
    String channelName,
    Map<String, RealtimeHandler> handlers, {
    required PresenceHandler onMembers,
  }) => _listen(channelName, _Listener(handlers, onMembers: onMembers));

  RealtimeSubscription _listen(String channelName, _Listener listener) {
    final registration = _registrations.putIfAbsent(channelName, () => _Registration(channelName));
    registration.listeners.add(listener);

    _ensureConnected();
    if (isConnected) _attach(registration);

    return RealtimeSubscription(() {
      registration.listeners.remove(listener);
      if (registration.listeners.isNotEmpty) return;
      registration.detach();
      _registrations.remove(channelName);
      _client?.unsubscribeFromChannel(channelName);
      if (_registrations.isEmpty) _client?.disconnect();
    });
  }

  /// Sends a client event (`client-{event}`) straight to everyone else on a
  /// channel this device is on — no server round trip. False when it can't
  /// go right now (not subscribed yet, socket down).
  bool whisper(String channelName, String event, Map<String, dynamic> data) {
    final channel = _registrations[channelName]?.channel;
    if (channel == null || !isConnected) return false;
    try {
      channel.whisper(event, data);
      return true;
    } catch (error) {
      debugPrint('[realtime] whisper $channelName: $error');
      return false;
    }
  }

  void dispose() {
    for (final registration in _registrations.values) {
      registration.detach();
    }
    _registrations.clear();
    _stateSubscription?.cancel();
    _client?.disconnect();
    _reconnectedController.close();
    _connectedController.close();
  }

  void _ensureConnected() {
    final client = _client ??= reverb.ReverbClient.instance(
      host: AppConfig.reverbHost,
      port: AppConfig.reverbPort,
      appKey: AppConfig.reverbKey,
      useTLS: AppConfig.reverbUseTls,
      authEndpoint: '${AppConfig.apiBaseUrl}/api/broadcasting/auth',
      authorizer: _authHeaders,
      // Protocol-level pings so a half-dead mobile socket is noticed and
      // reconnected instead of silently going quiet.
      pingInterval: const Duration(seconds: 25),
      onConnected: (_) => _onConnected(),
      onError: (error) => debugPrint('[realtime] $error'),
    );
    _stateSubscription ??= client.onConnectionStateChange.listen(
      (state) => _connectedController.add(state == reverb.ConnectionState.connected),
    );

    final state = client.connectionState;
    if (state == reverb.ConnectionState.disconnected || state == reverb.ConnectionState.error) {
      // Failures are retried by the package; nothing useful to do here.
      unawaited(client.connect().catchError((Object _) {}));
    }
  }

  Future<Map<String, String>> _authHeaders(String channelName, String socketId) async => {
    'Accept': 'application/json',
    if (_store.token != null) 'Authorization': 'Bearer ${_store.token}',
    if (_store.workspaceId != null) 'X-Workspace-ID': '${_store.workspaceId}',
  };

  /// Runs inside the package's connection handler: socket id is set, and
  /// channels that already existed are resubscribed right after we return.
  void _onConnected() {
    _registrations.values.forEach(_attach);
    if (_hasConnectedBefore) _reconnectedController.add(null);
    _hasConnectedBefore = true;
  }

  void _attach(_Registration registration) {
    final client = _client;
    if (client == null || registration.channel != null) return;
    try {
      if (registration.isPresence) {
        final channel = client.subscribeToPresenceChannel(registration.name);
        registration.channel = channel;
        // The roster arrives with the subscription (a state change, not an
        // event) and changes with member_added / member_removed.
        void members() {
          final list = [for (final m in channel.members) m.info];
          for (final listener in registration.listeners.toList()) {
            listener.onMembers?.call(list);
          }
        }

        registration.stateListener = (state) {
          if (state == reverb.ChannelState.subscribed) members();
        };
        channel.addStateListener(registration.stateListener!);
        registration.subscription = channel.stream.listen((event) {
          if (event.eventName == 'pusher:member_added' || event.eventName == 'pusher:member_removed') {
            members();
          } else {
            registration.dispatch(event.eventName, _decode(event.data));
          }
        });
      } else {
        final channel = client.subscribeToPrivateChannel(registration.name);
        registration.channel = channel;
        registration.subscription = channel.stream.listen(
          (event) => registration.dispatch(event.eventName, _decode(event.data)),
        );
      }
    } catch (error) {
      debugPrint('[realtime] subscribe ${registration.name}: $error');
    }
  }

  static Map<String, dynamic> _decode(Object? raw) {
    final value = raw is String ? _tryJson(raw) : raw;
    return value is Map ? value.cast<String, dynamic>() : const {};
  }

  static Object? _tryJson(String raw) {
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}

class _Registration {
  _Registration(this.name);

  final String name;
  final listeners = <_Listener>[];
  reverb.PrivateChannel? channel;
  StreamSubscription<reverb.ChannelEvent>? subscription;
  reverb.ChannelStateListener? stateListener;

  bool get isPresence => name.startsWith('presence-');

  void dispatch(String event, Map<String, dynamic> data) {
    for (final listener in listeners.toList()) {
      listener.handlers[event]?.call(data);
    }
  }

  void detach() {
    subscription?.cancel();
    subscription = null;
    if (stateListener case final listener?) channel?.removeStateListener(listener);
    stateListener = null;
    channel = null;
  }
}

class _Listener {
  _Listener(this.handlers, {this.onMembers});

  final Map<String, RealtimeHandler> handlers;
  final PresenceHandler? onMembers;
}

@Riverpod(keepAlive: true)
RealtimeClient realtimeClient(Ref ref) {
  final client = RealtimeClient(ref.watch(sessionStoreProvider));
  ref.onDispose(client.dispose);
  return client;
}
