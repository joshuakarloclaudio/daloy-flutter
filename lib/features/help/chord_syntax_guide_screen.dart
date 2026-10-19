import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import '../../shared/widgets/daloy_top_bar.dart';
import '../../shared/widgets/pressable.dart';
import '../../shared/widgets/segmented_control.dart';
import '../../shared/widgets/staggered_entrance.dart';
import '../songs/presentation/editor/help_parts.dart';
import '../songs/presentation/widgets/chord_sheet.dart';
import 'chord_syntax_guide_content.dart';

/// Opens the guide over whatever is showing (the chord editor's help sheet
/// lives on the root navigator, outside go_router's pages).
Future<void> showChordSyntaxGuide(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ChordSyntaxGuideScreen()));

/// Everything the chord editor understands, with what it turns into: the
/// web's `/app/help/chord-syntax`, English or Tagalog. Chips at the top jump
/// to a section.
class ChordSyntaxGuideScreen extends StatefulWidget {
  const ChordSyntaxGuideScreen({super.key});

  @override
  State<ChordSyntaxGuideScreen> createState() => _ChordSyntaxGuideScreenState();
}

class _ChordSyntaxGuideScreenState extends State<ChordSyntaxGuideScreen> {
  var _language = GuideLanguage.en;
  final _keys = {for (final s in guideSections) s.id: GlobalKey()};

  void _jumpTo(String id) {
    final target = _keys[id]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final gutter = DaloySpace.gutter(context);
    String t(Tr s) => s.inLang(_language);

    return Scaffold(
      appBar: DaloyTopBar(title: t(guideTitle)),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          gutter,
          DaloySpace.s4,
          gutter,
          DaloySpace.s10 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(t(guideIntro), style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
                const SizedBox(height: DaloySpace.s4),
                SegmentedControl<GuideLanguage>(
                  value: _language,
                  size: ControlSize.sm,
                  options: const [(GuideLanguage.en, 'English'), (GuideLanguage.tl, 'Tagalog')],
                  onChanged: (l) => setState(() => _language = l),
                ),
                const SizedBox(height: DaloySpace.s4),
                Wrap(
                  spacing: DaloySpace.s1_5,
                  runSpacing: DaloySpace.s1_5,
                  children: [for (final s in guideSections) _JumpChip(label: t(s.title), onTap: () => _jumpTo(s.id))],
                ),
                const SizedBox(height: DaloySpace.s6),
                StaggeredColumn(
                  spacing: DaloySpace.s4,
                  children: [
                    for (final s in guideSections) _SectionCard(key: _keys[s.id], section: s, language: _language),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _JumpChip extends StatelessWidget {
  const _JumpChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onPressed: onTap,
      semanticLabel: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s1_5),
        decoration: BoxDecoration(
          color: c.muted.withValues(alpha: 0.6),
          borderRadius: DaloyRadii.all(DaloyRadii.full),
          border: Border.all(color: c.border.withValues(alpha: 0.7)),
        ),
        child: Text(label, style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({super.key, required this.section, required this.language});

  final GuideSection section;
  final GuideLanguage language;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    String t(Tr s) => s.inLang(language);
    return Container(
      padding: const EdgeInsets.all(DaloySpace.s5),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: DaloyRadii.all(DaloyRadii.xl2),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t(section.title), style: context.text.titleMedium),
          for (final block in section.blocks) ...[
            const SizedBox(height: DaloySpace.s4),
            switch (block) {
              GuideText(:final text, :final small) => Text(
                t(text),
                style: (small ? context.text.bodySmall! : context.text.bodyMedium!).copyWith(
                  color: small ? c.mutedForeground.withValues(alpha: 0.85) : c.mutedForeground,
                ),
              ),
              GuideEntry(:final title, :final code, :final body) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t(title), style: context.text.titleSmall),
                  const SizedBox(height: DaloySpace.s1_5),
                  HelpCode(code),
                  const SizedBox(height: DaloySpace.s1_5),
                  Text(t(body), style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
                ],
              ),
              GuideTable() => _GuideTableView(table: block, language: language),
              GuideExample(:final content) => _Example(content: content),
            },
          ],
        ],
      ),
    );
  }
}

/// Code columns size to their widest cell; the meaning takes what's left and
/// wraps. The two-column qualities table needs 400 wide and scrolls sideways
/// on a narrower phone.
class _GuideTableView extends StatelessWidget {
  const _GuideTableView({required this.table, required this.language});

  final GuideTable table;
  final GuideLanguage language;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final code = context.text.bodySmall!.copyWith(fontFamily: 'monospace', color: c.chordInk);
    final head = context.text.labelSmall!.copyWith(color: c.mutedForeground, fontWeight: FontWeight.w500);
    final meaning = context.text.bodySmall!.copyWith(color: c.mutedForeground);
    const pad = EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2);
    final rule = BorderSide(color: c.border.withValues(alpha: 0.6));

    return ClipRRect(
      borderRadius: DaloyRadii.all(DaloyRadii.lg),
      child: ColoredBox(
        color: c.muted.withValues(alpha: 0.6),
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(box.maxWidth, table.codeColumns > 1 ? 400 : 0),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  for (var i = 0; i < table.codeColumns; i++) i: const IntrinsicColumnWidth(),
                  table.codeColumns: const FlexColumnWidth(),
                },
                border: TableBorder(horizontalInside: rule),
                children: [
                  TableRow(
                    children: [
                      for (final h in table.headers)
                        Padding(
                          padding: pad,
                          child: Text(h.inLang(language), style: head),
                        ),
                    ],
                  ),
                  for (final (cells, means) in table.rows)
                    TableRow(
                      children: [
                        for (final cell in cells)
                          Padding(
                            padding: pad,
                            child: Text(cell, style: code, softWrap: false),
                          ),
                        Padding(
                          padding: pad,
                          child: Text(means.inLang(language), style: meaning),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The snippet, drawn by the real chart.
class _Example extends StatelessWidget {
  const _Example({required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2_5),
      decoration: BoxDecoration(
        color: c.background.withValues(alpha: 0.6),
        borderRadius: DaloyRadii.all(DaloyRadii.lg),
        border: Border.all(color: c.border.withValues(alpha: 0.7)),
      ),
      child: ChordSheet(content: content, transposition: 0, zoom: 90),
    );
  }
}
