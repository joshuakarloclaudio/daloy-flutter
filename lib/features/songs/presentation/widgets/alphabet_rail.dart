import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/daloy_theme.dart';

const railLetters = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '#',
];

/// The A–Z fast-scroll strip down the right edge (iOS Contacts). Touch or
/// drag a letter to jump to it; letters with no songs are dimmed and land on
/// the next section that has some. Hidden from screen readers, who scroll
/// the list natively.
class AlphabetRail extends StatefulWidget {
  const AlphabetRail({super.key, required this.present, required this.onSelect});

  static const width = 22.0;

  /// Letters that have at least one song, in list order.
  final List<String> present;
  final ValueChanged<String> onSelect;

  @override
  State<AlphabetRail> createState() => _AlphabetRailState();
}

class _AlphabetRailState extends State<AlphabetRail> {
  String? _active;

  void _touch(double dy, double itemHeight) {
    final index = (dy / itemHeight).floor().clamp(0, railLetters.length - 1);
    // First section at or after the touched letter, else the last one.
    final target = widget.present.firstWhere((l) => railLetters.indexOf(l) >= index, orElse: () => widget.present.last);
    if (target == _active) return;
    HapticFeedback.selectionClick();
    setState(() => _active = target);
    widget.onSelect(target);
  }

  void _end() => setState(() => _active = null);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemHeight = (constraints.maxHeight / railLetters.length).clamp(0.0, 17.0);
          final present = widget.present.toSet();
          return Center(
            child: SizedBox(
              width: AlphabetRail.width,
              height: itemHeight * railLetters.length,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _touch(d.localPosition.dy, itemHeight),
                    onTapUp: (_) => _end(),
                    onTapCancel: _end,
                    onVerticalDragStart: (d) => _touch(d.localPosition.dy, itemHeight),
                    onVerticalDragUpdate: (d) => _touch(d.localPosition.dy, itemHeight),
                    onVerticalDragEnd: (_) => _end(),
                    onVerticalDragCancel: _end,
                    child: Column(
                      children: [
                        for (final letter in railLetters)
                          SizedBox(
                            height: itemHeight,
                            child: Center(
                              child: Text(
                                letter,
                                style: context.text.labelSmall!.copyWith(
                                  fontSize: 10.5,
                                  height: 1,
                                  color: letter == _active
                                      ? c.primaryInk
                                      : c.primaryInk.withValues(alpha: present.contains(letter) ? 0.9 : 0.3),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_active != null)
                    Positioned(
                      right: AlphabetRail.width + DaloySpace.s3,
                      top: (itemHeight * railLetters.indexOf(_active!) - 24 + itemHeight / 2).clamp(
                        0.0,
                        itemHeight * railLetters.length - 48,
                      ),
                      child: IgnorePointer(
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                          child: Text(_active!, style: context.text.titleLarge!.copyWith(color: c.primaryForeground)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
