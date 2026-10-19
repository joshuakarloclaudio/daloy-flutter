import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/session_controller.dart';
import '../../features/search/application/os_search_sync.dart';
import 'app_router.dart';
import 'incoming_link.dart';
import 'routes.dart';

/// Opens what the OS hands the app — a Spotlight hit or shortcut, a
/// Universal / App Link, a `daloy://` link — whether that launched the app or
/// found it running. Lives above the router, since a reset-password or join
/// link has to open before anyone is signed in.
class IncomingLinks extends ConsumerStatefulWidget {
  const IncomingLinks({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<IncomingLinks> createState() => _IncomingLinksState();
}

class _IncomingLinksState extends ConsumerState<IncomingLinks> {
  StreamSubscription<String>? _opens;

  @override
  void initState() {
    super.initState();
    final index = ref.read(osSearchIndexProvider);
    _opens = index.opens.listen(_open);
    // Launched from a link: the router is up by the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(index.takeLaunchPath().then((link) => link == null ? null : _open(link)));
    });
  }

  @override
  void dispose() {
    _opens?.cancel();
    super.dispose();
  }

  void _open(String raw) {
    if (!mounted) return;
    final route = routeForIncomingLink(raw);
    if (route == null) return;
    // Songs and line-ups are the signed-in user's own; the rest open for all.
    final session = ref.read(sessionControllerProvider).value;
    final isLibraryPath = route.startsWith('/songs/') || route.startsWith('/line-ups');
    if (isLibraryPath && (session == null || session.workspaceId == null)) return;
    final router = ref.read(appRouterProvider);
    // A tab, not a page over one.
    unawaited(route == Routes.newLineUp ? Future.sync(() => router.go(route)) : router.push(route));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
