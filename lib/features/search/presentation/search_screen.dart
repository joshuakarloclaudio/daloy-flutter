import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shell/shell_layout.dart';
import '../application/search_controller.dart';
import 'search_view.dart';

/// The phone's search page, pushed over the tabs from the magnifier at the
/// top right of each one. A page, not a modal: the query, results and scroll
/// stay put while you visit a song and come back, and Cancel leaves it.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  void _close(BuildContext context) {
    final router = GoRouter.of(context);
    router.canPop() ? router.pop() : router.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.background,
    body: SafeArea(bottom: false, child: SearchView(autofocus: true, onClose: () => _close(context))),
  );
}

/// Search floating over the current screen on a tablet, ⌘K-style: dims what's
/// behind, closes on Esc, a tap outside, or once a result is chosen.
Future<void> showSearchPanel(BuildContext context) {
  final host = context;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close search',
    barrierColor: Colors.black.withValues(alpha: 0.32),
    transitionDuration: DaloyMotion.medium,
    pageBuilder: (dialogContext, _, _) {
      final size = MediaQuery.sizeOf(dialogContext);
      final insets = MediaQuery.viewInsetsOf(dialogContext);
      final c = dialogContext.colors;
      return SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: size.height * 0.08, left: DaloySpace.s6, right: DaloySpace.s6),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 640,
                // Above the keyboard, with room to breathe.
                maxHeight: (size.height - insets.bottom) * 0.72,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: DaloyRadii.all(DaloyRadii.xl2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 32, offset: const Offset(0, 12)),
                  ],
                ),
                child: Material(
                  color: c.background,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: DaloyRadii.all(DaloyRadii.xl2),
                    side: BorderSide(color: c.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: DaloySpace.s2),
                    child: SearchView(host: host, autofocus: true, onDismiss: () => Navigator.of(dialogContext).pop()),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: DaloyMotion.ease, reverseCurve: Curves.easeIn);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.98, end: 1.0).animate(curved),
          alignment: Alignment.topCenter,
          child: child,
        ),
      );
    },
  );
}

bool _panelOpen = false;

/// Search, the right way for this screen: the floating panel on a tablet, a
/// page (field focused) pushed over the tabs on a phone. ⌘K, the magnifier on
/// every tab and the rail all come here.
void openSearch(BuildContext context) {
  if (ShellLayout.of(context) == ShellLayout.tablet) {
    if (_panelOpen) return;
    _panelOpen = true;
    showSearchPanel(context).whenComplete(() => _panelOpen = false);
    return;
  }
  final router = GoRouter.of(context);
  // Already searching (⌘K on a keyboard): back to typing, not a second page.
  if (router.state.matchedLocation == Routes.search) {
    ProviderScope.containerOf(context, listen: false).read(searchFocusRequestsProvider.notifier).request();
    return;
  }
  router.push(Routes.search);
}
