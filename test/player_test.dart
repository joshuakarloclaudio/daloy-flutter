import 'dart:async';

import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/device/screen_awake.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/perform/application/perform_controller.dart';
import 'package:daloy_flutter/features/perform/data/perform_prefs_repository.dart';
import 'package:daloy_flutter/features/perform/presentation/perform_screen.dart';
import 'package:daloy_flutter/features/player/application/music_player_controller.dart';
import 'package:daloy_flutter/features/player/data/youtube_engine.dart';
import 'package:daloy_flutter/features/player/domain/player_queue.dart';
import 'package:daloy_flutter/features/player/presentation/mini_player.dart';
import 'package:daloy_flutter/features/player/presentation/now_playing_screen.dart';
import 'package:daloy_flutter/features/player/presentation/perform_player_strip.dart';
import 'package:daloy_flutter/features/player/presentation/player_video_slot.dart';
import 'package:daloy_flutter/features/practice/application/practice_controller.dart';
import 'package:daloy_flutter/features/practice/data/click_output.dart';
import 'package:daloy_flutter/features/songs/domain/youtube_link.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

/// A YouTube player without a WebView: records what it's told, and the test
/// says what YouTube does.
class FakeEngine implements YouTubeEngine {
  final calls = <String>[];

  /// How many times the video was made; moving it between slots keeps it.
  var surfaces = 0;
  final _events = StreamController<EngineEvent>.broadcast(sync: true);
  Duration at = Duration.zero;
  bool disposed = false;

  void emit(EngineEvent event) => _events.add(event);

  @override
  Stream<EngineEvent> get events => _events.stream;

  @override
  Future<void> load(String videoId) async => calls.add('load $videoId');

  @override
  Future<void> cue(String videoId) async => calls.add('cue $videoId');

  @override
  Future<void> play() async => calls.add('play');

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> seekTo(Duration position) async => calls.add('seek ${position.inSeconds}');

  @override
  Future<Duration> position() async => at;

  @override
  Widget buildSurface(BuildContext context) => _FakeSurface(onCreate: () => surfaces++);

  @override
  Future<void> dispose() async => disposed = true;
}

class _FakeSurface extends StatefulWidget {
  const _FakeSurface({required this.onCreate});

  final VoidCallback onCreate;

  @override
  State<_FakeSurface> createState() => _FakeSurfaceState();
}

class _FakeSurfaceState extends State<_FakeSurface> {
  @override
  void initState() {
    super.initState();
    widget.onCreate();
  }

  @override
  Widget build(BuildContext context) => const ColoredBox(key: ValueKey('video'), color: Colors.black);
}

const _a = 'aaaaaaaaaaa';
const _c = 'ccccccccccc';

Map<String, dynamic> _song(int id, String title, {String? youtube, String? spotify}) => {
  'id': id,
  'title': title,
  'artist': 'Hillsong',
  'key': 'D',
  'transposition': 0,
  'bpm': 72,
  'time_signature': '4/4',
  'content': 'Verse:\n[D]You call me out\n[A]upon the waters',
  'lyrics': 'You call me out',
  'youtube_url': youtube,
  'spotify_url': spotify,
  'is_public': false,
  'created_at': '2026-10-15T08:00:00+00:00',
};

/// Three songs; the middle one has no link.
Map<String, dynamic> _detail() => {
  'id': 7,
  'title': 'Sunday Service',
  'date': '2999-01-04',
  'worship_leader': 'Ana',
  'songs_count': 3,
  'songs': [
    {
      'line_up_song_id': 901,
      'order': 0,
      'transposition': 2,
      'song': _song(41, 'Oceans', youtube: 'https://youtu.be/$_a'),
    },
    {'line_up_song_id': 902, 'order': 1, 'transposition': 0, 'song': _song(42, 'Cornerstone')},
    {
      'line_up_song_id': 903,
      'order': 2,
      'transposition': 0,
      'song': _song(
        43,
        'Way Maker',
        youtube: 'https://www.youtube.com/watch?v=$_c',
        spotify: 'https://open.spotify.com/x',
      ),
    },
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('YouTube links', () {
    test('every common form resolves to the video', () {
      for (final url in [
        'https://www.youtube.com/watch?v=$_a',
        'youtube.com/watch?v=$_a&t=30',
        'https://m.youtube.com/watch?v=$_a',
        'https://youtu.be/$_a?si=x',
        'https://www.youtube.com/shorts/$_a',
        'https://www.youtube.com/embed/$_a',
        'https://www.youtube.com/live/$_a',
        'https://music.youtube.com/watch?v=$_a',
        '  $_a  ',
      ]) {
        expect(resolveYouTubeVideoId(url), _a, reason: url);
      }
    });

    test('anything else is refused', () {
      for (final url in ['', 'https://vimeo.com/123', 'https://youtu.be/short', 'not a link', 'https://youtube.com/']) {
        expect(resolveYouTubeVideoId(url), isNull, reason: url);
      }
      expect(canonicalYouTubeUrl(_a), 'https://www.youtube.com/watch?v=$_a');
    });

    test('the queue skips songs without a link, and videos that won’t play', () {
      const tracks = [
        PlayerTrack(index: 0, songId: 1, title: 'A', videoId: _a),
        PlayerTrack(index: 1, songId: 2, title: 'B'),
        PlayerTrack(index: 2, songId: 3, title: 'C', videoId: _c),
      ];
      expect(findPlayableIndex(tracks, 0, 1), 2);
      expect(findPlayableIndex(tracks, 2, -1), 0);
      expect(findPlayableIndex(tracks, 2, 1), isNull);
      expect(findPlayableIndex(tracks, 0, 1, unavailable: {_c}), isNull);
      expect(findPlayableIndex(tracks, -1, 1, unavailable: {_a}), 2);
    });
  });

  late FakeApiAdapter api;
  late List<FakeEngine> engines;
  setUp(() {
    engines = [];
    api = FakeApiAdapter({
      'GET /api/line-ups/7': (_) => FakeApiAdapter.ok(_detail()),
      'GET /api/line-ups/7/line-up-songs/capos': (_) => FakeApiAdapter.ok({'capos': <Object>[]}),
    });
  });

  FakeEngine engine() => engines.last;

  Future<ProviderContainer> container({List<Override> extra = const []}) async {
    final c = await createTestContainer(
      api,
      overrides: [
        activeWorkspaceIdProvider.overrideWith((ref) => 1),
        isOnlineProvider.overrideWithValue(false),
        youtubeEngineFactoryProvider.overrideWithValue(() {
          final e = FakeEngine();
          engines.add(e);
          return e;
        }),
        ...extra,
      ],
    );
    final db = c.read(appDatabaseProvider);
    await db
        .into(db.lineUps)
        .insert(
          LineUpsCompanion.insert(
            id: const Value(7),
            workspaceId: 1,
            title: 'Sunday Service',
            date: '2999-01-04',
            songsCount: const Value(3),
          ),
        );
    await c.read(lineUpsRepositoryProvider).refreshDetail(7, 1);
    return c;
  }

  const source = PerformSource.lineUp(7);

  Future<void> settle() async {
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await pumpEventQueue();
  }

  group('player', () {
    Future<(ProviderContainer, MusicPlayer)> opened({int? start, bool play = true}) async {
      final c = await container();
      // As the app's mini player does: an unwatched provider is paused.
      final sub = c.listen(musicPlayerProvider, (_, _) {});
      addTearDown(sub.close);
      final player = c.read(musicPlayerProvider.notifier)..open(source, start: start, play: play);
      await settle();
      return (c, player);
    }

    test('plays the set from the first song with a link, keeping the rest in the queue', () async {
      final (c, _) = await opened();
      final state = c.read(musicPlayerProvider);
      expect(state.isOpen, isTrue);
      expect(state.title, 'Sunday Service');
      expect([for (final t in state.tracks) t.title], ['Oceans', 'Cornerstone', 'Way Maker']);
      expect(state.tracks[0].displayKey, 'E', reason: "the line-up's key");
      expect(state.tracks[1].hasVideo, isFalse);
      expect(state.currentIndex, 0);
      expect(engine().calls, ['load $_a']);
    });

    test('a song ending plays the next one with a link; the end of the set stops', () async {
      final (c, _) = await opened();
      engine().emit(const EngineStatusChanged(EngineStatus.playing));
      expect(c.read(musicPlayerProvider).isPlaying, isTrue);

      engine().emit(const EngineStatusChanged(EngineStatus.ended));
      final state = c.read(musicPlayerProvider);
      expect(state.currentIndex, 2, reason: 'Cornerstone has no link');
      expect(state.change, TrackChange.player);
      expect(engine().calls.last, 'load $_c');

      engine().emit(const EngineStatusChanged(EngineStatus.ended));
      expect(c.read(musicPlayerProvider).status, PlayerStatus.ended);
      expect(c.read(musicPlayerProvider).currentIndex, 2);
    });

    test('a video YouTube won’t play is marked and skipped', () async {
      final (c, _) = await opened();
      engine().emit(const EngineFailed(150));
      final state = c.read(musicPlayerProvider);
      expect(state.unavailable, {_a});
      expect(state.isUnavailable(state.tracks[0]), isTrue);
      expect(state.currentIndex, 2);
      expect(state.hasPrevious, isFalse);
    });

    test('previous restarts a song well under way, else goes back one', () async {
      final (c, player) = await opened(start: 2);
      expect(c.read(musicPlayerProvider).currentIndex, 2);

      engine().at = const Duration(seconds: 40);
      await player.previous();
      expect(engine().calls.last, 'seek 0');
      expect(c.read(musicPlayerProvider).currentIndex, 2);

      engine().at = const Duration(seconds: 1);
      await player.previous();
      expect(c.read(musicPlayerProvider).currentIndex, 0);
    });

    test('the chart moving cues its song: paused stays paused, playing plays on', () async {
      final (c, player) = await opened(play: false);
      expect(engine().calls, ['cue $_a']);

      player.followChart(source, 1);
      expect(c.read(musicPlayerProvider).currentIndex, 0, reason: 'no link: the player stays');

      player.followChart(source, 2);
      expect(engine().calls.last, 'cue $_c');
      expect(c.read(musicPlayerProvider).change, TrackChange.chart);

      engine().emit(const EngineStatusChanged(EngineStatus.playing));
      player.followChart(source, 0);
      expect(engine().calls.last, 'load $_a');

      // Another set on screen isn't linked.
      player.followChart(const PerformSource.lineUp(8), 2);
      expect(c.read(musicPlayerProvider).currentIndex, 0);
    });

    test('a link added from the queue lands on the device and makes the song playable', () async {
      final (c, player) = await opened();
      final cornerstone = c.read(musicPlayerProvider).tracks[1];

      expect(await player.saveLink(cornerstone, 'not a link'), "That doesn't look like a YouTube link.");
      expect(await player.saveLink(cornerstone, 'https://youtu.be/bbbbbbbbbbb'), isNull);
      await settle();

      final state = c.read(musicPlayerProvider);
      expect(state.tracks[1].videoId, 'bbbbbbbbbbb');
      expect(state.nextIndex, 1);
      final db = c.read(appDatabaseProvider);
      final edits = await db.select(db.songEdits).get();
      expect(edits.single.songId, 42, reason: 'queued for the server');
      final row = await (db.select(db.songs)..where((t) => t.id.equals(42))).getSingle();
      expect(row.youtubeUrl, 'https://www.youtube.com/watch?v=bbbbbbbbbbb');
    });

    test('closing lets the YouTube player go', () async {
      final (c, player) = await opened();
      player.close();
      expect(c.read(musicPlayerProvider).isOpen, isFalse);
      expect(engine().disposed, isTrue);
    });

    test('the video starting quiets the Practice click, for this practice only', () async {
      final c = await container(extra: [clickOutputProvider.overrideWithValue(SilentClickOutput())]);
      final sub = c.listen(practiceControllerProvider(source), (_, _) {});
      addTearDown(sub.close);
      await settle();
      final practice = c.read(practiceControllerProvider(source).notifier);
      expect(c.read(practiceControllerProvider(source)).clickOn, isTrue);

      practice.muteForVideo();
      expect(c.read(practiceControllerProvider(source)).clickOn, isFalse);
      expect((await c.read(performPrefsRepositoryProvider).watch().first).practiceClick, isTrue);

      await practice.setClick(true);
      expect(c.read(practiceControllerProvider(source)).clickOn, isTrue);
    });
  });

  group('screens', () {
    Future<void> pumpFrames(WidgetTester tester) async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<ProviderContainer> pump(WidgetTester tester, Widget home, {List<Override> extra = const []}) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = (await tester.runAsync(() => container(extra: extra)))!;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: DaloyTheme.light(),
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
            home: home,
          ),
        ),
      );
      await pumpFrames(tester);
      return c;
    }

    testWidgets('Listen plays the set: the video, the song, and the queue', (tester) async {
      final c = await pump(tester, const NowPlayingScreen(source: source));

      expect(find.byKey(const ValueKey('video')), findsOneWidget);
      expect(find.text('Sunday Service'), findsOneWidget);
      expect(find.text('Oceans'), findsWidgets);
      expect(find.text('Hillsong · Key of E'), findsWidgets);
      expect(find.text('No YouTube link'), findsOneWidget);
      expect(find.text('Add link'), findsOneWidget);
      expect(find.text('2 of 3 with YouTube'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Next'));
      await tester.pump();
      expect(c.read(musicPlayerProvider).currentIndex, 2);
      expect(find.text('Way Maker'), findsWidgets);
      expect(find.text('Spotify'), findsOneWidget, reason: 'its other apps');

      await tester.tap(find.text('Add link'));
      await pumpFrames(tester);
      expect(find.text('Add a link'), findsOneWidget);
    });

    testWidgets('the mini player holds the video under a screen, and closes', (tester) async {
      final c = await pump(tester, const MiniPlayerFrame(child: Scaffold(body: Text('Details'))));
      expect(find.byType(MiniPlayerBar), findsOneWidget);
      expect(find.text('Oceans'), findsNothing);

      c.read(musicPlayerProvider.notifier).open(source);
      await pumpFrames(tester);
      expect(find.text('Oceans'), findsOneWidget);
      expect(find.text('1 of 3 · Sunday Service'), findsOneWidget);
      expect(find.byKey(const ValueKey('video')), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Close player'));
      await pumpFrames(tester);
      expect(c.read(musicPlayerProvider).isOpen, isFalse);
      expect(find.text('Oceans'), findsNothing);
    });

    testWidgets('a screen over the mini player hands the video back as it closes', (tester) async {
      final c = await pump(tester, const MiniPlayerFrame(child: Scaffold(body: Text('Details'))));
      c.read(musicPlayerProvider.notifier).open(source);
      await pumpFrames(tester);
      engine().emit(const EngineStatusChanged(EngineStatus.playing));
      expect(engine().surfaces, 1);

      // Like the now-playing screen: see-through, so the mini player stays
      // on screen under it.
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      unawaited(
        navigator.push(
          PageRouteBuilder<void>(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, _, _) => const Scaffold(body: SizedBox(height: 200, child: PlayerVideoSlot())),
          ),
        ),
      );
      await pumpFrames(tester);
      expect(
        find.descendant(of: find.byType(PlayerVideoSlot).last, matching: find.byKey(const ValueKey('video'))),
        findsOneWidget,
      );
      expect(engine().surfaces, 1, reason: 'moved up, not made again');

      navigator.pop();
      await pumpFrames(tester);
      expect(engine().surfaces, 1, reason: 'moved back, not torn down and made again');
      expect(engine().calls, isNot(contains('pause')));
    });

    testWidgets('no slot on screen pauses the video', (tester) async {
      final c = await pump(tester, const MiniPlayerFrame(child: Scaffold(body: Text('Details'))));
      c.read(musicPlayerProvider.notifier).open(source);
      await pumpFrames(tester);
      engine().emit(const EngineStatusChanged(EngineStatus.playing));

      await tester.pumpWidget(UncontrolledProviderScope(container: c, child: const SizedBox()));
      await pumpFrames(tester);
      expect(engine().calls.last, 'pause');
    });

    testWidgets('Perform plays along, linked to the chart both ways', (tester) async {
      final c = await pump(
        tester,
        const PerformScreen(source: source),
        extra: [screenAwakeProvider.overrideWithValue(_Awake())],
      );
      await c.read(performPrefsRepositoryProvider).setAutoHide(false);
      expect(find.byType(PerformPlayerStrip), findsNothing);

      await tester.tap(find.bySemanticsLabel('Play along with YouTube'));
      await pumpFrames(tester);
      expect(find.byType(PerformPlayerStrip), findsOneWidget);
      expect(find.text('Playing along · 1 of 3'), findsOneWidget);
      expect(find.bySemanticsLabel('Play along with YouTube'), findsNothing);
      expect(engine().calls, ['load $_a']);

      // The chart moves: a song without a link leaves the video be; one with
      // a link cues it.
      await tester.tap(find.bySemanticsLabel('Next song'));
      await pumpFrames(tester);
      expect(c.read(musicPlayerProvider).currentIndex, 0);
      await tester.tap(find.bySemanticsLabel('Next song'));
      await pumpFrames(tester);
      expect(engine().calls.last, 'cue $_c');

      // The video moves: the chart follows.
      c.read(musicPlayerProvider.notifier).playTrack(0);
      await pumpFrames(tester);
      expect(c.read(performControllerProvider(source)).songIndex, 0);
    });
  });
}

class _Awake implements ScreenAwake {
  @override
  Future<void> hold() async {}

  @override
  Future<void> release() async {}
}
