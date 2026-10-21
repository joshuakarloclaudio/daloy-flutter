import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_sheet.dart';
import '../../../../shared/widgets/segmented_control.dart';
import '../../chart/nashville.dart';
import '../../editor/chart_editor_core.dart';
import '../../editor/popup_geometry.dart';
import '../../editor/quality_menu.dart';

enum KeyboardTab { chords, sections, edit }

/// Which root set the chord keys offer: the seven chords of the song's key
/// with their qualities attached, or the twelve bare roots (the only choice
/// when the song has no usable key).
enum ChordKeyLayout { diatonic, chromatic }

const _naturalNotes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
const _sharpNotes = ['C#', 'D#', 'F#', 'G#', 'A#'];
const _flatNotes = ['Db', 'Eb', 'Gb', 'Ab', 'Bb'];
const _naturalDegrees = ['1', '2', '3', '4', '5', '6', '7'];
const _flatDegrees = ['b2', 'b3', 'b5', 'b6', 'b7'];
const _sharpDegrees = ['#1', '#2', '#4', '#5', '#6'];

/// The modifier row, with what each prints on a number chart.
const _modifierRow = <(String label, String? numberLabel, String value)>[
  ('Maj', null, ''),
  ('m', null, 'm'),
  ('7', null, '7'),
  ('maj7', 'Δ7', 'maj7'),
  ('m7', null, 'm7'),
  ('sus2', null, 'sus2'),
  ('sus4', null, 'sus4'),
  ('dim', '°', 'dim'),
  ('dim7', '°7', 'dim7'),
  ('m7b5', 'ø7', 'm7b5'),
  ('aug', '+', 'aug'),
  ('6', null, '6'),
  ('9', null, '9'),
  ('add9', null, 'add9'),
  ('m9', null, 'm9'),
  ('11', null, '11'),
  ('13', null, '13'),
];

const sectionNames = ['Intro', 'Verse', 'Pre-Chorus', 'Chorus', 'Bridge', 'Outro', 'Interlude', 'Transpose', 'Shift'];
const _specialChars = ['-', '|', '/', '_', '.'];
const _repeatCounts = [2, 3, 4, 8];

/// Time signatures for one bar that doesn't fit the song's (`| 2/4 Em F#m |`).
const _barMeters = ['2/4', '3/4', '4/4', '6/4'];

enum _Tone { tonic, subdominant, dominant }

/// 1/3/6 tonic, 2/4 subdominant, 5/7 dominant — so a player spots "the V" by hue.
_Tone _toneOf(int degree) => switch (degree) {
  5 || 7 => _Tone.dominant,
  2 || 4 => _Tone.subdominant,
  _ => _Tone.tonic,
};

/// Height of the key area on every tab, so switching tabs (or Key ↔ All)
/// never makes the keyboard jump.
const keyboardBodyHeight = 264.0;

/// The toolbar above the key area.
const keyboardToolbarHeight = 44.0;

/// Gap inside a group of keys, and between groups.
const _gap = 6.0;
const _groupGap = 12.0;

/// The chord keyboard under the editor (the web's `ChordsTab` / `SectionsTab`
/// / `EditTab`), grouped as: toolbar · key area · tabs. The toolbar holds
/// history, text size and how chords are typed (set once, so it's a sheet,
/// not always-on toggles); Done lives in the screen's top bar. It only calls
/// into [core]; the screen rebuilds on change.
class ChordKeyboard extends StatelessWidget {
  const ChordKeyboard({
    super.key,
    required this.core,
    required this.tab,
    required this.onTab,
    required this.layout,
    required this.onLayout,
    required this.clearConfirm,
    required this.onCopy,
    required this.onPaste,
    required this.onClear,
    this.onZoomIn,
    this.onZoomOut,
    this.scale = 1,
  });

  /// 1 on a phone; a tablet's side panel stretches the keys to fill it.
  final double scale;

  final ChartEditorCore core;
  final KeyboardTab tab;
  final ValueChanged<KeyboardTab> onTab;
  final ChordKeyLayout layout;
  final ValueChanged<ChordKeyLayout> onLayout;
  final bool clearConfirm;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final VoidCallback onClear;

  /// Null when the chart is already at its largest / smallest.
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  Future<void> _openSettings(BuildContext context) => showDaloySheet<void>(
    context: context,
    constraints: const BoxConstraints(maxWidth: 560),
    // The keyboard rebuilds with the screen; the sheet keeps its own copy.
    builder: (_) => StatefulBuilder(
      builder: (context, setSheet) => _ChordKeySettings(
        core: core,
        layout: layout,
        onLayout: (l) {
          onLayout(l);
          setSheet(() {});
        },
        onNotation: (n) {
          core.notation = n;
          setSheet(() {});
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDiatonic = layout == ChordKeyLayout.diatonic && core.diatonic != null;
    final numbers = core.notation == ChordNotation.numbers;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DaloySpace.s3, DaloySpace.s1, DaloySpace.s3, DaloySpace.s2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Toolbar: history on the left; text size and the chord-key
              // settings (which read out what's set) on the right.
              SizedBox(
                height: keyboardToolbarHeight,
                child: Row(
                  children: [
                    _ToolButton(
                      icon: TablerIcons.arrow_back_up,
                      label: 'Undo',
                      onPressed: core.canUndo ? core.undo : null,
                    ),
                    _ToolButton(
                      icon: TablerIcons.arrow_forward_up,
                      label: 'Redo',
                      onPressed: core.canRedo ? core.redo : null,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _ToolButton(icon: TablerIcons.text_decrease, label: 'Smaller text', onPressed: onZoomOut),
                          _ToolButton(icon: TablerIcons.text_increase, label: 'Larger text', onPressed: onZoomIn),
                          const SizedBox(width: DaloySpace.s1),
                          // Shrinks before the row overflows on a narrow phone.
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _SettingsChip(
                                label: '${numbers ? '123' : 'ABC'} · ${isDiatonic ? 'Key' : 'All'}',
                                onPressed: () => _openSettings(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DaloySpace.s1),
              SizedBox(
                height: keyboardBodyHeight * scale,
                child: switch (tab) {
                  KeyboardTab.chords => _ChordsTab(core: core, isDiatonic: isDiatonic, scale: scale),
                  KeyboardTab.sections => _SectionsTab(core: core),
                  KeyboardTab.edit => _EditTab(
                    core: core,
                    clearConfirm: clearConfirm,
                    onCopy: onCopy,
                    onPaste: onPaste,
                    onClear: onClear,
                  ),
                },
              ),
              const SizedBox(height: DaloySpace.s2),
              _TabBar(tab: tab, onTab: onTab),
            ],
          ),
        ),
      ),
    );
  }
}

/// The toolbar's "ABC · Key" button: says how chords are typed, opens the
/// sheet that changes it.
class _SettingsChip extends StatelessWidget {
  const _SettingsChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: 'Chord keys: $label',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
          decoration: BoxDecoration(
            color: c.muted.withValues(alpha: 0.6),
            border: Border.all(color: c.border),
            borderRadius: DaloyRadii.all(DaloyRadii.xl),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(TablerIcons.adjustments_horizontal, size: 16, color: c.mutedForeground),
              const SizedBox(width: DaloySpace.s1_5),
              Text(label, style: context.text.labelMedium!.copyWith(color: c.foreground)),
            ],
          ),
        ),
      ),
    );
  }
}

/// How the chord keys type: letters or numbers, and the song's key or all
/// twelve roots.
class _ChordKeySettings extends StatelessWidget {
  const _ChordKeySettings({required this.core, required this.layout, required this.onLayout, required this.onNotation});

  final ChartEditorCore core;
  final ChordKeyLayout layout;
  final ValueChanged<ChordKeyLayout> onLayout;
  final ValueChanged<ChordNotation> onNotation;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasKey = core.diatonic != null;
    final current = hasKey ? layout : ChordKeyLayout.chromatic;
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: DaloySpace.s2),
      child: Text(text, style: context.text.labelLarge),
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Chord keys', style: context.text.titleMedium),
            const SizedBox(height: DaloySpace.s4),
            label('Type chords as'),
            SegmentedControl<ChordNotation>(
              value: core.notation,
              options: const [(ChordNotation.letters, 'Letters (ABC)'), (ChordNotation.numbers, 'Numbers (123)')],
              disabled: core.numbersAvailable ? const {} : const {ChordNotation.numbers},
              onChanged: onNotation,
            ),
            const SizedBox(height: DaloySpace.s4),
            label('Chord keys show'),
            SegmentedControl<ChordKeyLayout>(
              value: current,
              options: const [(ChordKeyLayout.diatonic, "The song's key"), (ChordKeyLayout.chromatic, 'All 12 roots')],
              disabled: hasKey ? const {} : const {ChordKeyLayout.diatonic},
              onChanged: onLayout,
            ),
            if (!hasKey || !core.numbersAvailable) ...[
              const SizedBox(height: DaloySpace.s3),
              Text(
                'Set a key for this song to use its chords or type numbers.',
                style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, required this.label, required this.onPressed});

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
    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    padding: EdgeInsets.zero,
    style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    color: context.colors.foreground,
    disabledColor: context.colors.mutedForeground.withValues(alpha: 0.35),
  );
}

/// [function] is the system keyboard's darker grey for ⌫ and return.
enum _KeyStyle { normal, function, ghost, danger, active }

/// What a held key offers: items fetched at press time (empty: it's a plain
/// tap key), how each reads, and what committing one does.
class HoldPopup {
  const HoldPopup({required this.items, required this.label, required this.onCommit});

  final List<String> Function() items;
  final String Function(String item) label;
  final void Function(String item) onCommit;
}

/// How long to hold before the popup opens — shorter than a context menu, it's a key.
const _holdDelay = Duration(milliseconds: 320);

/// A slide further than this before the popup opens abandons the press.
const _moveCancel = 14.0;

/// One key. Commits on press for plain keys, on release for [commitOnRelease]
/// ones. With a [popup] it's the iOS accent-key gesture: a tap inserts, a hold
/// opens a grid above the key, sliding picks a cell, lifting commits, and
/// sliding off the grid cancels.
class _Key extends StatefulWidget {
  const _Key({
    required this.onPress,
    required this.child,
    this.style = _KeyStyle.normal,
    this.label,
    this.fill,
    this.commitOnRelease = false,
    this.repeat = false,
    this.popup,
  });

  final VoidCallback onPress;
  final Widget child;
  final _KeyStyle style;
  final String? label;
  final Color? fill;
  final bool commitOnRelease;

  /// Held down, it fires again and again, like backspace on a phone keyboard.
  final bool repeat;
  final HoldPopup? popup;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _down = false;

  // Hold-popup state (only used when widget.popup != null).
  Timer? _timer;
  Offset _start = Offset.zero;
  bool _aborted = false;
  OverlayEntry? _entry;
  PopupLayout? _layout;
  List<String> _items = const [];
  final _active = ValueNotifier<int>(0);

  Timer? _repeatTimer;

  /// Hold-to-repeat timing, close to iOS / Gboard: a beat, then steady.
  static const _repeatDelay = Duration(milliseconds: 420);
  static const _repeatEvery = Duration(milliseconds: 70);

  void _startRepeat() {
    setState(() => _down = true);
    _fire();
    _repeatTimer?.cancel();
    _repeatTimer = Timer(_repeatDelay, () {
      _repeatTimer = Timer.periodic(_repeatEvery, (_) {
        if (mounted) _fire();
      });
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
    if (mounted) setState(() => _down = false);
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _timer?.cancel();
    _closePopup();
    _active.dispose();
    super.dispose();
  }

  void _fire() {
    HapticFeedback.selectionClick();
    widget.onPress();
  }

  void _closePopup() {
    _entry?.remove();
    _entry = null;
    _layout = null;
  }

  void _openPopup() {
    _timer = null;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !mounted) return;
    final anchor = box.localToGlobal(Offset.zero) & box.size;
    final layout = layoutPopup(anchor, _items.length, MediaQuery.sizeOf(context));
    _layout = layout;
    // Index 0 is the diatonic quality / the chord's third, so lifting straight
    // off without moving does the same as a plain tap would, or the likeliest thing.
    _active.value = 0;
    final popup = widget.popup!;
    _entry = OverlayEntry(
      builder: (_) => _PopupGrid(layout: layout, labels: [for (final i in _items) popup.label(i)], active: _active),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    HapticFeedback.mediumImpact();
  }

  void _onDown(PointerDownEvent e) {
    setState(() => _down = true);
    _aborted = false;
    if (widget.popup == null) {
      if (!widget.commitOnRelease) _fire();
      return;
    }
    _items = widget.popup!.items();
    _start = e.position;
    _timer?.cancel();
    if (_items.isNotEmpty) _timer = Timer(_holdDelay, _openPopup);
  }

  void _onMove(PointerMoveEvent e) {
    final layout = _layout;
    if (layout != null) {
      final index = hitTestPopup(layout, e.position);
      if (index != _active.value) {
        _active.value = index;
        if (index >= 0) HapticFeedback.selectionClick();
      }
      return;
    }
    if (_timer != null && (e.position - _start).distance > _moveCancel) {
      // The finger left the key before the hold landed: not a tap either.
      _timer!.cancel();
      _timer = null;
      _aborted = true;
    }
  }

  void _onUp(PointerUpEvent e) {
    setState(() => _down = false);
    _timer?.cancel();
    _timer = null;
    if (_layout != null) {
      final index = _active.value;
      _closePopup();
      if (index >= 0 && index < _items.length) widget.popup!.onCommit(_items[index]);
      return;
    }
    if (_aborted) return;
    if (widget.popup != null || widget.commitOnRelease) _fire();
  }

  void _onCancel(PointerCancelEvent e) {
    setState(() => _down = false);
    _timer?.cancel();
    _timer = null;
    _closePopup();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (bg, fg) = switch (widget.style) {
      _KeyStyle.normal => (widget.fill ?? c.muted.withValues(alpha: 0.8), c.foreground),
      _KeyStyle.function => (c.mutedForeground.withValues(alpha: 0.2), c.foreground),
      _KeyStyle.ghost => (Colors.transparent, c.mutedForeground),
      _KeyStyle.danger => (c.destructive.withValues(alpha: 0.1), c.destructive),
      _KeyStyle.active => (c.primary, c.primaryForeground),
    };
    final face = AnimatedScale(
      scale: _down ? 0.93 : 1,
      duration: DaloyMotion.fast,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: DaloyRadii.all(DaloyRadii.xl)),
        child: DefaultTextStyle.merge(
          style: context.text.titleSmall!.copyWith(color: fg),
          child: IconTheme(
            data: IconThemeData(color: fg, size: 22),
            child: widget.child,
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: widget.label != null,
      onTap: widget.onPress,
      child: widget.repeat
          ? Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (_) => _startRepeat(),
              onPointerUp: (_) => _stopRepeat(),
              onPointerCancel: (_) => _stopRepeat(),
              child: face,
            )
          : widget.popup != null
          // Raw pointer events: the slide onto the popup must keep reporting
          // to this key even once the finger has left it.
          ? Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _onDown,
              onPointerMove: _onMove,
              onPointerUp: _onUp,
              onPointerCancel: _onCancel,
              child: face,
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) {
                setState(() => _down = true);
                if (!widget.commitOnRelease) _fire();
              },
              onTapUp: (_) {
                setState(() => _down = false);
                if (widget.commitOnRelease) _fire();
              },
              onTapCancel: () => setState(() => _down = false),
              child: face,
            ),
    );
  }
}

/// The grid above a held key. Never takes touches: the held key keeps the
/// pointer, so the popup must not intercept the slide it is showing.
class _PopupGrid extends StatelessWidget {
  const _PopupGrid({required this.layout, required this.labels, required this.active});

  final PopupLayout layout;
  final List<String> labels;
  final ValueListenable<int> active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fromRect(
            rect: layout.rect,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.card,
                border: Border.all(color: c.border),
                borderRadius: DaloyRadii.all(DaloyRadii.xl2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: active,
            builder: (context, index, _) => Stack(
              children: [
                for (var i = 0; i < layout.cells.length; i++)
                  Positioned.fromRect(
                    rect: layout.cells[i],
                    child: Semantics(
                      container: true,
                      label: labels[i],
                      selected: i == index,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: i == index ? c.primary : c.muted.withValues(alpha: 0.8),
                          borderRadius: DaloyRadii.all(DaloyRadii.xl),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              labels[i],
                              maxLines: 1,
                              style: context.text.titleSmall!.copyWith(
                                color: i == index ? c.primaryForeground : c.foreground,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Keys sharing a row evenly, [gap] apart.
Widget _row(List<Widget> keys, {double gap = _gap}) => Row(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    for (var i = 0; i < keys.length; i++) ...[
      if (i > 0) SizedBox(width: gap),
      keys[i] is Expanded ? keys[i] : Expanded(child: keys[i]),
    ],
  ],
);

class _ChordsTab extends StatefulWidget {
  const _ChordsTab({required this.core, required this.isDiatonic, required this.scale});

  final double scale;
  final ChartEditorCore core;
  final bool isDiatonic;

  @override
  State<_ChordsTab> createState() => _ChordsTabState();
}

class _ChordsTabState extends State<_ChordsTab> {
  final _modScroll = ScrollController();

  @override
  void dispose() {
    _modScroll.dispose();
    super.dispose();
  }

  Color _toneFill(BuildContext context, _Tone tone) {
    final c = context.colors;
    final base = switch (tone) {
      _Tone.tonic => c.chordInk,
      _Tone.subdominant => const Color(0xFFD97706),
      _Tone.dominant => const Color(0xFFE11D48),
    };
    return base.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.12);
  }

  Color _toneInk(BuildContext context, _Tone tone) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (tone) {
      _Tone.tonic => c.chordInk,
      _Tone.subdominant => dark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      _Tone.dominant => dark ? const Color(0xFFFB7185) : const Color(0xFFE11D48),
    };
  }

  /// Hold a chord key for its qualities. [root] is the letter root the popup
  /// reasons in, whatever the key is labelled in; null (a number the key
  /// can't spell) means the key still taps but offers nothing.
  HoldPopup? _qualityPopup(String? root) {
    if (root == null) return null;
    final core = widget.core;
    return HoldPopup(
      items: () => qualityMenuForRoot(root, core.musicalKey),
      label: (q) => displayChord(root + q, core.notation, core.musicalKey, 0),
      onCommit: (q) => core.insertChordWithQuality(root, q),
    );
  }

  /// Hold `/` for the bass notes that suit the chord at the cursor.
  HoldPopup _bassPopup() {
    final core = widget.core;
    return HoldPopup(
      items: () {
        final root = core.chordRootAtCursor;
        final options = core.diatonic == null ? null : diatonicBassOptions(root, core.musicalKey);
        if (options != null && options.isNotEmpty) return options;
        // Chromatic fallback for a song with no usable key.
        final all = [..._naturalNotes, ...(core.useFlats ? _flatNotes : _sharpNotes)];
        return [
          for (final n in all)
            if (n != root) n,
        ];
      },
      label: (n) => '/${displayChord(n, core.notation, core.musicalKey, 0)}',
      onCommit: core.insertBassNote,
    );
  }

  Widget _chordKey(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    _Tone tone = _Tone.tonic,
    String? semantic,
    bool large = true,
    String? root,
  }) => _Key(
    fill: _toneFill(context, tone),
    commitOnRelease: true,
    popup: _qualityPopup(root),
    label: semantic ?? 'Insert $label',
    onPress: onTap,
    child: Text(
      label,
      maxLines: 1,
      style: (large ? context.text.titleMedium! : context.text.titleSmall!).copyWith(color: _toneInk(context, tone)),
    ),
  );

  /// A root key's letter spelling: itself in letters, its degree in the key in numbers.
  String? _letterRoot(String note) =>
      widget.core.notation == ChordNotation.numbers ? nashvilleToChord(note, widget.core.musicalKey) : note;

  @override
  Widget build(BuildContext context) {
    final core = widget.core;
    final c = context.colors;
    final numbers = core.notation == ChordNotation.numbers;
    final diatonic = core.diatonic;
    final isDiatonic = widget.isDiatonic && diatonic != null;
    final selected = core.selectedModifier;

    final naturals = numbers ? _naturalDegrees : _naturalNotes;
    final accidentals = numbers
        ? (core.useFlats ? _flatDegrees : _sharpDegrees)
        : (core.useFlats ? _flatNotes : _sharpNotes);

    // Qualities: a full-width row of their own, scrolling sideways.
    final modifiers = ListView.separated(
      controller: _modScroll,
      scrollDirection: Axis.horizontal,
      itemCount: _modifierRow.length,
      separatorBuilder: (_, _) => const SizedBox(width: _gap),
      itemBuilder: (context, i) {
        final (label, numberLabel, value) = _modifierRow[i];
        return SizedBox(
          width: 62,
          child: _Key(
            commitOnRelease: true,
            style: selected == value ? _KeyStyle.active : _KeyStyle.normal,
            label: label,
            onPress: () => core.selectModifier(value),
            child: Text(numbers && numberLabel != null ? numberLabel : label, style: context.text.titleSmall),
          ),
        );
      },
    );

    // ♯ / ♭ as a key on the accidentals row, first in line.
    final sharpFlat = _Key(
      style: _KeyStyle.ghost,
      label: core.useFlats ? 'Using flats. Switch to sharps' : 'Using sharps. Switch to flats',
      onPress: () => core.useFlats = !core.useFlats,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '♯',
              style: TextStyle(
                color: core.useFlats ? c.mutedForeground : c.primaryInk,
                fontWeight: core.useFlats ? FontWeight.w400 : FontWeight.w800,
              ),
            ),
            TextSpan(
              text: ' / ',
              style: TextStyle(color: c.mutedForeground),
            ),
            TextSpan(
              text: '♭',
              style: TextStyle(
                color: core.useFlats ? c.primaryInk : c.mutedForeground,
                fontWeight: core.useFlats ? FontWeight.w800 : FontWeight.w400,
              ),
            ),
          ],
          style: context.text.titleMedium,
        ),
      ),
    );

    // Laid out like a phone keyboard's last two rows: punctuation with ⌫ at
    // its right end, then a wide space bar with return in the corner.
    final specials = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final ch in _specialChars) ...[
          Expanded(
            flex: 2,
            child: _Key(
              label: ch == '/' ? 'Insert slash. Hold for bass notes' : 'Insert $ch',
              popup: ch == '/' ? _bassPopup() : null,
              onPress: () => core.insertText(ch),
              child: Text(ch, style: context.text.titleMedium!.copyWith(fontFamily: 'monospace')),
            ),
          ),
          const SizedBox(width: _gap),
        ],
        Expanded(
          flex: 3,
          child: _Key(
            label: 'Backspace',
            style: _KeyStyle.function,
            repeat: true,
            onPress: core.deleteBack,
            child: const Icon(TablerIcons.backspace, size: 22),
          ),
        ),
      ],
    );

    final bottom = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: _Key(
            label: 'Insert space',
            onPress: () => core.insertText(' '),
            child: Text('space', style: context.text.labelLarge!.copyWith(color: c.mutedForeground)),
          ),
        ),
        const SizedBox(width: _gap),
        Expanded(
          child: _Key(
            label: 'New line',
            style: _KeyStyle.function,
            onPress: () => core.insertText('\n'),
            child: const Icon(TablerIcons.corner_down_left, size: 22),
          ),
        ),
      ],
    );

    // Groups: qualities · chords (+ borrowed / accidentals) · typing rows.
    // Heights add up to [keyboardBodyHeight] in both layouts, so Key ↔ All
    // keeps the keyboard the same size.
    final s = widget.scale;
    final List<Widget> children;
    if (isDiatonic) {
      final borrowed = core.borrowed ?? const [];
      children = [
        SizedBox(height: 40 * s, child: modifiers),
        SizedBox(height: _groupGap * s),
        SizedBox(
          height: 52 * s,
          child: _row([
            for (final chord in diatonic)
              _chordKey(
                context,
                numbers ? chord.numberLabel : chord.root + (chord.quality == 'dim' ? '°' : chord.quality),
                () => core.insertDiatonicChord(chord.root, chord.quality),
                tone: _toneOf(chord.degree),
                semantic: 'Insert ${chord.chord}',
                large: false,
                root: chord.root,
              ),
          ]),
        ),
        SizedBox(height: _gap * s),
        // Borrowed chords, in a neutral tone so they read as "outside the key".
        SizedBox(
          height: 46 * s,
          child: _row([
            for (final chord in borrowed)
              _Key(
                label: 'Insert ${chord.chord}',
                commitOnRelease: true,
                popup: _qualityPopup(chord.root),
                onPress: () => core.insertDiatonicChord(chord.root, chord.quality),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    numbers ? chord.numberLabel : chord.chord,
                    maxLines: 1,
                    style: context.text.titleSmall!.copyWith(color: c.chordInk),
                  ),
                ),
              ),
          ]),
        ),
        SizedBox(height: _groupGap * s),
        SizedBox(height: 44 * s, child: specials),
        SizedBox(height: _gap * s),
        SizedBox(height: 46 * s, child: bottom),
      ];
    } else {
      final noKey = !core.numbersAvailable || diatonic == null;
      children = [
        SizedBox(height: 40 * s, child: modifiers),
        SizedBox(height: _groupGap * s),
        SizedBox(
          height: 52 * s,
          child: _row([
            for (final n in naturals) _chordKey(context, n, () => core.insertChord(n), root: _letterRoot(n)),
          ]),
        ),
        SizedBox(height: _gap * s),
        SizedBox(
          height: 46 * s,
          child: _row([
            sharpFlat,
            for (final n in accidentals)
              _chordKey(context, n, () => core.insertChord(n), large: false, root: _letterRoot(n)),
          ]),
        ),
        SizedBox(
          height: _groupGap * s,
          child: noKey
              ? Center(
                  child: Text(
                    'Set a song key to use its chords or type numbers.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall!.copyWith(color: c.mutedForeground, fontSize: 10, height: 1),
                  ),
                )
              : null,
        ),
        SizedBox(height: 44 * s, child: specials),
        SizedBox(height: _gap * s),
        SizedBox(height: 46 * s, child: bottom),
      ];
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [...children]);
  }
}

class _SectionsTab extends StatelessWidget {
  const _SectionsTab({required this.core});

  final ChartEditorCore core;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sectionNames.length; i += 3) ...[
          if (i > 0) const SizedBox(height: _gap),
          Expanded(
            child: _row([
              for (final name in sectionNames.skip(i).take(3))
                _Key(
                  onPress: () => core.insertSectionName(name),
                  child: Text(name, style: context.text.titleSmall),
                ),
            ]),
          ),
        ],
        const SizedBox(height: _groupGap),
        _labelledRow(context, 'REPEAT', [
          for (final n in _repeatCounts)
            _Key(
              label: 'Insert repeat marker x$n',
              onPress: () => core.insertRepeat(n),
              child: Text('x$n', style: context.text.titleMedium!.copyWith(fontFamily: 'monospace')),
            ),
        ]),
        const SizedBox(height: _gap),
        _labelledRow(context, 'TIME', [
          for (final m in _barMeters)
            _Key(
              label: 'Insert $m bar',
              onPress: () => core.insertMeter(m),
              child: Text(m, style: context.text.titleMedium!.copyWith(fontFamily: 'monospace')),
            ),
        ]),
      ],
    );
  }

  Widget _labelledRow(BuildContext context, String label, List<Widget> keys) => SizedBox(
    height: 48,
    child: Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: context.text.labelSmall!.copyWith(
              color: context.colors.mutedForeground,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: DaloySpace.s3),
        Expanded(child: _row(keys)),
      ],
    ),
  );
}

class _EditTab extends StatelessWidget {
  const _EditTab({
    required this.core,
    required this.clearConfirm,
    required this.onCopy,
    required this.onPaste,
    required this.onClear,
  });

  final ChartEditorCore core;
  final bool clearConfirm;
  final VoidCallback onCopy;
  final VoidCallback onPaste;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    Widget icon(IconData i, String label, VoidCallback f, {_KeyStyle style = _KeyStyle.normal}) =>
        _Key(label: label, style: style, repeat: true, onPress: f, child: Icon(i, size: 22));
    Widget text(IconData i, String t, VoidCallback f, {bool iconFirst = true}) => _Key(
      label: t,
      onPress: f,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconFirst) Icon(i, size: 18),
            if (iconFirst) const SizedBox(width: 4),
            Text(t, style: context.text.labelLarge),
            if (!iconFirst) const SizedBox(width: 4),
            if (!iconFirst) Icon(i, size: 18),
          ],
        ),
      ),
    );

    // Move · jump · delete and clipboard · clear. Four even rows that fill
    // the same height as the other tabs.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _row([
            icon(TablerIcons.arrow_left, 'Move left', core.moveLeft),
            icon(TablerIcons.arrow_right, 'Move right', core.moveRight),
            icon(TablerIcons.arrow_up, 'Move up', core.moveUp),
            icon(TablerIcons.arrow_down, 'Move down', core.moveDown),
          ]),
        ),
        const SizedBox(height: _gap),
        Expanded(
          child: _row([
            text(TablerIcons.arrow_bar_to_left, 'Line', core.moveToLineStart),
            text(TablerIcons.arrow_bar_to_right, 'Line', core.moveToLineEnd, iconFirst: false),
            text(TablerIcons.arrow_bar_to_up, 'Start', core.moveToStart),
            text(TablerIcons.arrow_bar_to_down, 'End', core.moveToEnd, iconFirst: false),
          ]),
        ),
        const SizedBox(height: _groupGap),
        Expanded(
          child: _row([
            _Key(
              label: 'Backspace',
              style: _KeyStyle.function,
              repeat: true,
              onPress: core.deleteBack,
              child: const Icon(TablerIcons.backspace, size: 22),
            ),
            _Key(
              label: 'Delete forward',
              style: _KeyStyle.function,
              repeat: true,
              onPress: core.deleteForward,
              child: Transform.flip(flipX: true, child: const Icon(TablerIcons.backspace, size: 22)),
            ),
            text(TablerIcons.copy, 'Copy', onCopy),
            text(TablerIcons.clipboard, 'Paste', onPaste),
          ]),
        ),
        const SizedBox(height: _gap),
        Expanded(
          child: _Key(
            style: _KeyStyle.danger,
            label: clearConfirm ? 'Tap again to clear all' : 'Clear all',
            onPress: onClear,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(TablerIcons.trash, size: 18),
                const SizedBox(width: 6),
                Text(clearConfirm ? 'Tap again to clear all' : 'Clear all', style: context.text.labelLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.tab, required this.onTab});

  final KeyboardTab tab;
  final ValueChanged<KeyboardTab> onTab;

  static const _tabs = [
    (KeyboardTab.chords, 'Chords', TablerIcons.music),
    (KeyboardTab.sections, 'Sections', TablerIcons.layout_rows),
    (KeyboardTab.edit, 'Edit', TablerIcons.arrows_move),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: c.muted.withValues(alpha: 0.6), borderRadius: DaloyRadii.all(DaloyRadii.xl)),
      child: Row(
        children: [
          for (final (t, label, icon) in _tabs)
            Expanded(
              child: Semantics(
                button: true,
                selected: tab == t,
                label: label,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onTab(t);
                  },
                  child: AnimatedContainer(
                    duration: DaloyMotion.fast,
                    decoration: BoxDecoration(
                      color: tab == t ? c.background : Colors.transparent,
                      border: tab == t ? Border.all(color: c.border) : null,
                      borderRadius: DaloyRadii.all(DaloyRadii.lg),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 20, color: tab == t ? c.primaryInk : c.mutedForeground),
                        const SizedBox(height: 2),
                        Text(
                          label.toUpperCase(),
                          style: context.text.labelSmall!.copyWith(
                            fontSize: 10,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w600,
                            color: tab == t ? c.primaryInk : c.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
