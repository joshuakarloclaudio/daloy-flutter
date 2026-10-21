/// Present between two devices on the same network, with no internet: the
/// presenting device advertises itself over Bonjour / mDNS and serves a
/// WebSocket; a teammate's device finds it, pairs with the 4-digit code the
/// presenter shows when asked (or a key it was given last time), then sees
/// the whole deck and sends commands. One paired device drives at a time;
/// the others watch until they take control. The messages are the deck and
/// commands as JSON (`present_deck.dart`), the same shape the web's two
/// windows trade.
///
/// Controller → presenter: `hello {name, device, token?}`, `code {code}`,
/// `take`, `command {command}`.
/// Presenter → controller: `pin` (type the code), `denied` (wrong code, try
/// again), `declined`, `welcome {by, token}`, `state {deck}`,
/// `driver {name?, you}`, `removed`, `ended`.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart' as nsd;

import '../domain/present_deck.dart';
import 'present_trust.dart';

const presentServiceType = '_daloy-present._tcp';

/// Wrong codes before the code changes, so it can't be guessed.
const _maxFailedPairings = 8;

/// Another device on the link: waiting for the code, or paired.
@immutable
class PresentPeer {
  const PresentPeer({required this.id, required this.name});

  /// Its install id (`presentDeviceId`), stable across days and addresses.
  final String id;

  /// "Ben's phone".
  final String name;

  @override
  bool operator ==(Object other) => other is PresentPeer && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => name;
}

class _Connection {
  _Connection(this.socket);

  final WebSocket socket;
  PresentPeer? peer;
  bool paired = false;
  Timer? timeout;

  void send(Map<String, Object?> message) => socket.add(jsonEncode(message));
}

/// The presenting side: serves the deck to paired controllers.
class PresentHost {
  PresentHost({
    required this.deviceName,
    required this.deviceId,
    required this.onCommand,
    this.workspaceId,
    PresentKeys? trusted,
    Random? random,
  }) : _trusted = trusted ?? PresentKeys(null, ''),
       _random = random ?? Random.secure() {
    code = _newCode();
  }

  /// "Ana's iPad" — what controllers see.
  final String deviceName;
  final String deviceId;

  /// Only teammates' devices show this presentation.
  final int? workspaceId;
  final void Function(PresentCommand command) onCommand;
  final PresentKeys _trusted;
  final Random _random;

  /// What a new controller types to pair. Changes after too many wrong tries.
  late String code;

  /// Told when [code] changes, so the screen shows the new one.
  void Function(String code)? codeChanged;

  /// Told when a device pairs or comes back with its key.
  void Function(PresentPeer peer, {required bool remembered})? onPaired;

  /// Devices asking to pair, waiting for someone to read them the code.
  final requests = ValueNotifier<List<PresentPeer>>(const []);

  /// Paired devices, as they come and go.
  final controllers = ValueNotifier<List<PresentPeer>>(const []);

  /// The paired device whose commands count; null while nobody's driving
  /// from afar. This device's own controls always work.
  final driver = ValueNotifier<PresentPeer?>(null);

  HttpServer? _server;
  nsd.Registration? _registration;
  final _connections = <_Connection>[];
  PresentDeckState? _deck;
  var _failed = 0;

  bool get isRunning => _server != null;

  /// The port it serves on, while running.
  int? get port => _server?.port;

  String _newCode() => _random.nextInt(10000).toString().padLeft(4, '0');

  /// Starts serving and advertising [title]. Throws if the network refuses.
  Future<void> start(String title) async {
    if (_server != null) return;
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _server = server;
    server.listen(_onRequest, onError: (_) {});
    try {
      _registration = await nsd.register(
        nsd.Service(
          name: _serviceName(deviceName, title),
          type: presentServiceType,
          port: server.port,
          txt: {
            'by': _txt(deviceName),
            'title': _txt(title),
            'dev': _txt(deviceId),
            if (workspaceId case final ws?) 'ws': _txt('$ws'),
          },
        ),
      );
    } on Object {
      // Still reachable once found another way; advertising is best effort.
    }
  }

  static Uint8List _txt(String value) =>
      Uint8List.fromList(utf8.encode(value.length > 120 ? value.substring(0, 120) : value));

  /// Bonjour names stop at 63 bytes.
  static String _serviceName(String by, String title) {
    final name = '$by · $title';
    final bytes = utf8.encode(name);
    if (bytes.length <= 60) return name;
    return utf8.decode(bytes.sublist(0, 60), allowMalformed: true).replaceAll('�', '');
  }

  Future<void> _onRequest(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    socket.pingInterval = const Duration(seconds: 5);
    final connection = _Connection(socket);
    _connections.add(connection);

    // Nothing is sent before a known key or the right code, and hello comes first.
    connection.timeout = Timer(const Duration(seconds: 15), () => _drop(connection));

    socket.listen(
      (data) async {
        final message = _decode(data);
        if (message == null) return;
        if (connection.peer == null) return _onHello(connection, message);
        if (!connection.paired) return _onCode(connection, message);
        switch (message['type']) {
          case 'take':
            _setDriver(connection.peer);
          case 'command' when driver.value?.id == connection.peer!.id:
            final command = PresentCommand.fromJson(((message['command'] as Map?) ?? const {}).cast());
            if (command != null) onCommand(command);
        }
      },
      onDone: () => _closed(connection),
      onError: (_) {},
      cancelOnError: true,
    );
  }

  void _onHello(_Connection connection, Map<String, Object?> message) {
    if (message['type'] != 'hello' || message['device'] is! String) {
      unawaited(connection.socket.close(WebSocketStatus.policyViolation));
      return;
    }
    connection.timeout?.cancel();
    final peer = PresentPeer(id: message['device']! as String, name: '${message['name'] ?? 'Another device'}');
    connection.peer = peer;
    final known = _trusted.tokenFor(peer.id);
    if (known != null && message['token'] == known) {
      _pair(connection, token: known, remembered: true);
      return;
    }
    // Long enough to walk over and read the code.
    connection.timeout = Timer(const Duration(minutes: 2), () => _drop(connection));
    _publish();
    connection.send({'type': 'pin'});
  }

  Future<void> _onCode(_Connection connection, Map<String, Object?> message) async {
    if (message['type'] != 'code') return;
    if (message['code'] == code) {
      _failed = 0;
      final token = newPresentToken(_random);
      _trusted.remember(connection.peer!.id, token: token, name: connection.peer!.name);
      _pair(connection, token: token, remembered: false);
      return;
    }
    if (++_failed >= _maxFailedPairings) _rotateCode();
    // A pause per wrong code, so guessing takes forever.
    await Future<void>.delayed(const Duration(seconds: 1));
    if (_connections.contains(connection)) connection.send({'type': 'denied'});
  }

  void _pair(_Connection connection, {required String token, required bool remembered}) {
    connection.timeout?.cancel();
    final peer = connection.peer!;
    // The same device again (a dropped Wi-Fi): the new connection wins.
    for (final other in [..._connections]) {
      if (other != connection && other.paired && other.peer?.id == peer.id) _drop(other);
    }
    connection.paired = true;
    connection.send({'type': 'welcome', 'by': deviceName, 'token': token});
    if (_deck case final deck?) connection.socket.add(_stateMessage(deck));
    if (driver.value == null) {
      _setDriver(peer);
    } else {
      _sendDriver(connection);
    }
    _publish();
    onPaired?.call(peer, remembered: remembered);
  }

  void _setDriver(PresentPeer? peer) {
    driver.value = peer;
    for (final c in _connections) {
      if (c.paired) _sendDriver(c);
    }
  }

  void _sendDriver(_Connection c) =>
      c.send({'type': 'driver', 'name': driver.value?.name, 'you': driver.value?.id == c.peer?.id});

  void _drop(_Connection connection, [String? goodbye]) {
    connection.timeout?.cancel();
    if (goodbye != null) connection.send({'type': goodbye});
    unawaited(connection.socket.close(WebSocketStatus.policyViolation));
    _closed(connection);
  }

  void _closed(_Connection connection) {
    connection.timeout?.cancel();
    if (!_connections.remove(connection)) return;
    if (connection.paired && driver.value?.id == connection.peer?.id) _setDriver(null);
    _publish();
  }

  /// Turns away a device asking to pair.
  void decline(String id) {
    for (final c in [..._connections]) {
      if (!c.paired && c.peer?.id == id) _drop(c, 'declined');
    }
  }

  /// Unpairs [id] and forgets its key, so it needs the code again.
  void disconnect(String id) {
    _trusted.forget(id);
    for (final c in [..._connections]) {
      if (c.peer?.id == id) _drop(c, 'removed');
    }
  }

  void _rotateCode() {
    code = _newCode();
    _failed = 0;
    codeChanged?.call(code);
  }

  void _publish() {
    requests.value = [
      for (final c in _connections)
        if (!c.paired && c.peer != null) c.peer!,
    ];
    controllers.value = [
      for (final c in _connections)
        if (c.paired) c.peer!,
    ];
  }

  String _stateMessage(PresentDeckState deck) => jsonEncode({'type': 'state', 'deck': deck.toJson()});

  /// Sends [deck] to every paired controller.
  void broadcast(PresentDeckState deck) {
    _deck = deck;
    final paired = _connections.where((c) => c.paired);
    if (paired.isEmpty) return;
    final message = _stateMessage(deck);
    for (final c in paired) {
      c.socket.add(message);
    }
  }

  Future<void> stop() async {
    for (final c in [..._connections]) {
      c.timeout?.cancel();
      if (c.paired) c.send({'type': 'ended'});
      await c.socket.close(WebSocketStatus.goingAway);
    }
    _connections.clear();
    driver.value = null;
    _publish();
    if (_registration case final r?) {
      try {
        await nsd.unregister(r);
      } on Object {
        // Gone with the app anyway.
      }
    }
    _registration = null;
    await _server?.close(force: true);
    _server = null;
  }

  void dispose() {
    unawaited(
      stop().whenComplete(() {
        requests.dispose();
        controllers.dispose();
        driver.dispose();
      }),
    );
  }
}

Map<String, Object?>? _decode(Object? data) {
  if (data is! String) return null;
  try {
    final value = jsonDecode(data);
    return value is Map ? value.cast() : null;
  } on FormatException {
    return null;
  }
}

/// A presentation found nearby.
@immutable
class NearbyPresenter {
  const NearbyPresenter({
    required this.id,
    required this.by,
    required this.title,
    required this.host,
    required this.port,
    this.deviceId = '',
    this.workspaceId,
  });

  /// The Bonjour name; unique on the network.
  final String id;
  final String by;
  final String title;
  final String host;
  final int port;

  /// The presenting install's id, for its remembered key.
  final String deviceId;
  final int? workspaceId;

  static NearbyPresenter? fromService(nsd.Service s) {
    final host = s.addresses?.firstOrNull?.address ?? s.host;
    if (s.name == null || host == null || s.port == null) return null;
    String txt(String key) {
      final bytes = s.txt?[key];
      return bytes == null ? '' : utf8.decode(bytes, allowMalformed: true);
    }

    final by = txt('by');
    return NearbyPresenter(
      id: s.name!,
      by: by.isEmpty ? s.name! : by,
      title: txt('title'),
      host: host,
      port: s.port!,
      deviceId: txt('dev'),
      workspaceId: int.tryParse(txt('ws')),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is NearbyPresenter && other.id == id && other.host == host && other.port == port;

  @override
  int get hashCode => Object.hash(id, host, port);
}

/// Looks for presentations on the network while running.
class PresentFinder {
  final presenters = ValueNotifier<List<NearbyPresenter>>(const []);
  nsd.Discovery? _discovery;

  bool get isRunning => _discovery != null;

  /// Null when it started; otherwise why it couldn't look.
  Future<String?> start() async {
    if (_discovery != null) return null;
    try {
      final discovery = await nsd.startDiscovery(presentServiceType, ipLookupType: nsd.IpLookupType.v4);
      _discovery = discovery;
      void refresh() => presenters.value = [for (final s in discovery.services) ?NearbyPresenter.fromService(s)];
      discovery.addListener(refresh);
      refresh();
      return null;
    } on Object catch (e) {
      return '$e';
    }
  }

  Future<void> stop() async {
    if (_discovery case final d?) {
      _discovery = null;
      presenters.value = const [];
      try {
        await nsd.stopDiscovery(d);
      } on Object {
        // Already gone.
      }
    }
  }

  void dispose() {
    unawaited(stop().whenComplete(presenters.dispose));
  }
}

/// Why pairing didn't work.
class PairingException implements Exception {
  const PairingException(this.message, {this.cancelled = false});

  /// Backed out of typing the code.
  const PairingException.cancelled() : message = '', cancelled = true;

  final String message;
  final bool cancelled;

  @override
  String toString() => message;
}

/// Asks for the code shown on the presenter; [error] says why it's asked
/// again. Null backs out.
typedef AskPresentCode = Future<String?> Function(String? error);

/// The controlling side: one paired presentation.
class PresentRemote {
  PresentRemote._(this._socket, {required this.presenterName, required this.presenterId, required this.token});

  final WebSocket _socket;

  /// "Ana's iPad".
  final String presenterName;

  /// Its install id, to remember [token] by.
  final String presenterId;

  /// The key that pairs with it next time without the code.
  final String token;

  final deck = ValueNotifier<PresentDeckState?>(null);

  /// Whether this device's commands count. When another paired device is
  /// driving, [driverName] says who.
  final driving = ValueNotifier<bool>(false);
  final driverName = ValueNotifier<String?>(null);

  /// Set once the presenter has gone (closed Present, left the network) or
  /// unpaired this device ([removed]).
  final ended = ValueNotifier<bool>(false);
  bool removed = false;

  /// Pairs with [presenter]: straight in with a remembered [token], else
  /// [askCode] for the code shown there. Throws [PairingException].
  static Future<PresentRemote> connect(
    NearbyPresenter presenter, {
    required String name,
    required String deviceId,
    String? token,
    required AskPresentCode askCode,
  }) async {
    final WebSocket socket;
    try {
      socket = await WebSocket.connect('ws://${presenter.host}:${presenter.port}/present')
          .timeout(const Duration(seconds: 8));
    } on Object {
      throw const PairingException("Couldn't reach it. Both devices need to be on the same Wi-Fi.");
    }
    socket.pingInterval = const Duration(seconds: 5);
    socket.add(jsonEncode({'type': 'hello', 'name': name, 'device': deviceId, 'token': ?token}));

    final welcome = Completer<PresentRemote>();
    // Waiting on the network, not on someone typing.
    Timer? answer = Timer(const Duration(seconds: 10), () {
      if (welcome.isCompleted) return;
      welcome.completeError(const PairingException('It didn’t answer. Try again.'));
      unawaited(socket.close());
    });
    void fail(PairingException e) {
      answer?.cancel();
      if (!welcome.isCompleted) welcome.completeError(e);
      unawaited(socket.close());
    }

    Future<void> ask(String? error) async {
      answer?.cancel();
      final code = await askCode(error);
      if (welcome.isCompleted) return;
      if (code == null) return fail(const PairingException.cancelled());
      socket.add(jsonEncode({'type': 'code', 'code': code}));
    }

    PresentRemote? remote;
    socket.listen(
      (data) {
        final message = _decode(data);
        if (message == null) return;
        switch (message['type']) {
          case 'pin':
            unawaited(ask(null));
          case 'denied':
            unawaited(ask('That code didn’t match.'));
          case 'declined':
            fail(PairingException('${presenter.by} said no.'));
          case 'welcome':
            answer?.cancel();
            answer = null;
            remote = PresentRemote._(
              socket,
              presenterName: '${message['by'] ?? presenter.by}',
              presenterId: presenter.deviceId,
              token: '${message['token'] ?? ''}',
            );
            if (!welcome.isCompleted) welcome.complete(remote);
          case 'state':
            remote?.deck.value = PresentDeckState.fromJson(((message['deck'] as Map?) ?? const {}).cast());
          case 'driver':
            remote?.driving.value = message['you'] == true;
            remote?.driverName.value = message['name'] as String?;
          case 'removed':
            remote?.removed = true;
            remote?.ended.value = true;
          case 'ended':
            remote?.ended.value = true;
        }
      },
      onDone: () {
        fail(PairingException('${presenter.by} stopped presenting.'));
        remote?.ended.value = true;
      },
      onError: (_) {},
      cancelOnError: true,
    );
    return welcome.future;
  }

  /// Become the one driving; whoever was is told.
  void takeControl() {
    if (ended.value) return;
    _socket.add(jsonEncode({'type': 'take'}));
  }

  /// Sent while [driving]; otherwise the presenter ignores it.
  void send(PresentCommand command) {
    if (ended.value) return;
    _socket.add(jsonEncode({'type': 'command', 'command': command.toJson()}));
  }

  Future<void> close() async {
    ended.value = true;
    await _socket.close(WebSocketStatus.normalClosure);
  }

  void dispose() {
    unawaited(
      close().whenComplete(() {
        deck.dispose();
        ended.dispose();
        driving.dispose();
        driverName.dispose();
      }),
    );
  }
}
