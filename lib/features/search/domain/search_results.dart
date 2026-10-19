import 'package:intl/intl.dart';

import '../../line_ups/domain/line_up.dart';
import '../../songs/domain/display_prefs.dart';
import '../../songs/domain/song.dart';
import 'search_text.dart';

/// A song found by its words: the line it matched on, and which view
/// (chart or lyrics) that line is in, so opening it can land there.
class LyricHit {
  const LyricHit({required this.song, required this.line, required this.text, required this.view});

  final Song song;

  /// Line within the chart's content or the lyrics, as [view] says.
  final int line;

  /// The line's words, chords taken out.
  final String text;
  final SongViewMode view;
}

/// The app's places and create actions, findable by name — web's "Go to"
/// and "Create" groups.
enum SearchDestination {
  newSong('New song', 'add create song', create: true),
  newLineUp('New line-up', 'add create setlist service line-up', create: true),
  home('Home', 'dashboard'),
  songs('Songs', 'library'),
  lineUps('Line-ups', 'setlists services'),
  profile('Profile & preferences', 'account theme font settings you sign out'),
  switchWorkspace('Switch workspace', 'team church workspace change'),
  chordGuide('Chord syntax guide', 'help chords format brackets');

  const SearchDestination(this.label, this.keywords, {this.create = false});

  final String label;
  final String keywords;
  final bool create;
}

/// Destinations whose name or keywords meet every term.
List<SearchDestination> matchDestinations(List<String> terms) {
  if (terms.isEmpty) return const [];
  return [
    for (final d in SearchDestination.values)
      if (terms.every((t) => words(fold('${d.label} ${d.keywords}')).any((w) => termMeetsWord(t, w) != null))) d,
  ];
}

/// Every grouped result for one query. Groups are kept apart rather than
/// interleaved: no score honestly ranks a song against a line-up.
class SearchResults {
  const SearchResults({
    this.songs = const [],
    this.lyrics = const [],
    this.lineUps = const [],
    this.destinations = const [],
  });

  static const empty = SearchResults();

  final List<Song> songs;
  final List<LyricHit> lyrics;
  final List<LineUp> lineUps;
  final List<SearchDestination> destinations;

  bool get isEmpty => songs.isEmpty && lyrics.isEmpty && lineUps.isEmpty && destinations.isEmpty;
}

/// Whether a line-up matches every term: by title, leader, or its date read
/// the ways people say it — "sunday", "oct", "20", "2026-10-20", "today",
/// "tomorrow".
bool lineUpMatchesTerms(LineUp lineUp, List<String> terms, {required DateTime now}) {
  if (terms.isEmpty) return false;
  final date = DateTime.parse('${lineUp.date}T12:00:00');
  final today = DateTime(now.year, now.month, now.day);
  final days = DateTime(date.year, date.month, date.day).difference(today).inDays;
  final haystack = words(
    fold(
      [
        lineUp.title,
        lineUp.leader ?? '',
        lineUp.date,
        DateFormat.MMMM().format(date),
        DateFormat.EEEE().format(date),
        '${date.day}',
        '${date.year}',
        if (days == 0) 'today',
        if (days == 1) 'tomorrow',
        if (days == -1) 'yesterday',
        if (days >= 0 && days < 7) 'this week',
        if (days >= 7 && days < 14) 'next week',
      ].join(' '),
    ),
  );
  return terms.every((t) => haystack.any((w) => termMeetsWord(t, w) != null) || lineUp.date.contains(t));
}
