import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/connectivity/online_status.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/realtime/realtime_client.dart';
import '../../../core/realtime/whisper_ids.dart';
import '../../auth/application/session_controller.dart';
import '../../line_ups/data/line_ups_repository.dart';
import '../../line_ups/domain/line_up.dart';
import '../../line_ups/domain/live_session.dart';
import '../../perform/application/perform_controller.dart';
import '../../perform/data/perform_prefs_repository.dart';
import '../../songs/data/songs_repository.dart';
import '../../songs/domain/display_prefs.dart';
import '../../songs/domain/song.dart';
import '../data/live_session_service.dart';
import '../domain/live_cue.dart';
import '../domain/live_state.dart';

part 'live_session_controller.g.dart';

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
@riverpod
class LiveSessionController extends _$LiveSessionController {
  static const moveDebounce = Duration(milliseconds: 250);
  static const autoReturnAfter = Duration(seconds: 8);

  RealtimeSubscription? _channel;
  StreamSubscription<void>? _reconnected;
  StreamSubscription<bool>? _connection;
  Timer? _moveTimer;
  Timer? _returnTimer;

  /// Bumped to make an in-flight join or resync moot.
  int _generation = 0;
  bool _sawActive = false;
  bool _left = false;
  bool _resyncing = false;

  /// Who is typing, and when to forget they were: whispers say "typing", never "stopped".
  static const typingFor = Duration(seconds: 5);
  static const typingEvery = Duration(seconds: 2);
  final _typingTimers = <int, Timer>{};
  DateTime? _typingSentAt;

  /// The session [LiveState.cues] belong to; a different one starts them over.
  int? _cuesSessionId;

  /// Ids of moves and key changes that arrived by whisper, so their
  /// broadcast is skipped.
  final _whispered = <String>{};

  @override
  LiveState build(int lineUpId) {
    ref.onDispose(_teardown);

    // Joins a session already running for this line-up when Perform opens;
    // one that starts later is offered, not forced.
    ref.listen(activeLiveSessionProvider, (_, next) {
      if (next case AsyncData(:final value)) scheduleMicrotask(() => _onActive(value));
    }, fireImmediately: true);

    ref.listen(isOnlineProvider, (was, online) {
      if (!online) {
        if (state.isIn) state = state.copyWith(status: LiveStatus.reconnecting);
      } else if (was == false) {
        unawaited(resync());
      }
    });

    return const LiveState();
  }

  LiveSessionService get _service => ref.read(liveSessionServiceProvider);
  RealtimeClient get _realtime => ref.read(realtimeClientProvider);
  int? get _me => ref.read(sessionControllerProvider).value?.user.id;

  // -- Joining and leaving --------------------------------------------------------

  void _onActive(LiveSession? active) {
    if (!ref.mounted) return;
    final first = !_sawActive;
    _sawActive = true;
    final ours = active != null && active.lineUpId == lineUpId ? active : null;

    if (state.isIn) {
      // The workspace's one session moved to another line-up.
      if (active != null && active.lineUpId != lineUpId) _ended(LiveEnd.endedByTeam);
      return;
    }
    if (state.status == LiveStatus.connecting) return;
    state = state.copyWith(invite: () => ours);
    if (first && ours != null && !_left) unawaited(join());
  }

  /// Goes live: joins this line-up's session, starting it if none is running.
  /// Refused (false) while another line-up is live — that one has to end first.
  Future<bool> join() async {
    if (state.isIn || state.status == LiveStatus.connecting) return state.isIn;
    final other = ref.read(activeLiveSessionProvider).value;
    if (other != null && other.lineUpId != lineUpId) return false;

    final generation = ++_generation;
    final analytics = ref.read(analyticsProvider);
    state = state.copyWith(status: LiveStatus.connecting, ended: () => null);
    try {
      final session = await _service.join(lineUpId);
      if (!ref.mounted || generation != _generation) return false;
      if (session.lineUpId != lineUpId) {
        // Someone else went live elsewhere a moment before us.
        unawaited(_service.leave(lineUpId).then((_) {}, onError: (_) {}));
        state = state.copyWith(status: LiveStatus.solo, ended: () => LiveEnd.failed);
        return false;
      }
      _left = false;
      _enter(session);
      ref.read(activeLiveSessionProvider.notifier).adopt(session);
      unawaited(
        analytics.trackAndFlush(other == null ? AnalyticsEvent.liveSessionStarted : AnalyticsEvent.liveSessionJoined),
      );
      return true;
    } on ApiException {
      if (ref.mounted && generation == _generation) {
        state = state.copyWith(status: LiveStatus.solo, ended: () => LiveEnd.failed);
      }
      return false;
    }
  }

  /// Steps out; the session goes on for the others (and ends if no one is left).
  Future<void> leave() async {
    if (!state.isIn) return;
    _left = true;
    _ended(LiveEnd.left);
    try {
      final rest = await _service.leave(lineUpId);
      if (ref.mounted) ref.read(activeLiveSessionProvider.notifier).adopt(rest);
    } on ApiException {
      // Already over, or offline: the server drops us when the session ends.
    }
  }

  /// Ends the session for everyone.
  Future<void> endForAll() async {
    if (!state.isIn) return;
    _left = true;
    _ended(LiveEnd.left);
    try {
      await _service.end(lineUpId);
      if (ref.mounted) ref.read(activeLiveSessionProvider.notifier).adopt(null);
    } on ApiException {
      // Already ended.
    }
  }

  void _enter(LiveSession session) {
    _teardown();
    _channel = _realtime.join(liveSessionChannel(session.id), {
      'state.updated': _onMoved,
      'client-moved': _onWhisperedMove,
      'cue.sent': (data) => _onCue(LiveCue.fromJson(data)),
      'client-cue': (data) => _onCue(LiveCue.fromJson(data)),
      'client-typing': _onTyping,
      'session.ended': (_) => _ended(LiveEnd.endedByTeam),
      'leader.updated': (data) => _setLeader((data['leader_user_id'] as num?)?.toInt(), data['leader_name'] as String?),
      'transposition.updated': (data) {
        if (_seen(data['change_id'])) return;
        _fromTeammate(data, _applyTransposition);
      },
      'client-transposed': (data) {
        _remember(data['change_id']);
        _fromTeammate({...data, 'updated_by_user_id': data['user_id']}, _applyTransposition);
      },
      'notes.updated': (data) => _fromTeammate(data, _applyNotes),
      'section-arrangement.updated': (data) => _fromTeammate(data, _applyArrangement),
      'song.updated': (data) => _fromTeammate(data, _applySong),
    }, onMembers: _onMembers);
    _reconnected = _realtime.reconnected.listen((_) => unawaited(resync()));
    _connection = _realtime.connectedChanges.listen((up) {
      if (!state.isIn) return;
      if (!up) {
        state = state.copyWith(status: LiveStatus.reconnecting);
      } else if (state.status == LiveStatus.connecting) {
        state = state.copyWith(status: LiveStatus.live);
      }
      // A reconnect after a drop resyncs through [reconnected].
    });

    _setLeader(session.leaderUserId, session.leaderName);
    final newSession = _cuesSessionId != session.id;
    _cuesSessionId = session.id;
    state = state.copyWith(
      status: _realtime.isConnected ? LiveStatus.live : LiveStatus.connecting,
      session: () => session,
      cues: newSession ? const [] : state.cues,
      invite: () => null,
      drifted: false,
      missed: false,
      position: () => _positionOf(session),
      moves: state.following ? state.moves + 1 : state.moves,
      ended: () => null,
    );
    unawaited(_loadCues(session.id));
  }

  void _ended(LiveEnd why) {
    _generation++;
    _teardown();
    if (!ref.mounted) return;
    if (why == LiveEnd.endedByTeam) ref.read(activeLiveSessionProvider.notifier).adopt(null);
    state = LiveState(following: state.following, cues: state.cues, ended: why);
  }

  /// Back from a dropped network, socket or the background: is the session
  /// still on, where is it, and what changed in the set meanwhile.
  Future<void> resync() async {
    final session = state.session;
    if (session == null || _resyncing || !ref.read(isOnlineProvider)) return;
    _resyncing = true;
    final generation = _generation;
    try {
      final active = await ref.read(lineUpsServiceProvider).activeLiveSession();
      if (!ref.mounted || generation != _generation) return;
      if (active == null || active.id != session.id || active.lineUpId != lineUpId) {
        _ended(LiveEnd.endedByTeam);
        return;
      }
      final workspaceId = ref.read(activeWorkspaceIdProvider);
      if (workspaceId != null) {
        unawaited(ref.read(lineUpsRepositoryProvider).refreshDetail(lineUpId, workspaceId).catchError((Object _) {}));
      }
      // Joining again is idempotent and answers with the latest position.
      final fresh = await _service.join(lineUpId);
      if (!ref.mounted || generation != _generation) return;
      final position = _positionOf(fresh);
      _setLeader(fresh.leaderUserId, fresh.leaderName);
      state = state.copyWith(
        status: _realtime.isConnected ? LiveStatus.live : LiveStatus.reconnecting,
        session: () => fresh,
        position: () => position,
        moves: state.isSynced && position != state.position ? state.moves + 1 : state.moves,
        missed: state.drifted && position != state.position ? true : state.missed,
      );
      unawaited(_loadCues(fresh.id));
    } on ApiException {
      // Still flaky — the next reconnect tries again.
    } finally {
      _resyncing = false;
    }
  }

  void _teardown() {
    _channel?.cancel();
    _channel = null;
    _reconnected?.cancel();
    _reconnected = null;
    _connection?.cancel();
    _connection = null;
    _moveTimer?.cancel();
    _returnTimer?.cancel();
    _clearTyping();
  }

  // -- Moving together -----------------------------------------------------------

  static LivePosition _positionOf(LiveSession s) => LivePosition(
    songIndex: s.currentSongIndex,
    chordsSectionId: s.activeSectionIdChords,
    lyricsSectionId: s.activeSectionIdLyrics,
  );

  /// Where [current] goes when someone moves to [songIndex] / [sectionId] in
  /// [viewMode]. Mirrors the server: a new song clears both views' sections.
  static LivePosition _moved(LivePosition? current, int songIndex, String? sectionId, SongViewMode viewMode) {
    final sameSong = current?.songIndex == songIndex;
    return LivePosition(
      songIndex: songIndex,
      chordsSectionId: viewMode == SongViewMode.chords ? sectionId : (sameSong ? current?.chordsSectionId : null),
      lyricsSectionId: viewMode == SongViewMode.lyrics ? sectionId : (sameSong ? current?.lyricsSectionId : null),
    );
  }

  String? get _channelName => switch (state.session) {
    final session? => liveSessionChannel(session.id),
    null => null,
  };

  void _remember(Object? id) {
    if (id is! String) return;
    _whispered.add(id);
    if (_whispered.length > 64) _whispered.remove(_whispered.first);
  }

  /// Whether a broadcast is one this device already took by whisper.
  bool _seen(Object? id) => id is String && _whispered.remove(id);

  void _onMoved(Map<String, dynamic> data) {
    // Already here by whisper.
    if (_seen(data['move_id'])) return;
    _arrive(
      LivePosition(
        songIndex: (data['current_song_index'] as num?)?.toInt() ?? 0,
        chordsSectionId: data['active_section_id_chords'] as String?,
        lyricsSectionId: data['active_section_id_lyrics'] as String?,
      ),
    );
  }

  void _onWhisperedMove(Map<String, dynamic> data) {
    final index = (data['current_song_index'] as num?)?.toInt();
    if (index == null) return;
    // The server refuses anyone but the leader; so does everyone listening.
    if (state.isLed && (data['user_id'] as num?)?.toInt() != state.leaderId) return;
    _remember(data['move_id']);
    final mode = data['view_mode'] == 'lyrics' ? SongViewMode.lyrics : SongViewMode.chords;
    _arrive(_moved(state.position, index, data['active_section_id'] as String?, mode));
  }

  void _arrive(LivePosition position) {
    if (position == state.position) return;
    state = state.copyWith(
      position: () => position,
      moves: state.isSynced ? state.moves + 1 : state.moves,
      missed: state.drifted ? true : state.missed,
    );
  }

  /// This device moved (a song, a section): tell the team, if its moves
  /// go to the team. A deliberate tap goes [now]; anything that can fire
  /// in a burst (a scroll through songs) waits for it to settle.
  void move({required int songIndex, String? sectionId, required SongViewMode viewMode, bool now = false}) {
    if (!state.canDrive) return;
    final current = state.position;
    if (current != null && current.songIndex == songIndex && current.sectionFor(viewMode) == sectionId) return;

    state = state.copyWith(position: () => _moved(current, songIndex, sectionId, viewMode));
    _moveTimer?.cancel();
    void send() => _send(songIndex, sectionId, viewMode);
    now ? send() : _moveTimer = Timer(moveDebounce, send);
  }

  void _send(int songIndex, String? sectionId, SongViewMode viewMode) {
    final moveId = whisperId();
    if (_channelName case final channel?) {
      _realtime.whisper(channel, 'moved', {
        'move_id': moveId,
        'user_id': _me,
        'current_song_index': songIndex,
        'active_section_id': sectionId,
        'view_mode': viewMode.name,
      });
    }
    unawaited(
      _service
          .move(lineUpId, songIndex: songIndex, sectionId: sectionId, viewMode: viewMode, moveId: moveId)
          .then((_) {}, onError: (Object _) {}),
    );
  }

  /// Scrolled by hand while following a leader: hold their moves for a
  /// while. Called through a drag, so the idle clock restarts until the
  /// finger lifts and rests. Without a leader, scrolling just leads.
  void drift() {
    if (!state.followsLeader) return;
    if (!state.drifted) state = state.copyWith(drifted: true);
    _returnTimer?.cancel();
    final autoReturn = ref.read(performPrefsProvider).value?.liveAutoReturn ?? true;
    if (autoReturn) _returnTimer = Timer(autoReturnAfter, _autoReturn);
  }

  void _autoReturn() {
    if (!ref.mounted || !state.drifted) return;
    final here = ref.read(performCursorProvider(PerformSource.lineUp(lineUpId))).songIndex;
    // Nothing to catch up on: quietly follow again without moving the chart.
    state.missed || state.position?.songIndex != here ? backToLive() : resume();
  }

  /// Goes to where the team is and follows again.
  void backToLive() {
    _returnTimer?.cancel();
    state = state.copyWith(drifted: false, missed: false, moves: state.moves + 1);
  }

  /// Follows again from here, without moving the chart.
  void resume() {
    _returnTimer?.cancel();
    if (!state.drifted) return;
    state = state.copyWith(drifted: false, missed: false);
  }

  /// The "Follow live" switch. Turning it on goes to the team.
  void setFollowing(bool on) {
    _returnTimer?.cancel();
    state = state.copyWith(following: on, drifted: false, missed: false, moves: on ? state.moves + 1 : state.moves);
  }

  // -- Leading ---------------------------------------------------------------------

  /// Takes the lead, from whoever had it.
  Future<bool> takeLead() async {
    if (!state.isIn) return false;
    final analytics = ref.read(analyticsProvider);
    try {
      final session = await _service.lead(lineUpId);
      unawaited(analytics.track(AnalyticsEvent.liveSessionLed));
      if (ref.mounted) _setLeader(session.leaderUserId, session.leaderName);
      return true;
    } on ApiException {
      return false;
    }
  }

  /// Steps down: everyone following moves the team again.
  Future<bool> stepDown() async {
    if (!state.leading) return false;
    try {
      await _service.releaseLead(lineUpId);
      if (ref.mounted) _setLeader(null, null);
      return true;
    } on ApiException {
      return false;
    }
  }

  void _setLeader(int? id, String? name) {
    final leading = id != null && id == _me;
    final follows = id != null && !leading;
    if (!follows) _returnTimer?.cancel();
    state = state.copyWith(
      leaderId: () => id,
      leaderName: () => name,
      leading: leading,
      drifted: follows ? state.drifted : false,
      missed: follows ? state.missed : false,
    );
  }

  void _onMembers(List<Map<String, dynamic>> members) {
    final byUser = <int, LiveParticipant>{};
    for (final m in members) {
      final id = (m['user_id'] as num?)?.toInt();
      if (id != null) byUser[id] = LiveParticipant(userId: id, name: m['name'] as String? ?? 'Someone');
    }
    final list = byUser.values.toList()..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    state = state.copyWith(participants: list, status: state.isIn ? LiveStatus.live : state.status);
  }

  // -- Cues --------------------------------------------------------------------------

  /// The cues sent before we joined (or while we were away), folded in under
  /// the ones that arrived live. They show in the list, not as a banner.
  Future<void> _loadCues(int sessionId) async {
    try {
      final past = await _service.cues(lineUpId);
      if (!ref.mounted || state.session?.id != sessionId) return;
      final known = {for (final c in state.cues) c.id};
      final merged = [...state.cues, for (final c in past) if (!known.contains(c.id)) c]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      state = state.copyWith(cues: merged);
    } on ApiException {
      // The list fills in live; the history comes with the next resync.
    }
  }

  // -- Typing ------------------------------------------------------------------------

  /// Tells the others you're typing: a whisper, at most one every couple of
  /// seconds, nothing saved and nothing sent to the server.
  void typing() {
    final channel = _channelName;
    if (channel == null || !state.isIn) return;
    final now = DateTime.now();
    if (_typingSentAt case final at? when now.difference(at) < typingEvery) return;
    _typingSentAt = now;
    final user = ref.read(sessionControllerProvider).value?.user;
    if (user == null) return;
    _realtime.whisper(channel, 'typing', {'user_id': user.id, 'name': user.name});
  }

  void _onTyping(Map<String, dynamic> data) {
    final id = (data['user_id'] as num?)?.toInt();
    if (id == null || id == _me) return;
    final name = data['name'] as String? ?? 'Someone';
    _typingTimers[id]?.cancel();
    _typingTimers[id] = Timer(typingFor, () => _stopTyping(id));
    if (state.typing.any((p) => p.userId == id)) return;
    state = state.copyWith(typing: [...state.typing, LiveParticipant(userId: id, name: name)]);
  }

  void _stopTyping(int? id) {
    if (id == null) return;
    _typingTimers.remove(id)?.cancel();
    if (!ref.mounted || !state.typing.any((p) => p.userId == id)) return;
    state = state.copyWith(typing: [for (final p in state.typing) if (p.userId != id) p]);
  }

  void _clearTyping() {
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    _typingTimers.clear();
    if (ref.mounted && state.typing.isNotEmpty) state = state.copyWith(typing: const []);
  }

  void _onCue(LiveCue cue) {
    // Sending is the end of typing.
    _stopTyping(cue.senderId);
    if (state.cues.any((c) => c.id == cue.id)) return;
    state = state.copyWith(cues: [...state.cues, cue], incoming: () => cue);
  }

  /// Sends a cue to everyone; false when it didn't go.
  Future<bool> sendCue(LiveCueKind kind, String body) async {
    final text = body.trim();
    if (!state.isIn || text.isEmpty) return false;
    final position = state.position;
    final view = ref.read(performControllerProvider(PerformSource.lineUp(lineUpId))).viewMode;
    // Whispered first, so it shows on the others' screens at once; the save
    // (under the same id) reaches older clients and observers, and is the
    // same cue to everyone who already has it.
    final cue = LiveCue(
      id: uuidV4(),
      kind: kind,
      body: text,
      createdAt: DateTime.now(),
      senderId: _me,
      senderName: ref.read(sessionControllerProvider).value?.user.name,
      songIndex: position?.songIndex,
      sectionId: position?.sectionFor(view),
    );
    final whispered = switch (_channelName) {
      final channel? => _realtime.whisper(channel, 'cue', cue.toJson()),
      null => false,
    };
    if (whispered) state = state.copyWith(cues: [...state.cues, cue]);
    try {
      final saved = await _service.sendCue(
        lineUpId,
        kind,
        text,
        songIndex: cue.songIndex,
        sectionId: cue.sectionId,
        id: cue.id,
      );
      if (ref.mounted && !state.cues.any((c) => c.id == saved.id)) {
        state = state.copyWith(cues: [...state.cues, saved]);
      }
      return true;
    } on ApiException {
      return whispered;
    }
  }

  void dismissIncoming() => state = state.copyWith(incoming: () => null);

  void clearEnded() => state = state.copyWith(ended: () => null);

  // -- Team edits ----------------------------------------------------------------------

  /// Runs [apply] unless this user made the change (it's already here).
  void _fromTeammate(Map<String, dynamic> data, Future<void> Function(Map<String, dynamic>) apply) {
    final by = (data['updated_by_user_id'] as num?)?.toInt();
    if (by != null && by == _me) return;
    unawaited(apply(data).catchError((Object _) {}));
  }

  LineUpsRepository get _lineUps => ref.read(lineUpsRepositoryProvider);

  Future<void> _applyTransposition(Map<String, dynamic> data) => _lineUps.applyRemoteTransposition(
    lineUpId,
    (data['line_up_song_id'] as num).toInt(),
    (data['transposition'] as num).toInt(),
  );

  Future<void> _applyNotes(Map<String, dynamic> data) => _lineUps.applyRemoteNotes(
    lineUpId,
    (data['line_up_song_id'] as num).toInt(),
    [for (final n in (data['notes'] as List? ?? const []).cast<Map<String, dynamic>>()) LineUpSongNote.fromJson(n)],
  );

  Future<void> _applyArrangement(Map<String, dynamic> data) => _lineUps.applyRemoteArrangement(
    lineUpId,
    (data['line_up_song_id'] as num).toInt(),
    data['field'] == 'lyrics' ? SongArrangementView.lyrics : SongArrangementView.chords,
    SectionArrangementField.fromJson((data['arrangement'] as Map).cast<String, dynamic>()),
  );

  Future<void> _applySong(Map<String, dynamic> data) async {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    final song = data['song'];
    if (workspaceId == null || song is! Map) return;
    await ref.read(songsRepositoryProvider).applyRemote(Song.fromJson(song.cast<String, dynamic>()), workspaceId);
  }
}
