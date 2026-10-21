import 'dart:async';
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
import 'package:daloy_flutter/features/present/data/present_trust.dart';
import 'package:daloy_flutter/features/present/domain/present_deck.dart';
import 'package:daloy_flutter/features/present/presentation/present_join_sheet.dart';
import 'package:daloy_flutter/features/present/presentation/present_remote_sheet.dart';
import 'package:daloy_flutter/features/present/presentation/present_screen.dart';
import 'package:daloy_flutter/features/songs/chart/chart_sections.dart';
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

  group('editing a section', () {
    const lyrics = 'Verse 1:\nOne\nTwo\n\nChorus: x2\n\nSing\nLoud\n\nBridge:\nHigh';

    String id(String label) => groupBySections(lyrics, 's').firstWhere((x) => x.label == label).id;

    test('replaces only that section’s lines, dropping blank ones', () {
      final out = replaceSection(lyrics, 's', id('Chorus'), lines: ['Sing it', '', 'Louder ']);
      expect(out, 'Verse 1:\nOne\nTwo\n\nChorus: x2\n\nSing it\nLouder\n\nBridge:\nHigh');
      // Still the same sections, so a line-up's arrangement still lines up.
      expect(groupBySections(out!, 's').map((x) => x.label), ['Verse 1', 'Chorus', 'Bridge']);
    });

    test('renames a written header and keeps its repeat', () {
      final out = replaceSection(lyrics, 's', id('Chorus'), label: 'Refrain', lines: ['Sing', 'Loud']);
      expect(out, contains('Refrain: x2'));
      expect(out, isNot(contains('Chorus')));
    });

    test('works on lyrics without headers, and finds nothing for a section that’s gone', () {
      const stanzas = 'A\nB\n\nC\nD';
      final second = groupBySections(stanzas, 's')[1].id;
      expect(replaceSection(stanzas, 's', second, label: 'Ignored', lines: ['E']), 'A\nB\n\nE');
      expect(replaceSection(stanzas, 's', 's-section-9', lines: ['E']), isNull);
    });

    test('the editor gets the whole of a split section; only headers can be renamed', () {
      const song = PresentSong(key: 's', title: 'A', songId: 5, lyrics: 'Verse:\n1\n2\n3\n4\n5\n6\n\nPlain\nstanza');
      final deck = PresentDeckState(slides: buildSlides([song]));
      // 6 lines at 4 a slide: two slides of three.
      final fromSecondHalf = deck.sectionAt(1)!;
      expect(fromSecondHalf.lines, ['1', '2', '3', '4', '5', '6']);
      expect(fromSecondHalf.labelled, isTrue);
      expect(deck.sectionAt(2)!.labelled, isFalse);
      const empty = PresentSong(key: 'e', title: 'B', songId: 6);
      // A song with no lyrics yet: its blank slide opens the editor to add some.
      final blank = PresentDeckState(slides: buildSlides([empty])).sectionAt(0)!;
      expect(blank.blank, isTrue);
      expect(blank.sectionId, blankSectionId('e'));
      expect(blank.lines, isEmpty);
    });

    test('the edit command survives the trip to the presenter', () {
      const edit = PresentEditSection(songIndex: 1, sectionId: 'x', label: 'Chorus', lines: ['a', 'b']);
      final back = PresentCommand.fromJson(jsonDecode(jsonEncode(edit.toJson())) as Map<String, Object?>);
      expect(back, isA<PresentEditSection>());
      back as PresentEditSection;
      expect((back.songIndex, back.sectionId, back.label), (1, 'x', 'Chorus'));
      expect(back.lines, ['a', 'b']);
    });
  });

  group('local network link', () {
    const deck = PresentDeckState(
      title: 'Sunday',
      slides: [
        PresentSlide(songIndex: 0, songTitle: 'A', sectionId: 'x', lines: ['Hi']),
      ],
    );

    Future<(PresentHost, NearbyPresenter, List<PresentCommand>)> serve({PresentKeys? trusted}) async {
      final received = <PresentCommand>[];
      final host = PresentHost(
        deviceName: 'Ana’s iPad',
        deviceId: 'ana',
        workspaceId: 1,
        trusted: trusted,
        onCommand: received.add,
      )..broadcast(deck);
      await host.start('Sunday');
      addTearDown(host.dispose);
      final here = NearbyPresenter(
        id: 'test',
        by: 'Ana’s iPad',
        title: 'Sunday',
        host: '127.0.0.1',
        port: host.port!,
        deviceId: 'ana',
        workspaceId: 1,
      );
      return (host, here, received);
    }

    Future<PresentRemote> join(
      NearbyPresenter here, {
      required String device,
      String? token,
      required AskPresentCode askCode,
    }) async {
      final remote = await PresentRemote.connect(here, name: device, deviceId: device, token: token, askCode: askCode);
      addTearDown(remote.dispose);
      return remote;
    }

    Future<String?> never(String? _) => throw StateError('asked for a code');

    test('asks for the code shown on the presenter, then mirrors the deck and sends commands', () async {
      final (host, here, received) = await serve();
      final remote = await join(
        here,
        device: 'ben',
        askCode: (error) async {
          // The presenter shows who's asking while the code is typed.
          await _until(() => host.requests.value.isNotEmpty);
          expect(host.requests.value.single.id, 'ben');
          return host.code;
        },
      );
      await _until(() => remote.deck.value != null);
      expect(remote.deck.value, deck);
      expect(remote.presenterName, 'Ana’s iPad');
      expect(remote.token, isNotEmpty);
      await _until(() => host.controllers.value.isNotEmpty);
      expect(host.controllers.value.single.name, 'ben');
      expect(host.requests.value, isEmpty);
      // The first to pair drives.
      await _until(() => remote.driving.value);
      expect(host.driver.value?.id, 'ben');

      remote.send(const PresentNext());
      await _until(() => received.isNotEmpty);
      expect(received.single, isA<PresentNext>());

      final moved = deck.copyWith(blanked: true);
      host.broadcast(moved);
      await _until(() => remote.deck.value == moved);

      await host.stop();
      await _until(() => remote.ended.value);
    });

    test('a wrong code asks again; the right one still pairs', () async {
      final (host, here, received) = await serve();
      final errors = <String?>[];
      final wrong = host.code == '0000' ? '1111' : '0000';
      final remote = await join(
        here,
        device: 'ben',
        askCode: (error) async {
          errors.add(error);
          return errors.length == 1 ? wrong : host.code;
        },
      );
      expect(errors, [null, 'That code didn’t match.']);
      expect(remote.token, isNotEmpty);
      expect(received, isEmpty);
    });

    test('a remembered key pairs without the code; disconnecting forgets it', () async {
      final trusted = PresentKeys(null, '');
      final (host, here, _) = await serve(trusted: trusted);
      final first = await join(here, device: 'ben', askCode: (_) async => host.code);
      expect(trusted.tokenFor('ben'), first.token);
      await first.close();
      await _until(() => host.controllers.value.isEmpty);

      final again = await join(here, device: 'ben', token: first.token, askCode: never);
      await _until(() => host.controllers.value.isNotEmpty);

      host.disconnect('ben');
      await _until(() => again.ended.value);
      expect(again.removed, isTrue);
      expect(trusted.tokenFor('ben'), isNull);

      var asked = false;
      final stale = await join(
        here,
        device: 'ben',
        token: first.token,
        askCode: (_) async {
          asked = true;
          return host.code;
        },
      );
      expect(asked, isTrue);
      expect(stale.token, isNot(first.token));
    });

    test('backing out or being declined pairs nothing', () async {
      final (host, here, received) = await serve();
      await expectLater(
        join(here, device: 'ben', askCode: (_) async => null),
        throwsA(isA<PairingException>().having((e) => e.cancelled, 'cancelled', isTrue)),
      );
      final declined = join(
        here,
        device: 'cara',
        askCode: (_) async {
          await _until(() => host.requests.value.isNotEmpty);
          host.decline('cara');
          return Completer<String?>().future;
        },
      );
      await expectLater(declined, throwsA(isA<PairingException>().having((e) => e.cancelled, 'cancelled', isFalse)));
      expect(host.controllers.value, isEmpty);
      expect(received, isEmpty);
    });

    test('one device drives at a time; the other takes control', () async {
      final (host, here, received) = await serve();
      final ben = await join(here, device: 'ben', askCode: (_) async => host.code);
      await _until(() => ben.driving.value);
      final cara = await join(here, device: 'cara', askCode: (_) async => host.code);
      await _until(() => cara.driverName.value == 'ben');
      expect(cara.driving.value, isFalse);

      // Watching, so it doesn't count.
      cara.send(const PresentNext());
      ben.send(const PresentPrev());
      await _until(() => received.isNotEmpty);
      expect(received.single, isA<PresentPrev>());

      cara.takeControl();
      await _until(() => cara.driving.value && !ben.driving.value);
      expect(ben.driverName.value, 'cara');
      expect(host.driver.value?.id, 'cara');

      // The driver leaving leaves nobody driving from afar.
      await cara.close();
      await _until(() => host.driver.value == null);
      await _until(() => ben.driverName.value == null);
    });

    testWidgets('the presenter shows the code only while someone asks, then who has control', (tester) async {
      final hosting = RemoteHosting(
        deviceName: 'Ana’s iPad',
        deviceId: 'ana',
        workspaceId: 1,
        trusted: PresentKeys(null, ''),
        onCommand: (_) {},
      );
      addTearDown(hosting.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: DaloyTheme.light(),
          // As over the slides: a full-screen stack, the banner at the top.
          home: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: PresentJoinRequestBanner(hosting: hosting, glass: true),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: PresentDriverChip(hosting: hosting, onPressed: () {}),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.textContaining('Code'), findsNothing);

      final typed = Completer<String?>();
      late Future<PresentRemote> joining;
      await tester.runAsync(() async {
        await hosting.start('Sunday');
        joining = PresentRemote.connect(
          NearbyPresenter(id: 't', by: 'Ana’s iPad', title: '', host: '127.0.0.1', port: hosting.port!),
          name: 'Ben’s phone',
          deviceId: 'ben',
          askCode: (_) => typed.future,
        );
        await _until(() => hosting.requests.isNotEmpty);
      });
      await tester.pumpAndSettle();
      expect(find.text('Ben’s phone wants to control the slides'), findsOneWidget);
      expect(find.text('Code  ${spacedCode(hosting.code)}'), findsOneWidget);
      // Hugs its two lines rather than filling the screen.
      expect(tester.getSize(find.byType(PresentJoinRequestBanner)).height, lessThan(120));

      await tester.runAsync(() async {
        typed.complete(hosting.code);
        final remote = await joining;
        addTearDown(remote.dispose);
        await _until(() => hosting.driver != null);
      });
      await tester.pumpAndSettle();
      expect(find.textContaining('wants to control'), findsNothing);
      expect(find.text('Ben’s phone has control'), findsOneWidget);
    });

    test('only teammates’ presentations are offered, never this device’s own', () {
      NearbyPresenter at(String device, int? ws) =>
          NearbyPresenter(id: device, by: device, title: '', host: 'h', port: 1, deviceId: device, workspaceId: ws);
      final found = [at('ana', 1), at('me', 1), at('other', 2), at('old', null)];
      expect(teamPresentations(found, workspaceId: 1, deviceId: 'me').map((p) => p.by), ['ana']);
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
      PresentDeckState deck() => c.read(presentDeckControllerProvider(const PerformSource.lineUp(7))).deck;

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

    testWidgets('an edit is saved into the song and the slides follow', (tester) async {
      final (c, _) = await pump(tester, display: const ExternalDisplay(name: 'LG TV', width: 1920, height: 1080));
      const source = PerformSource.lineUp(7);
      final deck = c.read(presentDeckControllerProvider(source)).deck;
      final verse = deck.sectionAt(0)!;
      expect(verse.lines, ['You call me out', 'upon the waters']);

      await tester.ensureVisible(find.text('Edit'));
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Lyrics'), 'You call me out\nupon the great waters');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Save'));
      await settle(tester);

      final db = c.read(appDatabaseProvider);
      final song = await tester.runAsync(() => (db.select(db.songs)..where((t) => t.id.equals(41))).getSingle());
      expect(song!.lyrics, 'Verse:\nYou call me out\nupon the great waters\n\nChorus:\nI will call upon your name');
      expect(c.read(presentDeckControllerProvider(source)).deck.slides.first.lines.last, 'upon the great waters');
      expect(find.text('Saved to “Oceans”.'), findsOneWidget);
    });

    testWidgets('a section further on can be edited from the list, without going to it', (tester) async {
      final (c, _) = await pump(tester, display: const ExternalDisplay(name: 'LG TV', width: 1920, height: 1080));
      const source = PerformSource.lineUp(7);
      expect(c.read(presentDeckControllerProvider(source)).deck.index, 0);

      final pencil = find.bySemanticsLabel('Edit Chorus');
      await tester.ensureVisible(pencil);
      await tester.tap(pencil);
      await tester.pumpAndSettle();
      expect(find.text('Edit Chorus'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Lyrics'), 'I will call upon Your name');
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Save'));
      await settle(tester);

      final deck = c.read(presentDeckControllerProvider(source)).deck;
      expect(deck.index, 0, reason: 'the room stays where it was');
      expect(deck.slides.last.lines, ['I will call upon Your name']);
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

  group('display channel', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('test/present_displays');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('the Mac lists every screen, marks the chosen one, and switches by id', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return call.method == 'getDisplays'
            ? [
                {'id': 2, 'name': 'DELL U2720Q', 'width': 2560.0, 'height': 1440.0, 'selected': false},
                {'id': 5, 'name': 'Epson Projector', 'width': 1920.0, 'height': 1080.0, 'selected': true},
              ]
            : null;
      });
      final display = PresentDisplayChannel(channel);

      final all = await display.all();
      expect([for (final d in all) d.display.name], ['DELL U2720Q', 'Epson Projector']);
      expect([for (final d in all) d.selected], [false, true]);

      await display.select(all.first.display);
      expect(calls.last.method, 'select');
      expect(calls.last.arguments, 2);
    });

    test('where there is only one external screen, it is the list', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'getDisplays') throw MissingPluginException();
        return {'name': 'LG TV', 'width': 1920.0, 'height': 1080.0};
      });

      final all = await PresentDisplayChannel(channel).all();
      expect(all, hasLength(1));
      expect(all.single.display, const ExternalDisplay(name: 'LG TV', width: 1920, height: 1080));
      expect(all.single.selected, isTrue);
    });
  });
}

Future<void> _until(bool Function() done) async {
  for (var i = 0; i < 200 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(done(), isTrue);
}
