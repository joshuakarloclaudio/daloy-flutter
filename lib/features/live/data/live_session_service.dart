import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';
import '../../line_ups/domain/live_session.dart';
import '../../songs/domain/display_prefs.dart';
import '../domain/live_cue.dart';

part 'live_session_service.g.dart';

/// `/api/line-ups/{id}/live-session…` — the twin of the live-session calls
/// in the web's `services/line-ups.ts`.
class LiveSessionService {
  const LiveSessionService(this._api);

  final ApiClient _api;

  String _path(int lineUpId) => '/api/line-ups/$lineUpId/live-session';

  /// Joins the workspace's session, starting one for this line-up if none is
  /// running. (The API's "start" resets the session in place and adds no one
  /// to it, so the app never uses it.)
  Future<LiveSession> join(int lineUpId) => _api.post('${_path(lineUpId)}/join', Decode.object(LiveSession.fromJson));

  /// Null when this was the last person in, which ends the session.
  Future<LiveSession?> leave(int lineUpId) =>
      _api.post('${_path(lineUpId)}/leave', Decode.nullable(LiveSession.fromJson));

  Future<void> end(int lineUpId) => _api.delete(_path(lineUpId));

  /// Takes the lead (from whoever had it): only this user moves the session.
  Future<LiveSession> lead(int lineUpId) => _api.post('${_path(lineUpId)}/lead', Decode.object(LiveSession.fromJson));

  /// Steps down; everyone following moves the session again.
  Future<void> releaseLead(int lineUpId) => _api.delete('${_path(lineUpId)}/lead');

  /// Saves where the team is. [moveId] is the id of the same move whispered
  /// over the socket; the server echoes it so devices that already moved skip it.
  Future<void> move(
    int lineUpId, {
    required int songIndex,
    String? sectionId,
    required SongViewMode viewMode,
    String? moveId,
  }) => _api.patch(
    _path(lineUpId),
    (_) {},
    body: {
      'current_song_index': songIndex,
      'active_section_id': sectionId,
      'view_mode': viewMode.name,
      'move_id': ?moveId,
    },
  );

  /// [id] names a cue already whispered, so the broadcast reads as the same cue.
  Future<LiveCue> sendCue(
    int lineUpId,
    LiveCueKind kind,
    String body, {
    int? songIndex,
    String? sectionId,
    String? id,
  }) => _api.post(
    '${_path(lineUpId)}/cues',
    Decode.object(LiveCue.fromJson),
    body: {'kind': kind.name, 'body': body, 'song_index': songIndex, 'section_id': sectionId, 'id': ?id},
  );
}

@Riverpod(keepAlive: true)
LiveSessionService liveSessionService(Ref ref) => LiveSessionService(ref.watch(apiClientProvider));
