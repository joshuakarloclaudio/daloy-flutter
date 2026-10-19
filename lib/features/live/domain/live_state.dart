import 'package:flutter/foundation.dart';

import '../../line_ups/domain/live_session.dart';
import '../../songs/domain/display_prefs.dart';
import 'live_cue.dart';

/// Where this device stands with the line-up's live session.
enum LiveStatus {
  /// Playing alone. A session may be running for this line-up ([LiveState.invite]).
  solo,

  /// Starting or joining.
  connecting,

  /// In the session, and the socket is up.
  live,

  /// In the session, but the network or socket dropped; it resyncs on return.
  reconnecting,
}

@immutable
class LiveParticipant {
  const LiveParticipant({required this.userId, required this.name});

  final int userId;
  final String name;

  @override
  bool operator ==(Object other) => other is LiveParticipant && other.userId == userId && other.name == name;

  @override
  int get hashCode => Object.hash(userId, name);
}

/// The session's place in the set. The song is shared; the highlighted
/// section is kept per view, so chord players and singers don't move each
/// other's highlight.
@immutable
class LivePosition {
  const LivePosition({required this.songIndex, this.chordsSectionId, this.lyricsSectionId});

  final int songIndex;
  final String? chordsSectionId;
  final String? lyricsSectionId;

  String? sectionFor(SongViewMode mode) => switch (mode) {
    SongViewMode.chords => chordsSectionId,
    SongViewMode.lyrics => lyricsSectionId,
  };

  @override
  bool operator ==(Object other) =>
      other is LivePosition &&
      other.songIndex == songIndex &&
      other.chordsSectionId == chordsSectionId &&
      other.lyricsSectionId == lyricsSectionId;

  @override
  int get hashCode => Object.hash(songIndex, chordsSectionId, lyricsSectionId);
}

/// Why the session went away, for the one-line notice Perform shows.
enum LiveEnd { endedByTeam, left, failed }

@immutable
class LiveState {
  const LiveState({
    this.status = LiveStatus.solo,
    this.session,
    this.invite,
    this.participants = const [],
    this.leaderId,
    this.leaderName,
    this.leading = false,
    this.following = true,
    this.drifted = false,
    this.missed = false,
    this.position,
    this.moves = 0,
    this.cues = const [],
    this.typing = const [],
    this.incoming,
    this.ended,
  });

  final LiveStatus status;

  /// The session this device is in (connecting, live or reconnecting).
  final LiveSession? session;

  /// A session running for this line-up that this device isn't in.
  final LiveSession? invite;

  /// Who's in, from the presence channel; sorted by name.
  final List<LiveParticipant> participants;

  /// Whoever took the lead. Null: shared — everyone following moves the team.
  final int? leaderId;
  final String? leaderName;

  /// This device's user is the leader.
  final bool leading;

  /// The "Follow live" switch: when off, this device neither moves with the
  /// team nor moves them.
  final bool following;

  /// Following someone else's lead and scrolled away by hand: their moves
  /// are held until "Back to live" or the idle timer.
  final bool drifted;

  /// A move arrived while drifted.
  final bool missed;

  /// The session's latest position.
  final LivePosition? position;

  /// Bumped each time Perform should go to [position].
  final int moves;

  /// This session's cues, oldest first.
  final List<LiveCue> cues;

  /// Teammates typing a cue right now.
  final List<LiveParticipant> typing;

  /// The latest cue from someone else, for the banner.
  final LiveCue? incoming;

  /// Set when a session this device was in went away.
  final LiveEnd? ended;

  bool get isIn => session != null;
  bool get isLive => status == LiveStatus.live;

  /// Moves with the team.
  bool get isSynced => isIn && following && !drifted;

  bool get isLed => leaderId != null;

  /// This device's moves go to the team: no one leads, or this user does.
  bool get canDrive => isIn && following && (!isLed || leading);

  /// Someone else leads: this device follows them and can drift away.
  bool get followsLeader => isIn && following && isLed && !leading;

  int get count => participants.isNotEmpty ? participants.length : (session?.participantCount ?? 0);

  LiveState copyWith({
    LiveStatus? status,
    LiveSession? Function()? session,
    LiveSession? Function()? invite,
    List<LiveParticipant>? participants,
    int? Function()? leaderId,
    String? Function()? leaderName,
    bool? leading,
    bool? following,
    bool? drifted,
    bool? missed,
    LivePosition? Function()? position,
    int? moves,
    List<LiveCue>? cues,
    List<LiveParticipant>? typing,
    LiveCue? Function()? incoming,
    LiveEnd? Function()? ended,
  }) => LiveState(
    status: status ?? this.status,
    session: session == null ? this.session : session(),
    invite: invite == null ? this.invite : invite(),
    participants: participants ?? this.participants,
    leaderId: leaderId == null ? this.leaderId : leaderId(),
    leaderName: leaderName == null ? this.leaderName : leaderName(),
    leading: leading ?? this.leading,
    following: following ?? this.following,
    drifted: drifted ?? this.drifted,
    missed: missed ?? this.missed,
    position: position == null ? this.position : position(),
    moves: moves ?? this.moves,
    cues: cues ?? this.cues,
    typing: typing ?? this.typing,
    incoming: incoming == null ? this.incoming : incoming(),
    ended: ended == null ? this.ended : ended(),
  );
}

/// The toast for a change of leader, or null when nothing changed. Same
/// wording as the web's `leaderChangeMessage`.
String? leaderChangeMessage({required LiveParticipant? previous, required LiveParticipant? next, required int? me}) {
  if (previous?.userId == next?.userId) return null;
  if (next != null) {
    if (next.userId == me) return 'You’re leading. Only your moves go to the team.';
    if (previous != null && previous.userId != me) return '${next.name} took over from ${previous.name}.';
    return '${next.name} is leading.';
  }
  if (previous!.userId == me) return 'You stopped leading. Everyone moves the team again.';
  return '${previous.name} stopped leading. Everyone moves the team again.';
}
