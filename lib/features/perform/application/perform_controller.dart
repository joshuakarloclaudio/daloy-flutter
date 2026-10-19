import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../line_ups/application/line_up_detail_controller.dart';
import '../../line_ups/domain/line_up.dart';
import '../../line_ups/domain/setlist_entry.dart';
import '../../songs/application/song_detail_controller.dart';
import '../../songs/chart/nashville.dart';
import '../../songs/domain/display_prefs.dart';
import '../data/perform_prefs_repository.dart';
import '../domain/perform_sections.dart';
import '../domain/perform_theme.dart';

part 'perform_controller.g.dart';

/// What Perform (or Practice) plays: a line-up's set, or one song from the
/// library as a set of one.
@immutable
sealed class PerformSource {
  const PerformSource();

  const factory PerformSource.lineUp(int id) = LineUpSource;
  const factory PerformSource.song(int id) = SongSource;

  /// The line-up, for live sessions; null for a single song.
  int? get lineUpId => switch (this) {
    LineUpSource(:final id) => id,
    SongSource() => null,
  };
}

final class LineUpSource extends PerformSource {
  const LineUpSource(this.id);

  final int id;

  @override
  bool operator ==(Object other) => other is LineUpSource && other.id == id;

  @override
  int get hashCode => Object.hash(LineUpSource, id);
}

final class SongSource extends PerformSource {
  const SongSource(this.id);

  final int id;

  @override
  bool operator ==(Object other) => other is SongSource && other.id == id;

  @override
  int get hashCode => Object.hash(SongSource, id);
}

/// One song as Perform draws it: the setlist row plus its sections in the
/// order this line-up plays them, for the view being shown.
class PerformSong {
  PerformSong({required this.row, required this.viewMode, bool? capoEditable})
    : capoEditable = capoEditable ?? row.canEditCapo;

  final SetlistSong row;
  final SongViewMode viewMode;

  /// The capo can be changed here (a line-up's needs to have synced).
  final bool capoEditable;

  /// The song in the library.
  int get songId => row.entry.song.id;

  String get key => 'song-${row.entry.lineUpSongId ?? 'p${row.position}'}';

  String? get text => switch (viewMode) {
    SongViewMode.chords => row.hasChords ? row.entry.song.content : null,
    SongViewMode.lyrics => row.hasLyrics ? row.entry.song.lyrics : null,
  };

  SectionArrangementField? get _arrangement => switch (viewMode) {
    SongViewMode.chords => row.entry.sectionArrangement?.chords,
    SongViewMode.lyrics => row.entry.sectionArrangement?.lyrics,
  };

  late final List<PerformSection> sections = text == null
      ? const []
      : applyArrangement(groupBySections(text!, key), _arrangement);

  /// Notes are pinned to chord-chart lines; lyrics have none.
  List<LineUpSongNote> get notes => viewMode == SongViewMode.chords ? row.entry.notes : const [];
}

class PerformState {
  const PerformState({
    this.title,
    this.isLoading = true,
    this.notFound = false,
    this.songsMissing = false,
    this.songs = const [],
    this.songIndex = 0,
    this.activeSectionId,
    this.chart = const ChartPrefs(),
    this.notation = ChordNotation.letters,
    this.prefs = const PerformPrefs(),
    this.isSingleSong = false,
  });

  final String? title;

  /// A song from the library rather than a line-up: its key is the song's own.
  final bool isSingleSong;
  final bool isLoading;
  final bool notFound;

  /// The set exists but its songs haven't reached this device.
  final bool songsMissing;
  final List<PerformSong> songs;

  /// Clamped to [songs]; 0 when empty.
  final int songIndex;

  /// The section being played, if one was picked.
  final String? activeSectionId;
  final ChartPrefs chart;

  /// What the user asked for; each song falls back to letters without a key.
  final ChordNotation notation;
  final PerformPrefs prefs;

  PerformSong? get current => songs.isEmpty ? null : songs[songIndex];
  bool get hasPrev => songIndex > 0;
  bool get hasNext => songIndex < songs.length - 1;
  PerformSong? get next => hasNext ? songs[songIndex + 1] : null;
  SongViewMode get viewMode => chart.viewMode;
}

/// Where you are in the set — kept apart from [PerformController], which
/// rebuilds on every Drift write and would otherwise lose it.
@riverpod
class PerformCursor extends _$PerformCursor {
  @override
  ({int songIndex, String? sectionId}) build(PerformSource source) => (songIndex: 0, sectionId: null);

  void goTo(int index) {
    if (index == state.songIndex) return;
    state = (songIndex: index, sectionId: null);
  }

  void selectSection(String? id) => state = (songIndex: state.songIndex, sectionId: id);
}

/// All of Perform's state and actions — the twin of
/// `use-performance-mode-page.ts` for a solo performance. Builds on the
/// line-up detail controller, so keys, capos and display prefs are the same
/// rows the line-up page edits, read from Drift and usable offline.
@riverpod
class PerformController extends _$PerformController {
  @override
  PerformState build(PerformSource source) {
    final cursor = ref.watch(performCursorProvider(source));
    final prefs = ref.watch(performPrefsProvider).value ?? const PerformPrefs();

    final PerformState base;
    switch (source) {
      case LineUpSource(:final id):
        final detail = ref.watch(lineUpDetailControllerProvider(id));
        base = PerformState(
          title: detail.lineUp?.title,
          isLoading: detail.isLoading,
          notFound: detail.notFound,
          songsMissing: detail.songsMissing,
          songs: [for (final row in detail.songs) PerformSong(row: row, viewMode: detail.prefs.viewMode)],
          chart: detail.prefs,
          notation: detail.notation,
        );
      case SongSource(:final id):
        final detail = ref.watch(songDetailControllerProvider(id));
        final song = detail.song;
        base = PerformState(
          title: song?.title,
          isLoading: detail.isLoading,
          notFound: !detail.isLoading && song == null,
          songs: [
            if (song != null)
              PerformSong(
                row: SetlistSong(
                  entry: SetlistEntry(position: 0, song: song, transposition: detail.transposition),
                  number: 1,
                  capo: detail.capo,
                  preferNumbers: (detail.prefs.notation ?? detail.accountNotation) == ChordNotation.numbers,
                ),
                viewMode: detail.prefs.viewMode,
                capoEditable: song.id > 0,
              ),
          ],
          chart: detail.prefs,
          notation: detail.prefs.notation ?? detail.accountNotation,
          isSingleSong: true,
        );
    }

    final index = base.songs.isEmpty ? 0 : cursor.songIndex.clamp(0, base.songs.length - 1);
    return PerformState(
      title: base.title,
      isLoading: base.isLoading,
      notFound: base.notFound,
      songsMissing: base.songsMissing,
      songs: base.songs,
      songIndex: index,
      activeSectionId: cursor.sectionId,
      chart: base.chart,
      notation: base.notation,
      prefs: prefs,
      isSingleSong: base.isSingleSong,
    );
  }

  PerformCursor get _cursor => ref.read(performCursorProvider(source).notifier);
  PerformPrefsRepository get _prefs => ref.read(performPrefsRepositoryProvider);

  // -- Moving through the set -----------------------------------------------

  /// Records the song being read (the screen tracks it as the set scrolls).
  void showSong(int index) {
    if (state.songs.isEmpty) return;
    _cursor.goTo(index.clamp(0, state.songs.length - 1));
  }

  /// Picks the section being played; picking it again clears it.
  void selectSection(String id) => _cursor.selectSection(state.activeSectionId == id ? null : id);

  /// Sets the section outright — where the team is, in a live session.
  void setSection(String? id) => _cursor.selectSection(id);

  // -- The current song's key (for everyone) and capo (just me) ----------------

  void transposeUp() => _onCurrent(lineUp: (d, p) => d.transposeUp(p), song: (d) => d.transposeUp());
  void transposeDown() => _onCurrent(lineUp: (d, p) => d.transposeDown(p), song: (d) => d.transposeDown());
  void resetKey() => _onCurrent(lineUp: (d, p) => d.resetKey(p), song: (d) => d.resetKey());
  void capoUp() => _onCurrent(lineUp: (d, p) => d.capoUp(p), song: (d) => d.capoUp());
  void capoDown() => _onCurrent(lineUp: (d, p) => d.capoDown(p), song: (d) => d.capoDown());

  void _onCurrent({
    required void Function(LineUpDetailController detail, int position) lineUp,
    required void Function(SongDetailController detail) song,
  }) {
    final current = state.current;
    if (current == null) return;
    switch (source) {
      case LineUpSource(:final id):
        lineUp(ref.read(lineUpDetailControllerProvider(id).notifier), current.row.position);
      case SongSource(:final id):
        song(ref.read(songDetailControllerProvider(id).notifier));
    }
  }

  // -- Display (this device) -------------------------------------------------

  Future<void> setViewMode(SongViewMode mode) {
    _cursor.selectSection(null);
    return _display((d) => d.setViewMode(mode), (d) => d.setViewMode(mode));
  }

  Future<void> zoomIn() => _display((d) => d.zoomIn(), (d) => d.zoomIn());
  Future<void> zoomOut() => _display((d) => d.zoomOut(), (d) => d.zoomOut());
  Future<void> setZoom(int zoom) => _display((d) => d.setZoom(zoom), (d) => d.setZoom(zoom));
  Future<void> setNotation(ChordNotation notation) =>
      _display((d) => d.setNotation(notation), (d) => d.setNotation(notation));

  Future<void> _display(
    Future<void> Function(LineUpDetailController detail) lineUp,
    Future<void> Function(SongDetailController detail) song,
  ) => switch (source) {
    LineUpSource(:final id) => lineUp(ref.read(lineUpDetailControllerProvider(id).notifier)),
    SongSource(:final id) => song(ref.read(songDetailControllerProvider(id).notifier)),
  };

  Future<void> setTheme(PerformTheme theme) => _prefs.setTheme(theme);
  Future<void> setAutoHide(bool on) => _prefs.setAutoHide(on);
  Future<void> setNotesVisible(bool on) => _prefs.setNotesVisible(on);
}
