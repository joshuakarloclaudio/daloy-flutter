import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/uuid.dart';
import '../../songs/chart/chart_sections.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up.dart';
import '../domain/prep_arrangement.dart';
import 'line_up_detail_controller.dart';

part 'line_up_prepare_controller.g.dart';

/// The longest note the server takes.
const noteMaxLength = 500;

/// One song on the Prepare screen: the set's row, its sections in each view
/// as this line-up plays them, and whether its prep is still on its way.
class PrepareSong {
  const PrepareSong({required this.song, required this.chords, required this.lyrics, this.pending = false, this.error});

  final SetlistSong song;
  final List<PrepSection> chords;
  final List<PrepSection> lyrics;

  /// Notes or arrangement changed here, not yet on the server.
  final bool pending;

  /// Why the server last refused them.
  final String? error;

  int get songId => song.entry.song.id;
  List<LineUpSongNote> get notes => song.entry.notes;

  List<PrepSection> sectionsFor(SongArrangementView view) => switch (view) {
    SongArrangementView.chords => chords,
    SongArrangementView.lyrics => lyrics,
  };

  bool rearranged(SongArrangementView view) => isRearranged(sectionsFor(view));
}

class LineUpPrepareState {
  const LineUpPrepareState({required this.detail, this.songs = const []});

  /// The line-up as its details screen sees it (key, capo, notation, zoom).
  final LineUpDetailState detail;
  final List<PrepareSong> songs;

  LineUp? get lineUp => detail.lineUp;
  bool get isLoading => detail.isLoading;
  bool get notFound => detail.notFound;
  bool get songsMissing => detail.songsMissing;

  int get pendingCount => songs.where((s) => s.pending).length;
  String? get error => songs.map((s) => s.error).nonNulls.firstOrNull;
}

@riverpod
Stream<Map<int, String?>> lineUpPrepOutbox(Ref ref, int lineUpId) =>
    ref.watch(lineUpsRepositoryProvider).watchPrepOutbox(lineUpId);

/// The Prepare screen: the team's notes and each song's section order for
/// this line-up. Every change lands on the device at once and is queued for
/// the server — no Save step, and it works offline.
@riverpod
class LineUpPrepareController extends _$LineUpPrepareController {
  @override
  LineUpPrepareState build(int lineUpId) {
    final detail = ref.watch(lineUpDetailControllerProvider(lineUpId));
    final outbox = ref.watch(lineUpPrepOutboxProvider(lineUpId)).value ?? const {};
    return LineUpPrepareState(
      detail: detail,
      songs: [
        for (final s in detail.songs)
          PrepareSong(
            song: s,
            chords: _sections(s, SongArrangementView.chords),
            lyrics: _sections(s, SongArrangementView.lyrics),
            pending: outbox.containsKey(s.entry.song.id),
            error: outbox[s.entry.song.id],
          ),
      ],
    );
  }

  static List<PrepSection> _sections(SetlistSong s, SongArrangementView view) {
    final text = view == SongArrangementView.chords ? s.entry.song.content : s.entry.song.lyrics;
    if (text == null || text.trim().isEmpty) return const [];
    final arrangement = s.entry.sectionArrangement;
    return prepSections(
      groupBySections(text, 'song-${s.entry.song.id}'),
      view == SongArrangementView.chords ? arrangement?.chords : arrangement?.lyrics,
    );
  }

  LineUpsRepository get _repo => ref.read(lineUpsRepositoryProvider);

  PrepareSong? _song(int songId) => state.songs.where((s) => s.songId == songId).firstOrNull;

  // -- Arrangement ----------------------------------------------------------

  Future<void> moveSection(int songId, SongArrangementView view, int from, int to) async {
    final song = _song(songId);
    if (song == null || from == to) return;
    await _repo.setArrangement(lineUpId, songId, view, movedSection(song.sectionsFor(view), from, to));
  }

  /// Cuts a section from this line-up, or brings it back.
  Future<void> toggleSection(int songId, SongArrangementView view, int originalIndex) async {
    final song = _song(songId);
    if (song == null) return;
    await _repo.setArrangement(lineUpId, songId, view, toggledSection(song.sectionsFor(view), originalIndex));
  }

  /// Back to the song as written. Returns what it was, for undo.
  Future<SectionArrangementField?> resetArrangement(int songId, SongArrangementView view) async {
    final song = _song(songId);
    if (song == null || !song.rearranged(view)) return null;
    final arrangement = song.song.entry.sectionArrangement ?? const SectionArrangement();
    final before = view == SongArrangementView.chords ? arrangement.chords : arrangement.lyrics;
    await _repo.setArrangement(lineUpId, songId, view, const SectionArrangementField());
    return before;
  }

  Future<void> restoreArrangement(int songId, SongArrangementView view, SectionArrangementField field) =>
      _repo.setArrangement(lineUpId, songId, view, field);

  // -- Notes ----------------------------------------------------------------

  /// Adds a note before chart line [line] (counted from the top of the song),
  /// or rewrites [existing]. False when [existing] was deleted meanwhile (on
  /// another device): it isn't brought back.
  Future<bool> saveNote(int songId, {required int line, required String text, LineUpSongNote? existing}) async {
    final song = _song(songId);
    final trimmed = text.trim();
    if (song == null || trimmed.isEmpty || trimmed.length > noteMaxLength) return true;
    final notes = [...song.notes];
    if (existing != null) {
      final at = notes.indexWhere((n) => n.id == existing.id);
      if (at < 0) return false;
      notes[at] = notes[at].copyWith(text: trimmed);
    } else {
      notes.add(LineUpSongNote(id: uuidV4(), line: line, text: trimmed));
    }
    await _repo.setNotes(lineUpId, songId, notes);
    return true;
  }

  /// Returns the notes as they were, for undo.
  Future<List<LineUpSongNote>?> deleteNote(int songId, LineUpSongNote note) async {
    final song = _song(songId);
    if (song == null) return null;
    final before = song.notes;
    await _repo.setNotes(lineUpId, songId, [
      for (final n in before)
        if (n.id != note.id) n,
    ]);
    return before;
  }

  Future<void> restoreNotes(int songId, List<LineUpSongNote> notes) => _repo.setNotes(lineUpId, songId, notes);
}
