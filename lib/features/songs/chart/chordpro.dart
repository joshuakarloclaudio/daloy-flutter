/// ChordPro ⇄ Daloy. Port of the web's `lib/chordpro.ts`, so a file imports
/// and exports the same on every platform. Pure Dart: no Flutter, no I/O.
///
/// Import reads a ChordPro file into a song's fields: the metadata directives
/// into title/artist/key/tempo/time, the body into a chart (inline chords kept
/// where they land, `{start_of_chorus}` and friends turned into `Chorus:`
/// headers) and lyrics (the same text with the chords taken out, so Present
/// has words to show). Export writes a chart back out as ChordPro.
///
/// Only what Daloy can show is kept. Fonts, chord diagrams (`{define}`), tab
/// and the other embedded-notation blocks are dropped on import.
library;

import '../domain/new_song.dart';
import '../domain/song_list_query.dart' show songKeys;
import '../editor/chart_edit.dart' show formatTypedChordToken;
import 'chart_parser.dart';
import 'chord_math.dart';

class ChordProSong {
  ChordProSong();

  String? title;
  String? artist;
  String? key;
  int? bpm;
  String? timeSignature;

  /// The chart, in Daloy's syntax. Empty when the file has no chords.
  String content = '';

  /// The words alone, with section headers. Empty when there are none.
  String lyrics = '';

  /// Songs after the first in a multi-song file — not imported.
  int skippedSongs = 0;

  bool get isEmpty => content.isEmpty && lyrics.isEmpty && title == null;
}

/// File extensions ChordPro is saved under.
const chordProExtensions = ['cho', 'crd', 'chopro', 'chordpro', 'pro', 'txt'];

// ---------------------------------------------------------------------------
// Import
// ---------------------------------------------------------------------------

final _directive = RegExp(r'^\s*\{\s*([A-Za-z_][\w-]*)\s*(?:[:\s]\s*([^}]*?))?\s*\}\s*$');
final _labelAttr = RegExp(r'^label\s*=\s*"([^"]*)"$', caseSensitive: false);

/// Words a `{comment}` starts with when it is really naming a section.
final _sectionWord = RegExp(
  r'^(intro|verse|pre[- ]?chorus|chorus|post[- ]?chorus|refrain|bridge|tag|outro|ending|interlude|instrumental|turnaround|vamp|hook|breakdown|solo|coda)\b',
  caseSensitive: false,
);

/// Directives only ChordPro itself uses — seeing one means the text is ChordPro.
final _chordProOnly = RegExp(
  r'^(title|t|subtitle|st|artist|key|tempo|time|capo|comment|c|ci|cb|comment_italic|comment_box|highlight|chorus|new_song|ns|start_of_\w+|end_of_\w+|so[cvbtg]|eo[cvbtg]|meta)$',
  caseSensitive: false,
);

const _envShort = {
  'soc': 'chorus',
  'sov': 'verse',
  'sob': 'bridge',
  'sot': 'tab',
  'sog': 'grid',
  'eoc': 'chorus',
  'eov': 'verse',
  'eob': 'bridge',
  'eot': 'tab',
  'eog': 'grid',
};

/// Blocks whose body Daloy has no way to show.
const _droppedEnvs = {'tab', 'abc', 'ly', 'svg', 'textblock', 'musicxml'};

typedef _Directive = ({String name, String value});

_Directive? _parseDirective(String line) {
  final match = _directive.firstMatch(line);
  if (match == null) return null;
  return (name: match[1]!.toLowerCase(), value: (match[2] ?? '').trim());
}

/// `{start_of_verse: Verse 2}` and `{sov label="Verse 2"}` both give "Verse 2".
String _directiveLabel(String value) => (_labelAttr.firstMatch(value)?[1] ?? value).trim();

String? _envStart(String name) {
  if (name.startsWith('start_of_')) return name.substring('start_of_'.length);
  return name.startsWith('so') ? _envShort[name] : null;
}

String? _envEnd(String name) {
  if (name.startsWith('end_of_')) return name.substring('end_of_'.length);
  return name.startsWith('eo') ? _envShort[name] : null;
}

/// Whether pasted text reads as ChordPro rather than a Daloy chart.
bool looksLikeChordPro(String text) => normalizeNewlines(text).split('\n').any((line) {
  final d = _parseDirective(line);
  return d != null && _chordProOnly.hasMatch(d.name);
});

final _keyPattern = RegExp(r'^([A-Ga-g])\s*([#b♯♭]?)\s*(m|min|minor|-)?\s*(?:maj|major)?$', caseSensitive: false);

/// "E minor", "em", "F♯m" → the key as Daloy writes it, or null.
String? normalizeChordProKey(String raw) {
  final match = _keyPattern.firstMatch(raw.trim());
  if (match == null) return null;
  final accidental = switch (match[2]) {
    '♯' => '#',
    '♭' => 'b',
    final a => a ?? '',
  };
  final key = '${match[1]!.toUpperCase()}$accidental${match[3] != null ? 'm' : ''}';
  if (songKeys.contains(key)) return key;
  // The picker spells each key one way; take its spelling when it has one.
  const enharmonic = {'A#': 'Bb', 'D#': 'Eb', 'Gb': 'F#', 'G#': 'Ab', 'A#m': 'Bbm', 'Gbm': 'F#m', 'D#m': 'Ebm'};
  final respelled = enharmonic[key];
  return respelled != null && songKeys.contains(respelled) ? respelled : key;
}

/// One ChordPro chord → Daloy's stored form (`[G]`, `[G]/[B]`), or null when
/// it isn't a chord Daloy can read.
String? chordProChordToDaloy(String raw) {
  final cleaned = raw
      .trim()
      .replaceAll('♯', '#')
      .replaceAll('♭', 'b')
      .replaceAll(RegExp(r'[()]'), '')
      .replaceAll('Δ', 'maj7')
      .replaceAll('ø', 'm7b5')
      .replaceAll('°', 'dim')
      .replaceFirstMapped(RegExp(r'^([A-Ga-g][#b]?)-'), (m) => '${m[1]}m')
      .replaceFirstMapped(RegExp(r'^([A-Ga-g][#b]?)\+'), (m) => '${m[1]}aug')
      .replaceFirstMapped(RegExp(r'^([A-Ga-g][#b]?)o(?=\d|$|/)'), (m) => '${m[1]}dim');
  return cleaned.isEmpty ? null : formatTypedChordToken(cleaned);
}

final _labelRepeat = RegExp(r'^(.*?)[\s:]*\(?\s*(?:[xX×](\d{1,2})|(\d{1,2})\s*[xX×])\s*\)?$');

/// `Chorus (x2)`, `Chorus x2`, `Chorus 2x` → its label and repeat count.
({String label, int repeat}) _splitLabelRepeat(String raw) {
  final match = _labelRepeat.firstMatch(raw.trim());
  if (match == null || (match[1] ?? '').isEmpty) return (label: raw.trim(), repeat: 1);
  final count = int.tryParse(match[2] ?? match[3] ?? '');
  return (label: match[1]!.trim(), repeat: count != null && count >= 1 ? count : 1);
}

/// A header line Daloy reads back as the same section.
String _headerLine(String raw) {
  final (:label, :repeat) = _splitLabelRepeat(raw);
  final suffix = repeat > 1 ? ' x$repeat' : '';
  final plain = label.replaceAll(RegExp(r'[^A-Za-z0-9 -]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (RegExp(r'^[A-Za-z]').hasMatch(plain)) return '$plain:$suffix';
  // Starts with a digit or symbol (`1st Verse`): the bracketed form takes any text.
  return '[${label.replaceAll(RegExp(r'[\[\]]'), '')}]$suffix';
}

String _titleCase(String name) =>
    name.replaceAll('_', ' ').replaceAllMapped(RegExp(r'\b\w'), (m) => m[0]!.toUpperCase()).trim();

/// A ChordPro lyric line with its chords rewritten into Daloy's syntax.
String _convertLyricLine(String line) => line.replaceAllMapped(RegExp(r'\[([^\]]*)\]'), (m) {
  final inner = m[1]!;
  if (inner.trim().startsWith('*')) return ''; // `[*Riff]`: an annotation, not a chord
  final chord = chordProChordToDaloy(inner);
  if (chord != null) return chord;
  // A bracketed section name (`[Chorus]`) means the same thing in Daloy.
  return _sectionWord.hasMatch(inner.trim()) ? '[${inner.trim()}]' : inner;
});

final _gridBar = RegExp(r'^:?\|+[.:]?$|^\|:$|^:\|:?$');

/// `| G . . . | C . . . |` → `| [G] | [C] |`. Beat dots and margin text go.
String _convertGridLine(String line) {
  final out = <String>[];
  for (final token in line.trim().split(RegExp(r'\s+'))) {
    if (token.isEmpty) continue;
    if (_gridBar.hasMatch(token)) {
      out.add('|');
    } else if (RegExp(r'^%+$').hasMatch(token)) {
      out.add('%');
    } else if (RegExp(r'^(?:[xX]\d{1,2}|\d{1,2}[xX])$').hasMatch(token)) {
      out.add(token.toLowerCase());
    } else if (chordProChordToDaloy(token) case final chord?) {
      out.add(chord);
    }
  }
  // Collapse `| |` runs left behind by dropped beats.
  return out.join(' ').replaceAll(RegExp(r'\|(\s+\|)+'), '|');
}

/// Strips a converted line down to its words; null when nothing but chords is left.
String? _lyricOf(String line) {
  final segments = parseLine(line);
  if (segments.any((s) => s.kind == SegmentKind.bar || s.kind == SegmentKind.simile)) return null;
  // Through `chordLyricWords`, so the `/` of a `[G]/[B]` goes with its chord.
  final words = chordLyricWords(segments)
      .expand((w) => w)
      .map((u) => u.section == null ? u.text : '')
      .join()
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return words.isEmpty ? null : words;
}

String _tidy(List<String> lines) => lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

class _Recorded {
  _Recorded(this.label);
  final String label;
  final content = <String>[];
  final lyrics = <String>[];
}

/// Reads one ChordPro song. A multi-song file gives its first song.
ChordProSong parseChordPro(String text) {
  final song = ChordProSong();
  String? subtitle;

  /// First value wins: a later `{title}` is usually a translation or a typo.
  bool applyMetadata(String name, String value) {
    switch (name) {
      case 'title' || 't':
        song.title ??= value.isEmpty ? null : value;
      case 'subtitle' || 'st':
        subtitle ??= value.isEmpty ? null : value;
      case 'artist':
        song.artist ??= value.isEmpty ? null : value;
      case 'key':
        song.key ??= normalizeChordProKey(value);
      case 'tempo':
        final bpm = int.tryParse(value.split(RegExp(r'[^\d]')).first);
        if (bpm != null && NewSong.isValidBpm(bpm)) song.bpm ??= bpm;
      case 'time':
        if (NewSong.timeSignatures.contains(value)) song.timeSignature ??= value;
      default:
        return false;
    }
    return true;
  }

  final lines = normalizeNewlines(text).split('\n');

  // Verses only get numbers when there's more than one to tell apart.
  final unlabeledVerses = lines.where((line) {
    final d = _parseDirective(line);
    return d != null && _envStart(d.name) == 'verse' && _directiveLabel(d.value).isEmpty;
  }).length;
  var verseNumber = 0;

  final content = <String>[];
  final lyrics = <String>[];
  String? env;
  var hasChords = false;
  var hasBody = false;

  /// The last chorus, which `{chorus}` repeats.
  _Recorded? chorus;
  _Recorded? recording;

  void startSection(String label) {
    for (final out in [content, lyrics]) {
      if (out.isNotEmpty && out.last != '') out.add('');
      out.add(_headerLine(label));
    }
  }

  void pushContent(String line, String? lyric) {
    content.add(line);
    recording?.content.add(line);
    if (lyric != null) {
      lyrics.add(lyric);
      recording?.lyrics.add(lyric);
    }
  }

  bool isNewSong(_Directive? d) => d?.name == 'new_song' || d?.name == 'ns';

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (RegExp(r'^\s*#').hasMatch(line)) continue;

    final directive = _parseDirective(line);
    if (directive != null) {
      final (:name, :value) = directive;

      if (isNewSong(directive)) {
        if (!hasBody && song.title == null) continue;
        song.skippedSongs = lines.skip(i).where((l) => isNewSong(_parseDirective(l))).length;
        break;
      }

      if (_envStart(name) case final started?) {
        env = started;
        if (_droppedEnvs.contains(started)) continue;
        final label = _directiveLabel(value);
        String? header = label.isEmpty ? null : label;
        if (header == null) {
          if (started == 'verse') {
            verseNumber += 1;
            header = unlabeledVerses > 1 ? 'Verse $verseNumber' : 'Verse';
          } else if (started != 'grid') {
            header = _titleCase(started);
          }
        }
        if (header != null) startSection(header);
        if (started == 'chorus') {
          chorus = _Recorded(header ?? 'Chorus');
          recording = chorus;
        }
        continue;
      }

      if (_envEnd(name) != null) {
        env = null;
        recording = null;
        continue;
      }

      if (applyMetadata(name, value)) continue;

      switch (name) {
        case 'meta':
          // `{meta: artist Hillsong}` is the long form of `{artist: Hillsong}`.
          final meta = RegExp(r'^(\S+)\s+(.+)$').firstMatch(value);
          if (meta != null) applyMetadata(meta[1]!.toLowerCase(), meta[2]!.trim());
        case 'chorus':
          final label = _directiveLabel(value);
          startSection(label.isNotEmpty ? label : chorus?.label ?? 'Chorus');
          if (chorus != null) {
            content.addAll(chorus.content);
            lyrics.addAll(chorus.lyrics);
          }
          hasBody = true;
        case 'comment' || 'c' || 'comment_italic' || 'ci' || 'comment_box' || 'cb' || 'highlight':
          if (value.isEmpty) continue;
          hasBody = true;
          if (_sectionWord.hasMatch(value)) {
            startSection(value);
          } else {
            // A note for the band: the chart keeps it, the lyrics don't.
            content.add(value.replaceAll(RegExp(r'[\[\]]'), ''));
          }
        default:
          // Fonts, diagrams, page layout, capo (personal in Daloy), anything else.
          break;
      }
      continue;
    }

    if (env != null && _droppedEnvs.contains(env)) continue;

    if (line.trim().isEmpty) {
      if (content.isNotEmpty && content.last != '') pushContent('', '');
      continue;
    }

    hasBody = true;
    if (env == 'grid') {
      final grid = _convertGridLine(line);
      if (grid.isNotEmpty) {
        hasChords = true;
        pushContent(grid, null);
      }
      continue;
    }

    final converted = _convertLyricLine(line);
    if (parseLine(converted).any((s) => s.kind == SegmentKind.chord)) hasChords = true;
    pushContent(converted, _lyricOf(converted));
  }

  song.artist ??= subtitle;
  song.content = hasChords ? _tidy(content) : '';
  final lyricText = _tidy(lyrics);
  // Headers alone aren't lyrics.
  final hasWords = lyricText.split('\n').any((l) => l.trim().isNotEmpty && sectionHeader(parseLine(l)) == null);
  song.lyrics = hasWords ? lyricText : '';
  return song;
}

// ---------------------------------------------------------------------------
// Export
// ---------------------------------------------------------------------------

class ChordProExportSong {
  const ChordProExportSong({
    required this.title,
    this.artist,
    this.key,
    this.bpm,
    this.timeSignature,
    this.content,
    this.lyrics,
    this.transposition = 0,
    this.capo = 0,
  });

  final String title;
  final String? artist;

  /// The written key; [transposition] moves it to the sounding key.
  final String? key;
  final int? bpm;
  final String? timeSignature;

  /// The chart, already arranged for a line-up when it is one.
  final String? content;

  /// Written out instead when the song has no chart.
  final String? lyrics;

  /// Semitones from the written key to the sounding key.
  final int transposition;

  /// The player's capo: the chords are written as the shapes they play.
  final int capo;
}

String? _envFor(String label) {
  if (RegExp(r'^chorus\b', caseSensitive: false).hasMatch(label)) return 'chorus';
  if (RegExp(r'^verse\b', caseSensitive: false).hasMatch(label)) return 'verse';
  if (RegExp(r'^bridge\b', caseSensitive: false).hasMatch(label)) return 'bridge';
  return null;
}

final _slashPair = RegExp(r'\[([^\]/]+)\]/\[([A-G][b#]?)\]');

/// A chart line with every chord transposed and `[G]/[B]` joined as `[G/B]`.
String _chordProLine(String line, int shift) => line
    .replaceAllMapped(RegExp(r'\[([^\]]+)\]'), (m) => isChordToken(m[1]!) ? '[${transposeChord(m[1]!, shift)}]' : m[0]!)
    .replaceAllMapped(_slashPair, (m) => '[${m[1]}/${m[2]}]');

List<String> _chordProBody(String text, int shift) {
  final out = <String>[];
  String? open;

  void close() {
    if (open == null) return;
    var blanks = 0;
    while (out.isNotEmpty && out.last.isEmpty) {
      out.removeLast();
      blanks += 1;
    }
    out.add('{end_of_$open}');
    for (var i = 0; i < blanks; i++) {
      out.add('');
    }
    open = null;
  }

  for (final line in normalizeNewlines(text).split('\n')) {
    if (sectionHeader(parseLine(line)) case (:final label, :final repeat)) {
      close();
      if (out.isNotEmpty && out.last.isNotEmpty) out.add('');
      final shown = repeat > 1 ? '$label x$repeat' : label;
      final env = _envFor(label);
      if (env != null) {
        out.add('{start_of_$env: $shown}');
        open = env;
      } else {
        out.add('{comment: $shown}');
      }
      continue;
    }
    out.add(line.trim().isEmpty ? '' : _chordProLine(line, shift));
  }
  close();
  return out;
}

String _chordProSong(ChordProExportSong song) {
  final artist = song.artist?.trim() ?? '';
  final lines = [
    '{title: ${song.title}}',
    if (artist.isNotEmpty) '{artist: $artist}',
    if (song.key case final key? when key.trim().isNotEmpty) '{key: ${transposeKey(key, song.transposition)}}',
    if (song.bpm case final bpm? when bpm > 0) '{tempo: $bpm}',
    if (song.timeSignature case final time? when time.isNotEmpty) '{time: $time}',
    if (song.capo > 0) '{capo: ${song.capo}}',
  ];
  final chart = (song.content?.trim().isNotEmpty ?? false) ? song.content : null;
  final body = chart ?? ((song.lyrics?.trim().isNotEmpty ?? false) ? song.lyrics : null);
  if (body != null) {
    lines
      ..add('')
      ..addAll(_chordProBody(body, song.transposition - song.capo));
  }
  return _tidy(lines);
}

/// Songs as one ChordPro file, separated by `{new_song}`.
String toChordPro(List<ChordProExportSong> songs) => '${songs.map(_chordProSong).join('\n\n{new_song}\n')}\n';
