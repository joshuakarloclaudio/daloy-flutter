import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/daloy_theme.dart';
import '../../core/utils/platform.dart';
import 'daloy_button.dart';
import 'daloy_top_bar.dart';
import 'split_view.dart';

/// Tracks a detail screen's scroll for [HeroTopBar]: whether content has
/// gone under the bar, and whether the big title (tagged with [titleKey])
/// has scrolled past it. Feed it from a `NotificationListener` with
/// [handle]; dispose it with the screen.
class HeroScrollState {
  final titleKey = GlobalKey();
  final scrolled = ValueNotifier(false);
  final titleHidden = ValueNotifier(false);

  /// Always false — for layouts that keep the title on screen (tablet panes).
  final never = ValueNotifier(false);

  bool handle(BuildContext context, ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical || n.depth != 0) return false;
    scrolled.value = n.metrics.extentBefore > 0;
    final box = titleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.attached) {
      final bottom = box.localToGlobal(Offset(0, box.size.height)).dy;
      titleHidden.value = bottom < MediaQuery.paddingOf(context).top + DaloyChrome.topBarHeight;
    }
    return false;
  }

  void dispose() {
    scrolled.dispose();
    titleHidden.dispose();
    never.dispose();
  }
}

/// The top bar of a detail screen that leads with artwork. Floats over the
/// artwork's wash; gains a background and hairline once content scrolls
/// under it, and the title once the big title has gone by. Position it at
/// the top of a `Stack` over the screen's scroll view.
class HeroTopBar extends StatelessWidget {
  const HeroTopBar({
    super.key,
    required this.title,
    required this.scrolled,
    required this.titleHidden,
    required this.onBack,
    this.actions = const [],
  });

  final String? title;
  final ValueListenable<bool> scrolled;
  final ValueListenable<bool> titleHidden;
  final VoidCallback onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isApple = Theme.of(context).platform.isApple;
    final top = MediaQuery.paddingOf(context).top;
    // In a split view's pane: nothing to go back to, and (under the shell's
    // tab capsule) no inline title; clear of the shell's trailing controls.
    final inPane = SplitPane.of(context);
    final chrome = TabletChrome.of(context);
    final showTitle = !(chrome?.tabsShowing ?? false);

    return ValueListenableBuilder(
      valueListenable: scrolled,
      builder: (context, isScrolled, child) => AnimatedContainer(
        duration: DaloyMotion.fast,
        padding: EdgeInsets.only(top: top),
        decoration: BoxDecoration(
          color: isScrolled ? c.background : c.background.withValues(alpha: 0),
          border: Border(bottom: BorderSide(color: isScrolled ? c.border : Colors.transparent)),
        ),
        child: child,
      ),
      child: SizedBox(
        height: DaloyChrome.topBarHeight,
        child: Row(
          children: [
            const SizedBox(width: DaloySpace.s1),
            if (inPane)
              const SizedBox(width: DaloySpace.s3)
            else
              TopBarIconButton(
                icon: isApple ? TablerIcons.chevron_left : TablerIcons.arrow_left,
                tooltip: 'Back',
                onPressed: onBack,
              ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: titleHidden,
                builder: (context, hidden, _) => AnimatedOpacity(
                  opacity: hidden && title != null && showTitle ? 1 : 0,
                  duration: DaloyMotion.fast,
                  child: AnimatedSlide(
                    offset: hidden ? Offset.zero : const Offset(0, 0.3),
                    duration: DaloyMotion.medium,
                    curve: DaloyMotion.ease,
                    child: Text(
                      title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isApple ? TextAlign.center : TextAlign.start,
                      style: context.text.titleLarge,
                    ),
                  ),
                ),
              ),
            ),
            ...actions,
            SizedBox(width: DaloySpace.s1 + (chrome?.trailingInset ?? 0)),
          ],
        ),
      ),
    );
  }
}
