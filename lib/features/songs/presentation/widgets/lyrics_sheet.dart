import 'package:flutter/material.dart';

import '../../chart/chart_parser.dart';
import 'chart_format.dart';
import 'chord_sheet.dart' show FocusedLine;

/// Lyrics only: `[Section]` labels become small-caps headings, everything
/// else prints as written. Set in the serif, like the web's `LyricsSheet`.
class LyricsSheet extends StatefulWidget {
  const LyricsSheet({
    super.key,
    required this.lyrics,
    required this.zoom,
    this.focusLine,
    this.focusKey,
    this.focusLit = false,
  });

  final String lyrics;
  final double zoom;

  /// A line to point out, as on [ChordSheet].
  final int? focusLine;
  final GlobalKey? focusKey;
  final bool focusLit;

  @override
  State<LyricsSheet> createState() => _LyricsSheetState();
}

class _LyricsSheetState extends State<LyricsSheet> {
  late List<List<Segment>> _lines = _parse(widget.lyrics);

  static List<List<Segment>> _parse(String text) => [
    for (final line in normalizeNewlines(text).split('\n')) parseLine(line),
  ];

  @override
  void didUpdateWidget(LyricsSheet old) {
    super.didUpdateWidget(old);
    if (old.lyrics != widget.lyrics) _lines = _parse(widget.lyrics);
  }

  @override
  Widget build(BuildContext context) {
    final format = LyricsFormat.of(context, zoom: widget.zoom);
    final size = format.size;
    final body = format.body;
    final heading = format.heading;

    return DefaultTextStyle(
      style: body,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, segments) in _lines.indexed)
            if (segments.isEmpty ||
                (segments.length == 1 && segments.first.kind == SegmentKind.text && segments.first.value.isEmpty))
              SizedBox(height: size)
            else if (i == widget.focusLine)
              FocusedLine(key: widget.focusKey, lit: widget.focusLit, child: _text(segments, heading))
            else
              _text(segments, heading),
        ],
      ),
    );
  }

  Widget _text(List<Segment> segments, TextStyle heading) => Text.rich(
    TextSpan(
      children: [
        for (final seg in segments)
          switch (seg.kind) {
            SegmentKind.section => TextSpan(text: '${seg.value.toUpperCase()}\n', style: heading),
            _ => TextSpan(text: seg.value),
          },
      ],
    ),
  );
}
