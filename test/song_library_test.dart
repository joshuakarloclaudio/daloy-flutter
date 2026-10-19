import 'package:daloy_flutter/core/network/api_client.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:daloy_flutter/features/songs/domain/song.dart';
import 'package:daloy_flutter/features/songs/domain/song_list_query.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SongsRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = SongsRepository(db, SongsService(ApiClient(Dio())));
    Future<void> add(
      int id,
      String title, {
      String? artist,
      String? key,
      String? content,
      String? lyrics,
      int ws = 1,
    }) => db
        .into(db.songs)
        .insert(
          SongsCompanion.insert(
            id: Value(id),
            workspaceId: ws,
            title: title,
            artist: Value(artist),
            key: Value(key),
            content: Value(content),
            lyrics: Value(lyrics),
            createdAt: Value(DateTime(2026, 1, id)),
          ),
        );
    await add(1, 'amazing grace', artist: 'Newton', key: 'G', lyrics: 'How sweet the sound, quietly');
    await add(2, 'Good Good Father', artist: 'Chris Tomlin', key: 'A', content: "[G]Oh I've heard a thousand");
    await add(3, '10,000 Reasons', key: 'G', content: '   ', lyrics: '');
    await add(4, 'Other Church Song', key: 'C', ws: 2);
    await add(5, '100% Pure_Joy', lyrics: 'it is 100% joy');
  });

  tearDown(() => db.close());

  Future<List<String>> titles(SongListQuery q) async => [for (final s in await repo.watchLibrary(1, q).first) s.title];

  test('is scoped to the workspace and sorts A–Z ignoring case', () async {
    expect(await titles(const SongListQuery()), [
      '10,000 Reasons',
      '100% Pure_Joy',
      'amazing grace',
      'Good Good Father',
    ]);
  });

  test('Z–A and recently added', () async {
    expect(await titles(const SongListQuery(sort: SongSort.za)), [
      'Good Good Father',
      'amazing grace',
      '100% Pure_Joy',
      '10,000 Reasons',
    ]);
    expect(await titles(const SongListQuery(sort: SongSort.recent)), [
      '100% Pure_Joy',
      '10,000 Reasons',
      'Good Good Father',
      'amazing grace',
    ]);
  });

  test('search matches title, artist, key and (from 2 letters) lyrics, case-insensitively', () async {
    expect(await titles(const SongListQuery(search: 'GRACE')), ['amazing grace']);
    expect(await titles(const SongListQuery(search: 'tomlin')), ['Good Good Father']);
    expect(await titles(const SongListQuery(search: 'sweet')), ['amazing grace']);
    // One character skips the lyrics column: 'q' is only in lyrics.
    expect(await titles(const SongListQuery(search: 'q')), isEmpty);
    expect(await titles(const SongListQuery(search: 'qu')), ['amazing grace']);
  });

  test('% and _ in a search are literal, not wildcards', () async {
    expect(await titles(const SongListQuery(search: '%')), ['100% Pure_Joy']);
    expect(await titles(const SongListQuery(search: '_')), ['100% Pure_Joy']);
  });

  test('key and content filters', () async {
    expect(await titles(const SongListQuery(key: 'G')), ['10,000 Reasons', 'amazing grace']);
    expect(await titles(const SongListQuery(content: SongContentFilter.hasChords)), ['Good Good Father']);
    expect(await titles(const SongListQuery(content: SongContentFilter.hasLyrics)), ['100% Pure_Joy', 'amazing grace']);
    // Whitespace-only content and empty lyrics still count as a draft.
    expect(await titles(const SongListQuery(content: SongContentFilter.draft)), ['10,000 Reasons']);
  });

  test('recently used puts songs last added to a line-up first, then the rest by title', () async {
    Future<void> used(int id, DateTime at) =>
        (db.update(db.songs)..where((t) => t.id.equals(id))).write(SongsCompanion(lastUsedAt: Value(at)));
    await used(2, DateTime(2026, 2, 1));
    await used(1, DateTime(2026, 3, 1));
    // Opening a song isn't using it.
    await repo.recordOpened(5, 1, at: DateTime(2026, 4, 1));
    expect(await titles(const SongListQuery(sort: SongSort.recentlyUsed)), [
      'amazing grace',
      'Good Good Father',
      '10,000 Reasons',
      '100% Pure_Joy',
    ]);
  });

  test('rows carry only list columns, never the chart or lyrics', () async {
    final Song song = (await repo.watchLibrary(1, const SongListQuery(search: 'good')).first).single;
    expect(song.content, isNull);
    expect(song.lyrics, isNull);
    expect(song.key, 'A');
  });

  test('section letters', () {
    expect(songSectionLetter('amazing grace'), 'A');
    expect(songSectionLetter('  Good'), 'G');
    expect(songSectionLetter('10,000 Reasons'), '#');
    expect(songSectionLetter(''), '#');
  });
}
