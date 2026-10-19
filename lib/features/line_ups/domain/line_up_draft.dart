import 'package:intl/intl.dart';

import '../../songs/domain/song.dart';

/// What a line-up is besides its songs — the create sheet's fields and the
/// top of the edit screen (`CreateLineUpData` / `UpdateLineUpData`).
class LineUpDetails {
  const LineUpDetails({required this.title, required this.date, this.worshipLeader});

  static const maxTextLength = 255;

  final String title;

  /// `YYYY-MM-DD`.
  final String date;
  final String? worshipLeader;

  static bool isValidTitle(String title) => title.trim().isNotEmpty;

  /// Trimmed, with a blank leader as null.
  LineUpDetails normalized() {
    final leader = worshipLeader?.trim();
    return LineUpDetails(
      title: title.trim(),
      date: date,
      worshipLeader: leader == null || leader.isEmpty ? null : leader,
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'date': date, 'worship_leader': worshipLeader};

  @override
  bool operator ==(Object other) =>
      other is LineUpDetails && other.title == title && other.date == date && other.worshipLeader == worshipLeader;

  @override
  int get hashCode => Object.hash(title, date, worshipLeader);
}

/// One song in a line-up being edited. [song] carries only what a row draws.
class LineUpDraftSong {
  const LineUpDraftSong({required this.song, this.transposition = 0});

  final Song song;
  final int transposition;

  int get songId => song.id;

  LineUpDraftSong withTransposition(int value) => LineUpDraftSong(song: song, transposition: value);

  @override
  bool operator ==(Object other) =>
      other is LineUpDraftSong && other.song.id == song.id && other.transposition == transposition;

  @override
  int get hashCode => Object.hash(song.id, transposition);
}

/// A line-up as the edit screen opens it.
class EditableLineUp {
  const EditableLineUp({required this.id, required this.details, required this.songs, required this.songsKnown});

  final int id;
  final LineUpDetails details;
  final List<LineUpDraftSong> songs;

  /// False when the line-up has songs this device has never fetched (it was
  /// only ever seen offline). Its song list can't be edited then — saving an
  /// empty list would wipe it on the server.
  final bool songsKnown;
}

/// The coming Sunday, or [now] itself on a Sunday — the usual next service.
DateTime nextSunday([DateTime? now]) {
  final base = now ?? DateTime.now();
  final day = DateTime(base.year, base.month, base.day, 12);
  return day.add(Duration(days: (DateTime.sunday - day.weekday) % 7));
}

/// "Sunday Service" for a Sunday — offered while the title is empty.
String suggestedLineUpTitle(String isoDate) =>
    '${DateFormat.EEEE().format(DateTime.parse('${isoDate}T12:00:00'))} Service';
