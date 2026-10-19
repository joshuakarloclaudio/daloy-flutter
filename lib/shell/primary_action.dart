import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a tab asks of the phone shell's bar: its one create action (the
/// detached `+`) and, optionally, an [inline] control that rides above the
/// open bar and sits beside the folded one (Songs: Library | Discover).
///
/// [onPressed] gets the button's rect on screen, so a menu can open from it.
/// Only [label], [icon] and whether there is an [inline] identify it: the
/// callback and the inline widget (which keeps itself up to date) can change
/// with every rebuild of the screen without the bar noticing.
class PrimaryAction {
  PrimaryAction({required this.label, required this.icon, required this.onPressed, this.inline});

  final String label;
  final IconData icon;
  void Function(Rect anchor) onPressed;
  Widget? inline;

  bool sameAs(PrimaryAction other) =>
      label == other.label && icon == other.icon && (inline == null) == (other.inline == null);
}

/// Branch index → that tab's action. Every tab's screen stays alive under the
/// shell, so the shell picks the current tab's.
final primaryActionsProvider = NotifierProvider<PrimaryActions, Map<int, PrimaryAction>>(PrimaryActions.new);

class PrimaryActions extends Notifier<Map<int, PrimaryAction>> {
  @override
  Map<int, PrimaryAction> build() => const {};

  void register(int branch, PrimaryAction action) {
    final current = state[branch];
    if (current != null && current.sameAs(action)) {
      // Same button, newer closure: no reason to rebuild the bar.
      current
        ..onPressed = action.onPressed
        ..inline = action.inline;
      return;
    }
    state = {...state, branch: action};
  }

  /// Leaving a screen takes its action with it, unless another screen has
  /// since claimed the branch with a different one.
  void unregister(int branch, PrimaryAction action) {
    final current = state[branch];
    if (current != null && current.sameAs(action)) state = {...state}..remove(branch);
  }
}

/// Declares [child]'s tab's create action to the shell. Wrap a tab screen in
/// it; screens never place the button themselves.
class RegisterPrimaryAction extends ConsumerStatefulWidget {
  const RegisterPrimaryAction({
    super.key,
    required this.branch,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.child,
    this.inline,
  });

  /// The tab's `StatefulShellRoute` branch index.
  final int branch;
  final String label;
  final IconData icon;
  final void Function(Rect anchor) onPressed;
  final Widget child;

  /// A control for the bar to carry for this tab. A widget that reads its own
  /// state, since the bar does not rebuild when the screen does.
  final Widget? inline;

  @override
  ConsumerState<RegisterPrimaryAction> createState() => _RegisterPrimaryActionState();
}

class _RegisterPrimaryActionState extends ConsumerState<RegisterPrimaryAction> {
  late final ProviderContainer _container = ProviderScope.containerOf(context, listen: false);
  PrimaryAction? _registered;

  @override
  void initState() {
    super.initState();
    _register();
  }

  @override
  void didUpdateWidget(RegisterPrimaryAction old) {
    super.didUpdateWidget(old);
    _register();
  }

  /// The whole app can be gone (a test tearing down, a sign-out rebuilding the
  /// scope) by the time a microtask runs.
  void _withNotifier(void Function(PrimaryActions notifier) use) {
    try {
      use(_container.read(primaryActionsProvider.notifier));
    } on StateError {
      // The container was disposed: nothing left to tell.
    }
  }

  /// Not while the tree is building: that would change a provider mid-build.
  void _register() {
    final action = PrimaryAction(
      label: widget.label,
      icon: widget.icon,
      onPressed: widget.onPressed,
      inline: widget.inline,
    );
    final previous = _registered;
    _registered = action;
    Future.microtask(() {
      if (!mounted) return;
      _withNotifier((notifier) {
        if (previous != null && previous.sameAs(action) == false) notifier.unregister(widget.branch, previous);
        notifier.register(widget.branch, action);
      });
    });
  }

  @override
  void dispose() {
    final action = _registered;
    final branch = widget.branch;
    if (action != null) {
      Future.microtask(() => _withNotifier((notifier) => notifier.unregister(branch, action)));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
