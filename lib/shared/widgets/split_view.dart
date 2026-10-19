import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import 'daloy_icon.dart';
import 'daloy_top_bar.dart';

/// A list beside the item it opened, as in Mail or Notes: on a tablet in
/// landscape, Songs and Line-ups show the chosen song or line-up in a pane
/// instead of pushing it over the whole screen. In portrait (or anywhere
/// narrower than [minWidth]) they push as on a phone.
///
/// The detail pane measures itself, not the screen: its `MediaQuery` has the
/// pane's size, so a detail screen lays out for the room it really has, and
/// [SplitPane.of] tells it to leave out its back button. The shell's floating
/// chrome is divided between the panes ([TabletChrome]): the list's bar keeps
/// clear of the leading controls, the detail's of the trailing ones.
class SplitView extends StatelessWidget {
  const SplitView({super.key, required this.list, required this.detail, required this.placeholder});

  final Widget list;

  /// The chosen item's screen; null shows [placeholder].
  final Widget? detail;
  final Widget placeholder;

  static const minWidth = 860.0;

  /// Whether a tab screen given [width] should split.
  static bool fits(BuildContext context, double width) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height && width >= minWidth;
  }

  static double listWidth(double width) => width >= 1100 ? 380 : 320;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chrome = TabletChrome.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final listWidth = SplitView.listWidth(box.maxWidth);
        final media = MediaQuery.of(context);
        final paneWidth = box.maxWidth - listWidth - 0.5;
        Widget withChrome(Widget child, {required bool leading}) => chrome == null
            ? child
            : TabletChrome(
                leadingInset: leading ? chrome.leadingInset : 0,
                trailingInset: leading ? 0 : chrome.trailingInset,
                tabsShowing: chrome.tabsShowing,
                child: child,
              );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: listWidth,
              child: MediaQuery.removePadding(
                context: context,
                removeRight: true,
                child: withChrome(list, leading: true),
              ),
            ),
            SizedBox(width: 0.5, child: ColoredBox(color: c.border)),
            Expanded(
              child: MediaQuery(
                data: media.copyWith(
                  size: Size(paneWidth, box.maxHeight),
                  padding: media.padding.copyWith(left: 0),
                  viewPadding: media.viewPadding.copyWith(left: 0),
                ),
                child: SplitPane(
                  child: withChrome(
                    AnimatedSwitcher(
                      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : DaloyMotion.fast,
                      child: detail ?? placeholder,
                    ),
                    leading: false,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Marks a detail screen shown in a [SplitView]'s pane, not pushed: no back
/// button, and one column however wide the pane is.
class SplitPane extends InheritedWidget {
  const SplitPane({super.key, required super.child});

  static bool of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<SplitPane>() != null;

  @override
  bool updateShouldNotify(SplitPane old) => false;
}

/// The empty detail pane: what to pick.
class SplitPlaceholder extends StatelessWidget {
  const SplitPlaceholder({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ColoredBox(
      color: c.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DaloyIcon(icon, size: 40, color: c.mutedForeground.withValues(alpha: 0.6)),
            const SizedBox(height: DaloySpace.s3),
            Text(message, style: context.text.bodyLarge!.copyWith(color: c.mutedForeground)),
          ],
        ),
      ),
    );
  }
}

/// The chosen row in a split view's list: a rounded tint behind it, inset
/// from the list's edges, as in iPadOS.
class PaneSelection extends StatelessWidget {
  const PaneSelection({super.key, required this.selected, required this.child});

  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: DaloyMotion.fast,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s1, vertical: 2),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.13),
                    borderRadius: DaloyRadii.all(DaloyRadii.xl),
                  ),
                ),
              ),
            ),
          ),
        ),
        Semantics(selected: selected, child: child),
      ],
    );
  }
}
