import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/search/application/os_search_sync.dart';
import 'package:daloy_flutter/features/search/data/search_repository.dart';
import 'package:daloy_flutter/features/search/domain/search_query.dart';
import 'package:daloy_flutter/features/search/domain/search_results.dart';
import 'package:daloy_flutter/features/search/domain/search_text.dart';
import 'package:daloy_flutter/features/songs/domain/display_prefs.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('text', () {
    test('folds accents and case, one character for one', () {
      expect(fold('Jesús Señor'), 'jesus senor');
      expect(fold('Ärger').length, 'Ärger'.length);
    });

    test('a term meets a word by its start, or within a typo from four letters', () {
      expect(termMeetsWord('amaz', 'amazing'), 0);
      expect(termMeetsWord('amazng', 'amazing'), 1);
      expect(termMeetsWord('graec', 'grace'), 1);
      expect(termMeetsWord('gce', 'grace'), isNull);
      expect(termMeetsWord('2025', '2026'), isNull, reason: 'numbers are exact');
    });

    test('ranks a title start over word starts over mid-word over typos', () {
      expect(matchScore('Way Maker', 'way', ['way']), 0);
      expect(matchScore('Goodness of God', 'god good', ['god', 'good']), 1);
      expect(matchScore('Oceans', 'cean', ['cean']), 2);
      expect(matchScore('Oceans', 'oceens', ['oceens']), 3);
      expect(matchScore('Oceans', 'hosanna', ['hosanna']), isNull);
    });

    test('strips chords, section labels and bar rows, keeping line numbers', () {
      const chart = 'Verse 1:\n[G]A[C]mazing grace\n| [G] [C] | [D] |\n[D]how sweet the sound';
      expect(chartPlainText(chart), '\nAmazing grace\n\nhow sweet the sound');
    });

    test('finds the line most terms meet', () {
      final line = bestLine('Amazing grace\nhow sweet the sound\nthat saved a wretch', ['sweet', 'sound']);
      expect(line, (line: 1, hits: 2, text: 'how sweet the sound'));
    });

    test('highlights the typed part of a word, or a whole word met with a typo', () {
      expect(highlightRanges('Amazing Grace', ['ama']), [(start: 0, end: 3)]);
      expect(highlightRanges('Amazing Grace', ['graec']), [(start: 8, end: 13)]);
    });
  });

  group('query', () {
    test('reads key and tempo tokens out of the text', () {
      final q = SearchQuery.parse('key:bb  hosanna 72bpm');
      expect(q.text, 'hosanna');
      expect(q.key, 'Bb');
      expect(q.bpm, (min: 67, max: 77));
      expect(SearchQuery.parse('Key:F#min').key, 'F#m');
      expect(SearchQuery.parse('bpm:130-110').bpm, (min: 110, max: 130));
    });

    test('music filters keep it to songs', () {
      final q = SearchQuery.parse('key:G');
      expect(q.wantsSongs, isTrue);
      expect(q.wantsLineUps, isFalse);
      expect(q.wantsActions, isFalse);
      expect(q.keepsSong('g', null), isTrue);
      expect(q.keepsSong('A', 120), isFalse);
    });

    test('removing a token chip leaves the rest', () {
      expect(removeSearchToken('way key:G maker 120bpm', key: true), 'way maker 120bpm');
      expect(removeSearchToken('way key:G maker 120bpm', bpm: true), 'way key:G maker');
    });

    test('line-ups match the ways a date is said', () {
      final now = DateTime(2026, 10, 16);
      const sunday = LineUp(id: 1, title: 'Sunday Service', date: '2026-10-18', worshipLeader: 'Ana');
      expect(lineUpMatchesTerms(sunday, ['sunday'], now: now), isTrue);
      expect(lineUpMatchesTerms(sunday, ['oct', '18'], now: now), isTrue);
      expect(lineUpMatchesTerms(sunday, ['ana'], now: now), isTrue);
      expect(lineUpMatchesTerms(sunday, ['this', 'week'], now: now), isTrue);
      expect(lineUpMatchesTerms(sunday, ['tomorrow'], now: now), isFalse);
      expect(lineUpMatchesTerms(sunday, ['2025'], now: now), isFalse);
    });

    test('destinations by name or keyword', () {
      expect(matchDestinations(['prof']), [SearchDestination.profile]);
      expect(matchDestinations(['chords']), contains(SearchDestination.chordGuide));
    });
  });

  group('repository', () {
    late AppDatabase db;
    late SearchRepository repo;
    final now = DateTime(2026, 10, 16);

    Future<void> addSong(
      int id,
      String title, {
      String? artist,
      String? key,
      int? bpm,
      String? content,
      String? lyrics,
      int ws = 1,
    }) => db
        .into(db.songs)
        .insertOnConflictUpdate(
          SongsCompanion.insert(
            id: Value(id),
            workspaceId: ws,
            title: title,
            artist: Value(artist),
            key: Value(key),
            bpm: Value(bpm),
            content: Value(content),
            lyrics: Value(lyrics),
          ),
        );

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = SearchRepository(db);
      await addSong(1, 'Amazing Grace', artist: 'John Newton', key: 'G', bpm: 72, content: '[G]A[C]mazing grace');
      await addSong(
        2,
        'Way Maker',
        artist: 'Sinach',
        key: 'E',
        bpm: 68,
        lyrics: 'Way maker\nMiracle worker, promise keeper',
      );
      await addSong(
        3,
        'Goodness of God',
        artist: 'Bethel',
        key: 'Ab',
        bpm: 63,
        content: '[Ab]I love you Lord\n[Db]oh Your mercy never fails me',
      );
      await addSong(4, 'Hosanna', key: 'G', bpm: 120, ws: 2, lyrics: 'miracle');
      await addSong(-5, 'Miracle Pending', key: 'G');
      await db
          .into(db.lineUps)
          .insert(
            LineUpsCompanion.insert(id: const Value(10), workspaceId: 1, title: 'Sunday Service', date: '2026-10-18'),
          );
      await db
          .into(db.lineUps)
          .insert(
            LineUpsCompanion.insert(id: const Value(11), workspaceId: 1, title: 'Youth Night', date: '2026-09-01'),
          );
    });

    tearDown(() => db.close());

    Future<SearchResults> search(String input, {SearchScope scope = SearchScope.all}) =>
        repo.search(1, SearchQuery.parse(input, scope: scope), now: now);

    test('titles first, typo-tolerant, scoped to the workspace', () async {
      expect([for (final s in (await search('amazng')).songs) s.title], ['Amazing Grace']);
      expect([for (final s in (await search('sinach')).songs) s.title], ['Way Maker']);
      expect((await search('hosanna')).songs, isEmpty);
    });

    test('finds songs by a line of their words, chords taken out, and says where', () async {
      final miracle = (await search('miracle worker')).lyrics.single;
      expect(miracle.song.title, 'Way Maker');
      expect(miracle.view, SongViewMode.lyrics);
      expect(miracle.line, 1);
      expect(miracle.text, 'Miracle worker, promise keeper');

      final mercy = (await search('mercy fails')).lyrics.single;
      expect(mercy.view, SongViewMode.chords);
      expect(mercy.line, 1);

      // A word split by a chord still matches.
      expect((await search('amazing')).lyrics, isEmpty, reason: 'already shown by title');
      expect((await search('amazing', scope: SearchScope.lyrics)).lyrics.single.song.id, 1);
    });

    test('the index follows edits and deletes', () async {
      await addSong(2, 'Way Maker', artist: 'Sinach', lyrics: 'You are here, moving in our midst');
      expect((await search('miracle')).lyrics, isEmpty);
      expect((await search('midst')).lyrics.single.song.id, 2);
      await (db.delete(db.songs)..where((t) => t.id.equals(2))).go();
      expect((await search('midst')).lyrics, isEmpty);
    });

    test('a song saved again before indexing still saves', () async {
      // The queue row is already there; the trigger must not fail the upsert.
      await addSong(1, 'Amazing Grace', content: '[G]Amazing love');
      await addSong(1, 'Amazing Grace', content: '[G]Amazing love, how can it be');
      expect((await search('love how', scope: SearchScope.lyrics)).lyrics.single.song.id, 1);
    });

    test('key and tempo filter songs and lyric hits', () async {
      expect([for (final s in (await search('key:G')).songs) s.id], [1]);
      expect([for (final s in (await search('70bpm')).songs) s.id], [1, 2]);
      expect((await search('mercy key:G')).lyrics, isEmpty);
      expect((await search('mercy key:Ab')).lyrics.single.song.id, 3);
    });

    test('line-ups by day, coming up first; destinations by name', () async {
      expect([for (final l in (await search('sunday')).lineUps) l.id], [10]);
      expect([for (final l in (await search('service night')).lineUps) l.id], isEmpty);
      final both = await search('sept', scope: SearchScope.lineUps);
      expect(both.lineUps.single.id, 11);
      expect((await search('new song')).destinations, [SearchDestination.newSong]);
    });

    test('recent searches: newest first, case-folded, capped', () async {
      for (var i = 0; i < 10; i++) {
        await repo.remember(1, 'q$i', at: DateTime(2026, 1, 1, 0, i));
      }
      await repo.remember(1, 'Q3', at: DateTime(2026, 1, 2));
      final recent = await repo.watchRecent(1).first;
      expect(recent.first, 'Q3');
      expect(recent, hasLength(8));
      expect(recent.where((q) => q.toLowerCase() == 'q3'), hasLength(1));
      await repo.forget(1, 'Q3');
      expect(await repo.watchRecent(1).first, isNot(contains('Q3')));
    });

    test('OS items: every saved song and line-up; shortcuts start with the next line-up', () async {
      await db
          .into(db.recentSongAccesses)
          .insert(RecentSongAccessesCompanion.insert(songId: const Value(2), workspaceId: 1, lastAccessedAt: now));
      final built = await buildOsSearchItems(db, 1, now: now);
      expect([for (final i in built.items) i.id], ['song:1', 'song:2', 'song:3', 'lineup:10', 'lineup:11']);
      final way = built.items[1];
      expect(way.path, '/songs/2');
      expect(way.description, 'Way maker');
      expect([for (final i in built.shortcuts) i.id], ['lineup:10', 'song:2']);
    });

    test('signing out empties the index', () async {
      await repo.catchUp();
      await db.clearAll();
      final rows = await db.customSelect('SELECT count(*) AS n FROM song_search').getSingle();
      expect(rows.read<int>('n'), 0);
    });
  });
}
