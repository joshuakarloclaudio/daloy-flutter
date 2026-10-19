/// Edits the lyrics editor's section chips make. Pure Dart, like `chart_edit`.
library;

import '../chart/chart_parser.dart';

/// The chips above the keyboard, in the order a song usually runs.
const lyricsSectionNames = ['Verse', 'Pre-Chorus', 'Chorus', 'Bridge', 'Tag', 'Outro'];

/// Verses differ from one another, so each gets a number; a chorus is the
/// same words every time and stays plain.
const _numbered = {'Verse'};

/// The label a chip inserts: `Verse 3` when the lyrics already have two
/// verses, `Chorus` otherwise.
String lyricsSectionLabel(String text, String name) {
  if (!_numbered.contains(name)) return name;
  final pattern = RegExp('^${RegExp.escape(name.toLowerCase())}\\b');
  final count = text
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .map((line) => sectionHeader(parseLine(line))?.label)
      .whereType<String>()
      .where((label) => pattern.hasMatch(label.trim().toLowerCase()))
      .length;
  return '$name ${count + 1}';
}

/// Puts a `Name:` header on its own line at the cursor, a blank line apart
/// from the stanza above, and leaves the cursor on the line below it, ready
/// for the words. On a blank line the header takes that line; on a line with
/// words it goes after the line, so nothing typed is split.
({String text, int cursor}) insertLyricsSection(String text, int cursor, String name) {
  final at = cursor.clamp(0, text.length);
  final lineStart = at == 0 ? 0 : text.lastIndexOf('\n', at - 1) + 1;
  final nextBreak = text.indexOf('\n', at);
  final lineEnd = nextBreak == -1 ? text.length : nextBreak;
  final header = '${lyricsSectionLabel(text, name)}:\n';

  if (text.substring(lineStart, lineEnd).trim().isEmpty) {
    final before = text.substring(0, lineStart);
    final pad = before.isEmpty || before.endsWith('\n\n') ? '' : '\n';
    final insert = '$pad$header';
    return (text: before + insert + text.substring(lineEnd), cursor: before.length + insert.length);
  }

  final insert = '\n\n$header';
  return (text: text.substring(0, lineEnd) + insert + text.substring(lineEnd), cursor: lineEnd + insert.length);
}
