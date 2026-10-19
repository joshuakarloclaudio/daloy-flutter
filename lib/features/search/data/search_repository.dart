import 'dart:async';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../line_ups/domain/line_up.dart';
import '../../songs/domain/display_prefs.dart';
import '../../songs/domain/song.dart';
import '../domain/search_query.dart';
import '../domain/search_results.dart';
import '../domain/search_text.dart';

part 'search_repository.g.dart';

/// Group sizes on the mixed "All" page; a chip shows up to [_scopedLimit].
const _mixedLimits = (songs: 6, lyrics: 5, lineUps: 4, destinations: 4);
const _scopedLimit = 50;
const _recentLimit = 8;

/// Search over the workspace's offline library: songs by title and artist
/// (ranked in Dart, typo-tolerant), songs by their words (FTS5), line-ups,
/// and the app's destinations. Works with no signal, like everything that
/// reads from Drift.
class SearchRepository {
  SearchRepository(this._db);

  final AppDatabase _db;

  // -- Index ---------------------------------------------------------------

  Future<void>? _draining;

  /// Brings the FTS index up to date with [Songs]: every song the triggers
  /// queued is re-read, its chords stripped, and its row rewritten. Calls
  /// while one is running share it.
  Future<void> catchUp() => _draining ??= _drain().whenComplete(() => _draining = null);

  Future<void> _drain() async {
    while (true) {
      // Read the songs and clear their queue rows in one transaction, so a
      // save landing meanwhile re-queues after us rather than being lost.
      final more = await _db.transaction(() async {
        final queued = await (_db.select(_db.songSearchQueue)..limit(200)).get();
        if (queued.isEmpty) return false;
        final ids = [for (final q in queued) q.songId];
        final rows = await (_db.select(_db.songs)..where((t) => t.id.isIn(ids))).get();
        final byId = {for (final r in rows) r.id: r};
        for (final id in ids) {
          await _db.customStatement('DELETE FROM ${SearchIndexSchema.table} WHERE rowid = ?', [id]);
          final row = byId[id];
          if (row == null) continue;
          await _db.customStatement(
            'INSERT INTO ${SearchIndexSchema.table} (rowid, workspace_id, title, artist, chords, lyrics) '
            'VALUES (?, ?, ?, ?, ?, ?)',
            [
              row.id,
              row.workspaceId,
              row.title,
              row.artist ?? '',
              chartPlainText(row.content ?? ''),
              lyricsPlainText(row.lyrics ?? ''),
            ],
          );
        }
        await (_db.delete(_db.songSearchQueue)..where((t) => t.songId.isIn(ids))).go();
        return true;
      });
      if (!more) return;
    }
  }

  /// Keeps the index current in the background: drains shortly after songs
  /// change, so a search rarely has anything to wait for.
  StreamSubscription<void> keepIndexed() {
    Timer? debounce;
    final sub = _db
        // The queue is filled by SQL triggers, which Drift's change tracking
        // can't see, so this listens to the songs themselves.
        .tableUpdates(TableUpdateQuery.onTable(_db.songs))
        .listen((_) {
          debounce?.cancel();
          debounce = Timer(const Duration(milliseconds: 400), catchUp);
        });
    unawaited(catchUp());
    sub.onDone(() => debounce?.cancel());
    return sub;
  }

  // -- Search --------------------------------------------------------------

  /// [query]'s results, again whenever songs or line-ups change.
  Stream<SearchResults> watch(int workspaceId, SearchQuery query, {DateTime Function()? now}) async* {
    if (query.isEmpty) {
      yield SearchResults.empty;
      return;
    }
    yield await search(workspaceId, query, now: now?.call());
    final changes = _db.tableUpdates(TableUpdateQuery.onAllTables([_db.songs, _db.lineUps]));
    await for (final _ in changes) {
      yield await search(workspaceId, query, now: now?.call());
    }
  }

  Future<SearchResults> search(int workspaceId, SearchQuery query, {DateTime? now}) async {
    if (query.isEmpty) return SearchResults.empty;
    final mixed = query.scope == SearchScope.all;
    final terms = query.terms;

    final songs = query.wantsSongs
        ? await _songsByTitle(workspaceId, query, mixed ? _mixedLimits.songs : _scopedLimit)
        : const <Song>[];
    final lyrics = query.wantsLyrics && query.hasText
        ? await _songsByWords(
            workspaceId,
            query,
            mixed ? _mixedLimits.lyrics : _scopedLimit,
            exclude: {for (final s in songs) s.id},
          )
        : const <LyricHit>[];
    final lineUps = query.wantsLineUps && query.hasText
        ? await _lineUps(workspaceId, terms, mixed ? _mixedLimits.lineUps : _scopedLimit, now ?? DateTime.now())
        : const <LineUp>[];
    final destinations = query.wantsActions
        ? matchDestinations(terms).take(_mixedLimits.destinations).toList()
        : const <SearchDestination>[];
    return SearchResults(songs: songs, lyrics: lyrics, lineUps: lineUps, destinations: destinations);
  }

  /// Title and artist, ranked: the whole query starting the title, then
  /// every word starting a word, then mid-word, then within a typo. A title
  /// match beats the same match on the artist. Ties go A–Z. With only a key
  /// or tempo, every song that passes, A–Z.
  Future<List<Song>> _songsByTitle(int workspaceId, SearchQuery query, int limit) async {
    final s = _db.songs;
    final rows =
        await (_db.selectOnly(s)
              ..addColumns([s.id, s.title, s.artist, s.key, s.bpm, s.isPublic])
              // Songs still waiting for the server can't open their page yet.
              ..where(s.workspaceId.equals(workspaceId) & s.id.isBiggerOrEqualValue(0)))
            .get();
    final terms = query.terms;
    final scored = <(double, Song)>[];
    for (final r in rows) {
      final song = Song(
        id: r.read(s.id)!,
        title: r.read(s.title)!,
        artist: r.read(s.artist),
        key: r.read(s.key),
        bpm: r.read(s.bpm),
        isPublic: r.read(s.isPublic) ?? false,
      );
      if (!query.keepsSong(song.key, song.bpm)) continue;
      if (!query.hasText) {
        scored.add((0, song));
        continue;
      }
      final title = matchScore(song.title, query.text, terms);
      final artist = song.artist == null ? null : matchScore(song.artist!, query.text, terms);
      // Title and artist together, so "way maker sinach" finds it.
      final both = song.artist == null ? null : matchScore('${song.title} ${song.artist}', query.text, terms);
      final best = [
        ?title,
        if (artist != null) artist + 0.5,
        if (both != null) both + 0.75,
      ].fold<double?>(null, (a, b) => a == null || b < a ? b : a);
      if (best != null) scored.add((best, song));
    }
    scored.sort((a, b) {
      final c = a.$1.compareTo(b.$1);
      return c != 0 ? c : a.$2.title.toLowerCase().compareTo(b.$2.title.toLowerCase());
    });
    return [for (final (_, song) in scored.take(limit)) song];
  }

  /// Songs whose chart or lyrics hold every term (each as a word prefix),
  /// best match first, with the line each matched on.
  Future<List<LyricHit>> _songsByWords(
    int workspaceId,
    SearchQuery query,
    int limit, {
    required Set<int> exclude,
  }) async {
    final terms = query.terms;
    final match = '{chords lyrics} : ${terms.map((t) => '"${t.replaceAll('"', '')}"*').join(' ')}';
    final filters = StringBuffer();
    final args = <Variable<Object>>[Variable.withString(match), Variable.withInt(workspaceId)];
    if (query.key != null) {
      filters.write(' AND lower(s.key) = ?');
      args.add(Variable.withString(query.key!.toLowerCase()));
    }
    if (query.bpm != null) {
      filters.write(' AND s.bpm BETWEEN ? AND ?');
      args
        ..add(Variable.withInt(query.bpm!.min))
        ..add(Variable.withInt(query.bpm!.max));
    }
    args.add(Variable.withInt(limit + exclude.length));

    await catchUp();
    final rows = await _db
        .customSelect(
          'SELECT s.* FROM ${SearchIndexSchema.table} f JOIN songs s ON s.id = f.rowid '
          'WHERE ${SearchIndexSchema.table} MATCH ? AND f.workspace_id = ? AND s.id >= 0$filters '
          'ORDER BY bm25(${SearchIndexSchema.table}, 0, 0, 0, 1, 1) LIMIT ?',
          variables: args,
          readsFrom: {_db.songs},
        )
        .get();

    final hits = <LyricHit>[];
    for (final r in rows) {
      final row = _db.songs.map(r.data);
      if (exclude.contains(row.id)) continue;
      final inChart = bestLine(chartPlainText(row.content ?? ''), terms);
      final inLyrics = bestLine(lyricsPlainText(row.lyrics ?? ''), terms);
      final useLyrics = inLyrics != null && (inChart == null || inLyrics.hits > inChart.hits);
      final line = useLyrics ? inLyrics : inChart;
      if (line == null) continue;
      hits.add(
        LyricHit(
          song: Song(id: row.id, title: row.title, artist: row.artist, key: row.key, bpm: row.bpm),
          line: line.line,
          text: line.text,
          view: useLyrics ? SongViewMode.lyrics : SongViewMode.chords,
        ),
      );
      if (hits.length == limit) break;
    }
    return hits;
  }

  /// Coming up soonest first, then the most recent past ones.
  Future<List<LineUp>> _lineUps(int workspaceId, List<String> terms, int limit, DateTime now) async {
    final rows = await (_db.select(_db.lineUps)..where((t) => t.workspaceId.equals(workspaceId))).get();
    final today = isoDate(now);
    final found = [
      for (final r in rows)
        if (lineUpMatchesTerms(
          LineUp(id: r.id, title: r.title, date: r.date, worshipLeader: r.worshipLeader),
          terms,
          now: now,
        ))
          LineUp(
            id: r.id,
            title: r.title,
            date: r.date,
            worshipLeader: r.worshipLeader,
            songsCount: r.songsCount,
            version: r.version,
          ),
    ];
    final upcoming = found.where((l) => l.date.compareTo(today) >= 0).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final past = found.where((l) => l.date.compareTo(today) < 0).toList()..sort((a, b) => b.date.compareTo(a.date));
    return [...upcoming, ...past].take(limit).toList();
  }

  // -- Recent searches -----------------------------------------------------

  Stream<List<String>> watchRecent(int workspaceId) =>
      (_db.select(_db.recentSearches)
            ..where((t) => t.workspaceId.equals(workspaceId))
            ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
            ..limit(_recentLimit))
          .watch()
          .map((rows) => [for (final r in rows) r.query]);

  /// Remembers [query] (trimmed) as the newest, keeping the last few.
  Future<void> remember(int workspaceId, String query, {DateTime? at}) async {
    final q = query.trim();
    if (q.isEmpty) return;
    await _db.transaction(() async {
      // Same words in a different case are the same search.
      await (_db.delete(
        _db.recentSearches,
      )..where((t) => t.workspaceId.equals(workspaceId) & t.query.lower().equals(q.toLowerCase()))).go();
      await _db
          .into(_db.recentSearches)
          .insert(RecentSearchesCompanion.insert(workspaceId: workspaceId, query: q, searchedAt: at ?? DateTime.now()));
      final keep =
          await (_db.select(_db.recentSearches)
                ..where((t) => t.workspaceId.equals(workspaceId))
                ..orderBy([(t) => OrderingTerm.desc(t.searchedAt)])
                ..limit(_recentLimit))
              .get();
      await (_db.delete(
        _db.recentSearches,
      )..where((t) => t.workspaceId.equals(workspaceId) & t.query.isNotIn([for (final k in keep) k.query]))).go();
    });
  }

  Future<void> forget(int workspaceId, String query) =>
      (_db.delete(_db.recentSearches)..where((t) => t.workspaceId.equals(workspaceId) & t.query.equals(query))).go();

  Future<void> forgetAll(int workspaceId) =>
      (_db.delete(_db.recentSearches)..where((t) => t.workspaceId.equals(workspaceId))).go();
}

@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) {
  final repo = SearchRepository(ref.watch(appDatabaseProvider));
  final sub = repo.keepIndexed();
  ref.onDispose(sub.cancel);
  return repo;
}
