/// Chord and key arithmetic — port of the transposition half of the web's
/// `lib/chords.ts`. Pure Dart: no Flutter, no I/O.
library;

const _sharps = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
const _flats = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

int _noteIndex(String note) {
  final sharp = _sharps.indexOf(note);
  return sharp != -1 ? sharp : _flats.indexOf(note);
}

String _shift(String note, int semitones) {
  final index = _noteIndex(note);
  if (index == -1) return note;
  final next = ((index + semitones) % 12 + 12) % 12;
  return note.endsWith('b') ? _flats[next] : _sharps[next];
}

final _rootAndRest = RegExp(r'^([A-G][b#]?)(.*)$');

/// `Am7` up two semitones is `Bm7`. Anything that isn't a chord is returned
/// untouched, so one odd token never breaks a chart.
String transposeChord(String chord, int semitones) {
  if (semitones == 0) return chord;
  final match = _rootAndRest.firstMatch(chord);
  if (match == null) return chord;
  return _shift(match[1]!, semitones) + match[2]!;
}

String transposeKey(String key, int semitones) => transposeChord(key, semitones);

/// Semitones from [fromKey]'s root to [toKey]'s, the short way round
/// (−5…+6), so G → F reads as −2 rather than +10. 0 when either isn't a key.
int transpositionBetweenKeys(String fromKey, String toKey) {
  final from = _rootAndRest.firstMatch(fromKey);
  final to = _rootAndRest.firstMatch(toKey);
  if (from == null || to == null) return 0;
  final a = _noteIndex(from[1]!);
  final b = _noteIndex(to[1]!);
  if (a == -1 || b == -1) return 0;
  final up = ((b - a) % 12 + 12) % 12;
  return up > 6 ? up - 12 : up;
}

/// The twelve keys [key] can be played in, from the original upwards,
/// keeping its quality (`Em` → `Em`, `Fm`, `F#m`, …).
List<String> transposedKeys(String key) => [for (var i = 0; i < 12; i++) transposeKey(key, i)];

/// Whether `text` (the inside of a `[...]`) reads as a chord rather than a
/// section label.
bool isChordToken(String text) =>
    RegExp(r'^[A-G][b#]?(maj|min|sus|aug|dim|add|M|m|[0-9]|[#b])*$').hasMatch(text.trim());

/// A chord split into root, quality and optional slash-bass.
typedef ParsedChord = ({String root, String quality, String? bass});

ParsedChord? parseChordInner(String inner) {
  final slash = inner.indexOf('/');
  final main = slash == -1 ? inner : inner.substring(0, slash);
  final bass = slash == -1 ? null : inner.substring(slash + 1);
  final match = _rootAndRest.firstMatch(main);
  if (match == null) return null;
  return (root: match[1]!, quality: match[2]!, bass: bass);
}
