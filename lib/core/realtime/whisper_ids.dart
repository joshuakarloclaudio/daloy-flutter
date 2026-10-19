import 'dart:math';

final _random = Random.secure();

String _hex(int bytes) =>
    [for (var i = 0; i < bytes; i++) _random.nextInt(256).toRadixString(16).padLeft(2, '0')].join();

/// Names a change whispered over the socket. The HTTP save sends it too and
/// the server echoes it in its broadcast, so devices that already applied the
/// whisper skip the broadcast.
String whisperId() => _hex(8);

/// A random (v4) UUID — what the server would have named a cue.
String uuidV4() {
  final h = _hex(16);
  final variant = (8 + _random.nextInt(4)).toRadixString(16);
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-4${h.substring(13, 16)}-$variant${h.substring(17, 20)}-${h.substring(20)}';
}
