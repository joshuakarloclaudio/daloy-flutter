import 'package:flutter/material.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../chart/chart_parser.dart';
import '../../chart/chord_math.dart';
import '../widgets/chart_format.dart';

/// Whether [line] heads a section — the same test [groupBySections] uses.
bool _isHeader(String line) => line.trim().isNotEmpty && sectionHeader(parseLine(line)) != null;

/// Uppercase only when it keeps the length (it does for anything but the
/// odd `ß`), so offsets in the field stay put.
String _upper(String s) {
  final up = s.toUpperCase();
  return up.length == s.length ? up : s;
}

/// The lyrics field, drawn as the lyrics sheet draws lyrics: the serif body
/// and section headings (`[Chorus]`, `Verse:`) in small spaced caps. Only the
/// look changes; the text is exactly what was typed.
class LyricsTextController extends TextEditingController {
  LyricsTextController({super.text});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    // Mid-composition (IME), keep the platform's underline: draw plain.
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    }
    final format = LyricsFormat.of(context);
    final heading = format.heading.copyWith(height: format.body.height);
    final lines = text.split('\n');
    return TextSpan(
      style: style ?? format.body,
      children: [
        for (final (i, line) in lines.indexed) ...[
          if (_isHeader(line)) TextSpan(text: _upper(line), style: heading) else TextSpan(text: line),
          if (i < lines.length - 1) const TextSpan(text: '\n'),
        ],
      ],
    );
  }
}

final _chordOrText = RegExp(r'\[[^\]\n]*\]|[^\[]+|\[');
final _word = RegExp(r'[|%]|[^\s|%]+|\s+');

/// The chord editor's free-type field: the chart's source with its parts
/// coloured as the chart draws them — chords in chord ink (brackets faded),
/// section headers as section labels, barlines and repeats as structure.
class ChartSourceTextController extends TextEditingController {
  ChartSourceTextController({super.text});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    }
    final c = context.colors;
    final base = style ?? DefaultTextStyle.of(context).style;
    final chord = base.copyWith(color: c.chordInk).weight(FontWeight.w600);
    final bracket = base.copyWith(color: c.chordInk.withValues(alpha: 0.4));
    final header = base.copyWith(color: c.mutedForeground, letterSpacing: 0.6).weight(FontWeight.w700);
    final structure = base.copyWith(color: c.chordInk.withValues(alpha: 0.6));

    InlineSpan piece(String part) {
      if (part.length >= 2 && part.startsWith('[') && part.endsWith(']')) {
        final inner = part.substring(1, part.length - 1);
        return TextSpan(
          children: [
            TextSpan(text: '[', style: bracket),
            TextSpan(text: inner, style: isChordToken(inner) ? chord : header),
            TextSpan(text: ']', style: bracket),
          ],
        );
      }
      // `|`, `%` and `x2` only read as structure between chords; colouring
      // them anywhere is harmless and keeps this a cheap per-keystroke pass.
      return TextSpan(
        children: [
          for (final m in _word.allMatches(part))
            TextSpan(
              text: m[0],
              style: m[0] == '|' || m[0] == '%' || parseRepeatToken(m[0]!) != null ? structure : null,
            ),
        ],
      );
    }

    final lines = text.split('\n');
    return TextSpan(
      style: base,
      children: [
        for (final (i, line) in lines.indexed) ...[
          if (_isHeader(line))
            TextSpan(text: line, style: header)
          else
            for (final m in _chordOrText.allMatches(line)) piece(m[0]!),
          if (i < lines.length - 1) const TextSpan(text: '\n'),
        ],
      ],
    );
  }
}
