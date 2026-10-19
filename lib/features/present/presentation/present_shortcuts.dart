import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../domain/present_deck.dart';

/// Keyboards, clickers and page-turner pedals: arrows, Page Up/Down and
/// space move through the slides (as in Perform); B or . blanks the screen,
/// as in Keynote and PowerPoint.
class PresentShortcuts extends StatelessWidget {
  const PresentShortcuts({super.key, required this.onCommand, required this.child, this.onEscape});

  final ValueChanged<PresentCommand> onCommand;
  final VoidCallback? onEscape;
  final Widget child;

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final PresentCommand? command;
    if (key == LogicalKeyboardKey.space) {
      command = shift ? const PresentPrev() : const PresentNext();
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.enter) {
      command = const PresentNext();
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.pageUp) {
      command = const PresentPrev();
    } else if (event is KeyDownEvent && (key == LogicalKeyboardKey.keyB || key == LogicalKeyboardKey.period)) {
      command = const PresentToggleBlank();
    } else if (event is KeyDownEvent && key == LogicalKeyboardKey.escape && onEscape != null) {
      onEscape!();
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
    onCommand(command);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) => Focus(autofocus: true, onKeyEvent: _onKey, child: child);
}
