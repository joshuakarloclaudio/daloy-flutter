/// Present's deck: lyric slides, where the room is in them, and how they
/// look. One value, sent whole to the projector screen and to a paired
/// remote on every change (the web's `PresentDeckState` in
/// `lib/present-sync.ts`). Port of `lib/present-slides.ts` plus the
/// auto-split. Pure Dart.
library;

import 'package:flutter/foundation.dart';

import '../../line_ups/domain/line_up.dart';
import '../../perform/domain/perform_sections.dart';

enum PresentTheme {
  cinema('Cinema'),
  sanctuary('Sanctuary'),
  dawn('Dawn'),
  paper('Paper'),
  stage('Stage');

  const PresentTheme(this.label);
  final String label;

  static PresentTheme parse(String? value) => values.asNameMap()[value] ?? cinema;
}

enum PresentFont {
  sans('Sans'),
  serif('Serif');

  const PresentFont(this.label);
  final String label;

  static PresentFont parse(String? value) => values.asNameMap()[value] ?? sans;
}

/// How the slides look. Kept per device.
@immutable
class PresentLook {
  const PresentLook({
    this.theme = PresentTheme.cinema,
    this.font = PresentFont.sans,
    this.zoom = defaultZoom,
    this.linesPerSlide = defaultLinesPerSlide,
  });

  static const minZoom = 70;
  static const maxZoom = 200;
  static const zoomStep = 10;
  static const defaultZoom = 100;

  static const linesPerSlideOptions = [2, 4, 6];
  static const defaultLinesPerSlide = 4;

  final PresentTheme theme;
  final PresentFont font;

  /// Percent of the base lyric size.
  final int zoom;

  /// Longer sections are split across slides.
  final int linesPerSlide;

  bool get canZoomIn => zoom < maxZoom;
  bool get canZoomOut => zoom > minZoom;

  PresentLook copyWith({PresentTheme? theme, PresentFont? font, int? zoom, int? linesPerSlide}) => PresentLook(
    theme: theme ?? this.theme,
    font: font ?? this.font,
    zoom: (zoom ?? this.zoom).clamp(minZoom, maxZoom),
    linesPerSlide: linesPerSlide ?? this.linesPerSlide,
  );

  Map<String, Object?> toJson() => {
    'theme': theme.name,
    'font': font.name,
    'zoom': zoom,
    'linesPerSlide': linesPerSlide,
  };

  factory PresentLook.fromJson(Map<String, Object?> json) => PresentLook(
    theme: PresentTheme.parse(json['theme'] as String?),
    font: PresentFont.parse(json['font'] as String?),
    zoom: ((json['zoom'] as num?)?.toInt() ?? defaultZoom).clamp(minZoom, maxZoom),
    linesPerSlide: linesPerSlideOptions.contains(json['linesPerSlide'])
        ? json['linesPerSlide']! as int
        : defaultLinesPerSlide,
  );

  @override
  bool operator ==(Object other) =>
      other is PresentLook &&
      other.theme == theme &&
      other.font == font &&
      other.zoom == zoom &&
      other.linesPerSlide == linesPerSlide;

  @override
  int get hashCode => Object.hash(theme, font, zoom, linesPerSlide);
}

/// One slide: a section of a song's lyrics, or part of one.
@immutable
class PresentSlide {
  const PresentSlide({
    required this.songIndex,
    required this.songTitle,
    required this.sectionId,
    this.displayKey,
    this.tempo,
    this.label = '',
    this.lines = const [],
    this.part = 1,
    this.parts = 1,
  });

  final int songIndex;
  final String songTitle;

  /// The section this slide comes from — finds the same place again when
  /// the split changes.
  final String sectionId;

  /// For the operator, never the slide.
  final String? displayKey;
  final String? tempo;
  final String label;

  /// Empty for a song without lyrics.
  final List<String> lines;

  /// Which piece of a split section this is, of [parts].
  final int part;
  final int parts;

  /// "Chorus 2/3" when split; the label as written otherwise.
  String get fullLabel => parts > 1 ? (label.isEmpty ? '$part/$parts' : '$label $part/$parts') : label;

  /// A few lines to tell the slide apart in a list.
  List<String> previewLines([int max = 2]) {
    final words = lines.where((l) => l.trim().isNotEmpty).take(max).toList();
    if (words.isNotEmpty) return words;
    return [if (label.isNotEmpty) label else songTitle];
  }

  Map<String, Object?> toJson() => {
    'songIndex': songIndex,
    'songTitle': songTitle,
    'sectionId': sectionId,
    'displayKey': displayKey,
    'tempo': tempo,
    'label': label,
    'lines': lines,
    'part': part,
    'parts': parts,
  };

  factory PresentSlide.fromJson(Map<String, Object?> json) => PresentSlide(
    songIndex: (json['songIndex'] as num?)?.toInt() ?? 0,
    songTitle: json['songTitle'] as String? ?? '',
    sectionId: json['sectionId'] as String? ?? '',
    displayKey: json['displayKey'] as String?,
    tempo: json['tempo'] as String?,
    label: json['label'] as String? ?? '',
    lines: [for (final l in json['lines'] as List? ?? const []) '$l'],
    part: (json['part'] as num?)?.toInt() ?? 1,
    parts: (json['parts'] as num?)?.toInt() ?? 1,
  );

  @override
  bool operator ==(Object other) =>
      other is PresentSlide &&
      other.songIndex == songIndex &&
      other.songTitle == songTitle &&
      other.sectionId == sectionId &&
      other.displayKey == displayKey &&
      other.tempo == tempo &&
      other.label == label &&
      listEquals(other.lines, lines) &&
      other.part == part &&
      other.parts == parts;

  @override
  int get hashCode =>
      Object.hash(songIndex, songTitle, sectionId, displayKey, tempo, label, Object.hashAll(lines), part, parts);
}

/// A song as Present takes it.
@immutable
class PresentSong {
  const PresentSong({
    required this.key,
    required this.title,
    this.lyrics,
    this.displayKey,
    this.tempo,
    this.arrangement,
  });

  /// Scopes section ids (`song-<lineUpSongId>`).
  final String key;
  final String title;
  final String? lyrics;
  final String? displayKey;
  final String? tempo;
  final SectionArrangementField? arrangement;
}

/// Every song's slides in set order. A section longer than [linesPerSlide]
/// is split evenly (6 lines at 4 a slide → 3 + 3), and a song without
/// lyrics still gets one empty slide so the set keeps its place.
List<PresentSlide> buildSlides(List<PresentSong> songs, {int linesPerSlide = PresentLook.defaultLinesPerSlide}) => [
  for (final (i, song) in songs.indexed) ..._songSlides(song, i, linesPerSlide),
];

List<PresentSlide> _songSlides(PresentSong song, int index, int perSlide) {
  PresentSlide slide(
    String sectionId, {
    String label = '',
    List<String> lines = const [],
    int part = 1,
    int parts = 1,
  }) => PresentSlide(
    songIndex: index,
    songTitle: song.title,
    sectionId: sectionId,
    displayKey: song.displayKey,
    tempo: song.tempo,
    label: label,
    lines: lines,
    part: part,
    parts: parts,
  );

  final lyrics = song.lyrics?.trim();
  if (lyrics == null || lyrics.isEmpty) return [slide('${song.key}-empty')];

  final slides = <PresentSlide>[];
  for (final section in applyArrangement(groupBySections(lyrics, song.key), song.arrangement)) {
    final lines = _trimBlank(section.lines);
    if (lines.isEmpty && section.label.isEmpty) continue;
    final chunks = splitEvenly(lines, perSlide);
    for (final (p, chunk) in chunks.indexed) {
      slides.add(slide(section.id, label: section.label, lines: chunk, part: p + 1, parts: chunks.length));
    }
  }
  return slides.isEmpty ? [slide('${song.key}-empty')] : slides;
}

List<String> _trimBlank(List<String> lines) {
  var start = 0;
  var end = lines.length;
  while (start < end && lines[start].trim().isEmpty) {
    start++;
  }
  while (end > start && lines[end - 1].trim().isEmpty) {
    end--;
  }
  return lines.sublist(start, end);
}

/// [lines] in as few pieces of at most [max] as it takes, as even as they
/// can be, earlier pieces taking the extra line.
List<List<String>> splitEvenly(List<String> lines, int max) {
  if (lines.length <= max || max < 1) return [lines];
  final pieces = (lines.length / max).ceil();
  final base = lines.length ~/ pieces;
  final extra = lines.length % pieces;
  final out = <List<String>>[];
  var at = 0;
  for (var i = 0; i < pieces; i++) {
    final size = base + (i < extra ? 1 : 0);
    out.add(lines.sublist(at, at + size));
    at += size;
  }
  return out;
}

/// [at]'s place in [slides] after they were rebuilt (a song edited, a
/// different split): the same slide, else the same share of the way through
/// its section, else where [index] was.
int locateSlide(PresentSlide? at, int index, List<PresentSlide> slides) {
  if (slides.isEmpty) return 0;
  if (at == null) return index.clamp(0, slides.length - 1);
  final same = slides.indexOf(at);
  if (same >= 0) return same;
  final section = [
    for (final (i, s) in slides.indexed)
      if (s.songIndex == at.songIndex && s.sectionId == at.sectionId) i,
  ];
  if (section.isEmpty) return index.clamp(0, slides.length - 1);
  return section[((at.part - 1) / at.parts * section.length).floor().clamp(0, section.length - 1)];
}

/// One song in the deck's song list.
typedef PresentSongEntry = ({int songIndex, String title, String? displayKey, int firstSlide});

/// Everything a screen needs to draw the deck or drive it.
@immutable
class PresentDeckState {
  const PresentDeckState({
    this.title = '',
    this.slides = const [],
    this.index = 0,
    this.blanked = false,
    this.look = const PresentLook(),
  });

  final String title;
  final List<PresentSlide> slides;
  final int index;

  /// The projector shows only the background.
  final bool blanked;
  final PresentLook look;

  PresentSlide? get current => slides.isEmpty ? null : slides[index.clamp(0, slides.length - 1)];
  PresentSlide? get next => index + 1 < slides.length ? slides[index + 1] : null;
  bool get hasPrev => index > 0;
  bool get hasNext => index < slides.length - 1;

  List<PresentSongEntry> get songs {
    final out = <PresentSongEntry>[];
    for (final (i, s) in slides.indexed) {
      if (out.isEmpty || out.last.songIndex != s.songIndex) {
        out.add((songIndex: s.songIndex, title: s.songTitle, displayKey: s.displayKey, firstSlide: i));
      }
    }
    return out;
  }

  PresentDeckState copyWith({String? title, List<PresentSlide>? slides, int? index, bool? blanked, PresentLook? look}) {
    final nextSlides = slides ?? this.slides;
    final nextIndex = index ?? this.index;
    return PresentDeckState(
      title: title ?? this.title,
      slides: nextSlides,
      index: nextSlides.isEmpty ? 0 : nextIndex.clamp(0, nextSlides.length - 1),
      blanked: blanked ?? this.blanked,
      look: look ?? this.look,
    );
  }

  Map<String, Object?> toJson() => {
    'title': title,
    'slides': [for (final s in slides) s.toJson()],
    'index': index,
    'blanked': blanked,
    'look': look.toJson(),
  };

  factory PresentDeckState.fromJson(Map<String, Object?> json) => PresentDeckState(
    title: json['title'] as String? ?? '',
    slides: [for (final s in json['slides'] as List? ?? const []) PresentSlide.fromJson((s as Map).cast())],
    index: (json['index'] as num?)?.toInt() ?? 0,
    blanked: json['blanked'] == true,
    look: PresentLook.fromJson(((json['look'] as Map?) ?? const {}).cast()),
  );

  @override
  bool operator ==(Object other) =>
      other is PresentDeckState &&
      other.title == title &&
      listEquals(other.slides, slides) &&
      other.index == index &&
      other.blanked == blanked &&
      other.look == look;

  @override
  int get hashCode => Object.hash(title, Object.hashAll(slides), index, blanked, look);
}

/// What any control surface — this device, a pedal, a paired remote — asks
/// the deck to do.
@immutable
sealed class PresentCommand {
  const PresentCommand();

  Map<String, Object?> toJson();

  static PresentCommand? fromJson(Map<String, Object?> json) => switch (json['type']) {
    'next' => const PresentNext(),
    'prev' => const PresentPrev(),
    'jump' => PresentJump((json['index'] as num?)?.toInt() ?? 0),
    'blank' => const PresentToggleBlank(),
    'look' => PresentSetLook(PresentLook.fromJson(((json['look'] as Map?) ?? const {}).cast())),
    _ => null,
  };
}

class PresentNext extends PresentCommand {
  const PresentNext();
  @override
  Map<String, Object?> toJson() => {'type': 'next'};
}

class PresentPrev extends PresentCommand {
  const PresentPrev();
  @override
  Map<String, Object?> toJson() => {'type': 'prev'};
}

class PresentJump extends PresentCommand {
  const PresentJump(this.index);
  final int index;
  @override
  Map<String, Object?> toJson() => {'type': 'jump', 'index': index};
}

class PresentToggleBlank extends PresentCommand {
  const PresentToggleBlank();
  @override
  Map<String, Object?> toJson() => {'type': 'blank'};
}

class PresentSetLook extends PresentCommand {
  const PresentSetLook(this.look);
  final PresentLook look;
  @override
  Map<String, Object?> toJson() => {'type': 'look', 'look': look.toJson()};
}
