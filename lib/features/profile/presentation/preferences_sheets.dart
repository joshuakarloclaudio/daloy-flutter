import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/prefs/device_prefs.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../../shared/widgets/sheet_frame.dart';
import '../../songs/chart/nashville.dart';
import '../../songs/data/song_detail_repository.dart';
import '../../songs/domain/display_prefs.dart';
import '../application/preferences_actions.dart';

Future<void> _show(BuildContext context, Widget Function(BuildContext) builder) =>
    showDaloySheet<void>(context: context, fit: true, builder: builder);

/// Light, dark or follow the phone — each shown as the surface it gives.
Future<void> showAppearanceSheet(BuildContext context) => _show(context, (_) => const _AppearanceSheet());

/// Daloy's own typeface, or the platform's.
Future<void> showTypefaceSheet(BuildContext context) => _show(context, (_) => const _TypefaceSheet());

/// What a song opens as: its chords, or just the words.
Future<void> showDefaultViewSheet(BuildContext context) => _show(context, (_) => const _DefaultViewSheet());

/// Letters or Nashville numbers, with the same four chords in both.
Future<void> showNotationSheet(BuildContext context) => _show(context, (_) => const _NotationSheet());

String themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => 'System',
  ThemeMode.light => 'Light',
  ThemeMode.dark => 'Dark',
};

String appFontLabel(AppFont font) => switch (font) {
  AppFont.daloy => 'Daloy',
  AppFont.system => 'System',
};

/// A big tappable tile: a sample on top, a label under it, ringed when chosen.
class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.selected, required this.label, required this.onTap, required this.sample});

  final bool selected;
  final String label;
  final VoidCallback onTap;
  final Widget sample;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onPressed: onTap,
        child: AnimatedContainer(
          duration: DaloyMotion.fast,
          padding: const EdgeInsets.all(DaloySpace.s1_5),
          decoration: BoxDecoration(
            borderRadius: DaloyRadii.all(DaloyRadii.xl2),
            border: Border.all(color: selected ? c.primary : c.border, width: selected ? 2 : 1),
          ),
          child: Column(
            children: [
              ClipRRect(borderRadius: DaloyRadii.all(DaloyRadii.xl), child: sample),
              const SizedBox(height: DaloySpace.s2),
              Text(label, style: context.text.labelLarge!.copyWith(color: selected ? c.primaryInk : c.mutedForeground)),
              const SizedBox(height: DaloySpace.s1),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppearanceSheet extends ConsumerWidget {
  const _AppearanceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(devicePrefsControllerProvider.select((p) => p.themeMode));
    final controller = ref.read(devicePrefsControllerProvider.notifier);
    return SheetFrame(
      title: 'Appearance',
      description: 'Kept on this device. System follows your phone, so Daloy dims with it at night.',
      children: [
        const SheetSectionLabel('Theme'),
        Row(
          children: [
            for (final (i, m) in ThemeMode.values.indexed) ...[
              if (i > 0) const SizedBox(width: DaloySpace.s3),
              Expanded(
                child: _OptionTile(
                  selected: mode == m,
                  label: themeModeLabel(m),
                  onTap: () => controller.setThemeMode(m),
                  sample: _ThemeSample(mode: m),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// A miniature screen in the palette the option gives; System is split down
/// the middle.
class _ThemeSample extends StatelessWidget {
  const _ThemeSample({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    Widget half(DaloyColors p) => ColoredBox(
      color: p.background,
      child: Padding(
        padding: const EdgeInsets.all(DaloySpace.s2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 6,
              width: 26,
              decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(height: 6),
            Container(
              height: 18,
              decoration: BoxDecoration(
                color: p.card,
                border: Border.all(color: p.border),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 5,
              width: 34,
              decoration: BoxDecoration(
                color: p.mutedForeground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );

    return SizedBox(
      height: 76,
      child: switch (mode) {
        ThemeMode.light => half(DaloyColors.light),
        ThemeMode.dark => half(DaloyColors.dark),
        ThemeMode.system => Row(
          children: [
            Expanded(child: half(DaloyColors.light)),
            Expanded(child: half(DaloyColors.dark)),
          ],
        ),
      },
    );
  }
}

class _TypefaceSheet extends ConsumerWidget {
  const _TypefaceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final font = ref.watch(devicePrefsControllerProvider.select((p) => p.font));
    final controller = ref.read(devicePrefsControllerProvider.notifier);
    final c = context.colors;

    Widget sample(String? serif, String? sans) => ColoredBox(
      color: c.card,
      child: SizedBox(
        height: 76,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aa',
                style: TextStyle(fontFamily: serif, fontSize: 26, fontWeight: FontWeight.w600, color: c.foreground),
              ),
              Text(
                'Worship',
                style: TextStyle(fontFamily: sans, fontSize: 13, color: c.mutedForeground),
              ),
            ],
          ),
        ),
      ),
    );

    return SheetFrame(
      title: 'Typeface',
      description:
          'Daloy sets titles in Merriweather and everything else in DM Sans. System uses your phone’s own font.',
      children: [
        const SheetSectionLabel('Font'),
        Row(
          children: [
            Expanded(
              child: _OptionTile(
                selected: font == AppFont.daloy,
                label: 'Daloy',
                onTap: () => controller.setFont(AppFont.daloy),
                sample: sample('Merriweather', 'DMSans'),
              ),
            ),
            const SizedBox(width: DaloySpace.s3),
            Expanded(
              child: _OptionTile(
                selected: font == AppFont.system,
                label: 'System',
                onTap: () => controller.setFont(AppFont.system),
                sample: sample(null, null),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DefaultViewSheet extends ConsumerWidget {
  const _DefaultViewSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(chartPrefsProvider.select((p) => p.value?.viewMode ?? SongViewMode.chords));
    final c = context.colors;
    return SheetFrame(
      title: 'Default view',
      description: 'What a song shows first: chords to play from, or just the words to sing along.',
      children: [
        const SheetSectionLabel('Open songs as'),
        SegmentedControl<SongViewMode>(
          value: mode,
          options: const [(SongViewMode.chords, 'Chords'), (SongViewMode.lyrics, 'Lyrics')],
          onChanged: (m) => ref.read(preferencesActionsProvider.notifier).setDefaultView(m),
        ),
        const SizedBox(height: DaloySpace.s5),
        _Specimen(
          label: 'Preview',
          child: AnimatedSwitcher(
            duration: DaloyMotion.fast,
            child: Column(
              key: ValueKey(mode),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mode == SongViewMode.chords)
                  Text(
                    'G           D/F#         Em',
                    style: _chartStyle(context).copyWith(color: c.primaryInk, fontWeight: FontWeight.w700),
                  ),
                Text('Amazing grace, how sweet the sound', style: _chartStyle(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotationSheet extends ConsumerWidget {
  const _NotationSheet();

  static const _specimen = ['G', 'Am', 'Cmaj7', 'F#dim'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(chartPrefsProvider).value;
    final notation = prefs?.notation ?? ChordNotation.letters;
    final c = context.colors;
    return SheetFrame(
      title: 'Chord notation',
      description: 'Letters are real chord names. Numbers are Nashville: the same chart reads in any key.',
      children: [
        const SheetSectionLabel('Chords as'),
        SegmentedControl<ChordNotation>(
          value: notation,
          options: const [(ChordNotation.letters, 'Letters'), (ChordNotation.numbers, 'Numbers')],
          onChanged: (n) => ref.read(preferencesActionsProvider.notifier).setNotation(n),
        ),
        const SizedBox(height: DaloySpace.s5),
        _Specimen(
          label: 'In the key of G',
          child: Row(
            children: [
              for (final chord in _specimen)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: DaloyMotion.fast,
                    child: Text(
                      displayChord(chord, notation, 'G', 0),
                      key: ValueKey('$notation$chord'),
                      style: _chartStyle(context).copyWith(color: c.primaryInk, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

TextStyle _chartStyle(BuildContext context) =>
    context.text.bodyLarge!.copyWith(fontFamily: 'monospace', fontFeatures: const [FontFeature.tabularFigures()]);

/// The choice shown rather than described: a dashed-edged card with a sample.
class _Specimen extends StatelessWidget {
  const _Specimen({required this.child, this.label});

  final Widget child;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(DaloySpace.s4),
      decoration: BoxDecoration(
        color: c.muted.withValues(alpha: 0.5),
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(label!.toUpperCase(), style: context.text.labelSmall!.copyWith(color: c.mutedForeground)),
            const SizedBox(height: DaloySpace.s2),
          ],
          child,
        ],
      ),
    );
  }
}

/// Row glyph for preferences.
const kPrefIcons = (
  appearance: TablerIcons.sun_moon,
  typeface: TablerIcons.typography,
  view: TablerIcons.eye,
  notation: TablerIcons.hash,
);
