import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'platform.dart';

/// Keeps the acrylic window's tint on the app's theme, not the system's:
/// a light app on a dark-mode PC would otherwise sit over a dark blur.
class WindowBackdropSync extends StatefulWidget {
  const WindowBackdropSync({super.key, required this.child});

  final Widget child;

  @override
  State<WindowBackdropSync> createState() => _WindowBackdropSyncState();
}

class _WindowBackdropSyncState extends State<WindowBackdropSync> {
  static const _channel = MethodChannel('daloy/window');

  bool? _dark;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasAcrylic) return;
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (dark == _dark) return;
    _dark = dark;
    _channel.invokeMethod<void>('setDark', dark);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
