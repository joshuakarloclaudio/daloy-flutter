/// Present between two devices on the same network, with no internet: the
/// presenting device advertises itself over Bonjour / mDNS and serves a
/// WebSocket; a controller finds it, pairs with the 4-digit code shown on
/// the presenter, then sees the whole deck and sends commands. The messages
/// are the deck and commands as JSON (`present_deck.dart`), the same shape
/// the web's two windows trade.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart' as nsd;

import '../domain/present_deck.dart';

const presentServiceType = '_daloy-present._tcp';

/// Wrong codes before the code changes, so it can't be guessed.
const _maxFailedPairings = 8;

/// A device controlling this presentation.
typedef _Paired = ({String name, WebSocket socket});

/// The presenting side: serves the deck to paired controllers.
class PresentHost {
  PresentHost({required this.deviceName, required this.onCommand, Random? random})
    : _random = random ?? Random.secure() {
    code = _newCode();
  }

  /// "Ana's iPad" — what controllers see in their list.
  final String deviceName;
  final void Function(PresentCommand command) onCommand;
  final Random _random;

  /// What a controller types to pair. Changes after too many wrong tries.
  late String code;

  /// Paired controllers' names, as they come and go.
  final controllers = ValueNotifier<List<String>>(const []);

  HttpServer? _server;
  nsd.Registration? _registration;
  final _paired = <_Paired>[];
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
          txt: {'by': _txt(deviceName), 'title': _txt(title)},
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
    _Paired? paired;

    // Nothing is sent before the right code arrives, and the code must come first.
    final timeout = Timer(const Duration(seconds: 15), () {
      if (paired == null) unawaited(socket.close(WebSocketStatus.policyViolation));
    });

    socket.listen(
      (data) async {
        final message = _decode(data);
        if (message == null) return;
        if (paired == null) {
          timeout.cancel();
          if (message['type'] != 'hello' || message['code'] != code) {
            if (++_failed >= _maxFailedPairings) _rotateCode();
            // A pause per wrong code, so guessing takes forever.
            await Future<void>.delayed(const Duration(seconds: 1));
            socket.add(jsonEncode({'type': 'denied'}));
            await socket.close(WebSocketStatus.policyViolation);
            return;
          }
          final name = '${message['name'] ?? 'Another device'}';
          paired = (name: name, socket: socket);
          _paired.add(paired!);
          _publish();
          socket.add(jsonEncode({'type': 'welcome', 'by': deviceName}));
          if (_deck case final deck?) socket.add(_stateMessage(deck));
          return;
        }
        if (message['type'] == 'command') {
          final command = PresentCommand.fromJson(((message['command'] as Map?) ?? const {}).cast());
          if (command != null) onCommand(command);
        }
      },
      onDone: () {
        timeout.cancel();
        if (paired != null && _paired.remove(paired)) _publish();
      },
      onError: (_) {},
      cancelOnError: true,
    );
  }

  void _rotateCode() {
    code = _newCode();
    _failed = 0;
    codeChanged?.call(code);
  }

  /// Told when [code] changes, so the screen shows the new one.
  void Function(String code)? codeChanged;

  void _publish() => controllers.value = [for (final c in _paired) c.name];

  String _stateMessage(PresentDeckState deck) => jsonEncode({'type': 'state', 'deck': deck.toJson()});

  /// Sends [deck] to every paired controller.
  void broadcast(PresentDeckState deck) {
    _deck = deck;
    if (_paired.isEmpty) return;
    final message = _stateMessage(deck);
    for (final c in _paired) {
      c.socket.add(message);
    }
  }

  Future<void> stop() async {
    for (final c in [..._paired]) {
      c.socket.add(jsonEncode({'type': 'ended'}));
      await c.socket.close(WebSocketStatus.goingAway);
    }
    _paired.clear();
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
    unawaited(stop());
    controllers.dispose();
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
  });

  /// The Bonjour name; unique on the network.
  final String id;
  final String by;
  final String title;
  final String host;
  final int port;

  static NearbyPresenter? fromService(nsd.Service s) {
    final host = s.addresses?.firstOrNull?.address ?? s.host;
    if (s.name == null || host == null || s.port == null) return null;
    String txt(String key) {
      final bytes = s.txt?[key];
      return bytes == null ? '' : utf8.decode(bytes, allowMalformed: true);
    }

    final by = txt('by');
    return NearbyPresenter(id: s.name!, by: by.isEmpty ? s.name! : by, title: txt('title'), host: host, port: s.port!);
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

  /// Null when it started; otherwise why it couldn't look.
  Future<String?> start() async {
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
      try {
        await nsd.stopDiscovery(d);
      } on Object {
        // Already gone.
      }
    }
  }

  void dispose() {
    unawaited(stop());
    presenters.dispose();
  }
}

/// Why pairing didn't work.
class PairingException implements Exception {
  const PairingException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The controlling side: one paired presentation.
class PresentRemote {
  PresentRemote._(this._socket, this.presenterName);

  final WebSocket _socket;

  /// "Ana's iPad".
  final String presenterName;
  final deck = ValueNotifier<PresentDeckState?>(null);

  /// Set once the presenter has gone (closed Present, left the network).
  final ended = ValueNotifier<bool>(false);

  /// Pairs with [presenter] using [code]; throws [PairingException].
  static Future<PresentRemote> connect(NearbyPresenter presenter, String code, {required String name}) async {
    final WebSocket socket;
    try {
      socket = await WebSocket.connect('ws://${presenter.host}:${presenter.port}/present')
          .timeout(const Duration(seconds: 8));
    } on Object {
      throw const PairingException("Couldn't reach it. Both devices need to be on the same Wi-Fi.");
    }
    socket.pingInterval = const Duration(seconds: 5);
    socket.add(jsonEncode({'type': 'hello', 'code': code, 'name': name}));

    final welcome = Completer<PresentRemote>();
    PresentRemote? remote;
    socket.listen(
      (data) {
        final message = _decode(data);
        if (message == null) return;
        switch (message['type']) {
          case 'welcome':
            remote = PresentRemote._(socket, '${message['by'] ?? presenter.by}');
            welcome.complete(remote);
          case 'denied':
            if (!welcome.isCompleted) welcome.completeError(const PairingException('That code didn’t match.'));
          case 'state':
            remote?.deck.value = PresentDeckState.fromJson(((message['deck'] as Map?) ?? const {}).cast());
          case 'ended':
            remote?.ended.value = true;
        }
      },
      onDone: () {
        if (!welcome.isCompleted) {
          welcome.completeError(const PairingException('That code didn’t match.'));
        }
        remote?.ended.value = true;
      },
      onError: (_) {},
      cancelOnError: true,
    );
    return welcome.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        unawaited(socket.close());
        throw const PairingException('It didn’t answer. Try again.');
      },
    );
  }

  void send(PresentCommand command) {
    if (ended.value) return;
    _socket.add(jsonEncode({'type': 'command', 'command': command.toJson()}));
  }

  Future<void> close() async {
    ended.value = true;
    await _socket.close(WebSocketStatus.normalClosure);
  }

  void dispose() {
    unawaited(close());
    deck.dispose();
    ended.dispose();
  }
}
