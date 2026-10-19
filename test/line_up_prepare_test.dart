import 'dart:convert';

import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/application/add_song_to_line_up.dart';
import 'package:daloy_flutter/features/line_ups/application/line_up_prepare_controller.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/line_ups/domain/prep_arrangement.dart';
import 'package:daloy_flutter/features/line_ups/presentation/line_up_prepare_screen.dart';
import 'package:daloy_flutter/features/line_ups/presentation/widgets/add_to_line_up_sheet.dart';
import 'package:daloy_flutter/features/songs/chart/chart_sections.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:daloy_flutter/features/songs/domain/song.dart';
import 'package:daloy_flutter/shared/widgets/sheet_nav_bar.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

const _chart = 'Verse 1:\n[G]Amazing [C]grace\n[D]how sweet\n\nChorus:\n[C]My chains\n\nBridge:\n[Em]Oh';

Map<String, dynamic> _song(int id, String title) => {
  'id': id,
  'title': title,
  'artist': 'Hillsong',
  'key': 'G',
  'transposition': 0,
  'bpm': 72,
  'time_signature': '4/4',
  'content': _chart,
  'lyrics': 'Verse 1:\nAmazing grace\n\nChorus:\nMy chains',
  'is_public': false,
  'created_at': '2026-10-15T08:00:00+00:00',
};

Map<String, dynamic> _entry(int pivot, int order, int songId, String title, {List<Object> notes = const []}) => {
  'line_up_song_id': pivot,
  'order': order,
  'transposition': 0,
  'song': _song(songId, title),
  'notes': notes,
};

const _oldNote = {'id': 'b4e1c7a0-0000-4000-8000-000000000001', 'line': 2, 'text': 'From the server'};

Map<String, dynamic> _detail({List<Map<String, dynamic>>? songs}) {
  final list =
      songs ??
      [
        _entry(901, 0, 41, 'Oceans', notes: [_oldNote]),
        _entry(902, 1, 42, 'Way Maker'),
      ];
  return {
    'id': 7,
    'title': 'Sunday Service',
    'date': '2999-01-04',
    'worship_leader': 'Ana',
    'songs_count': list.length,
    'songs': list,
  };
}

ChartSection _block(int i, String label) => ChartSection(id: 's-$i', label: label, startLine: i, lines: ['[G]line $i']);

void main() {
  group('arrangement rules', () {
    final blocks = [_block(0, 'Verse 1'), _block(1, 'Chorus'), _block(2, 'Bridge')];

    test('lists the stored order, then the cut ones, then new sections; stale ones drop', () {
      expect(prepDisplayOrder(3, null), [0, 1, 2]);
      expect(prepDisplayOrder(3, const SectionArrangementField(order: [2, 0], removed: [1])), [2, 0, 1]);
      // 5 is gone from the song; 2 was added after the arrangement was saved.
      expect(prepDisplayOrder(3, const SectionArrangementField(order: [1, 5, 0])), [1, 0, 2]);
    });

    test('moving and cutting write the order without the cut sections', () {
      final sections = prepSections(blocks, null);
      expect(isRearranged(sections), isFalse);

      final moved = movedSection(sections, 2, 0);
      expect(
        [moved.order, moved.removed],
        [
          [2, 0, 1],
          <int>[],
        ],
      );

      final cut = toggledSection(prepSections(blocks, moved), 0);
      expect(
        [cut.order, cut.removed],
        [
          [2, 1],
          [0],
        ],
      );
      final shown = prepSections(blocks, cut);
      expect([for (final s in shown) (s.originalIndex, s.removed)], [(2, false), (1, false), (0, true)]);
      expect(isRearranged(shown), isTrue);

      final back = toggledSection(shown, 0);
      expect(
        [back.order, back.removed],
        [
          [2, 1, 0],
          <int>[],
        ],
      );
    });

    test('short names and previews', () {
      expect(sectionShortLabel(_block(0, 'Verse 2'), 0), 'V2');
      expect(sectionShortLabel(_block(0, 'Pre-Chorus'), 0), 'PC');
      expect(sectionShortLabel(_block(0, 'Solo 2'), 0), 'Solo2');
      expect(sectionShortLabel(_block(0, ''), 3), '4');
      expect(linePreview('[G]Amazing [C]grace'), 'Amazing grace');
      expect(linePreview('| [G] [C] | [D] |'), '| G C | D |');
    });

    test('the line-up picker groups by day, soonest first, past latest first', () {
      final now = DateTime(2026, 10, 16, 9);
      LineUp l(int id, String date) => LineUp(id: id, title: 'L$id', date: date);
      final g = groupLineUpsForPicker([
        l(1, '2026-10-01'),
        l(2, '2026-10-20'),
        l(3, '2026-10-16'),
        l(4, '2026-10-17'),
        l(5, '2026-10-18'),
        l(6, '2026-09-01'),
      ], now: now);
      expect(
        [
          for (final x in g.coming) '${x.label}: ${[for (final y in x.lineUps) y.id].join(',')}',
        ],
        ['Today: 3', 'Tomorrow: 4', 'Upcoming: 5,2'],
      );
      expect([for (final y in g.past) y.id], [1, 6]);
      expect(groupLineUpsForPicker([l(1, '2026-10-01'), l(2, '2026-10-20')], search: 'L1', now: now).past.length, 1);
    });
  });

  late FakeApiAdapter api;
  late List<String> calls;
  late Map<String, dynamic> serverDetail;
  var online = true;

  setUp(() {
    online = true;
    calls = [];
    serverDetail = _detail();
    FakeReply guard(RequestOptions r, FakeReply Function() reply) {
      calls.add('${r.method} ${r.path} ${r.data == null ? '' : jsonEncode(r.data)}'.trim());
      if (!online) throw DioException(requestOptions: r, type: DioExceptionType.connectionError);
      return reply();
    }

    api = FakeApiAdapter({
      'GET /api/line-ups/7': (r) => guard(r, () => FakeApiAdapter.ok(serverDetail)),
      'GET /api/line-ups/7/line-up-songs/capos': (r) => guard(r, () => FakeApiAdapter.ok({'capos': []})),
      for (final pivot in [901, 902, 903])
        'POST /api/line-ups/7/line-up-songs/$pivot/notes': (r) => guard(r, () => FakeApiAdapter.ok({})),
      'DELETE /api/line-ups/7/line-up-songs/901/notes/${_oldNote['id']}': (r) => guard(r, () => FakeApiAdapter.ok({})),
      'PATCH /api/line-ups/7/line-up-songs/901/section-arrangement': (r) => guard(r, () => FakeApiAdapter.ok({})),
      'PATCH /api/line-ups/7/line-up-songs/902/section-arrangement': (r) =>
          guard(r, () => FakeApiAdapter.error(422, 'A line-up song cannot have more than 200 sections.')),
      'PUT /api/line-ups/7/songs': (r) => guard(r, () => FakeApiAdapter.ok(serverDetail)),
      'GET /api/line-ups': (r) => guard(r, () => FakeApiAdapter.ok({'line_ups': []})),
    });
  });

  Future<ProviderContainer> container() => createTestContainer(
    api,
    overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1), isOnlineProvider.overrideWith((ref) => online)],
  );

  Future<void> seed(ProviderContainer c) async {
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
    calls.clear();
  }

  Future<List<LineUpPrepOutboxRow>> queued(ProviderContainer c) {
    final db = c.read(appDatabaseProvider);
    return db.select(db.lineUpPrepOutbox).get();
  }

  Future<List<LineUpSongNote>> notesOf(ProviderContainer c, int songId) async {
    final list = await c.read(lineUpsRepositoryProvider).watchSetlist(7).first;
    return list.firstWhere((e) => e.song.id == songId).notes;
  }

  group('repository', () {
    test('a note saves on the device offline, outlives a refresh, then goes out', () async {
      final c = await container();
      await seed(c);
      final repo = c.read(lineUpsRepositoryProvider);

      online = false;
      const mine = LineUpSongNote(id: 'b4e1c7a0-0000-4000-8000-000000000002', line: 5, text: 'Softly');
      await repo.setNotes(7, 41, [mine]);
      expect(await notesOf(c, 41), [mine]);
      // One queued change per note: the old one deleted, mine added.
      expect({for (final q in await queued(c)) q.kind}, {'note:${_oldNote['id']}', 'note:${mine.id}'});

      // The server still has the old note; the unsent changes win.
      online = true;
      calls.clear();
      api.routes['POST /api/line-ups/7/line-up-songs/901/notes'] = (r) {
        calls.add('POST note ${jsonEncode(r.data)}');
        return FakeApiAdapter.error(503, 'Down for a moment.');
      };
      await repo.refreshDetail(7, 1);
      expect(await notesOf(c, 41), [mine]);

      api.routes['POST /api/line-ups/7/line-up-songs/901/notes'] = (r) {
        calls.add('POST note ${jsonEncode(r.data)}');
        return FakeApiAdapter.ok({});
      };
      await repo.flushPrep(1);
      expect(calls, contains('POST note {"id":"${mine.id}","line":5,"text":"Softly"}'));
      expect(calls, contains('DELETE /api/line-ups/7/line-up-songs/901/notes/${_oldNote['id']}'));
      expect(await queued(c), isEmpty);
    });

    test('an arrangement sends one view and keeps the other; a refusal keeps its reason', () async {
      final c = await container();
      await seed(c);
      final repo = c.read(lineUpsRepositoryProvider);

      await repo.setArrangement(7, 41, SongArrangementView.lyrics, const SectionArrangementField(order: [1, 0]));
      await repo.setArrangement(
        7,
        41,
        SongArrangementView.chords,
        const SectionArrangementField(order: [2], removed: [0, 1]),
      );
      expect(calls, [
        'PATCH /api/line-ups/7/line-up-songs/901/section-arrangement {"field":"lyrics","order":[1,0],"removed":[],"base":{"order":[],"removed":[]}}',
        'PATCH /api/line-ups/7/line-up-songs/901/section-arrangement {"field":"chords","order":[2],"removed":[0,1],"base":{"order":[],"removed":[]}}',
      ]);
      final entry = (await repo.watchSetlist(7).first).first;
      expect(entry.sectionArrangement!.lyrics.order, [1, 0]);
      expect(entry.sectionArrangement!.chords.removed, [0, 1]);

      await repo.setArrangement(7, 42, SongArrangementView.chords, const SectionArrangementField(order: [1, 0]));
      final refused = (await queued(c)).single;
      expect(
        (refused.songId, refused.kind, refused.error),
        (42, 'chords', 'A line-up song cannot have more than 200 sections.'),
      );
    });

    test('adding a song here marks it used at once', () async {
      final c = await container();
      await seed(c);
      final db = c.read(appDatabaseProvider);
      await db.into(db.songs).insert(SongsRepository.songCompanion(Song.fromJson(_song(43, 'Gratitude')), 1));

      online = false;
      final at = DateTime(2026, 10, 19, 9);
      expect(await c.read(lineUpsRepositoryProvider).addSong(7, 43, now: at), AddSongResult.added);
      final row = await (db.select(db.songs)..where((t) => t.id.equals(43))).getSingle();
      expect(row.lastUsedAt, at);
    });

    test('a song the server has not seen waits for the set to go out first', () async {
      final c = await container();
      await seed(c);
      final repo = c.read(lineUpsRepositoryProvider);
      await c
          .read(appDatabaseProvider)
          .into(c.read(appDatabaseProvider).songs)
          .insert(SongsRepository.songCompanion(Song.fromJson(_song(43, 'Gratitude')), 1));

      online = false;
      expect(await repo.addSong(7, 43), AddSongResult.added);
      expect(await repo.addSong(7, 43), AddSongResult.alreadyIn);
      await repo.setNotes(7, 43, const [
        LineUpSongNote(id: 'b4e1c7a0-0000-4000-8000-000000000003', line: 1, text: 'Key up'),
      ]);
      expect(calls.where((c) => c.contains('/notes')), isEmpty);

      online = true;
      calls.clear();
      serverDetail = _detail(
        songs: [
          _entry(901, 0, 41, 'Oceans', notes: [_oldNote]),
          _entry(902, 1, 42, 'Way Maker'),
          _entry(903, 2, 43, 'Gratitude'),
        ],
      );
      await repo.flushOutbox(1);
      expect(calls.first, startsWith('PUT /api/line-ups/7/songs'));
      expect(calls.last, startsWith('POST /api/line-ups/7/line-up-songs/903/notes'));
      expect((await notesOf(c, 43)).single.text, 'Key up');
      expect(await queued(c), isEmpty);
    });

    test("editing the set keeps a staying song's entry, notes and arrangement", () async {
      final c = await container();
      await seed(c);
      final repo = c.read(lineUpsRepositoryProvider);
      online = false;
      await repo.setNotes(7, 42, const [
        LineUpSongNote(id: 'b4e1c7a0-0000-4000-8000-000000000004', line: 1, text: 'Drop'),
      ]);

      final editable = (await repo.loadEditable(7))!;
      // Way Maker leaves, Oceans stays.
      await repo.save(7, editable.details, songs: [editable.songs.first]);
      final set = await repo.watchSetlist(7).first;
      expect(set.single.lineUpSongId, 901);
      expect(set.single.notes.single.text, 'From the server');
      // The note on the song that left has nowhere to go.
      expect(await queued(c), isEmpty);
    });

    test("a teammate's note waits behind an unsent local one", () async {
      final c = await container();
      await seed(c);
      final repo = c.read(lineUpsRepositoryProvider);
      online = false;
      const mine = LineUpSongNote(id: 'b4e1c7a0-0000-4000-8000-000000000005', line: 1, text: 'Mine');
      await repo.setNotes(7, 41, [mine]);
      await repo.applyRemoteNotes(7, 901, const []);
      expect(await notesOf(c, 41), [mine]);
      await repo.applyRemoteNotes(7, 902, const [LineUpSongNote(id: 'x', line: 1, text: 'Theirs')]);
      expect((await notesOf(c, 42)).single.text, 'Theirs');
    });

    test('adding to a line-up whose set is not here fetches it first, or says it needs a connection', () async {
      final c = await container();
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
      await db.into(db.songs).insert(SongsRepository.songCompanion(Song.fromJson(_song(43, 'Gratitude')), 1));
      final adder = c.read(songLineUpAdderProvider);

      online = false;
      expect(await adder.add(7, 43), AddToLineUpOutcome.needsConnection);
      online = true;
      c.invalidate(isOnlineProvider);
      expect(await adder.add(7, 43), AddToLineUpOutcome.added);
      expect(await adder.add(7, 41), AddToLineUpOutcome.alreadyIn);
      expect([for (final e in await c.read(lineUpsRepositoryProvider).watchSetlist(7).first) e.song.id], [41, 42, 43]);
    });
  });

  group('screens', () {
    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 8; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<ProviderContainer> pump(WidgetTester tester, Widget home, {Size size = const Size(390, 844)}) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = await container();
      await tester.runAsync(() => seed(c));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp.router(
            theme: DaloyTheme.light(),
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
            routerConfig: GoRouter(
              routes: [GoRoute(path: '/', builder: (_, _) => home)],
            ),
          ),
        ),
      );
      await settle(tester);
      return c;
    }

    testWidgets('Prepare cuts a section and pins a note under a line', (tester) async {
      final c = await pump(tester, const LineUpPrepareScreen(lineUpId: 7));

      expect(find.text('Sunday Service'), findsOneWidget);
      expect(find.text('Oceans'), findsOneWidget);
      expect(find.text('Verse 1'), findsWidgets);
      expect(find.text('Amazing grace'), findsWidgets);

      await tester.tap(find.byTooltip('Cut Bridge').first);
      await settle(tester);
      final first = c.read(lineUpPrepareControllerProvider(7)).songs.first;
      expect(
        [for (final s in first.chords) (s.block.label, s.removed)],
        [('Verse 1', false), ('Chorus', false), ('Bridge', true)],
      );
      expect(find.text('Reset'), findsOneWidget);

      await tester.tap(find.text('Notes'));
      await settle(tester);
      // Oceans' server note shows; the cut Bridge doesn't.
      expect(find.textContaining('From the server', findRichText: true), findsOneWidget);
      await tester.tap(find.textContaining('chains', findRichText: true).first);
      await settle(tester);
      expect(find.text('Add note'), findsOneWidget);
      expect(find.textContaining('Under “My chains”'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Band drops out');
      await tester.pump();
      await tester.tap(find.byKey(SheetNavBar.actionKey));
      await settle(tester);

      final notes = c.read(lineUpPrepareControllerProvider(7)).songs.first.notes;
      expect([for (final n in notes) (n.line, n.text)], [(2, 'From the server'), (6, 'Band drops out')]);
      expect(find.textContaining('Band drops out', findRichText: true), findsOneWidget);
      expect(calls.where((c) => c.contains('/notes')), hasLength(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Prepare fits a 320pt phone', (tester) async {
      await pump(tester, const LineUpPrepareScreen(lineUpId: 7, notes: true), size: const Size(320, 640));
      await tester.tap(find.text('Arrange'));
      await settle(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Add to line-up lists what is coming and adds at the end of the set', (tester) async {
      final c = await pump(
        tester,
        Consumer(
          builder: (context, ref, _) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => addSongToLineUp(context, ref, Song.fromJson(_song(43, 'Gratitude'))),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      final db = c.read(appDatabaseProvider);
      await tester.runAsync(() async {
        await db.into(db.songs).insert(SongsRepository.songCompanion(Song.fromJson(_song(43, 'Gratitude')), 1));
        await db
            .into(db.lineUps)
            .insert(
              LineUpsCompanion.insert(id: const Value(8), workspaceId: 1, title: 'Old Service', date: '2001-01-07'),
            );
      });

      await tester.tap(find.text('open'));
      await settle(tester);
      expect(find.text('Add to line-up'), findsOneWidget);
      expect(find.text('UPCOMING'), findsOneWidget);
      expect(find.text('Sunday Service'), findsOneWidget);
      expect(find.text('Old Service'), findsNothing);
      expect(find.text('Show 1 past line-up'), findsOneWidget);

      // What the server answers once the set goes out.
      serverDetail = _detail(
        songs: [
          _entry(901, 0, 41, 'Oceans', notes: [_oldNote]),
          _entry(902, 1, 42, 'Way Maker'),
          _entry(903, 2, 43, 'Gratitude'),
        ],
      );
      await tester.tap(find.text('Sunday Service'));
      await settle(tester);
      expect(find.text('Added to “Sunday Service”.'), findsOneWidget);
      final set = await tester.runAsync(() => c.read(lineUpsRepositoryProvider).watchSetlist(7).first);
      expect([for (final e in set!) e.song.id], [41, 42, 43]);
      expect(tester.takeException(), isNull);
    });
  });
}
