import 'dart:convert';

import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/device/screen_awake.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/perform/application/perform_controller.dart';
import 'package:daloy_flutter/features/present/application/present_controller.dart';
import 'package:daloy_flutter/features/present/data/present_display.dart';
import 'package:daloy_flutter/features/present/data/present_link.dart';
import 'package:daloy_flutter/features/present/domain/present_deck.dart';
import 'package:daloy_flutter/features/present/presentation/present_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

const _lyrics = 'Verse 1:\nOne\nTwo\nThree\nFour\nFive\nSix\n\nChorus:\nSing\nLoud';

List<String> _labels(List<PresentSlide> slides) => [for (final s in slides) '${s.fullLabel}|${s.lines.join('/')}'];

class _FakeAwake extends ScreenAwake {
  int held = 0;
  int released = 0;

  @override
  Future<void> hold() async => held++;

  @override
  Future<void> release() async => released++;
}

void main() {
  group('slides', () {
    test('long sections split evenly, each part labelled', () {
      final slides = buildSlides([const PresentSong(key: 's1', title: 'A', lyrics: _lyrics)], linesPerSlide: 4);
      expect(_labels(slides), ['Verse 1 1/2|One/Two/Three', 'Verse 1 2/2|Four/Five/Six', 'Chorus|Sing/Loud']);

      final roomy = buildSlides([const PresentSong(key: 's1', title: 'A', lyrics: _lyrics)], linesPerSlide: 6);
      expect(_labels(roomy), ['Verse 1|One/Two/Three/Four/Five/Six', 'Chorus|Sing/Loud']);
    });

    test('splits as evenly as they can, the first parts taking the extra line', () {
      expect(splitEvenly(['1', '2', '3', '4', '5'], 2).map((p) => p.length).toList(), [2, 2, 1]);
      expect(splitEvenly(['1', '2', '3', '4', '5', '6', '7'], 4).map((p) => p.length).toList(), [4, 3]);
      expect(splitEvenly(['1', '2'], 4), [
        ['1', '2'],
      ]);
    });

    test('the line-up arrangement orders and cuts; a song without lyrics keeps one slide', () {
      final slides = buildSlides([
        const PresentSong(
          key: 's1',
          title: 'A',
          lyrics: _lyrics,
          arrangement: SectionArrangementField(order: [1], removed: [0]),
        ),
        const PresentSong(key: 's2', title: 'B'),
      ]);
      expect(_labels(slides), ['Chorus|Sing/Loud', '|']);
      expect(slides.last.songIndex, 1);
    });

    test('changing the split keeps the room in the same section', () {
      const song = PresentSong(key: 's1', title: 'A', lyrics: _lyrics);
      final four = buildSlides([song], linesPerSlide: 4);
      final two = buildSlides([song], linesPerSlide: 2);
      // The verse's second half (Four, Five, Six) starts in its second pair.
      expect(locateSlide(four[1], 1, two), 1);
      expect(locateSlide(four[2], 2, two), 3);
      expect(locateSlide(null, 99, two), two.length - 1);
    });

    test('the deck and commands survive the trip as JSON', () {
      final deck = PresentDeckState(
        title: 'Sunday',
        slides: buildSlides([const PresentSong(key: 's1', title: 'A', lyrics: _lyrics, displayKey: 'G')]),
        index: 1,
        blanked: true,
        look: const PresentLook(theme: PresentTheme.stage, font: PresentFont.serif, zoom: 130, linesPerSlide: 2),
      );
      expect(PresentDeckState.fromJson(jsonDecode(jsonEncode(deck.toJson())) as Map<String, Object?>), deck);
      for (final c in [
        const PresentNext(),
        const PresentPrev(),
        const PresentJump(3),
        const PresentToggleBlank(),
        PresentSetLook(deck.look),
      ]) {
        expect(
          PresentCommand.fromJson(jsonDecode(jsonEncode(c.toJson())) as Map<String, Object?>)!.toJson(),
          c.toJson(),
        );
      }
      expect(deck.songs.single.title, 'A');
    });
  });

  group('local network link', () {
    const deck = PresentDeckState(
      title: 'Sunday',
      slides: [
        PresentSlide(songIndex: 0, songTitle: 'A', sectionId: 'x', lines: ['Hi']),
      ],
    );

    Future<(PresentHost, NearbyPresenter, List<PresentCommand>)> serve() async {
      final received = <PresentCommand>[];
      final host = PresentHost(deviceName: 'Ana’s iPad', onCommand: received.add)..broadcast(deck);
      await host.start('Sunday');
      addTearDown(host.dispose);
      final here = NearbyPresenter(id: 'test', by: 'Ana’s iPad', title: 'Sunday', host: '127.0.0.1', port: host.port!);
      return (host, here, received);
    }

    test('pairs with the right code, mirrors the deck and sends commands', () async {
      final (host, here, received) = await serve();
      final remote = await PresentRemote.connect(here, host.code, name: 'Ben’s phone');
      addTearDown(remote.dispose);
      await _until(() => remote.deck.value != null);
      expect(remote.deck.value, deck);
      expect(remote.presenterName, 'Ana’s iPad');
      await _until(() => host.controllers.value.isNotEmpty);
      expect(host.controllers.value, ['Ben’s phone']);

      remote.send(const PresentNext());
      await _until(() => received.isNotEmpty);
      expect(received.single, isA<PresentNext>());

      final moved = deck.copyWith(blanked: true);
      host.broadcast(moved);
      await _until(() => remote.deck.value == moved);

      await host.stop();
      await _until(() => remote.ended.value);
    });

    test('a wrong code is refused, and nothing is sent', () async {
      final (host, here, received) = await serve();
      final wrong = host.code == '0000' ? '1111' : '0000';
      await expectLater(PresentRemote.connect(here, wrong, name: 'Ben'), throwsA(isA<PairingException>()));
      expect(host.controllers.value, isEmpty);
      expect(received, isEmpty);
    });
  });

  group('screen', () {
    late FakeApiAdapter api;
    setUp(() {
      api = FakeApiAdapter({
        'GET /api/line-ups/7': (_) => FakeApiAdapter.ok({
          'id': 7,
          'title': 'Sunday Service',
          'date': '2999-01-04',
          'songs_count': 1,
          'songs': [
            {
              'line_up_song_id': 901,
              'order': 0,
              'transposition': 0,
              'song': {
                'id': 41,
                'title': 'Oceans',
                'key': 'D',
                'lyrics': 'Verse:\nYou call me out\nupon the waters\n\nChorus:\nI will call upon your name',
                'is_public': false,
              },
            },
          ],
        }),
        'GET /api/line-ups/7/line-up-songs/capos': (_) => FakeApiAdapter.ok({'capos': <Object>[]}),
      });
    });

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<(ProviderContainer, _FakeAwake)> pump(WidgetTester tester, {ExternalDisplay? display}) async {
      tester.view
        ..physicalSize = const Size(844, 390)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final awake = _FakeAwake();
      final calls = <String>[];
      final channel = const MethodChannel('test/present_display');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return switch (call.method) {
          'getDisplay' =>
            display == null ? null : {'name': display.name, 'width': display.width, 'height': display.height},
          'show' => display != null,
          _ => null,
        };
      });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null),
      );
      final c = await createTestContainer(
        api,
        overrides: [
          activeWorkspaceIdProvider.overrideWith((ref) => 1),
          isOnlineProvider.overrideWithValue(true),
          screenAwakeProvider.overrideWithValue(awake),
          presentDisplayChannelProvider.overrideWithValue(PresentDisplayChannel(channel)),
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
              songsCount: const Value(1),
            ),
          );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: DaloyTheme.light(),
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
            home: const PresentScreen(source: PerformSource.lineUp(7)),
          ),
        ),
      );
      await settle(tester);
      return (c, awake);
    }

    testWidgets('presents here: the first slide, taps and keys move, B blanks', (tester) async {
      final (c, awake) = await pump(tester);
      final deck = () => c.read(presentDeckControllerProvider(const PerformSource.lineUp(7))).deck;

      expect(awake.held, 1);
      expect(find.text('You call me out'), findsOneWidget);

      // The right side moves on, the left comes back.
      await tester.tapAt(const Offset(800, 200));
      await tester.pump();
      expect(deck().index, 1);
      expect(find.text('I will call upon your name'), findsOneWidget);
      await tester.tapAt(const Offset(40, 200));
      await tester.pump();
      expect(deck().index, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(deck().index, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      await tester.pump();
      expect(deck().blanked, isTrue);
      expect(find.text('I will call upon your name'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      expect(awake.released, 1);
    });

    testWidgets('with an external display, this device is the control panel', (tester) async {
      await pump(tester, display: const ExternalDisplay(name: 'LG TV', width: 1920, height: 1080));

      expect(find.text('ON LG TV'), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('2 / 2'), findsOneWidget);
    });
  });
}

Future<void> _until(bool Function() done) async {
  for (var i = 0; i < 200 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(done(), isTrue);
}
