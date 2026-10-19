import 'package:daloy_flutter/core/network/api_client.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/utils/formatters.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up_list_query.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late LineUpsRepository repo;
  final today = DateTime.now();
  String day(int offset) => isoDate(DateTime(today.year, today.month, today.day + offset, 12));

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = LineUpsRepository(db, LineUpsService(ApiClient(Dio())));
    Future<void> add(int id, String title, String date, {String? leader, int songs = 0, int ws = 1}) => db
        .into(db.lineUps)
        .insert(
          LineUpsCompanion.insert(
            id: Value(id),
            workspaceId: ws,
            title: title,
            date: date,
            worshipLeader: Value(leader),
            songsCount: Value(songs),
          ),
        );
    await add(1, 'Last month', day(-40), leader: 'Ana', songs: 4);
    await add(2, 'Last week', day(-7), songs: 0);
    await add(3, 'Tonight', day(0), leader: 'Ben', songs: 3);
    await add(4, 'Next week', day(7), songs: 5);
    await add(5, 'Other church', day(1), ws: 2);
  });

  tearDown(() => db.close());

  Future<List<String>> titles(LineUpListQuery q) async => [
    for (final l in await repo.watchLibrary(1, q).first) l.title,
  ];

  test('is scoped to the workspace and ordered newest date first', () async {
    expect(await titles(const LineUpListQuery()), ['Next week', 'Tonight', 'Last week', 'Last month']);
  });

  test('timing and content filters', () async {
    expect(await titles(const LineUpListQuery(timing: LineUpTiming.upcoming)), ['Next week', 'Tonight']);
    expect(await titles(const LineUpListQuery(timing: LineUpTiming.past)), ['Last week', 'Last month']);
    expect(await titles(const LineUpListQuery(content: LineUpContent.empty)), ['Last week']);
    expect(await titles(const LineUpListQuery(content: LineUpContent.hasSongs, timing: LineUpTiming.past)), [
      'Last month',
    ]);
  });

  test('search matches title, leader and date', () async {
    final lastWeek = day(-7);
    expect(await titles(const LineUpListQuery(search: 'ben')), ['Tonight']);
    expect(await titles(const LineUpListQuery(search: 'next')), ['Next week']);
    expect(await titles(LineUpListQuery(search: lastWeek)), ['Last week']);
  });

  group('groupLineUps', () {
    LineUp l(int id, String date) => LineUp(id: id, title: 'L$id', date: date);
    final items = [l(1, '2026-08-30'), l(2, '2026-09-06'), l(3, '2026-09-20'), l(4, '2026-10-15'), l(5, '2026-10-20')];

    test('Coming up is soonest first, earlier months follow newest first', () {
      final sections = groupLineUps(items, today: '2026-10-15', sort: LineUpSort.newestFirst);
      expect([for (final s in sections) s.label], ['Coming up', 'September 2026', 'August 2026']);
      expect([for (final x in sections[0].lineUps) x.id], [4, 5]);
      expect([for (final x in sections[1].lineUps) x.id], [3, 2]);
    });

    test('oldest first flips the earlier months only', () {
      final sections = groupLineUps(items, today: '2026-10-15', sort: LineUpSort.oldestFirst);
      expect([for (final s in sections) s.label], ['Coming up', 'August 2026', 'September 2026']);
      expect([for (final x in sections[0].lineUps) x.id], [4, 5]);
      expect([for (final x in sections[2].lineUps) x.id], [2, 3]);
    });

    test('empty groups are omitted', () {
      expect(
        groupLineUps([l(1, '2026-01-01')], today: '2026-10-15', sort: LineUpSort.newestFirst).single.label,
        'January 2026',
      );
    });
  });
}
