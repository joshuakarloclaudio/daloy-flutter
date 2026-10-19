import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../../shared/widgets/daloy_sheet.dart' show sheetMaxHeightFactor;
import '../../../../core/theme/daloy_theme.dart';
import '../../../../shared/widgets/daloy_glass.dart';
import '../../data/perform_prefs_repository.dart';
import '../../domain/perform_theme.dart';

/// Draws [child] in the device's Perform theme, and keeps up as it changes —
/// sheets wrap themselves in this too, so a theme picked in the settings
/// sheet repaints the sheet as well as the chart behind it.
class PerformThemed extends ConsumerWidget {
  const PerformThemed({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(performPrefsProvider).value?.theme ?? PerformTheme.appDefault;
    final palette = theme.resolve(MediaQuery.platformBrightnessOf(context));
    final dark = palette.brightness == Brightness.dark;
    return PerformPaletteScope(
      palette: palette,
      child: AnimatedTheme(
        data: palette.theme,
        duration: palette.flat || MediaQuery.disableAnimationsOf(context) ? Duration.zero : DaloyMotion.medium,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Chrome floating over the chart: frosted on screens that can blur, solid
/// on e-ink panels where blur and translucency smear. With [borderRadius],
/// the frost, fill and border all follow the rounded shape (a pill).
///
/// [shadow] lifts it off the chart, for the floating pieces (none on e-ink).
class PerformGlass extends StatelessWidget {
  const PerformGlass({super.key, required this.child, this.border, this.borderRadius, this.shadow = false});

  final Widget child;
  final Border? border;
  final BorderRadius? borderRadius;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final palette = PerformPaletteScope.of(context);
    return DaloyGlass(
      borderRadius: borderRadius ?? BorderRadius.zero,
      tintAlpha: 0.82,
      shadow: shadow,
      sheen: false,
      hairline: false,
      border: border,
      flat: palette.flat,
      child: child,
    );
  }
}

/// Every panel Perform opens. Up from the bottom on a phone, where the thumb
/// is; in from the right on a tablet, so the chart stays readable beside it.
Future<T?> showPerformSheet<T>(
  BuildContext context, {
  required String title,
  String? description,
  required WidgetBuilder builder,
}) {
  final wide = MediaQuery.sizeOf(context).width >= DaloyBreakpoints.tablet;
  Widget body(BuildContext sheetContext) => PerformThemed(
    child: Builder(
      builder: (themed) =>
          _PerformSheetBody(title: title, description: description, side: wide, child: builder(themed)),
    ),
  );

  if (!wide) {
    return showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      // The body draws its own surface, in the Perform theme.
      backgroundColor: Colors.transparent,
      elevation: 0,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * sheetMaxHeightFactor),
      builder: body,
    );
  }

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.25),
    transitionDuration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : DaloyMotion.medium,
    pageBuilder: (sheetContext, _, _) => Align(
      alignment: Alignment.centerRight,
      child: SizedBox(width: 384, height: double.infinity, child: body(sheetContext)),
    ),
    transitionBuilder: (_, animation, _, child) => SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: DaloyMotion.ease, reverseCurve: Curves.easeIn)),
      child: child,
    ),
  );
}

class _PerformSheetBody extends StatelessWidget {
  const _PerformSheetBody({required this.title, required this.description, required this.side, required this.child});

  final String title;
  final String? description;
  final bool side;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final content = SafeArea(
      top: side,
      left: false,
      child: Column(
        mainAxisSize: side ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!side)
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: DaloySpace.s2),
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: c.border, borderRadius: DaloyRadii.all(DaloyRadii.full)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s3, DaloySpace.s2, DaloySpace.s2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: context.text.titleMedium),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(description!, style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  icon: Icon(TablerIcons.x, size: 18, color: c.mutedForeground),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s1, DaloySpace.s5, DaloySpace.s5),
              child: child,
            ),
          ),
        ],
      ),
    );

    return Material(
      color: c.card,
      shape: side
          ? Border(left: BorderSide(color: c.border))
          : const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(DaloyRadii.xl3))),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
