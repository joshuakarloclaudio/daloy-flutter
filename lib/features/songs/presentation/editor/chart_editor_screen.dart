import 'dart:async';

import 'package:flutter/cupertino.dart' show cupertinoTextSelectionControls;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_toast.dart';
import '../../../../shared/widgets/daloy_top_bar.dart';
import '../../../../shared/widgets/discard_changes_dialog.dart';
import '../../../../shared/widgets/glass_buttons.dart';
import '../../chart/nashville.dart';
import '../../editor/chart_editor_core.dart';
import '../../editor/nashville_paste.dart';
import 'chart_editor_view.dart';
import 'chord_editor_help.dart';
import 'chord_keyboard.dart';
import 'formatted_text_controllers.dart';
import 'nashville_paste_prompt.dart';

const _minZoom = 80;
const _maxZoom = 200;
const _zoomStep = 10;

/// Opens the chord editor over the current screen. Resolves to the edited
/// chart when the user taps Done, or null when they leave without saving.
Future<String?> showChartEditor(
  BuildContext context, {
  required String content,
  required String? musicalKey,
  required ChordNotation notation,
}) => Navigator.of(context).push<String>(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => ChartEditorScreen(content: content, musicalKey: musicalKey, notation: notation),
  ),
);

/// The chord editor: the rendered chart with the chord keyboard (the web's
/// `ChordEditor`). Chords are typed on the Chords tab or a hardware keyboard
/// and always stored as letters; free-type mode swaps in the system keyboard.
class ChartEditorScreen extends StatefulWidget {
  const ChartEditorScreen({super.key, required this.content, required this.musicalKey, required this.notation});

  final String content;
  final String? musicalKey;

  /// The reader's preference. A key that can't be numbered always types letters.
  final ChordNotation notation;

  @override
  State<ChartEditorScreen> createState() => _ChartEditorScreenState();
}

class _ChartEditorScreenState extends State<ChartEditorScreen> {
  /// Wide enough for the chart and the keyboard side by side.
  static const _sideBySideWidth = 840.0;
  static const _sidePanelWidth = 460.0;

  late final ChartEditorCore _core = ChartEditorCore(
    content: widget.content,
    musicalKey: widget.musicalKey,
    notation: widget.notation,
    onChanged: () {
      if (mounted) setState(() {});
    },
  );
  late ChordKeyLayout _layout = _core.diatonic != null ? ChordKeyLayout.diatonic : ChordKeyLayout.chromatic;
  KeyboardTab _tab = KeyboardTab.chords;
  int _zoom = 100;
  bool _clearConfirm = false;
  Timer? _clearTimer;

  /// Free-type: the system keyboard in a plain text field, for anyone who'd
  /// rather type the brackets (or paste a whole chart) than use the chord keys.
  bool _freetype = false;
  final _text = ChartSourceTextController();

  String get _initial => widget.content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  String get _current => _freetype ? _text.text.replaceAll('\r\n', '\n') : _core.content;
  bool get _dirty => _current != _initial;

  @override
  void dispose() {
    _clearTimer?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _zoomBy(int delta) => setState(() => _zoom = (_zoom + delta).clamp(_minZoom, _maxZoom));

  void _done() => Navigator.of(context).pop(_current);

  void _toggleMode() {
    if (_freetype) {
      // Back to the chord keys: take what was typed as one undoable edit.
      _core.setContent(_text.text, _text.selection.isValid ? _text.selection.start : _text.text.length);
      setState(() => _freetype = false);
    } else {
      _text.value = TextEditingValue(
        text: _core.content,
        selection: TextSelection.collapsed(offset: _core.cursor),
      );
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _freetype = true);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _freetype ? _text.text : _core.content));
    if (!mounted) return;
    showDaloyToast(ScaffoldMessenger.of(context), 'Chart copied.');
  }

  /// The text to insert for a paste: bare chords bracketed, and a number chart
  /// only converted if asked. Null when there's nothing to paste.
  Future<String?> _pastedText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (!mounted || text == null || text.isEmpty) return null;
    var asChords = false;
    if (countNashvilleLines(text) > 0) {
      // Detection is a heuristic and a wrong guess looks normal, so ask first.
      final choice = await showNashvillePastePrompt(context, text: text, musicalKey: widget.musicalKey);
      if (!mounted) return null;
      asChords = choice == PasteChoice.asChords;
    }
    return prepareChordPaste(text, asChords: asChords, musicalKey: widget.musicalKey);
  }

  Future<void> _paste() async {
    final text = await _pastedText();
    if (text != null) _core.insertText(text);
  }

  /// A paste in the free-type field goes through the same path, so what you
  /// get doesn't depend on which keyboard happens to be up.
  Future<void> _pasteIntoField() async {
    final text = await _pastedText();
    if (text == null) return;
    final value = _text.value;
    final sel = value.selection.isValid ? value.selection : TextSelection.collapsed(offset: value.text.length);
    _text.value = value
        .replaced(sel, text)
        .copyWith(selection: TextSelection.collapsed(offset: sel.start + text.length));
  }

  void _clear() {
    if (_clearConfirm) {
      _clearTimer?.cancel();
      setState(() => _clearConfirm = false);
      _core.replaceAll('');
      return;
    }
    setState(() => _clearConfirm = true);
    _clearTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _clearConfirm = false);
    });
  }

  /// Hardware keyboard, in chord-key mode: typing writes the chart, arrows
  /// move the caret, ⌘/Ctrl+Z undoes — what the web editor does on a desktop.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (_freetype || event is KeyUpEvent) return KeyEventResult.ignored;
    final keys = HardwareKeyboard.instance;
    final mod = keys.isMetaPressed || keys.isControlPressed;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }
    if (mod) {
      if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
        _done();
      } else if (key == LogicalKeyboardKey.equal ||
          key == LogicalKeyboardKey.add ||
          key == LogicalKeyboardKey.numpadAdd) {
        _zoomBy(_zoomStep);
      } else if (key == LogicalKeyboardKey.minus || key == LogicalKeyboardKey.numpadSubtract) {
        _zoomBy(-_zoomStep);
      } else if (key == LogicalKeyboardKey.keyV) {
        unawaited(_paste());
      } else if (key == LogicalKeyboardKey.keyZ) {
        keys.isShiftPressed ? _core.redo() : _core.undo();
      } else if (key == LogicalKeyboardKey.keyY) {
        _core.redo();
      } else {
        return KeyEventResult.ignored;
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      _core.moveLeft();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _core.moveRight();
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _core.moveUp();
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _core.moveDown();
    } else if (key == LogicalKeyboardKey.backspace) {
      _core.deleteBack();
    } else if (key == LogicalKeyboardKey.delete) {
      _core.deleteForward();
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      _core.typeNewline();
    } else if (!keys.isAltPressed && _isTypable(event.character)) {
      _core.typeChar(event.character!);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  /// A single printable character (a space counts; control characters don't).
  static bool _isTypable(String? ch) => ch != null && ch.length == 1 && (ch == ' ' || ch.trim().isNotEmpty);

  Widget _keyboard({double scale = 1}) => ChordKeyboard(
    core: _core,
    tab: _tab,
    onTab: (t) => setState(() => _tab = t),
    layout: _layout,
    onLayout: (l) => setState(() => _layout = l),
    clearConfirm: _clearConfirm,
    onCopy: _copy,
    onPaste: _paste,
    onClear: _clear,
    onZoomIn: _zoom < _maxZoom ? () => _zoomBy(_zoomStep) : null,
    onZoomOut: _zoom > _minZoom ? () => _zoomBy(-_zoomStep) : null,
    scale: scale,
  );

  Widget _chart() => ChartEditorView(
    content: _core.content,
    cursor: _core.cursor,
    zoom: _zoom.toDouble(),
    notation: _core.notation,
    musicalKey: widget.musicalKey,
    onTap: _core.tapAt,
  );

  /// Chords-and-keys mode: the chart over the keyboard on a phone, side by
  /// side (the keys stretched to fill their panel) on a wide screen.
  Widget _customBody() => LayoutBuilder(
    builder: (context, box) {
      if (box.maxWidth < _sideBySideWidth) {
        return Column(
          children: [
            Expanded(child: _chart()),
            // Centred and capped, so a portrait tablet's keys aren't a mile wide.
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 640), child: _keyboard()),
          ],
        );
      }
      // Toolbar + gaps + tab bar + padding around the key area.
      const chrome = keyboardToolbarHeight + 4 + 8 + 48 + 12;
      final scale = ((box.maxHeight - chrome - MediaQuery.paddingOf(context).bottom) / keyboardBodyHeight).clamp(
        1.0,
        1.45,
      );
      return Row(
        children: [
          Expanded(child: _chart()),
          SizedBox(
            width: _sidePanelWidth,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _keyboard(scale: scale),
            ),
          ),
        ],
      );
    },
  );

  /// The system keyboard in a plain monospace field.
  Widget _freetypeBody() {
    final c = context.colors;
    final gutter = DaloySpace.gutter(context);
    return Column(
      children: [
        Expanded(
          child: TextField(
            selectionControls: cupertinoTextSelectionControls,
            controller: _text,
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            style: context.text.bodyMedium!.copyWith(fontFamily: 'monospace', height: 1.5),
            onChanged: (_) => setState(() {}),
            contextMenuBuilder: (context, state) => AdaptiveTextSelectionToolbar.buttonItems(
              anchors: state.contextMenuAnchors,
              buttonItems: [
                for (final item in state.contextMenuButtonItems)
                  item.type == ContextMenuButtonType.paste
                      ? ContextMenuButtonItem(
                          type: ContextMenuButtonType.paste,
                          onPressed: () {
                            state.hideToolbar();
                            unawaited(_pasteIntoField());
                          },
                        )
                      : item,
              ],
            ),
            decoration: InputDecoration(
              hintText: 'Intro:\n[C][Em][Am][F]\n[C][Dm][G]\n\nVerse:\n…',
              hintStyle: context.text.bodyMedium!.copyWith(fontFamily: 'monospace', color: c.mutedForeground),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(gutter, DaloySpace.s3, gutter, DaloySpace.s3),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            gutter,
            DaloySpace.s2,
            gutter,
            DaloySpace.s3 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                text: 'Wrap chords in brackets: ',
                children: [
                  TextSpan(
                    text: '[C] [Am] [G]/[B]',
                    style: TextStyle(fontFamily: 'monospace', color: c.chordInk),
                  ),
                  const TextSpan(text: ' · Section headers: '),
                  TextSpan(
                    text: 'Chorus:',
                    style: TextStyle(fontFamily: 'monospace', color: c.chordInk),
                  ),
                ],
              ),
              style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmDiscardChanges(context) && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: DaloyTopBar(
          title: 'Chords',
          actions: [
            _IconKey(
              icon: TablerIcons.help_circle,
              label: 'Help',
              onPressed: () => showChordEditorHelp(context, musicalKey: widget.musicalKey),
            ),
            _IconKey(
              icon: _freetype ? TablerIcons.keyboard : TablerIcons.pencil,
              label: _freetype ? 'Switch to the chord keyboard' : 'Switch to the system keyboard',
              onPressed: _toggleMode,
            ),
            const SizedBox(width: DaloySpace.s1),
            GlassTextButton(label: 'Done', prominent: true, onPressed: _done),
          ],
        ),
        body: Focus(
          autofocus: true,
          onKeyEvent: _onKey,
          child: Column(
            children: [
              // The chart hides the stored letters in numbers mode, so say so:
              // changing the song's key later re-letters it.
              if (!_freetype && _core.notation == ChordNotation.numbers)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4, vertical: DaloySpace.s1_5),
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.05),
                    border: Border(bottom: BorderSide(color: c.border)),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: 'Saved as chords in the key of ',
                      children: [
                        TextSpan(
                          text: widget.musicalKey,
                          style: TextStyle(fontWeight: FontWeight.w700, color: c.foreground),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                  ),
                ),
              Expanded(child: _freetype ? _freetypeBody() : _customBody()),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconKey extends StatelessWidget {
  const _IconKey({required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed == null
        ? null
        : () {
            HapticFeedback.selectionClick();
            onPressed!();
          },
    tooltip: label,
    icon: Icon(icon, size: 22),
    color: context.colors.mutedForeground,
    disabledColor: context.colors.mutedForeground.withValues(alpha: 0.35),
  );
}
