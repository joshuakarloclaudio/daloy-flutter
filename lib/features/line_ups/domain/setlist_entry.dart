import 'package:flutter/foundation.dart';

import '../../songs/domain/song.dart';
import 'line_up.dart';

/// One song in a line-up as this device holds it: the library copy of the
/// song, its key for this service, and the team's notes on it.
@immutable
class SetlistEntry {
  const SetlistEntry({
    required this.position,
    required this.song,
    this.lineUpSongId,
    this.transposition = 0,
    this.notes = const [],
    this.sectionArrangement,
  });

  /// 0-based place in the set — also the Drift row's key with the line-up id.
  final int position;
  final Song song;

  /// The server's pivot id; null while the entry only exists on this device.
  final int? lineUpSongId;

  /// Semitones from the song's written key, for this line-up only.
  final int transposition;
  final List<LineUpSongNote> notes;

  /// Section order and cuts for this service; null plays the song as written.
  final SectionArrangement? sectionArrangement;

  @override
  bool operator ==(Object other) =>
      other is SetlistEntry &&
      other.position == position &&
      other.song == song &&
      other.lineUpSongId == lineUpSongId &&
      other.transposition == transposition &&
      listEquals(other.notes, notes) &&
      other.sectionArrangement == sectionArrangement;

  @override
  int get hashCode =>
      Object.hash(position, song, lineUpSongId, transposition, Object.hashAll(notes), sectionArrangement);
}
