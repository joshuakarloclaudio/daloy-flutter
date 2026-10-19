import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/session_controller.dart';
import '../../line_ups/data/line_ups_repository.dart';
import '../../line_ups/domain/line_up.dart';
import '../../songs/chart/nashville.dart';
import '../../songs/data/song_detail_repository.dart';
import '../../songs/domain/song.dart';
import '../domain/export_sheet.dart';

/// What to export and how chords are written by default, all read from this
/// device's database so an export never needs a connection.
typedef ExportSource = ({ExportSet set, ChordNotation notation});

/// The chords as written here: this device's choice, else the account's.
Future<ChordNotation> _preferredNotation(WidgetRef ref) async {
  final prefs = await ref.read(songDetailRepositoryProvider).watchPrefs().first;
  return prefs.notation ?? ChordNotation.parse(ref.read(sessionControllerProvider).value?.user.chordNotation);
}

/// A song in its saved key, with this device's capo (the web's export too).
Future<ExportSource> songExportSource(WidgetRef ref, Song song) async {
  final repo = ref.read(songDetailRepositoryProvider);
  final latest = await repo.watchSong(song.id).first ?? song;
  final capo = song.isPending ? 0 : await repo.watchCapo(song.id).first;
  return (
    set: ExportSet.song(ExportSong(song: latest, transposition: latest.transposition ?? 0, capo: capo)),
    notation: await _preferredNotation(ref),
  );
}

/// A line-up's set in order, each song in this service's key and section
/// order. Null when its songs haven't reached this device yet.
Future<ExportSource?> lineUpExportSource(WidgetRef ref, LineUp lineUp) async {
  final setlist = await ref.read(lineUpsRepositoryProvider).watchSetlist(lineUp.id).first;
  if (setlist.isEmpty) return null;
  return (
    set: ExportSet.lineUp(lineUp, [
      for (final e in setlist)
        ExportSong(song: e.song, transposition: e.transposition, arrangement: e.sectionArrangement),
    ]),
    notation: await _preferredNotation(ref),
  );
}
