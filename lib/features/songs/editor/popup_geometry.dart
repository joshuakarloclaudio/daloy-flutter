/// Layout maths for the long-press popups (quality and bass-note grids) —
/// port of the web's `lib/quality-popup-geometry.ts`. Pure arithmetic, so the
/// hit-test during a slide costs nothing per move and can't disagree with
/// what is drawn.
library;

import 'dart:math' as math;
import 'dart:ui';

const popupCellWidth = 66.0;
const popupCellHeight = 46.0;
const popupGap = 4.0;
const popupPad = 6.0;
const popupMaxCols = 3;

/// Clearance between the popup and the key it belongs to.
const _anchorOffset = 10.0;

/// Minimum gap between the popup and the screen edge.
const _edgeMargin = 8.0;

/// How far past the grid the finger may stray and still count as inside.
const _hitTolerance = 14.0;

class PopupLayout {
  const PopupLayout({
    required this.rect,
    required this.cols,
    required this.rows,
    required this.cells,
    required this.below,
  });

  /// The whole popup, in screen coordinates.
  final Rect rect;
  final int cols;
  final int rows;

  /// Each cell, in order.
  final List<Rect> cells;

  /// True when the popup had to sit under its key for lack of headroom.
  final bool below;
}

/// Positions a popup of [count] cells above (or, if cramped, below) [anchor].
PopupLayout layoutPopup(Rect anchor, int count, Size screen) {
  final cols = math.min(popupMaxCols, math.max(1, count));
  final rows = (count / cols).ceil();
  final width = cols * popupCellWidth + (cols - 1) * popupGap + popupPad * 2;
  final height = rows * popupCellHeight + (rows - 1) * popupGap + popupPad * 2;

  // Centre on the key, then pull back inside the screen; clamping the low end
  // last keeps a popup wider than the screen pinned left rather than off-right.
  final centred = anchor.center.dx - width / 2;
  final left = math.max(_edgeMargin, math.min(centred, screen.width - width - _edgeMargin));

  final above = anchor.top - height - _anchorOffset;
  final below = above < _edgeMargin;
  final top = below ? anchor.bottom + _anchorOffset : above;

  final cells = [
    for (var i = 0; i < count; i++)
      Rect.fromLTWH(
        left + popupPad + (i % cols) * (popupCellWidth + popupGap),
        top + popupPad + (i ~/ cols) * (popupCellHeight + popupGap),
        popupCellWidth,
        popupCellHeight,
      ),
  ];
  return PopupLayout(rect: Rect.fromLTWH(left, top, width, height), cols: cols, rows: rows, cells: cells, below: below);
}

/// Which cell the finger is over, or -1 for "off the grid — release cancels".
/// The gaps between cells resolve to the nearest cell, so a slide across the
/// grid never flickers through a dead zone.
int hitTestPopup(PopupLayout layout, Offset p) {
  final r = layout.rect;
  if (p.dx < r.left - _hitTolerance ||
      p.dx > r.right + _hitTolerance ||
      p.dy < r.top - _hitTolerance ||
      p.dy > r.bottom + _hitTolerance) {
    return -1;
  }
  final col = ((p.dx - r.left - popupPad) / (popupCellWidth + popupGap)).floor().clamp(0, layout.cols - 1);
  final row = ((p.dy - r.top - popupPad) / (popupCellHeight + popupGap)).floor().clamp(0, layout.rows - 1);
  final index = row * layout.cols + col;
  // The last row can be short — a point under its empty tail is a miss.
  return index < layout.cells.length ? index : -1;
}
