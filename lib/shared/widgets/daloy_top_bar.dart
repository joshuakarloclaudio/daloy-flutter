import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/theme/daloy_theme.dart';
import '../../core/utils/platform.dart';
import 'daloy_button.dart';

/// The 48px touch top bar every screen gets (`useMobileTopBar` /
/// `PageHeader`): back chevron (automatic), title, actions. Flat, with a
/// hairline that appears once content scrolls under it.
class DaloyTopBar extends StatefulWidget implements PreferredSizeWidget {
  const DaloyTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.centerTitle = false,
    this.transparent = false,
    this.largeTitle = false,
  });

  final String? title;

  /// Replaces [title] — e.g. Home's workspace switcher.
  final Widget? titleWidget;
  final List<Widget> actions;

  /// Centred on the bar, for a title that is a control (a segmented switch)
  /// rather than a name — it reads as balanced, not pushed to one side.
  final bool centerTitle;

  /// No fill, for a bar over artwork (the auth screens).
  final bool transparent;

  /// The screen leads its scroll view with a [LargeTitle] (or [SliverLargeTitle])
  /// carrying the same name. The inline title and the hairline stay hidden
  /// until that title has scrolled under the bar, as in iOS.
  final bool largeTitle;

  @override
  Size get preferredSize => const Size.fromHeight(DaloyChrome.topBarHeight);

  @override
  State<DaloyTopBar> createState() => _DaloyTopBarState();
}

class _DaloyTopBarState extends State<DaloyTopBar> {
  ScrollNotificationObserverState? _observer;
  bool _scrolledUnder = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _observer?.removeListener(_onScroll);
    _observer = ScrollNotificationObserver.maybeOf(context);
    _observer?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _observer?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification || notification.depth != 0) return;
    if (notification.metrics.axis != Axis.vertical) return;
    final scrolled = notification.metrics.extentBefore > (widget.largeTitle ? LargeTitle.collapseAt : 0);
    if (scrolled != _scrolledUnder) setState(() => _scrolledUnder = scrolled);
  }

  /// Back (or close, over a full-screen dialog) as the same 40px round
  /// button the detail screens' [HeroTopBar] uses, not Material's larger one.
  Widget? _leading(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null || !route.impliesAppBarDismissal) return null;
    final isApple = Theme.of(context).platform.isApple;
    final close = route is PageRoute && route.fullscreenDialog;
    return Padding(
      padding: const EdgeInsets.only(left: DaloySpace.s1),
      child: TopBarIconButton(
        icon: close ? TablerIcons.x : (isApple ? TablerIcons.chevron_left : TablerIcons.arrow_left),
        tooltip: close ? 'Close' : 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // A tablet tab screen shares its bar row with the shell's floating chrome:
    // clear of its controls at both ends, and no inline title under the tabs.
    final chrome = TabletChrome.of(context);
    final back = _leading(context);
    final leading = chrome != null && chrome.leadingInset > 0
        ? Padding(
            padding: EdgeInsets.only(left: chrome.leadingInset),
            child: back,
          )
        : back;
    var title = chrome?.tabsShowing ?? false
        ? null
        : widget.titleWidget ?? (widget.title == null ? null : Text(widget.title!));
    if (widget.largeTitle && title != null) {
      title = AnimatedOpacity(
        opacity: _scrolledUnder ? 1 : 0,
        duration: DaloyMotion.fast,
        // Say it once: the large title is the one a screen reader finds.
        child: ExcludeSemantics(excluding: !_scrolledUnder, child: title),
      );
    }
    final light = Theme.of(context).brightness == Brightness.light;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light).copyWith(
        statusBarColor: Colors.transparent,
      ),
      // Flat chrome: no elevation or scroll-under tint. The Material is only
      // here so fields and ink in `titleWidget` have an ancestor.
      child: Material(
        color: widget.transparent ? Colors.transparent : c.background,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: _scrolledUnder ? c.border : Colors.transparent)),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: DaloyChrome.topBarHeight,
              child: IconTheme(
                data: IconThemeData(color: c.foreground),
                child: DefaultTextStyle(
                  style: context.text.titleLarge!.copyWith(color: c.foreground),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  child: NavigationToolbar(
                    leading: leading == null
                        ? null
                        : ConstrainedBox(constraints: const BoxConstraints(minWidth: 48), child: leading),
                    middle: title,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...widget.actions,
                        SizedBox(width: DaloySpace.s2 + (chrome?.trailingInset ?? 0)),
                      ],
                    ),
                    centerMiddle: widget.centerTitle,
                    middleSpacing: back == null ? DaloySpace.gutter(context) : DaloySpace.s1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the tablet shell's floating chrome takes from a tab screen's top bar,
/// so `DaloyTopBar` can keep clear of it: the controls at either end of the
/// bar row, and whether the tab capsule sits in the middle (then the bar has
/// no inline title, as on iPadOS).
class TabletChrome extends InheritedWidget {
  const TabletChrome({
    super.key,
    required this.leadingInset,
    required this.trailingInset,
    required this.tabsShowing,
    required super.child,
  });

  final double leadingInset;
  final double trailingInset;
  final bool tabsShowing;

  /// Only for a tab's own root screen: anything pushed over it inside the tab
  /// lays out its bar as usual.
  static TabletChrome? of(BuildContext context) {
    final chrome = context.dependOnInheritedWidgetOfExactType<TabletChrome>();
    if (chrome == null) return null;
    return (ModalRoute.of(context)?.isFirst ?? true) ? chrome : null;
  }

  @override
  bool updateShouldNotify(TabletChrome old) =>
      old.leadingInset != leadingInset || old.trailingInset != trailingInset || old.tabsShowing != tabsShowing;
}

/// The big title that leads a list or settings screen's scroll view and
/// scrolls away under [DaloyTopBar] (`largeTitle: true`). Fixed height, so
/// the bar knows when it has gone ([collapseAt]).
class LargeTitle extends StatelessWidget {
  const LargeTitle(this.title, {super.key, this.inset, this.trailing});

  final String title;

  /// Horizontal inset; the page gutter when null.
  final double? inset;

  /// A control on the title's line, at the far end (Songs' Library | Discover
  /// on a tablet, whose bar row belongs to the tabs).
  final Widget? trailing;

  static const height = 52.0;

  /// Scroll offset at which the title is under the bar and the inline one
  /// takes over.
  static const collapseAt = 36.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            inset ?? DaloySpace.gutter(context),
            0,
            inset ?? DaloySpace.gutter(context),
            DaloySpace.s1,
          ),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.displaySmall!.copyWith(fontSize: 32),
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: DaloySpace.s3), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class SliverLargeTitle extends StatelessWidget {
  const SliverLargeTitle(this.title, {super.key, this.inset, this.trailing});

  final String title;
  final double? inset;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: LargeTitle(title, inset: inset, trailing: trailing),
  );
}
