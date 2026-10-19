import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_link.g.dart';

/// A join or invitation link the user opened before they could use it
/// (signed out, or with no workspace yet). Held until they're in, then opened.
@Riverpod(keepAlive: true)
class PendingLink extends _$PendingLink {
  @override
  String? build() => null;

  void hold(String location) => state = location;

  /// Takes the held location, leaving none behind.
  String? take() {
    final held = state;
    state = null;
    return held;
  }
}
