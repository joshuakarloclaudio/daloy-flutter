import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/app_database.dart';
import '../domain/perform_theme.dart';

part 'perform_prefs_repository.g.dart';

/// How Perform looks on this device. Never synced: a stage tablet and a
/// phone in the pew want different things.
@immutable
class PerformPrefs {
  const PerformPrefs({
    this.theme = PerformTheme.appDefault,
    this.autoHide = true,
    this.notesVisible = true,
    this.liveAutoReturn = true,
    this.practiceClick = true,
    this.practiceHaptics = false,
    this.practiceFlash = true,
  });

  final PerformTheme theme;

  /// Chrome fades out after a few idle seconds; a tap brings it back.
  final bool autoHide;
  final bool notesVisible;

  /// Live sessions: scrolled away by hand, go back to the team after a few
  /// idle seconds.
  final bool liveAutoReturn;

  /// Practice: the metronome is heard. Off, the clock still runs silently.
  final bool practiceClick;

  /// Practice: a haptic tick on every beat.
  final bool practiceHaptics;

  /// Practice: the playing bar pulses on the beat.
  final bool practiceFlash;

  PerformPrefs copyWithPractice({bool? click, bool? haptics, bool? flash}) => PerformPrefs(
    theme: theme,
    autoHide: autoHide,
    notesVisible: notesVisible,
    liveAutoReturn: liveAutoReturn,
    practiceClick: click ?? practiceClick,
    practiceHaptics: haptics ?? practiceHaptics,
    practiceFlash: flash ?? practiceFlash,
  );

  @override
  bool operator ==(Object other) =>
      other is PerformPrefs &&
      other.theme == theme &&
      other.autoHide == autoHide &&
      other.notesVisible == notesVisible &&
      other.liveAutoReturn == liveAutoReturn &&
      other.practiceClick == practiceClick &&
      other.practiceHaptics == practiceHaptics &&
      other.practiceFlash == practiceFlash;

  @override
  int get hashCode =>
      Object.hash(theme, autoHide, notesVisible, liveAutoReturn, practiceClick, practiceHaptics, practiceFlash);
}

/// Perform's columns of the one-row `DisplayPrefs` table.
class PerformPrefsRepository {
  PerformPrefsRepository(this._db);

  final AppDatabase _db;

  Stream<PerformPrefs> watch() => (_db.select(_db.displayPrefs)..where((t) => t.id.equals(1))).watchSingleOrNull().map(
    (row) => row == null
        ? const PerformPrefs()
        : PerformPrefs(
            theme: PerformTheme.parse(row.performTheme),
            autoHide: row.performAutoHide,
            notesVisible: row.performNotes,
            liveAutoReturn: row.liveAutoReturn,
            practiceClick: row.practiceClick,
            practiceHaptics: row.practiceHaptics,
            practiceFlash: row.practiceFlash,
          ),
  );

  Future<void> _write(DisplayPrefsCompanion change) async {
    final updated = await (_db.update(_db.displayPrefs)..where((t) => t.id.equals(1))).write(change);
    if (updated == 0) await _db.into(_db.displayPrefs).insert(change.copyWith(id: const Value(1)));
  }

  Future<void> setTheme(PerformTheme theme) =>
      _write(DisplayPrefsCompanion(performTheme: Value(theme == PerformTheme.appDefault ? null : theme.name)));

  Future<void> setAutoHide(bool on) => _write(DisplayPrefsCompanion(performAutoHide: Value(on)));

  Future<void> setNotesVisible(bool on) => _write(DisplayPrefsCompanion(performNotes: Value(on)));

  Future<void> setLiveAutoReturn(bool on) => _write(DisplayPrefsCompanion(liveAutoReturn: Value(on)));

  Future<void> setPracticeClick(bool on) => _write(DisplayPrefsCompanion(practiceClick: Value(on)));

  Future<void> setPracticeHaptics(bool on) => _write(DisplayPrefsCompanion(practiceHaptics: Value(on)));

  Future<void> setPracticeFlash(bool on) => _write(DisplayPrefsCompanion(practiceFlash: Value(on)));
}

@Riverpod(keepAlive: true)
PerformPrefsRepository performPrefsRepository(Ref ref) => PerformPrefsRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<PerformPrefs> performPrefs(Ref ref) => ref.watch(performPrefsRepositoryProvider).watch();
