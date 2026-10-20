import 'package:flutter/material.dart';

import '../core/theme/daloy_theme.dart';
import '../core/utils/platform.dart';

/// Holds every tab's navigator, alive, and shows the current one — the
/// platform's way. iOS swaps tabs instantly, like `UITabBarController`;
/// Android fades the new tab through, rising slightly, like Material's
/// navigation bar. Skipped when the OS asks for reduced motion.
class BranchSwitcher extends StatefulWidget {
  const BranchSwitcher({super.key, required this.currentIndex, required this.children});

  final int currentIndex;
  final List<Widget> children;

  @override
  State<BranchSwitcher> createState() => _BranchSwitcherState();
}

class _BranchSwitcherState extends State<BranchSwitcher> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: DaloyMotion.medium, value: 1);
  late final _fade = CurvedAnimation(parent: _controller, curve: DaloyMotion.ease);
  late final _scale = Tween(begin: 0.97, end: 1.0).animate(_fade);

  @override
  void didUpdateWidget(BranchSwitcher old) {
    super.didUpdateWidget(old);
    if (old.currentIndex == widget.currentIndex) return;
    final animate = !Theme.of(context).platform.isApple && !MediaQuery.disableAnimationsOf(context);
    animate ? _controller.forward(from: 0) : _controller.value = 1;
  }

  @override
  void dispose() {
    _fade.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (final (i, child) in widget.children.indexed)
            // Same widget tree whether shown or not, so a tab's navigator
            // never loses its stack.
            Offstage(
              offstage: i != widget.currentIndex,
              child: TickerMode(
                enabled: i == widget.currentIndex,
                child: FadeTransition(
                  opacity: i == widget.currentIndex ? _fade : kAlwaysCompleteAnimation,
                  child: ScaleTransition(
                    scale: i == widget.currentIndex ? _scale : kAlwaysCompleteAnimation,
                    child: child,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
