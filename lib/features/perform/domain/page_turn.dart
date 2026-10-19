/// Page turns through a set that scrolls as one chart, so the end of one
/// song and the start of the next can share a screen (songs played straight
/// through). Pure, so the pedal rule is tested without a screen.
library;

/// Lines kept from the page before, so the eye finds its place.
const pageTurnOverlap = 72.0;

/// How far one turn moves when [visible] pixels of chart show at once.
double pageStep(double visible) => (visible - pageTurnOverlap).clamp(visible * 0.5, double.infinity);

/// Where one turn lands, or null at either end of the set.
double? pageTurnTarget({
  required double offset,
  required double maxExtent,
  required double step,
  required bool forward,
}) {
  // A pixel of slack: scroll positions land on fractions.
  const slack = 1.0;
  if (forward) return offset >= maxExtent - slack ? null : (offset + step).clamp(0, maxExtent).toDouble();
  return offset <= slack ? null : (offset - step).clamp(0, maxExtent).toDouble();
}

/// The song being read: the last one whose heading has reached [readLine]
/// (a little under the top chrome). At the very bottom of the set, the last
/// song that has come into view — a short closing song may never reach the
/// line. [tops] are each song's top in the same coordinates as [readLine].
int currentSongAt(List<double> tops, {required double readLine, required bool atEnd, required double viewportBottom}) {
  if (tops.isEmpty) return 0;
  var current = 0;
  for (var i = 0; i < tops.length; i++) {
    if (tops[i] <= readLine) current = i;
  }
  if (atEnd) {
    for (var i = tops.length - 1; i > current; i--) {
      if (tops[i] < viewportBottom) return i;
    }
  }
  return current;
}

/// Where "previous song" goes: back to the top of this song when you're well
/// into it, otherwise to the song before.
int previousSongTarget({required int current, required double currentTop, required double readLine}) =>
    currentTop < readLine - 120 ? current : (current - 1).clamp(0, current);

/// How far to scroll so a block from [top] to [bottom] (on screen) sits
/// whole between [upper] and [lower]: as little as possible, or null when it
/// already does. A block taller than the space lands with its top at [upper].
double? revealDelta({required double top, required double bottom, required double upper, required double lower}) {
  if (bottom - top > lower - upper || top < upper) return top == upper ? null : top - upper;
  if (bottom > lower) return bottom - lower;
  return null;
}
