import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/theme/daloy_theme.dart';
import 'package:daloy_flutter/core/utils/formatters.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/line_up_draft.dart';
import 'package:daloy_flutter/features/line_ups/presentation/line_up_edit_screen.dart';
import 'package:daloy_flutter/features/line_ups/presentation/new_line_up_sheet.dart';
import 'package:daloy_flutter/features/line_ups/presentation/widgets/line_up_edit_song_row.dart';
import 'package:daloy_flutter/features/songs/data/songs_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

Future<ProviderContainer> _pump(WidgetTester tester, Widget Function(BuildContext) home) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = await tester.runAsync(
    () => createTestContainer(
      FakeApiAdapter({}),
      overrides: [activeWorkspaceIdProvider.overrideWith((ref) => 1), isOnlineProvider.overrideWithValue(false)],
    ),
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container!,
      child: MaterialApp(
        theme: DaloyTheme.light(),
        home: Scaffold(body: Builder(builder: home)),
      ),
    ),
  );
  return container;
}

void main() {
  testWidgets('the new line-up sheet defaults to next Sunday and offers a title', (tester) async {
    int? created;
    final container = await _pump(
      tester,
      (context) =>
          TextButton(onPressed: () async => created = await showNewLineUpSheet(context), child: const Text('Go')),
    );
    await tester.runAsync(
      () => container
          .read(appDatabaseProvider)
          .into(container.read(appDatabaseProvider).lineUps)
          .insert(
            LineUpsCompanion.insert(
              id: const Value(1),
              workspaceId: 1,
              title: 'Old',
              date: '2026-01-04',
              worshipLeader: const Value('Ana Reyes'),
            ),
          ),
    );

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    final sunday = isoDate(nextSunday());
    expect(find.text('New line-up'), findsOneWidget);
    expect(find.text(DateFormat.yMMMEd().format(DateTime.parse('${sunday}T12:00:00'))), findsOneWidget);

    await tester.tap(find.text(suggestedLineUpTitle(sunday)));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Sunday Service'), findsOneWidget);

    // Leaders from earlier line-ups show once the field has focus.
    await tester.tap(find.widgetWithText(TextField, 'Optional'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana Reyes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(created, isNegative);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the editor transposes, and asks before throwing edits away', (tester) async {
    late final int id;
    final container = await _pump(
      tester,
      (context) => TextButton(
        onPressed: () =>
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LineUpEditScreen(lineUpId: id))),
        child: const Text('Open'),
      ),
    );
    final db = container.read(appDatabaseProvider);
    final lineUps = container.read(lineUpsRepositoryProvider);
    await tester.runAsync(() async {
      for (final (songId, title, key) in [(41, 'Oceans', 'G'), (42, 'Way Maker', null)]) {
        await db
            .into(db.songs)
            .insert(SongsCompanion.insert(id: Value(songId), workspaceId: 1, title: title, key: Value(key)));
      }
      id = await lineUps.createLocal(1, const LineUpDetails(title: 'Sunday Service', date: '2026-10-18'));
      final editable = await lineUps.loadEditable(id);
      final songs = [
        for (final r in await db.select(db.songs).get()) LineUpDraftSong(song: SongsRepository.songFromRow(r)),
      ];
      await lineUps.save(id, editable!.details, songs: songs);
    });

    await tester.tap(find.text('Open'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pumpAndSettle();

    expect(find.text('Edit line-up'), findsOneWidget);
    expect(find.text('Oceans'), findsOneWidget);
    expect(find.text('No key'), findsOneWidget);
    expect(find.textContaining('2 songs'), findsOneWidget);

    // The row's key button — the cover preview above carries the key too.
    await tester.tap(find.descendant(of: find.byType(LineUpEditSongRow), matching: find.text('G')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    expect(find.text('Written in G'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Edit line-up'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
