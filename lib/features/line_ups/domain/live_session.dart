import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_session.freezed.dart';
part 'live_session.g.dart';

/// `GET /api/live-session` — the workspace's running performance, if any.
@freezed
abstract class LiveSession with _$LiveSession {
  const factory LiveSession({
    required int id,
    required int lineUpId,
    @Default(0) int currentSongIndex,
    String? activeSectionIdChords,
    String? activeSectionIdLyrics,
    @Default(0) int participantCount,
    required int startedByUserId,
    required String startedByUserName,
    required DateTime startedAt,

    /// Who moves the session, when someone has taken the lead (opt-in).
    int? leaderUserId,
    String? leaderName,
  }) = _LiveSession;

  factory LiveSession.fromJson(Map<String, dynamic> json) => _$LiveSessionFromJson(json);
}

/// The presence channel everyone in session [sessionId] is on.
String liveSessionChannel(int sessionId) => 'presence-live-session.$sessionId';
