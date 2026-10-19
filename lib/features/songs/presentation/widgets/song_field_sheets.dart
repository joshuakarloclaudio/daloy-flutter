import 'package:flutter/cupertino.dart' show cupertinoTextSelectionControls;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_button.dart';
import '../../../../shared/widgets/daloy_sheet.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../domain/new_song.dart';
import '../../domain/song_list_query.dart';
import '../../domain/tap_tempo.dart';
import 'song_list_sheets.dart';

/// Picks the song's written key. Resolves to a record so "No key"
/// (`value: null`) can be told apart from a dismissed sheet (null).
Future<({String? value})?> showSongKeyPicker(BuildContext context, String? current) => _showTileSheet(
  context,
  title: 'Key',
  subtitle: 'The key the chart is written in.',
  options: songKeys,
  current: current,
  noneLabel: 'No key',
);

/// Picks the song's time signature, or none.
Future<({String? value})?> showTimeSignaturePicker(BuildContext context, String? current) => _showTileSheet(
  context,
  title: 'Time signature',
  options: NewSong.timeSignatures,
  current: current,
  noneLabel: 'None',
);

Future<({String? value})?> _showTileSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<String> options,
  required String? current,
  required String noneLabel,
}) => showDaloySheet<({String? value})>(
  context: context,
  fit: true,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (sheetContext) {
    final c = sheetContext.colors;
    void pick(String? value) {
      HapticFeedback.selectionClick();
      Navigator.of(sheetContext).pop((value: value));
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: sheetContext.text.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: DaloySpace.s1),
              Text(subtitle, style: sheetContext.text.bodyMedium!.copyWith(color: c.mutedForeground)),
            ],
            const SizedBox(height: DaloySpace.s4),
            // Six to a row, so the keys line up as majors over minors.
            LayoutBuilder(
              builder: (context, box) {
                const columns = 6;
                const gap = DaloySpace.s2;
                final width = ((box.maxWidth - gap * (columns - 1)) / columns).floorToDouble();
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final option in options)
                      KeyTile(label: option, width: width, selected: option == current, onTap: () => pick(option)),
                  ],
                );
              },
            ),
            const SizedBox(height: DaloySpace.s3),
            Pressable(
              onPressed: () => pick(null),
              semanticLabel: current == null ? '$noneLabel, selected' : noneLabel,
              child: Container(
                height: ControlSize.md.height,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: current == null ? c.primary : c.border),
                  borderRadius: DaloyRadii.all(DaloyRadii.xl),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (current == null) ...[
                      Icon(TablerIcons.check, size: 16, color: c.primaryInk),
                      const SizedBox(width: DaloySpace.s1_5),
                    ],
                    Text(
                      noneLabel,
                      style: sheetContext.text.labelLarge!.copyWith(
                        color: current == null ? c.primaryInk : c.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);

/// Sets the tempo: type it, or tap along on the pad. Resolves to the BPM as
/// text ('' clears it), or null when dismissed.
Future<({String bpm})?> showTempoSheet(BuildContext context, String current) => showDaloySheet<({String bpm})>(
  context: context,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (_) => _TempoSheet(current: current),
);

class _TempoSheet extends StatefulWidget {
  const _TempoSheet({required this.current});

  final String current;

  @override
  State<_TempoSheet> createState() => _TempoSheetState();
}

class _TempoSheetState extends State<_TempoSheet> {
  late final _text = TextEditingController(text: widget.current);
  final _tapTempo = TapTempo();
  int _taps = 0;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String? get _error {
    final t = _text.text.trim();
    if (t.isEmpty) return null;
    final v = int.tryParse(t);
    return v != null && NewSong.isValidBpm(v) ? null : 'Between ${NewSong.minBpm} and ${NewSong.maxBpm} BPM.';
  }

  void _tap() {
    HapticFeedback.lightImpact();
    final bpm = _tapTempo.tap();
    setState(() {
      _taps++;
      if (bpm != null) _text.text = '$bpm';
    });
  }

  void _done() => Navigator.of(context).pop((bpm: _text.text.trim()));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final error = _error;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tempo', style: context.text.titleMedium),
              const SizedBox(height: DaloySpace.s4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IntrinsicWidth(
                    child: TextField(
                      selectionControls: cupertinoTextSelectionControls,
                      controller: _text,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 3,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => error == null ? _done() : null,
                      style: context.text.displaySmall!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      decoration: InputDecoration(
                        hintText: '–',
                        counterText: '',
                        filled: false,
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 72),
                        hintStyle: context.text.displaySmall!.copyWith(color: c.mutedForeground),
                      ),
                    ),
                  ),
                  const SizedBox(width: DaloySpace.s2),
                  Text('BPM', style: context.text.titleMedium!.copyWith(color: c.mutedForeground)),
                ],
              ),
              SizedBox(
                height: 24,
                child: Center(
                  child: Text(
                    error ?? (_taps == 1 ? 'Keep tapping…' : ''),
                    style: context.text.bodySmall!.copyWith(color: error != null ? c.destructive : c.mutedForeground),
                  ),
                ),
              ),
              const SizedBox(height: DaloySpace.s2),
              // The pad: big enough to tap along with a thumb while listening.
              Pressable(
                onPressed: _tap,
                pressedScale: 0.97,
                semanticLabel: 'Tap tempo',
                child: Container(
                  height: 132,
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.08),
                    border: Border.all(color: c.primary.withValues(alpha: 0.25)),
                    borderRadius: DaloyRadii.all(DaloyRadii.xl2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(TablerIcons.hand_finger, size: 28, color: c.primaryInk),
                      const SizedBox(height: DaloySpace.s2),
                      Text('Tap along to the beat', style: context.text.labelLarge!.copyWith(color: c.primaryInk)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DaloySpace.s4),
              Row(
                children: [
                  Expanded(
                    child: DaloyButton.outline(
                      label: 'Clear',
                      expand: true,
                      onPressed: () => Navigator.of(context).pop((bpm: '')),
                    ),
                  ),
                  const SizedBox(width: DaloySpace.s3),
                  Expanded(
                    child: DaloyButton(label: 'Done', expand: true, onPressed: error == null ? _done : null),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
