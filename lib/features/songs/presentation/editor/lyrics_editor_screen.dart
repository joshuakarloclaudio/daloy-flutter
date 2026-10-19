import 'package:flutter/cupertino.dart' show cupertinoTextSelectionControls;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_button.dart';
import '../../../../shared/widgets/daloy_top_bar.dart';
import '../../../../shared/widgets/discard_changes_dialog.dart';
import '../../../../shared/widgets/glass_buttons.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../editor/lyrics_edit.dart';
import '../widgets/chart_format.dart';
import 'formatted_text_controllers.dart';
import 'help_parts.dart';

/// Opens the lyrics editor over the current screen. Resolves to the edited
/// lyrics when the user taps Done, or null when they leave without them.
Future<String?> showLyricsEditor(BuildContext context, {required String lyrics}) =>
    Navigator.of(context)
        .push<String>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => LyricsEditorScreen(lyrics: lyrics)));

/// The lyrics, full screen: the same shape as the chord editor (close · title
/// · help · Done), with the system keyboard and a row of section chips riding
/// on top of it. Done hands the text back to the song's draft; it isn't saved
/// until the song is.
class LyricsEditorScreen extends StatefulWidget {
  const LyricsEditorScreen({super.key, required this.lyrics});

  final String lyrics;

  @override
  State<LyricsEditorScreen> createState() => _LyricsEditorScreenState();
}

class _LyricsEditorScreenState extends State<LyricsEditorScreen> {
  late final _text = LyricsTextController(text: widget.lyrics);
  final _focus = FocusNode();

  bool get _dirty => _text.text != widget.lyrics;

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _insertSection(String name) {
    final sel = _text.selection;
    final cursor = sel.isValid ? sel.end : _text.text.length;
    final edit = insertLyricsSection(_text.text, cursor, name);
    HapticFeedback.selectionClick();
    _text.value = TextEditingValue(
      text: edit.text,
      selection: TextSelection.collapsed(offset: edit.cursor),
    );
    _focus.requestFocus();
    setState(() {});
    // A typed edit scrolls the field to the caret; one set from code doesn't,
    // so a header added far down would land out of sight. Once it's laid out,
    // bring the caret's line into view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final field = _focus.context?.findAncestorStateOfType<EditableTextState>();
      field?.bringIntoView(TextPosition(offset: edit.cursor));
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final gutter = DaloySpace.gutter(context);
    // The lyrics sheet's serif and headings (shared [LyricsFormat]).
    final style = LyricsFormat.of(context).body;
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmDiscardChanges(context) && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: DaloyTopBar(
          title: 'Lyrics',
          actions: [
            TopBarIconButton(
              icon: TablerIcons.help_circle,
              tooltip: 'Help',
              onPressed: () => showLyricsEditorHelp(context),
            ),
            const SizedBox(width: DaloySpace.s1),
            GlassTextButton(label: 'Done', prominent: true, onPressed: () => Navigator.of(context).pop(_text.text)),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    selectionControls: cupertinoTextSelectionControls,
                    controller: _text,
                    focusNode: _focus,
                    autofocus: widget.lyrics.isEmpty,
                    expands: true,
                    maxLines: null,
                    minLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: style,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Verse 1:\nAmazing grace, how sweet the sound\nThat saved a wretch like me…',
                      hintStyle: style.copyWith(color: c.mutedForeground),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.fromLTRB(gutter, DaloySpace.s3, gutter, DaloySpace.s8),
                    ),
                  ),
                ),
                _SectionBar(
                  onInsert: _insertSection,
                  bottomInset: keyboardUp ? 0 : MediaQuery.paddingOf(context).bottom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Section chips in one sideways-scrolling row, under a hairline. Each puts
/// a header on its own line at the cursor (`Verse 2:` counts the verses).
class _SectionBar extends StatelessWidget {
  const _SectionBar({required this.onInsert, required this.bottomInset});

  final ValueChanged<String> onInsert;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final gutter = DaloySpace.gutter(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border.withValues(alpha: 0.7))),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: gutter, vertical: DaloySpace.s2),
            itemCount: lyricsSectionNames.length,
            separatorBuilder: (_, _) => const SizedBox(width: DaloySpace.s2),
            itemBuilder: (context, i) {
              final name = lyricsSectionNames[i];
              return Pressable(
                onPressed: () => onInsert(name),
                semanticLabel: 'Insert $name section',
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3_5),
                  decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.full)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(TablerIcons.plus, size: 14, color: c.mutedForeground),
                      const SizedBox(width: DaloySpace.s1),
                      Text(name, style: context.text.labelLarge),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// How lyrics are written: the web's "Lyrics notation" help, with the chips.
Future<void> showLyricsEditorHelp(BuildContext context) => showEditorHelpSheet(
  context,
  title: 'Lyrics notation',
  children: const [
    HelpRow(
      title: 'Section headers',
      code: 'Verse 1:\nPre-Chorus:\n[Chorus]',
      description: 'A name and a colon on its own line, or a name in square brackets, starts a section. The chips above the keyboard insert one at the cursor.',
    ),
    HelpRow(
      title: 'Lyric lines',
      code: 'Amazing grace, how sweet the sound\nThat saved a wretch like me',
      description: 'Write lyrics as plain text. Blank lines add space between stanzas.',
    ),
    HelpNote(
      lead: 'Chords live apart:',
      body: 'lyrics and the chord chart are two separate texts. Put chords in the chart, not here, so the lyrics view stays clean.',
    ),
  ],
);
