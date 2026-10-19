import '../chart/nashville.dart';

/// The qualities offered when a root key is long-pressed — six at most, since
/// the popup is a 3×2 grid the thumb covers without leaving the key. Index 0
/// is the diatonic quality, so the first cell agrees with a plain tap.
const _degreeQualities = <int, List<String>>{
  1: ['', 'sus4', 'sus2', 'maj7', 'add9', '6'],
  2: ['m', 'm7', 'sus4', 'm9', '7', ''],
  3: ['m', 'm7', 'sus4', 'm9', '', '7'],
  4: ['', 'maj7', 'add9', 'sus2', '6', 'm'],
  5: ['', 'sus4', '7', 'sus2', 'add9', 'm'],
  6: ['m', 'm7', 'm9', 'sus4', '', '6'],
  7: ['dim', 'm7b5', 'm', '', '7', 'dim7'],
};

/// Roots that aren't scale degrees: borrowed chords, secondary dominants.
const _chromaticQualities = ['', 'm', '7', 'maj7', 'm7', 'sus4'];

/// Qualities to offer for a letter root in a key (null key → chromatic list).
List<String> qualityMenuForRoot(String root, String? musicalKey) {
  final degree = degreeOfRoot(root, musicalKey);
  if (degree == null) return _chromaticQualities;
  return _degreeQualities[degree] ?? _chromaticQualities;
}
