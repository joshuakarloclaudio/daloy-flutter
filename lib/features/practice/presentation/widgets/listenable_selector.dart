import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Rebuilds only when [select] picks something new out of [listenable] —
/// so a beat reaches the one bar that's playing, not every section.
class ListenableSelector<T, S> extends StatefulWidget {
  const ListenableSelector({super.key, required this.listenable, required this.select, required this.builder});

  final ValueListenable<T> listenable;
  final S Function(T value) select;
  final Widget Function(BuildContext context, S selected) builder;

  @override
  State<ListenableSelector<T, S>> createState() => _ListenableSelectorState<T, S>();
}

class _ListenableSelectorState<T, S> extends State<ListenableSelector<T, S>> {
  late S _selected = widget.select(widget.listenable.value);

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_changed);
  }

  @override
  void didUpdateWidget(ListenableSelector<T, S> old) {
    super.didUpdateWidget(old);
    if (old.listenable != widget.listenable) {
      old.listenable.removeListener(_changed);
      widget.listenable.addListener(_changed);
    }
    _selected = widget.select(widget.listenable.value);
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    final next = widget.select(widget.listenable.value);
    if (next != _selected) setState(() => _selected = next);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _selected);
}
