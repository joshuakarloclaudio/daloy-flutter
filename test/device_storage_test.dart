import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/utils/formatters.dart';
import 'package:daloy_flutter/features/profile/application/device_data.dart';
import 'package:daloy_flutter/shell/floating_tab_bar.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('library on this device', () {
    late AppDatabase db;
    final at = DateTime(2026, 10, 19);

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      await db.into(db.workspaces).insert(WorkspacesCompanion.insert(id: const Value(1), name: 'Grace', role: 'admin'));
      await db.into(db.displayPrefs).insert(DisplayPrefsCompanion.insert(id: const Value(1)));
      await db.into(db.songs).insert(SongsCompanion.insert(id: const Value(10), workspaceId: 1, title: 'Way Maker'));
      await db.into(db.songs).insert(SongsCompanion.insert(id: const Value(20), workspaceId: 2, title: 'Goodness'));
      await db
          .into(db.lineUps)
          .insert(LineUpsCompanion.insert(id: const Value(5), workspaceId: 2, title: 'Sunday', date: '2026-10-25'));
      await db.markSynced(1, at);
    });

    tearDown(() => db.close());

    test('counts nothing pending on a synced device', () async {
      expect(await db.pendingChangeCount(), 0);
      expect(await db.pendingWorkspaceIds(), isEmpty);
    });

    test('counts every outbox and dirty capo, and which workspaces they belong to', () async {
      await db.into(db.songOutbox).insert(SongOutboxCompanion.insert(workspaceId: 1, createdAt: at));
      await db
          .into(db.songEdits)
          .insert(SongEditsCompanion.insert(songId: const Value(20), workspaceId: 2, updatedAt: at));
      await db
          .into(db.lineUpPrepOutbox)
          .insert(LineUpPrepOutboxCompanion.insert(lineUpId: 5, songId: 20, kind: 'chords', updatedAt: at));
      await db.into(db.songCapos).insert(SongCaposCompanion.insert(songId: const Value(10), dirty: const Value(true)));
      await db.into(db.songCapos).insert(SongCaposCompanion.insert(songId: const Value(20)));

      expect(await db.pendingChangeCount(), 4);
      expect(await db.pendingWorkspaceIds(), {1, 2});
    });

    test('deviceData counts the library and sizes it by kind', () async {
      final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
      addTearDown(container.dispose);
      final sub = container.listen(deviceDataProvider, (_, _) {});
      addTearDown(sub.close);

      final data = await container.read(deviceDataProvider.future);
      expect((data.songs, data.lineUps, data.workspaces, data.pendingChanges), (2, 1, 2, 0));
      expect(data.storage.songs, greaterThan(0));
      expect(data.storage.lineUps, greaterThan(0));
      expect(data.storage.total, greaterThanOrEqualTo(data.storage.songs + data.storage.lineUps));
    });

    test('clearLibrary empties the library but keeps the workspaces and prefs', () async {
      await db.clearLibrary();

      expect(await db.select(db.songs).get(), isEmpty);
      expect(await db.select(db.lineUps).get(), isEmpty);
      expect(await db.lastSyncedAt(1), isNull);
      expect(await db.select(db.workspaces).get(), hasLength(1));
      expect(await db.select(db.displayPrefs).get(), hasLength(1));
    });
  });

  test('bytesParts picks the unit that keeps it short', () {
    expect(bytesParts(512), (value: '512', unit: 'B'));
    expect(bytesParts(4300), (value: '4.2', unit: 'KB'));
    expect(bytesParts(5 * 1024 * 1024), (value: '5.0', unit: 'MB'));
    expect(bytesParts(150 * 1024 * 1024), (value: '150', unit: 'MB'));
    expect(formatBytes(0), '0 B');
    expect(changesLabel(1), '1 change');
  });

  test('the tab bar clears a three-button nav bar but dips into a home indicator', () {
    // Gesture handle (Android), home indicator (iPhone), no inset.
    expect(FloatingGlassTabBar.insetFor(24), 18 + FloatingGlassTabBar.height);
    expect(FloatingGlassTabBar.insetFor(34), 28 + FloatingGlassTabBar.height);
    expect(FloatingGlassTabBar.insetFor(0), 12 + FloatingGlassTabBar.height);
    // Three-button nav: the whole bar sits above the buttons.
    expect(FloatingGlassTabBar.insetFor(48), 56 + FloatingGlassTabBar.height);
  });
}
