import 'package:flutter/material.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/segmented_control.dart';
import '../../songs/presentation/widgets/stepper_track.dart';
import '../domain/present_deck.dart';
import 'present_slide_view.dart';

/// Theme, font, size and lines per slide. Each change applies to the wall
/// at once ([onChanged]); [current] reads the live look back, so a remote's
/// sheet follows what the presenter has.
Future<void> showPresentSettingsSheet(
  BuildContext context, {
  required ValueGetter<PresentLook> current,
  required ValueChanged<PresentLook> onChanged,
  required Listenable changes,
  Rect? anchor,
}) => showDaloySheet<void>(
  context: context,
  fit: true,
  anchor: anchor,
  builder: (_) => ListenableBuilder(
    listenable: changes,
    builder: (context, _) => _PresentSettings(look: current(), onChanged: onChanged),
  ),
);

class _PresentSettings extends StatelessWidget {
  const _PresentSettings({required this.look, required this.onChanged});

  final PresentLook look;
  final ValueChanged<PresentLook> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Slides', style: context.text.titleMedium),
            const SizedBox(height: DaloySpace.s1),
            Text(
              'How the lyrics look on the big screen. Kept on this device.',
              style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
            ),
            const SizedBox(height: DaloySpace.s5),
            const _Label('Theme'),
            SizedBox(
              height: 86,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: PresentTheme.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: DaloySpace.s2),
                itemBuilder: (_, i) {
                  final theme = PresentTheme.values[i];
                  return _ThemeSwatch(
                    theme: theme,
                    selected: theme == look.theme,
                    onTap: () => onChanged(look.copyWith(theme: theme)),
                  );
                },
              ),
            ),
            const SizedBox(height: DaloySpace.s5),
            const _Label('Font'),
            SegmentedControl<PresentFont>(
              value: look.font,
              options: [for (final f in PresentFont.values) (f, f.label)],
              onChanged: (f) => onChanged(look.copyWith(font: f)),
            ),
            const SizedBox(height: DaloySpace.s5),
            const _Label('Text size'),
            StepperTrack(
              label: '${look.zoom}%',
              decreaseLabel: 'Smaller text',
              increaseLabel: 'Larger text',
              onDecrease: look.canZoomOut
                  ? () => onChanged(look.copyWith(zoom: look.zoom - PresentLook.zoomStep))
                  : null,
              onIncrease: look.canZoomIn
                  ? () => onChanged(look.copyWith(zoom: look.zoom + PresentLook.zoomStep))
                  : null,
            ),
            const SizedBox(height: DaloySpace.s5),
            const _Label('Lines per slide'),
            SegmentedControl<int>(
              value: look.linesPerSlide,
              options: [for (final n in PresentLook.linesPerSlideOptions) (n, '$n')],
              onChanged: (n) => onChanged(look.copyWith(linesPerSlide: n)),
            ),
            const SizedBox(height: DaloySpace.s2),
            Text(
              'Longer sections split evenly across slides.',
              style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.theme, required this.selected, required this.onTap});

  final PresentTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = PresentThemeStyle.of(theme);
    return Pressable(
      onPressed: onTap,
      semanticLabel: '${theme.label} theme${selected ? ', selected' : ''}',
      child: Column(
        children: [
          Container(
            width: 96,
            height: 54,
            decoration: BoxDecoration(
              gradient: style.background,
              borderRadius: DaloyRadii.all(DaloyRadii.md),
              border: Border.all(color: selected ? c.primary : c.border, width: selected ? 2 : 1),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final w in [48.0, 32.0])
                  Container(
                    width: w,
                    height: 3,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: style.foreground.withValues(alpha: w == 48 ? 0.7 : 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: DaloySpace.s1_5),
          Text(
            theme.label,
            style: context.text.labelMedium!.copyWith(color: selected ? c.foreground : c.mutedForeground),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: DaloySpace.s2),
    child: Text(text.toUpperCase(), style: context.text.labelSmall!.copyWith(color: context.colors.mutedForeground)),
  );
}
