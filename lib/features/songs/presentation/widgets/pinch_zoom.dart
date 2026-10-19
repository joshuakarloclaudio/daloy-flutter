import 'package:flutter/widgets.dart';

/// Two-finger pinch over [child], reported as a scale factor relative to the
/// moment the second finger landed. Raw pointers rather than a scale gesture,
/// so a one-finger drag is left entirely to the scroll view.
class PinchZoom extends StatefulWidget {
  const PinchZoom({super.key, required this.child, required this.onUpdate, required this.onEnd, this.onActiveChanged});

  final Widget child;

  /// Called as fingers move, with the factor since the pinch began (1 = none).
  final ValueChanged<double> onUpdate;

  /// Called when the pinch ends, with its final factor.
  final ValueChanged<double> onEnd;

  /// True while two fingers are down — the cue to freeze scrolling.
  final ValueChanged<bool>? onActiveChanged;

  @override
  State<PinchZoom> createState() => _PinchZoomState();
}

class _PinchZoomState extends State<PinchZoom> {
  final _pointers = <int, Offset>{};
  double? _startDistance;
  double _factor = 1;

  double get _distance {
    final points = _pointers.values.take(2).toList();
    return (points[0] - points[1]).distance;
  }

  void _down(PointerDownEvent e) {
    _pointers[e.pointer] = e.position;
    if (_pointers.length == 2 && _startDistance == null) {
      _startDistance = _distance;
      _factor = 1;
      widget.onActiveChanged?.call(true);
    }
  }

  void _move(PointerMoveEvent e) {
    if (!_pointers.containsKey(e.pointer)) return;
    _pointers[e.pointer] = e.position;
    final start = _startDistance;
    if (start == null || start < 1 || _pointers.length < 2) return;
    _factor = _distance / start;
    widget.onUpdate(_factor);
  }

  void _up(PointerEvent e) {
    _pointers.remove(e.pointer);
    if (_startDistance != null && _pointers.length < 2) {
      _startDistance = null;
      widget.onActiveChanged?.call(false);
      widget.onEnd(_factor);
    }
  }

  @override
  Widget build(BuildContext context) =>
      Listener(onPointerDown: _down, onPointerMove: _move, onPointerUp: _up, onPointerCancel: _up, child: widget.child);
}
