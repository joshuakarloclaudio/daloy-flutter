// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A line-up's live session as one device sees it: the twin of the web's
/// `use-performance-live-session.ts`, owned by Perform.
///
/// Control is shared by default, as on the web: everyone who is following
/// moves the team (scrolling into another song included) and moves with it.
/// Leading is opt-in: once someone takes the lead (anyone can take over),
/// only they move the team. A follower of a leader who scrolls by hand
/// drifts: the leader's moves are held until "Back to live" or
/// [autoReturnAfter] of stillness.
///
/// A move is whispered over the socket, straight to the others, and saved
/// over HTTP for anyone who joins or resyncs later. The save's broadcast
/// carries the whisper's id, so devices that already moved skip it; older
/// clients, which don't whisper, still move everyone through it.
///
/// Team edits (key, notes, arrangement, the song itself) are written to
/// Drift as they arrive, so Perform shows them without knowing about them.
/// The session is the one network-only read: offline, it waits and then
/// resyncs.

@ProviderFor(LiveSessionController)
final liveSessionControllerProvider = LiveSessionControllerFamily._();

/// A line-up's live session as one device sees it: the twin of the web's
/// `use-performance-live-session.ts`, owned by Perform.
///
/// Control is shared by default, as on the web: everyone who is following
/// moves the team (scrolling into another song included) and moves with it.
/// Leading is opt-in: once someone takes the lead (anyone can take over),
/// only they move the team. A follower of a leader who scrolls by hand
/// drifts: the leader's moves are held until "Back to live" or
/// [autoReturnAfter] of stillness.
///
/// A move is whispered over the socket, straight to the others, and saved
/// over HTTP for anyone who joins or resyncs later. The save's broadcast
/// carries the whisper's id, so devices that already moved skip it; older
/// clients, which don't whisper, still move everyone through it.
///
/// Team edits (key, notes, arrangement, the song itself) are written to
/// Drift as they arrive, so Perform shows them without knowing about them.
/// The session is the one network-only read: offline, it waits and then
/// resyncs.
final class LiveSessionControllerProvider
    extends $NotifierProvider<LiveSessionController, LiveState> {
  /// A line-up's live session as one device sees it: the twin of the web's
  /// `use-performance-live-session.ts`, owned by Perform.
  ///
  /// Control is shared by default, as on the web: everyone who is following
  /// moves the team (scrolling into another song included) and moves with it.
  /// Leading is opt-in: once someone takes the lead (anyone can take over),
  /// only they move the team. A follower of a leader who scrolls by hand
  /// drifts: the leader's moves are held until "Back to live" or
  /// [autoReturnAfter] of stillness.
  ///
  /// A move is whispered over the socket, straight to the others, and saved
  /// over HTTP for anyone who joins or resyncs later. The save's broadcast
  /// carries the whisper's id, so devices that already moved skip it; older
  /// clients, which don't whisper, still move everyone through it.
  ///
  /// Team edits (key, notes, arrangement, the song itself) are written to
  /// Drift as they arrive, so Perform shows them without knowing about them.
  /// The session is the one network-only read: offline, it waits and then
  /// resyncs.
  LiveSessionControllerProvider._({
    required LiveSessionControllerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'liveSessionControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveSessionControllerHash();

  @override
  String toString() {
    return r'liveSessionControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LiveSessionController create() => LiveSessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LiveState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LiveState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveSessionControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveSessionControllerHash() =>
    r'4b8bcec108969cfcfbea8c94192261e637d7a011';

/// A line-up's live session as one device sees it: the twin of the web's
/// `use-performance-live-session.ts`, owned by Perform.
///
/// Control is shared by default, as on the web: everyone who is following
/// moves the team (scrolling into another song included) and moves with it.
/// Leading is opt-in: once someone takes the lead (anyone can take over),
/// only they move the team. A follower of a leader who scrolls by hand
/// drifts: the leader's moves are held until "Back to live" or
/// [autoReturnAfter] of stillness.
///
/// A move is whispered over the socket, straight to the others, and saved
/// over HTTP for anyone who joins or resyncs later. The save's broadcast
/// carries the whisper's id, so devices that already moved skip it; older
/// clients, which don't whisper, still move everyone through it.
///
/// Team edits (key, notes, arrangement, the song itself) are written to
/// Drift as they arrive, so Perform shows them without knowing about them.
/// The session is the one network-only read: offline, it waits and then
/// resyncs.

final class LiveSessionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          LiveSessionController,
          LiveState,
          LiveState,
          LiveState,
          int
        > {
  LiveSessionControllerFamily._()
    : super(
        retry: null,
        name: r'liveSessionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A line-up's live session as one device sees it: the twin of the web's
  /// `use-performance-live-session.ts`, owned by Perform.
  ///
  /// Control is shared by default, as on the web: everyone who is following
  /// moves the team (scrolling into another song included) and moves with it.
  /// Leading is opt-in: once someone takes the lead (anyone can take over),
  /// only they move the team. A follower of a leader who scrolls by hand
  /// drifts: the leader's moves are held until "Back to live" or
  /// [autoReturnAfter] of stillness.
  ///
  /// A move is whispered over the socket, straight to the others, and saved
  /// over HTTP for anyone who joins or resyncs later. The save's broadcast
  /// carries the whisper's id, so devices that already moved skip it; older
  /// clients, which don't whisper, still move everyone through it.
  ///
  /// Team edits (key, notes, arrangement, the song itself) are written to
  /// Drift as they arrive, so Perform shows them without knowing about them.
  /// The session is the one network-only read: offline, it waits and then
  /// resyncs.

  LiveSessionControllerProvider call(int lineUpId) =>
      LiveSessionControllerProvider._(argument: lineUpId, from: this);

  @override
  String toString() => r'liveSessionControllerProvider';
}

/// A line-up's live session as one device sees it: the twin of the web's
/// `use-performance-live-session.ts`, owned by Perform.
///
/// Control is shared by default, as on the web: everyone who is following
/// moves the team (scrolling into another song included) and moves with it.
/// Leading is opt-in: once someone takes the lead (anyone can take over),
/// only they move the team. A follower of a leader who scrolls by hand
/// drifts: the leader's moves are held until "Back to live" or
/// [autoReturnAfter] of stillness.
///
/// A move is whispered over the socket, straight to the others, and saved
/// over HTTP for anyone who joins or resyncs later. The save's broadcast
/// carries the whisper's id, so devices that already moved skip it; older
/// clients, which don't whisper, still move everyone through it.
///
/// Team edits (key, notes, arrangement, the song itself) are written to
/// Drift as they arrive, so Perform shows them without knowing about them.
/// The session is the one network-only read: offline, it waits and then
/// resyncs.

abstract class _$LiveSessionController extends $Notifier<LiveState> {
  late final _$args = ref.$arg as int;
  int get lineUpId => _$args;

  LiveState build(int lineUpId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LiveState, LiveState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LiveState, LiveState>,
              LiveState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
