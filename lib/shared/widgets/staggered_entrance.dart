import 'package:clock/clock.dart';
import 'package:flutter/material.dart';

import '../../core/theme/daloy_theme.dart';

/// Fades and lifts its children in one after another on first build
/// (`PageStagger`). Skipped when the OS asks for reduced motion. For rows and
/// sections that aren't one column, use [Entrance].
class StaggeredColumn extends StatefulWidget {
  const StaggeredColumn({super.key, required this.children, this.spacing = 0});

  final List<Widget> children;
  final double spacing;

  @override
  State<StaggeredColumn> createState() => _StaggeredColumnState();
}

class _StaggeredColumnState extends State<StaggeredColumn> with SingleTickerProviderStateMixin {
  static const _step = 0.12;
  static const _span = 0.5;

  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, child) in widget.children.indexed) ...[
          if (i > 0) SizedBox(height: widget.spacing),
          if (reduce)
            child
          else
            _Entrance(
              animation: CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  (i * _step).clamp(0, 1 - _span),
                  ((i * _step) + _span).clamp(_span, 1),
                  curve: DaloyMotion.ease,
                ),
              ),
              child: child,
            ),
        ],
      ],
    );
  }
}

class _Entrance extends AnimatedWidget {
  const _Entrance({required Animation<double> animation, required this.child}) : super(listenable: animation);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    return Opacity(
      opacity: t,
      child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child),
    );
  }
}

/// Starts the clock for the [Entrance]s under it the first time it's
/// [ready] — when a list's content first arrives. Items built in the first
/// moments come in staggered; anything built later (scrolled to, filtered
/// in, refreshed) just appears, so lazy lists don't re-animate as you scroll.
class EntranceScope extends StatefulWidget {
  const EntranceScope({super.key, this.ready = true, required this.child});

  final bool ready;
  final Widget child;

  @override
  State<EntranceScope> createState() => _EntranceScopeState();
}

class _EntranceScopeState extends State<EntranceScope> {
  Stopwatch? _clock;

  @override
  Widget build(BuildContext context) {
    if (widget.ready) _clock ??= clock.stopwatch()..start();
    return _EntranceClock(clock: _clock, child: widget.child);
  }
}

class _EntranceClock extends InheritedWidget {
  const _EntranceClock({required this.clock, required super.child});

  final Stopwatch? clock;

  @override
  bool updateShouldNotify(_EntranceClock old) => false;
}

/// Fades and lifts [child] in once, [index] steps after its siblings — the
/// same motion as [StaggeredColumn], for content that isn't one column
/// (sliver rows, sections). Under an [EntranceScope] it only plays in the
/// scope's opening moments. Skipped when the OS asks for reduced motion.
class Entrance extends StatefulWidget {
  const Entrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  static const _step = Duration(milliseconds: 55);
  static const _length = Duration(milliseconds: 380);

  /// Rows past this many come in together; nobody waits on row 30.
  static const _maxIndex = 8;
  static const _window = Duration(milliseconds: 500);

  AnimationController? _controller;
  CurvedAnimation? _curve;
  var _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    if (MediaQuery.disableAnimationsOf(context)) return;

    final scope = context.getInheritedWidgetOfExactType<_EntranceClock>();
    final Duration elapsed;
    if (scope == null) {
      elapsed = Duration.zero;
    } else if (scope.clock case final clock?) {
      elapsed = clock.elapsed;
    } else {
      return;
    }
    if (elapsed > _window) return;

    // The delay is the front of one longer animation, not a timer, so the
    // whole entrance is a single run of frames.
    final delay = _step * widget.index.clamp(0, _maxIndex) - elapsed;
    final wait = delay.isNegative ? Duration.zero : delay;
    final total = wait + _length;
    _controller = AnimationController(vsync: this, duration: total)..forward();
    _curve = CurvedAnimation(
      parent: _controller!,
      curve: Interval(wait.inMicroseconds / total.inMicroseconds, 1, curve: DaloyMotion.ease),
    );
  }

  @override
  void dispose() {
    _curve?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _curve == null ? widget.child : _Entrance(animation: _curve!, child: widget.child);
}
