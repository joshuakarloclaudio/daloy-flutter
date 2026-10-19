import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/features/home_screen_widget/home_screen_widget.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 19, 9);

  Future<void> lineUp(int id, String date, {int songsCount = 0, bool loaded = false, int workspaceId = 1}) => db
      .into(db.lineUps)
      .insert(
        LineUpsCompanion.insert(
          id: Value(id),
          workspaceId: workspaceId,
          title: 'Set $id',
          date: date,
          worshipLeader: const Value('  Ana '),
          songsCount: Value(songsCount),
          songsLoaded: Value(loaded),
        ),
      );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db
        .into(db.songs)
        .insert(SongsCompanion.insert(id: const Value(1), workspaceId: 1, title: 'Way Maker', key: const Value('G')));
    await db.into(db.songs).insert(SongsCompanion.insert(id: const Value(2), workspaceId: 1, title: 'Goodness'));
  });
  tearDown(() => db.close());

  test('the next line-ups from today on, soonest first, without unsent ones or other workspaces', () async {
    await lineUp(1, '2026-10-12');
    await lineUp(2, '2026-10-26');
    await lineUp(3, '2026-10-19');
    await lineUp(-4, '2026-10-20');
    await lineUp(5, '2026-10-21', workspaceId: 2);
    await lineUp(6, '2026-11-02');
    await lineUp(7, '2026-11-09');

    final upcoming = await upcomingForHomeWidget(db, 1, now: now);
    expect([for (final l in upcoming) l.id], [3, 2, 6]);
    expect(upcoming.first.leader, 'Ana');
    expect(upcoming.first.toJson()['path'], '/line-ups/3');
  });

  test('songs come in order and in this line-up\'s key; unfetched sets carry only a count', () async {
    await lineUp(1, '2026-10-26', songsCount: 2, loaded: true);
    await lineUp(2, '2026-11-02', songsCount: 5);
    await db.into(db.lineUpSongs).insert(LineUpSongsCompanion.insert(lineUpId: 1, position: 1, songId: 2));
    await db
        .into(db.lineUpSongs)
        .insert(LineUpSongsCompanion.insert(lineUpId: 1, position: 0, songId: 1, transposition: const Value(2)));

    final upcoming = await upcomingForHomeWidget(db, 1, now: now);
    expect(upcoming[0].songs, [(title: 'Way Maker', key: 'A'), (title: 'Goodness', key: null)]);
    expect(upcoming[1].songs, isNull);
    expect(upcoming[1].songsCount, 5);
  });

  test('signed out, the widget only opens the app', () {
    final json = const HomeWidgetSnapshot().toJson();
    expect(json['workspace'], isNull);
    expect(json['lineUps'], isEmpty);
    expect(json['newLineUpPath'], '/line-ups?new=1');
  });
}
