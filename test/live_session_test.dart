import 'dart:convert';

import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/device/screen_awake.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/application/line_up_detail_controller.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/live_session.dart';
import 'package:daloy_flutter/features/live/application/live_session_controller.dart';
import 'package:daloy_flutter/features/live/domain/live_cue.dart';
import 'package:daloy_flutter/features/live/domain/live_state.dart';
import 'package:daloy_flutter/features/live/presentation/live_widgets.dart';
import 'package:daloy_flutter/features/perform/application/perform_controller.dart';
import 'package:daloy_flutter/features/perform/data/perform_prefs_repository.dart';
import 'package:daloy_flutter/features/perform/presentation/perform_screen.dart';
import 'package:daloy_flutter/features/songs/domain/display_prefs.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

const _channel = 'presence-live-session.5';
const _chart = 'Verse:\n[D]You call me out\n\nChorus:\n[G]I will call\n\nBridge:\n[Bm]Spirit lead me';

Map<String, dynamic> _song(int id, String title) => {
  'id': id,
  'title': title,
  'artist': 'Hillsong',
  'key': 'D',
  'transposition': 0,
  'bpm': 72,
  'time_signature': '4/4',
  'content': _chart,
  'lyrics': 'You call me out',
  'is_public': false,
  'created_at': '2026-10-15T08:00:00+00:00',
};

Map<String, dynamic> _detail() => {
  'id': 7,
  'title': 'Sunday Service',
  'date': '2999-01-04',
  'worship_leader': 'Ana',
  'songs_count': 2,
  'songs': [
    {'line_up_song_id': 901, 'order': 0, 'transposition': 0, 'song': _song(41, 'Oceans'), 'section_arrangement': null},
    {
      'line_up_song_id': 902,
      'order': 1,
      'transposition': 0,
      'song': _song(42, 'Cornerstone'),
      'section_arrangement': null,
    },
  ],
};

/// `LiveSessionData`, exactly as the API sends it.
Map<String, dynamic> _sessionJson({int lineUpId = 7, int song = 0, String? chords, int count = 2, int? leader}) => {
  'id': 5,
  'line_up_id': lineUpId,
  'current_song_index': song,
  'active_section_id_chords': chords,
  'active_section_id_lyrics': null,
  'participant_count': count,
  'started_by_user_id': 2,
  'started_by_user_name': 'Ben Cruz',
  'started_at': '2026-10-16T09:00:00+00:00',
  'leader_user_id': leader,
  'leader_name': leader == null ? null : (leader == 1 ? 'Ana Reyes' : 'Ben Cruz'),
};

LiveSession _session({int lineUpId = 7, int? leader}) =>
    LiveSession.fromJson(_sessionJson(lineUpId: lineUpId, leader: leader));

void main() {
  late FakeApiAdapter api;
  late FakeRealtime realtime;
  late Map<String, dynamic> joined;

  setUp(() {
    realtime = FakeRealtime();
    joined = _sessionJson();
    api = FakeApiAdapter({
      'GET /api/line-ups/7': (_) => FakeApiAdapter.ok(_detail()),
      'GET /api/line-ups/7/line-up-songs/capos': (_) => FakeApiAdapter.ok({'capos': <Object>[]}),
      'POST /api/line-ups/7/live-session/join': (_) => FakeApiAdapter.ok(joined),
      'POST /api/line-ups/7/live-session/leave': (_) => FakeApiAdapter.ok(_sessionJson(count: 1)),
      'DELETE /api/line-ups/7/live-session': (_) => FakeApiAdapter.ok(null),
      'PATCH /api/line-ups/7/live-session': (_) => FakeApiAdapter.ok(joined),
      'GET /api/live-session': (_) => FakeApiAdapter.ok(joined),
      'POST /api/line-ups/7/live-session/cues': (r) {
        final body = r.data as Map<String, dynamic>;
        return FakeApiAdapter.ok({
          'id': body['id'] ?? 'cue-mine',
          'kind': body['kind'],
          'body': body['body'],
          'sender_name': 'Ana Reyes',
          'created_at': 1792141200000,
          'section_id': body['section_id'],
          'song_index': body['song_index'],
        });
      },
    });
  });

  List<String> calls(String method, String path) => [
    for (final r in api.requests)
      if (r.method == method && r.path == path) jsonEncode(r.data),
  ];

  Future<ProviderContainer> container({LiveSession? live, List<Override> extra = const []}) async {
    final storage = MemoryStorage()
      ..values['daloy.token'] = 'abc'
      ..values['daloy.workspace_id'] = '1'
      ..values['daloy.user'] = jsonEncode(userJson());
    final c = await createTestContainer(
      api,
      storage: storage,
      realtime: realtime,
      liveSession: live,
      overrides: [
        activeWorkspaceIdProvider.overrideWith((ref) => 1),
        isOnlineProvider.overrideWithValue(true),
        ...extra,
      ],
    );
    await c.read(sessionControllerProvider.future);
    final db = c.read(appDatabaseProvider);
    await db
        .into(db.lineUps)
        .insert(
          LineUpsCompanion.insert(
            id: const Value(7),
            workspaceId: 1,
            title: 'Sunday Service',
            date: '2999-01-04',
            songsCount: const Value(2),
          ),
        );
    await c.read(lineUpsRepositoryProvider).refreshDetail(7, 1);
    return c;
  }

  /// Opens the live controller (as Perform does) and lets it settle.
  Future<LiveSessionController> open(ProviderContainer c) async {
    final sub = c.listen(liveSessionControllerProvider(7), (_, _) {});
    final perform = c.listen(performControllerProvider(PerformSource.lineUp(7)), (_, _) {});
    addTearDown(sub.close);
    addTearDown(perform.close);
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    return c.read(liveSessionControllerProvider(7).notifier);
  }

  LiveState read(ProviderContainer c) => c.read(liveSessionControllerProvider(7));

  group('joining', () {
    test('Perform joins a session already running for its line-up, and shows who is in', () async {
      final c = await container(live: _session());
      await open(c);

      expect(calls('POST', '/api/line-ups/7/live-session/join'), hasLength(1));
      expect(read(c).status, LiveStatus.live);
      expect(realtime.channels, contains(_channel));
      expect(read(c).position?.songIndex, 0);

      // One person on two devices counts once; sorted by name.
      realtime.setMembers(_channel, [
        {'id': '2:a', 'name': 'Ben Cruz', 'user_id': 2},
        {'id': '1:b', 'name': 'Ana Reyes', 'user_id': 1},
        {'id': '2:c', 'name': 'Ben Cruz', 'user_id': 2},
      ]);
      expect([for (final p in read(c).participants) p.name], ['Ana Reyes', 'Ben Cruz']);
      expect(read(c).count, 2);
    });

    test('alone, nothing is joined until "Go live"', () async {
      final c = await container();
      final live = await open(c);
      expect(read(c).status, LiveStatus.solo);
      expect(api.requests.where((r) => r.path.contains('live-session')), isEmpty);

      expect(await live.join(), isTrue);
      expect(read(c).isLive, isTrue);
      expect(c.read(activeLiveSessionProvider).value?.id, 5);
    });

    test('going live is refused while another line-up is live', () async {
      final c = await container(live: _session(lineUpId: 99));
      final live = await open(c);
      expect(read(c).invite, isNull);
      expect(await live.join(), isFalse);
      expect(calls('POST', '/api/line-ups/7/live-session/join'), isEmpty);
    });

    test('leaving keeps the session going for the others, offered again', () async {
      final c = await container(live: _session());
      final live = await open(c);
      await live.leave();
      expect(calls('POST', '/api/line-ups/7/live-session/leave'), hasLength(1));
      expect(read(c).status, LiveStatus.solo);
      expect(read(c).ended, LiveEnd.left);
      expect(realtime.channels, isNot(contains(_channel)));
      await pumpEventQueue();
      expect(read(c).invite?.id, 5);
    });

    test('the team ending it, or it moving to another line-up, ends it here', () async {
      final c = await container(live: _session());
      await open(c);
      realtime.emit(_channel, 'session.ended', {'line_up_id': 7});
      expect(read(c).status, LiveStatus.solo);
      expect(read(c).ended, LiveEnd.endedByTeam);
      expect(c.read(activeLiveSessionProvider).value, isNull);
    });
  });

  group('moving together', () {
    test('a team move goes to this device when following', () async {
      final c = await container(live: _session());
      await open(c);
      final before = read(c).moves;
      realtime.emit(_channel, 'state.updated', {
        'current_song_index': 1,
        'active_section_id_chords': 'song-902-section-3',
        'active_section_id_lyrics': null,
        'updated_by_user_id': 2,
      });
      expect(read(c).moves, before + 1);
      expect(read(c).position?.sectionFor(SongViewMode.chords), 'song-902-section-3');
    });

    test('following a leader, scrolled away, their moves are held until "Back to live"', () async {
      joined = _sessionJson(leader: 2);
      final c = await container(live: _session(leader: 2));
      final live = await open(c);
      live.drift();
      final before = read(c).moves;
      realtime.emit(_channel, 'state.updated', {
        'current_song_index': 1,
        'active_section_id_chords': null,
        'active_section_id_lyrics': null,
        'updated_by_user_id': 2,
      });
      expect(read(c).moves, before);
      expect(read(c).missed, isTrue);

      live.backToLive();
      expect(read(c).drifted, isFalse);
      expect(read(c).moves, before + 1);
    });

    test('with no leader, scrolling never drifts', () async {
      final c = await container(live: _session());
      final live = await open(c);
      live.drift();
      expect(read(c).drifted, isFalse);
    });

    test('a move is sent once, after the taps settle, in the API shape', () async {
      final c = await container(live: _session());
      final live = await open(c);
      live.move(songIndex: 1, viewMode: SongViewMode.chords);
      live.move(songIndex: 1, sectionId: 'song-902-section-0', viewMode: SongViewMode.chords);
      // Already there: nothing to send.
      live.move(songIndex: 1, sectionId: 'song-902-section-0', viewMode: SongViewMode.chords);
      await Future<void>.delayed(LiveSessionController.moveDebounce + const Duration(milliseconds: 50));
      final sent = calls('PATCH', '/api/line-ups/7/live-session');
      expect(sent, hasLength(1));
      final body = jsonDecode(sent.single) as Map<String, dynamic>;
      expect(body, {
        'current_song_index': 1,
        'active_section_id': 'song-902-section-0',
        'view_mode': 'chords',
        'move_id': isA<String>(),
      });
      // The same move went straight to the team, under the same id.
      expect(realtime.whispers, hasLength(1));
      expect(realtime.whispers.single, startsWith('$_channel client-moved '));
      expect(realtime.whispers.single, contains('"move_id":"${body['move_id']}"'));
      expect(realtime.whispers.single, contains('"active_section_id":"song-902-section-0"'));
    });

    test('a tapped section goes at once', () async {
      final c = await container(live: _session());
      final live = await open(c);
      live.move(songIndex: 0, sectionId: 'song-901-section-1', viewMode: SongViewMode.chords, now: true);
      expect(realtime.whispers, hasLength(1));
      await pumpEventQueue();
      expect(calls('PATCH', '/api/line-ups/7/live-session'), hasLength(1));
    });

    test("a teammate's whispered move lands at once; its broadcast is skipped", () async {
      final c = await container(live: _session());
      await open(c);
      final before = read(c).moves;
      realtime.emit(_channel, 'client-moved', {
        'move_id': 'm1',
        'user_id': 2,
        'current_song_index': 1,
        'active_section_id': 'song-902-section-1',
        'view_mode': 'chords',
      });
      expect(read(c).moves, before + 1);
      expect(read(c).position?.sectionFor(SongViewMode.chords), 'song-902-section-1');

      // Someone else moves meanwhile; the first move's late broadcast mustn't undo it.
      realtime.emit(_channel, 'client-moved', {
        'move_id': 'm2',
        'user_id': 3,
        'current_song_index': 1,
        'active_section_id': 'song-902-section-2',
        'view_mode': 'chords',
      });
      realtime.emit(_channel, 'state.updated', {
        'current_song_index': 1,
        'active_section_id_chords': 'song-902-section-1',
        'active_section_id_lyrics': null,
        'updated_by_user_id': 2,
        'move_id': 'm1',
      });
      expect(read(c).position?.sectionFor(SongViewMode.chords), 'song-902-section-2');
      expect(read(c).moves, before + 2);

      // A broadcast nobody whispered (an older client) still moves everyone.
      realtime.emit(_channel, 'state.updated', {
        'current_song_index': 0,
        'active_section_id_chords': null,
        'active_section_id_lyrics': null,
        'updated_by_user_id': 4,
        'move_id': null,
      });
      expect(read(c).position?.songIndex, 0);
    });

    test('a whispered move in the other view keeps my section; a new song clears both', () async {
      final c = await container(live: _session());
      await open(c);
      realtime.emit(_channel, 'client-moved', {
        'move_id': 'm1',
        'user_id': 2,
        'current_song_index': 0,
        'active_section_id': 'song-901-section-1',
        'view_mode': 'chords',
      });
      realtime.emit(_channel, 'client-moved', {
        'move_id': 'm2',
        'user_id': 3,
        'current_song_index': 0,
        'active_section_id': 'song-901-section-2',
        'view_mode': 'lyrics',
      });
      expect(read(c).position?.chordsSectionId, 'song-901-section-1');
      expect(read(c).position?.lyricsSectionId, 'song-901-section-2');

      realtime.emit(_channel, 'client-moved', {
        'move_id': 'm3',
        'user_id': 2,
        'current_song_index': 1,
        'active_section_id': null,
        'view_mode': 'chords',
      });
      expect(read(c).position?.chordsSectionId, isNull);
      expect(read(c).position?.lyricsSectionId, isNull);
    });

    test('while someone leads, whispers from anyone else are ignored', () async {
      joined = _sessionJson(leader: 2);
      final c = await container(live: _session(leader: 2));
      await open(c);
      final before = read(c).position;
      realtime.emit(_channel, 'client-moved', {
        'move_id': 'm1',
        'user_id': 3,
        'current_song_index': 1,
        'active_section_id': null,
        'view_mode': 'chords',
      });
      expect(read(c).position, before);
      realtime.emit(_channel, 'client-moved', {
        'move_id': 'm2',
        'user_id': 2,
        'current_song_index': 1,
        'active_section_id': null,
        'view_mode': 'chords',
      });
      expect(read(c).position?.songIndex, 1);
    });

    test('leading is opt-in; while someone else leads, my moves stay here', () async {
      final c = await container(live: _session());
      final live = await open(c);
      expect(read(c).isLed, isFalse);
      expect(read(c).canDrive, isTrue);

      // Ben takes the lead.
      realtime.emit(_channel, 'leader.updated', {
        'leader_user_id': 2,
        'leader_name': 'Ben Cruz',
        'updated_by_user_id': 2,
      });
      expect(read(c).leaderName, 'Ben Cruz');
      expect(read(c).followsLeader, isTrue);
      live.move(songIndex: 1, viewMode: SongViewMode.chords);
      await Future<void>.delayed(LiveSessionController.moveDebounce + const Duration(milliseconds: 50));
      expect(calls('PATCH', '/api/line-ups/7/live-session'), isEmpty);

      // I take over, then step down.
      api.routes['POST /api/line-ups/7/live-session/lead'] = (_) => FakeApiAdapter.ok(_sessionJson(leader: 1));
      api.routes['DELETE /api/line-ups/7/live-session/lead'] = (_) => FakeApiAdapter.ok(_sessionJson());
      expect(await live.takeLead(), isTrue);
      expect(read(c).leading, isTrue);
      expect(read(c).canDrive, isTrue);
      live.move(songIndex: 1, viewMode: SongViewMode.chords);
      await Future<void>.delayed(LiveSessionController.moveDebounce + const Duration(milliseconds: 50));
      expect(calls('PATCH', '/api/line-ups/7/live-session'), hasLength(1));

      expect(await live.stepDown(), isTrue);
      expect(read(c).isLed, isFalse);
      expect(calls('DELETE', '/api/line-ups/7/live-session/lead'), hasLength(1));
    });

    test('with "Follow live" off, nothing goes either way', () async {
      final c = await container(live: _session());
      final live = await open(c);
      live.setFollowing(false);
      final before = read(c).moves;
      realtime.emit(_channel, 'state.updated', {
        'current_song_index': 1,
        'active_section_id_chords': null,
        'active_section_id_lyrics': null,
        'updated_by_user_id': 2,
      });
      live.move(songIndex: 0, viewMode: SongViewMode.chords);
      await Future<void>.delayed(LiveSessionController.moveDebounce + const Duration(milliseconds: 50));
      expect(read(c).moves, before);
      expect(calls('PATCH', '/api/line-ups/7/live-session'), isEmpty);

      live.setFollowing(true);
      expect(read(c).moves, before + 1);
    });

    test('back from a dropped socket, it resyncs to where the team is', () async {
      final c = await container(live: _session());
      await open(c);
      realtime.drop();
      await pumpEventQueue();
      expect(read(c).status, LiveStatus.reconnecting);

      joined = _sessionJson(song: 1, count: 3);
      final before = read(c).moves;
      realtime.reconnect();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(read(c).status, LiveStatus.live);
      expect(read(c).position?.songIndex, 1);
      expect(read(c).moves, before + 1);
    });

    test('a resync that finds the session gone ends it here', () async {
      final c = await container(live: _session());
      await open(c);
      joined = _sessionJson();
      api.routes['GET /api/live-session'] = (_) => FakeApiAdapter.ok(null);
      await c.read(liveSessionControllerProvider(7).notifier).resync();
      expect(read(c).status, LiveStatus.solo);
      expect(read(c).ended, LiveEnd.endedByTeam);
    });
  });

  group('cues', () {
    test('team cues arrive once; mine go out with where I am', () async {
      final c = await container(live: _session());
      final live = await open(c);
      final cue = {
        'id': 'cue-1',
        'kind': 'preset',
        'body': 'Bridge',
        'sender_name': 'Ben Cruz',
        'created_at': 1792141200000,
        'section_id': null,
        'song_index': 0,
      };
      realtime.emit(_channel, 'cue.sent', cue);
      realtime.emit(_channel, 'cue.sent', cue);
      expect(read(c).cues, hasLength(1));
      expect(read(c).incoming?.body, 'Bridge');
      expect(read(c).incoming?.senderName, 'Ben Cruz');

      expect(await live.sendCue(LiveCueKind.text, '  Watch me for the ending '), isTrue);
      // Whispered first, then saved under the same id; it shows here once.
      expect(realtime.whispers, hasLength(1));
      expect(realtime.whispers.single, startsWith('$_channel client-cue '));
      final whispered = jsonDecode(realtime.whispers.single.split(' client-cue ').last) as Map<String, dynamic>;
      expect(whispered['body'], 'Watch me for the ending');
      expect(whispered['sender_name'], 'Ana Reyes');
      expect(calls('POST', '/api/line-ups/7/live-session/cues'), [
        jsonEncode({
          'kind': 'text',
          'body': 'Watch me for the ending',
          'song_index': 0,
          'section_id': null,
          'id': whispered['id'],
        }),
      ]);
      expect([for (final c in read(c).cues) c.id], ['cue-1', whispered['id']]);
    });

    test("a teammate's whispered cue shows once, broadcast and all", () async {
      final c = await container(live: _session());
      await open(c);
      final cue = {
        'id': '7d9f3c2a-1b4e-4f6a-9c8d-2e5b7a1f0c3d',
        'kind': 'preset',
        'body': 'Last chorus',
        'sender_name': 'Ben Cruz',
        'created_at': 1792141200000,
        'section_id': null,
        'song_index': 1,
      };
      realtime.emit(_channel, 'client-cue', cue);
      expect(read(c).incoming?.body, 'Last chorus');
      realtime.emit(_channel, 'cue.sent', cue);
      expect(read(c).cues, hasLength(1));
    });

    test('the lead changing hands reads the same as on the web', () {
      const ana = LiveParticipant(userId: 1, name: 'Ana');
      const ben = LiveParticipant(userId: 2, name: 'Ben');
      const cy = LiveParticipant(userId: 3, name: 'Cy');
      expect(leaderChangeMessage(previous: null, next: null, me: 1), isNull);
      expect(leaderChangeMessage(previous: ben, next: ben, me: 1), isNull);
      expect(leaderChangeMessage(previous: null, next: ben, me: 1), 'Ben is leading.');
      expect(leaderChangeMessage(previous: cy, next: ben, me: 1), 'Ben took over from Cy.');
      expect(
        leaderChangeMessage(previous: ben, next: null, me: 1),
        'Ben stopped leading. Everyone moves the team again.',
      );
      expect(leaderChangeMessage(previous: null, next: ana, me: 1), 'You’re leading. Only your moves go to the team.');
      expect(
        leaderChangeMessage(previous: ana, next: null, me: 1),
        'You stopped leading. Everyone moves the team again.',
      );
      expect(leaderChangeMessage(previous: ana, next: ben, me: 1), 'Ben is leading.');
    });

    test('the web presets keep their bodies', () {
      expect([for (final p in liveCuePresets) p.body], containsAll(['↩ Repeat', 'Bridge', 'Outro', 'Vamp', 'Stop']));
      expect(liveEmojiCues, ['👏', '🔥', '🙌', '⏸️', '▶️']);
    });
  });

  group('team edits', () {
    Future<List<LineUpSongRow>> rows(ProviderContainer c) {
      final db = c.read(appDatabaseProvider);
      return (db.select(db.lineUpSongs)..where((t) => t.lineUpId.equals(7))).get();
    }

    test('key, notes and arrangement changes land in Drift; my own echo is ignored', () async {
      final c = await container(live: _session());
      await open(c);

      realtime.emit(_channel, 'transposition.updated', {
        'line_up_song_id': 901,
        'transposition': 2,
        'updated_by_user_id': 2,
      });
      realtime.emit(_channel, 'transposition.updated', {
        'line_up_song_id': 902,
        'transposition': 5,
        'updated_by_user_id': 1,
      });
      realtime.emit(_channel, 'notes.updated', {
        'line_up_song_id': 901,
        'notes': [
          {'id': 'n1', 'line': 1, 'text': 'Soft'},
        ],
        'updated_by_user_id': 2,
      });
      realtime.emit(_channel, 'section-arrangement.updated', {
        'line_up_song_id': 901,
        'field': 'chords',
        'arrangement': {
          'order': [2, 0],
          'removed': [1],
        },
        'updated_by_user_id': 2,
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final saved = await rows(c);
      expect(saved[0].transposition, 2);
      expect(saved[1].transposition, 0);
      expect(LineUpsRepository.decodeNotes(saved[0].notes).single.text, 'Soft');
      expect(LineUpsRepository.decodeArrangement(saved[0].sectionArrangement)?.chords.order, [2, 0]);
    });

    test("a teammate's whispered key lands at once; a late broadcast of it doesn't undo a newer one", () async {
      final c = await container(live: _session());
      await open(c);
      realtime.emit(_channel, 'client-transposed', {
        'change_id': 'k1',
        'user_id': 2,
        'line_up_song_id': 901,
        'transposition': 2,
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect((await rows(c))[0].transposition, 2);

      realtime.emit(_channel, 'client-transposed', {
        'change_id': 'k2',
        'user_id': 3,
        'line_up_song_id': 901,
        'transposition': 4,
      });
      realtime.emit(_channel, 'transposition.updated', {
        'line_up_song_id': 901,
        'transposition': 2,
        'updated_by_user_id': 2,
        'change_id': 'k1',
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect((await rows(c))[0].transposition, 4);
    });

    test('changing the key while live whispers each tap, and the save carries the last one', () async {
      api.routes['PATCH /api/line-ups/7/line-up-songs/901'] = (_) => FakeApiAdapter.ok(null);
      final c = await container(live: _session());
      await open(c);
      final detail = c.listen(lineUpDetailControllerProvider(7), (_, _) {});
      addTearDown(detail.close);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final notifier = c.read(lineUpDetailControllerProvider(7).notifier);
      notifier.transposeUp(0);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      notifier.transposeUp(0);
      expect(realtime.whispers, hasLength(2));
      expect(realtime.whispers.last, startsWith('$_channel client-transposed '));
      final last = jsonDecode(realtime.whispers.last.split(' client-transposed ').last) as Map<String, dynamic>;
      expect(last['line_up_song_id'], 901);
      expect(last['transposition'], 2);

      await Future<void>.delayed(const Duration(milliseconds: 1400));
      expect(calls('PATCH', '/api/line-ups/7/line-up-songs/901'), [
        jsonEncode({'transposition': 2, 'change_id': last['change_id']}),
      ]);
    });

    test('a song saved by a teammate replaces the copy here', () async {
      final c = await container(live: _session());
      await open(c);
      realtime.emit(_channel, 'song.updated', {
        'song': {..._song(41, 'Oceans (Where Feet May Fail)'), 'key': 'E'},
        'updated_by_user_id': 2,
      });
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final db = c.read(appDatabaseProvider);
      final song = await (db.select(db.songs)..where((t) => t.id.equals(41))).getSingle();
      expect(song.title, 'Oceans (Where Feet May Fail)');
      expect(song.key, 'E');
    });
  });

  group('screen', () {
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<ProviderContainer> pump(WidgetTester tester, {LiveSession? live}) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      late ProviderContainer c;
      await tester.runAsync(() async {
        c = await container(live: live, extra: [screenAwakeProvider.overrideWithValue(_NoAwake())]);
        await c.read(performPrefsRepositoryProvider).setAutoHide(false);
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: DaloyTheme.light(),
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
            home: const PerformScreen(source: PerformSource.lineUp(7)),
          ),
        ),
      );
      await settle(tester);
      return c;
    }

    testWidgets('alone: "Go live" is in the top bar, and there are no cues', (tester) async {
      await pump(tester);
      expect(find.bySemanticsLabel('Go live'), findsOneWidget);
      expect(find.bySemanticsLabel('Cues'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('live: the count, the cue pad, a team cue and a team move', (tester) async {
      final c = await pump(tester, live: _session());
      realtime.setMembers(_channel, [
        {'id': '1:a', 'name': 'Ana Reyes', 'user_id': 1},
        {'id': '2:b', 'name': 'Ben Cruz', 'user_id': 2},
      ]);
      await tester.pump();
      expect(find.text('LIVE · 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Cues'), findsOneWidget);

      realtime.emit(_channel, 'cue.sent', {
        'id': 'cue-1',
        'kind': 'preset',
        'body': 'Last chorus',
        'sender_name': 'Ben Cruz',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'section_id': null,
        'song_index': 0,
      });
      await tester.pump();
      expect(find.byType(LiveCueBanner), findsOneWidget);
      expect(find.text('Last chorus'), findsOneWidget);
      // It leaves on its own.
      await tester.pump(LiveCueBanner.showFor + const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.text('Last chorus'), findsNothing);

      realtime.emit(_channel, 'state.updated', {
        'current_song_index': 1,
        'active_section_id_chords': null,
        'active_section_id_lyrics': null,
        'updated_by_user_id': 2,
      });
      await settle(tester);
      expect(c.read(performControllerProvider(PerformSource.lineUp(7))).songIndex, 1);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a web highlight of the next song\'s intro, sent with the song at the top, lands here', (tester) async {
      final c = await pump(tester, live: _session());
      // What the web sent before its fix: song 1 (index 0), section from song 2.
      realtime.emit(_channel, 'state.updated', {
        'current_song_index': 0,
        'active_section_id_chords': 'song-902-section-0',
        'active_section_id_lyrics': null,
        'updated_by_user_id': 2,
      });
      await settle(tester);
      await tester.runAsync(
        () => Future<void>.delayed(LiveSessionController.moveDebounce + const Duration(milliseconds: 50)),
      );
      final perform = c.read(performControllerProvider(PerformSource.lineUp(7)));
      expect(perform.songIndex, 1);
      expect(perform.activeSectionId, 'song-902-section-0');
      // Going there isn't sent back (it would clear the team's highlight).
      expect(calls('PATCH', '/api/line-ups/7/live-session'), isEmpty);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('a toast says when someone starts or stops leading', (tester) async {
      await pump(tester, live: _session());
      expect(find.text('Ben Cruz is leading.'), findsNothing);

      realtime.emit(_channel, 'leader.updated', {
        'leader_user_id': 2,
        'leader_name': 'Ben Cruz',
        'updated_by_user_id': 2,
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Ben Cruz is leading.'), findsOneWidget);

      realtime.emit(_channel, 'leader.updated', {'leader_user_id': null, 'leader_name': null, 'updated_by_user_id': 2});
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Ben Cruz stopped leading. Everyone moves the team again.'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('no leader: scrolling into the next song takes the team along', (tester) async {
      final c = await pump(tester, live: _session());
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await settle(tester);
      await tester.runAsync(
        () => Future<void>.delayed(LiveSessionController.moveDebounce + const Duration(milliseconds: 50)),
      );
      expect(c.read(performControllerProvider(PerformSource.lineUp(7))).songIndex, 1);
      expect(c.read(liveSessionControllerProvider(7)).drifted, isFalse);
      expect(calls('PATCH', '/api/line-ups/7/live-session').last, contains('"current_song_index":1'));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('following a leader, scrolled away: "Back to live" takes you to them', (tester) async {
      joined = _sessionJson(leader: 2);
      final c = await pump(tester, live: _session(leader: 2));
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -40));
      await settle(tester);
      expect(c.read(liveSessionControllerProvider(7)).drifted, isTrue);

      realtime.emit(_channel, 'state.updated', {
        'current_song_index': 1,
        'active_section_id_chords': null,
        'active_section_id_lyrics': null,
        'updated_by_user_id': 2,
      });
      await settle(tester);
      expect(c.read(performControllerProvider(PerformSource.lineUp(7))).songIndex, 0);
      expect(find.text('Back to live'), findsOneWidget);

      await tester.tap(find.text('Back to live'));
      await settle(tester);
      expect(c.read(performControllerProvider(PerformSource.lineUp(7))).songIndex, 1);
      expect(find.text('Back to live'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });
}

class _NoAwake extends ScreenAwake {
  @override
  Future<void> hold() async {}

  @override
  Future<void> release() async {}
}
