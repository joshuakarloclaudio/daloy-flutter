import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../chart/chart_parser.dart';
import '../../chart/nashville.dart';
import '../../editor/chart_edit.dart';
import '../../editor/editor_line.dart';
import '../widgets/chart_format.dart';
import '../widgets/chord_sheet.dart' show BarDivider, BeatDots, MeterBadge, RepeatBadge;

/// The chart as the editor shows it, formatted like Perform and Practice (the
/// shared [ChartFormat] and section label) but one source line per row, with
/// a caret you place by tapping. Structure is drawn with the chart's own
/// widgets (barline rules, the rounded `×2` badge, `⁄⁄`, beat dots) and
/// Perform's gaps; every piece still spans its source length (a widget is one
/// placeholder, padded with zero-width ones), so taps and the caret map
/// straight back to the text. Each source line is its own
/// tap target, laid out with a [TextPainter] so a tap resolves to an exact
/// column and the caret sits where the next chord will land.
///
/// [cursor] is a source offset; [onTap] reports (line, column).
class ChartEditorView extends StatefulWidget {
  const ChartEditorView({
    super.key,
    required this.content,
    required this.cursor,
    required this.zoom,
    required this.onTap,
    this.notation = ChordNotation.letters,
    this.musicalKey,
    this.scrollController,
  });

  final String content;
  final int cursor;

  /// Percent; 100 draws at [chartBaseFontSize].
  final double zoom;
  final void Function(int line, int col) onTap;
  final ChordNotation notation;
  final String? musicalKey;
  final ScrollController? scrollController;

  @override
  State<ChartEditorView> createState() => _ChartEditorViewState();
}

class _ChartEditorViewState extends State<ChartEditorView> {
  final _activeKey = GlobalKey();

  @override
  void didUpdateWidget(ChartEditorView old) {
    super.didUpdateWidget(old);
    if (old.cursor != widget.cursor || old.content != widget.content) {
      // Keep the caret's line on screen as the keyboard moves it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _activeKey.currentContext;
        if (ctx != null && ctx.mounted) {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.3,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final format = ChartFormat.of(context, zoom: widget.zoom, notation: widget.notation, musicalKey: widget.musicalKey);
    final size = format.em;
    final styles = _LineStyles(format: format, header: sectionLabelStyle(context));
    final lines = widget.content.split('\n');
    final caret = cursorLineCol(widget.content, widget.cursor);
    final gutter = DaloySpace.gutter(context);

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(gutter - 8, DaloySpace.s3, gutter - 8, DaloySpace.s8),
      children: [
        for (var i = 0; i < lines.length; i++)
          _LineView(
            key: i == caret.line ? _activeKey : ValueKey(i),
            index: i,
            line: EditorLine.parse(lines[i], notation: widget.notation, musicalKey: widget.musicalKey),
            styles: styles,
            caretCol: i == caret.line ? caret.col : null,
            lineHeight: size * 1.5,
            onTap: widget.onTap,
          ),
      ],
    );
  }
}

class _LineStyles {
  const _LineStyles({required this.format, required this.header});

  final ChartFormat format;

  /// A section header line, as Perform heads a section.
  final TextStyle header;

  static final _repeatX = RegExp(r'[xX](?=\d)|(?<=\d)[xX]');
  static final _headerPart = RegExp(r':|\s+|[^:\s]+');
  static final _dots = RegExp(r'^\.+$');

  /// Perform's gaps: inside a bar (and between a barline and its chords)…
  static const _barGap = DaloySpace.s2;

  /// …and between chords on a bare chord line (6 padding each side + 16 spacing).
  static const _chordGap = 6 + DaloySpace.s4 + 6;

  /// `x2` → `×2`: same length, so offsets don't move.
  static String _times(String text) => text.replaceAll(_repeatX, '×');

  static InlineSpan _box(Widget child) => WidgetSpan(alignment: PlaceholderAlignment.middle, child: child);

  /// A piece drawn as [first] (one placeholder) plus zero-width fillers for
  /// the rest of its source characters, so its drawn length is its source length.
  static List<InlineSpan> _widget(Widget first, int length) => [
    _box(first),
    for (var i = 1; i < length; i++) _box(const SizedBox.shrink()),
  ];

  /// A run of whitespace drawn as one fixed gap.
  static List<InlineSpan> _gap(double width, int length) => _widget(SizedBox(width: width), length);

  /// Is this a bare chord line (chords and spaces, maybe a repeat), drawn as Perform's chord row?
  static bool isChordRow(EditorLine line) =>
      line.pieces.any((p) => p.kind == PieceKind.chord) &&
      line.pieces.every(
        (p) =>
            p.kind == PieceKind.chord ||
            p.kind == PieceKind.pad ||
            p.kind == PieceKind.repeat ||
            (p.kind == PieceKind.text && p.text.trim().isEmpty),
      );

  /// The spans for [line], drawn with the same pieces as the read-only chart:
  /// barline rules, the rounded repeat badge, `⁄⁄` for `%`, beat dots, and
  /// Perform's gaps. Each piece spans exactly its drawn length.
  TextSpan span(EditorLine line, {required bool isHeader}) {
    if (isHeader) return _header(line);
    final structured = line.pieces.any((p) => p.kind == PieceKind.bar || p.kind == PieceKind.repeat);
    final chordRow = isChordRow(line);
    final pieces = line.pieces;

    // The nearest piece that draws something (not a space, not a pad) on
    // either side — Perform's gaps depend on what sits there, not on how
    // many spaces were typed.
    EditorPiece? solid(int from, int step) {
      for (var j = from; j >= 0 && j < pieces.length; j += step) {
        final q = pieces[j];
        if (q.kind != PieceKind.pad && !(q.kind == PieceKind.text && q.text.trim().isEmpty)) return q;
      }
      return null;
    }

    return TextSpan(
      style: format.base,
      children: [
        for (var i = 0; i < pieces.length; i++)
          ..._piece(
            line,
            pieces[i],
            before: solid(i - 1, -1),
            after: solid(i + 1, 1),
            structured: structured,
            chordRow: chordRow,
          ),
      ],
    );
  }

  /// `Chorus: x2` → `CHORUS  ×2` in the section label style; the colon takes
  /// no room, as Perform shows no colon.
  TextSpan _header(EditorLine line) => TextSpan(
    style: header,
    children: [
      for (final p in line.pieces)
        for (final m in _headerPart.allMatches(p.text))
          if (m[0] == ':')
            _box(const SizedBox.shrink())
          else if (m[0]!.trim().isEmpty)
            TextSpan(text: m[0], style: const TextStyle(letterSpacing: 4))
          else
            TextSpan(text: _times(m[0]!).toUpperCase()),
    ],
  );

  static bool _isBar(EditorPiece? p) => p != null && p.kind == PieceKind.bar && p.text == '|';

  /// One piece of a line. On a bar line the gaps follow Perform's `_BarUnit`:
  /// each barline carries 8 on the side facing its bar's content, atoms
  /// inside a bar sit 8 apart, touching chords stay one atom, an empty bar is
  /// 2em wide, and the repeat badge sits 8 past the last barline. On a bare
  /// chord row, chords sit 28 apart (`_ChordRow`: 6 padding + 16 spacing).
  List<InlineSpan> _piece(
    EditorLine line,
    EditorPiece p, {
    required EditorPiece? before,
    required EditorPiece? after,
    required bool structured,
    required bool chordRow,
  }) {
    final color = format.structure;
    final em = format.em;
    final blank = p.kind == PieceKind.pad || (p.kind == PieceKind.text && p.text.trim().isEmpty);
    final length = p.text.length;

    if (blank && (structured || chordRow)) {
      // Spaces at the ends, or beside a barline or the badge, take no room:
      // those carry their own padding.
      final between =
          before != null &&
          after != null &&
          !_isBar(before) &&
          !_isBar(after) &&
          before.kind != PieceKind.repeat &&
          after.kind != PieceKind.repeat;
      final double width;
      if (chordRow) {
        width = before == null || after == null ? 0 : (after.kind == PieceKind.repeat ? 6 + DaloySpace.s4 : _chordGap);
      } else {
        // Touching chords (`[G][D]`) are one atom in Perform: no gap.
        width = between && p.kind != PieceKind.pad ? _barGap : 0;
      }
      return _gap(width, length);
    }

    return switch (p.kind) {
      PieceKind.chord => [_chord(line, p)],
      PieceKind.label => [TextSpan(text: p.text.toUpperCase(), style: format.sectionStyle)],
      PieceKind.heading => [TextSpan(text: p.text.toUpperCase(), style: header)],
      PieceKind.bar when p.text == '%' => [
        _box(
          Text(
            '⁄⁄',
            style: format.chord.copyWith(fontSize: em * 0.9, color: color.withValues(alpha: 0.5)),
          ),
        ),
      ],
      PieceKind.bar => [
        _box(
          Padding(
            padding: EdgeInsets.only(
              left: before == null || _isBar(before) ? 0 : _barGap,
              // An empty bar (`| |`) is 2em wide, as `_BarUnit` draws it.
              // (the next barline adds nothing on its side, so this one carries it all).
              right: _isBar(after)
                  ? em * 2
                  : after == null || after.kind == PieceKind.repeat
                  ? 0
                  : _barGap,
            ),
            child: BarDivider(color: color, height: em * 1.15),
          ),
        ),
      ],
      PieceKind.repeat => _widget(
        Padding(
          padding: EdgeInsets.only(left: chordRow || before == null ? 0 : _barGap),
          child: RepeatBadge(count: parseRepeatToken(p.text) ?? 2, color: color, size: em),
        ),
        length,
      ),
      PieceKind.meter => _widget(MeterBadge(signature: p.text, color: color, size: em), length),
      PieceKind.text when structured && _dots.hasMatch(p.text) => [
        for (var i = 0; i < length; i++)
          _box(
            Padding(
              padding: EdgeInsets.only(left: i == 0 ? 0 : em * 0.28 * 0.8),
              child: BeatDots(count: 1, color: color, size: em * 0.28),
            ),
          ),
      ],
      PieceKind.text when structured => [
        TextSpan(
          text: p.text,
          style: TextStyle(color: color.withValues(alpha: 0.55)),
        ),
      ],
      _ => [TextSpan(text: p.text)],
    };
  }

  /// The chord as the chart draws it (numbers with their smaller extensions),
  /// unless that would draw different characters than the editor counts.
  InlineSpan _chord(EditorLine line, EditorPiece p) {
    final token = line.source.substring(p.srcStart + 1, p.srcEnd - 1);
    final span = format.chordSpan(token);
    return span.toPlainText() == p.text ? span : TextSpan(text: p.text, style: format.chord);
  }
}

class _LineView extends StatefulWidget {
  const _LineView({
    super.key,
    required this.index,
    required this.line,
    required this.styles,
    required this.caretCol,
    required this.lineHeight,
    required this.onTap,
  });

  final int index;
  final EditorLine line;
  final _LineStyles styles;

  /// The caret's source column when it is on this line.
  final int? caretCol;
  final double lineHeight;
  final void Function(int line, int col) onTap;

  @override
  State<_LineView> createState() => _LineViewState();
}

class _LineViewState extends State<_LineView> {
  /// The laid-out line. Taps and the caret ask it directly, so inline
  /// widgets (barlines, badges) are measured exactly as drawn.
  final _text = GlobalKey();

  RenderParagraph? get _paragraph => _text.currentContext?.findRenderObject() as RenderParagraph?;

  /// A section header (`Verse:`, `[Chorus] x2`), by the same test that splits sections.
  bool get _isHeading => widget.line.source.trim().isNotEmpty && sectionHeader(parseLine(widget.line.source)) != null;

  void _tap(TapUpDetails d) {
    final paragraph = _paragraph;
    if (paragraph == null) return;
    final pos = paragraph.getPositionForOffset(paragraph.globalToLocal(d.globalPosition));
    widget.onTap(widget.index, widget.line.colForDrawnOffset(pos.offset));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final line = widget.line;
    final active = widget.caretCol != null;
    final heading = _isHeading;

    return Semantics(
      label: line.isEmpty ? 'Empty line ${widget.index + 1}' : line.drawnText,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: _tap,
        child: Container(
          margin: EdgeInsets.only(top: heading ? DaloySpace.s4 : 0, bottom: heading ? DaloySpace.s1 : 0),
          // A chord row opens with its first chord's padding, as in Perform.
          padding: EdgeInsets.only(left: 8 + (_LineStyles.isChordRow(line) ? 6 : 0), right: 8),
          constraints: BoxConstraints(minHeight: widget.lineHeight),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: active ? c.primary.withValues(alpha: 0.06) : null,
            border: active ? Border.all(color: c.primary.withValues(alpha: 0.12)) : null,
            borderRadius: DaloyRadii.all(DaloyRadii.xl),
          ),
          child: CustomPaint(
            foregroundPainter: active
                ? _CaretPainter(
                    paragraph: () => _paragraph,
                    offset: line.drawnOffsetForCol(widget.caretCol!),
                    color: c.primary,
                    source: line.source,
                    // One height per line's type size, whatever sits beside it.
                    height: (heading ? widget.styles.header.fontSize! : widget.styles.format.em) * 1.25,
                  )
                : null,
            child: SizedBox(
              width: double.infinity,
              child: Text.rich(key: _text, widget.styles.span(line, isHeader: heading)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CaretPainter extends CustomPainter {
  const _CaretPainter({
    required this.paragraph,
    required this.offset,
    required this.color,
    required this.source,
    required this.height,
  });

  /// Read at paint time: by then the line has been laid out.
  final RenderParagraph? Function() paragraph;
  final int offset;
  final Color color;

  /// Repaint when the line's text changes even if the offset doesn't.
  final String source;

  /// Fixed: the paragraph's own caret height swells next to inline widgets
  /// and on rows that wrap.
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final p = paragraph();
    if (p == null || !p.hasSize) return;
    final at = p.getOffsetForCaret(TextPosition(offset: offset), Rect.zero);

    // The visual row the caret is on: every box that spans its y. Centring
    // on the row keeps it level beside a barline or badge, which sit lower.
    final probe = at.dy + 1;
    double? top;
    double? bottom;
    for (final box in p.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: p.text.toPlainText(includeSemanticsLabels: false).length),
    )) {
      if (box.top > probe || box.bottom < probe) continue;
      top = top == null ? box.top : (box.top < top ? box.top : top);
      bottom = bottom == null ? box.bottom : (box.bottom > bottom ? box.bottom : bottom);
    }
    final centre = top != null && bottom != null ? (top + bottom) / 2 : size.height / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(at.dx - 1, centre - height / 2, 2, height), const Radius.circular(1)),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_CaretPainter old) =>
      old.offset != offset || old.color != color || old.source != source || old.height != height;
}
