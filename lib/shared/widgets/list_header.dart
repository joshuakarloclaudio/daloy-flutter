import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';
import '../../core/utils/platform.dart';
import 'list_search_field.dart';

/// Search field over a strip of [FilterPill]s — the top of a list screen. It
/// scrolls away with the content (like a native search bar); the pinned
/// section headers are what stay.
///
/// On the desktop, with room for it ([inlineFrom]), the field and the pills
/// share one row: nothing to scroll sideways, and a pointer-sized field.
/// Narrower (a split view's list, a small window) they stack, and the strip
/// scrolls by drag as well as touch.
class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchHint,
    required this.chips,
  });

  /// Stacked height. Fixed so screens can compute exact scroll offsets.
  static const height = 112.0;
  static const inlineHeight = 60.0;
  static const _chipHeight = 36.0;
  static const _searchWidth = 280.0;

  /// The header width from which the desktop puts search and pills in a row.
  static const inlineFrom = 720.0;

  /// Whether a header [width] wide lays out as one row.
  static bool isInline(double width) => isDesktop && width >= inlineFrom;

  /// The header's height at a given [width].
  static double heightFor(double width) => isInline(width) ? inlineHeight : height;

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;

  /// Pills in order; spacing is added between them.
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    final gutter = DaloySpace.gutter(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final inline = isInline(constraints.maxWidth);
        final strip = SizedBox(
          height: _chipHeight,
          child: _ChipStrip(chips: chips, padding: inline ? 0 : gutter),
        );

        if (inline) {
          return SizedBox(
            height: inlineHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: gutter),
              child: Row(
                children: [
                  SizedBox(
                    width: _searchWidth,
                    child: ListSearchField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                      hint: searchHint,
                      height: ControlSize.md.height,
                    ),
                  ),
                  const SizedBox(width: DaloySpace.s4),
                  Expanded(child: strip),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: DaloySpace.s2),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: gutter),
                child: ListSearchField(controller: searchController, onChanged: onSearchChanged, hint: searchHint),
              ),
              const SizedBox(height: DaloySpace.s2_5),
              strip,
              const SizedBox(height: DaloySpace.s3),
            ],
          ),
        );
      },
    );
  }
}

/// The pill strip. On the desktop the plain mouse wheel scrolls it sideways
/// while it overflows (otherwise only Shift+wheel would); once it fits, or at
/// either end, the wheel passes through to scroll the page.
class _ChipStrip extends StatefulWidget {
  const _ChipStrip({required this.chips, required this.padding});

  final List<Widget> chips;
  final double padding;

  @override
  State<_ChipStrip> createState() => _ChipStripState();
}

class _ChipStripState extends State<_ChipStrip> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;
    final position = _controller.position;
    // Shift+wheel already arrives as a horizontal delta.
    final delta = event.scrollDelta.dx != 0 ? event.scrollDelta.dx : event.scrollDelta.dy;
    final target = (position.pixels + delta).clamp(0.0, position.maxScrollExtent);
    if (position.maxScrollExtent <= 0 || target == position.pixels) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) => _controller.jumpTo(target));
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onSignal,
      child: ScrollConfiguration(
        // A mouse drags the strip too — there is no swipe on the desktop.
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad},
          scrollbars: false,
        ),
        child: ListView.separated(
          controller: _controller,
          // Survives the strip being rebuilt (e.g. when results go empty).
          key: const PageStorageKey('list-filter-chips'),
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: widget.padding),
          itemCount: widget.chips.length,
          separatorBuilder: (_, _) => const SizedBox(width: DaloySpace.s2),
          itemBuilder: (_, i) => widget.chips[i],
        ),
      ),
    );
  }
}
