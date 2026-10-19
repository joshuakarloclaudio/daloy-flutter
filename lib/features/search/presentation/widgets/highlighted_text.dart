import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../domain/search_text.dart';

/// [text] with the parts that matched [terms] marked: a soft wash behind
/// them, in the primary ink — so you can see *why* a row is here.
class HighlightedText extends StatelessWidget {
  const HighlightedText(this.text, {super.key, required this.terms, required this.style, this.maxLines = 1});

  final String text;
  final List<String> terms;
  final TextStyle style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ranges = highlightRanges(text, terms);
    final marked = style.copyWith(color: c.primaryInk, backgroundColor: c.primary.withValues(alpha: 0.12));
    final spans = <TextSpan>[];
    var at = 0;
    for (final r in ranges) {
      if (r.start < at) continue;
      if (r.start > at) spans.add(TextSpan(text: text.substring(at, r.start)));
      spans.add(TextSpan(text: text.substring(r.start, r.end), style: marked));
      at = r.end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// A long line cut down to the stretch around its first match, so the match
/// is visible in one line: "…way maker, miracle worker, promise keeper".
String snippetAround(String line, List<String> terms, {int lead = 24}) {
  final ranges = highlightRanges(line, terms);
  if (ranges.isEmpty || ranges.first.start <= lead) return line;
  var start = ranges.first.start - lead;
  // Start on a word.
  final space = line.indexOf(' ', start);
  if (space != -1 && space < ranges.first.start) start = space + 1;
  return '…${line.substring(start)}';
}
