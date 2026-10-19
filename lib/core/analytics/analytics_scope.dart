import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/session_controller.dart';
import '../connectivity/online_status.dart';
import '../router/app_router.dart';
import 'analytics.dart';

/// Records app open, screen views, connectivity changes and trips to the
/// background, and uploads the queue on start, on reconnect and on the way
/// out — the twin of the web's `use-analytics-tracking.ts`.
class AnalyticsScope extends ConsumerStatefulWidget {
  const AnalyticsScope({super.key, required this.child});

  final Widget child;

  /// The event a screen also counts as, keyed by its route template.
  static AnalyticsEvent? startedOn(String screen) => switch (screen) {
    '/line-ups/:id/perform' => AnalyticsEvent.performanceStarted,
    '/line-ups/:id/practice' || '/songs/:id/practice' => AnalyticsEvent.practiceStarted,
    '/line-ups/:id/present' || '/songs/:id/present' => AnalyticsEvent.presentStarted,
    _ => null,
  };

  @override
  ConsumerState<AnalyticsScope> createState() => _AnalyticsScopeState();
}

class _AnalyticsScopeState extends ConsumerState<AnalyticsScope> {
  late final AppLifecycleListener _lifecycle;
  late final GoRouter _router;
  int? _openedFor;
  String? _lastScreen;

  Analytics get _analytics => ref.read(analyticsProvider);

  @override
  void initState() {
    super.initState();
    _router = ref.read(appRouterProvider);
    _router.routerDelegate.addListener(_onRoute);
    _lifecycle = AppLifecycleListener(
      onHide: () {
        _analytics.backgrounded();
        _analytics.trackAndFlush(AnalyticsEvent.appBackgrounded, screen: _lastScreen);
      },
      onShow: () {
        if (_analytics.foregrounded()) {
          _analytics.trackAndFlush(AnalyticsEvent.appOpened);
          _trackScreen(_lastScreen, force: true);
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onSignedIn(ref.read(sessionControllerProvider).value?.user.id);
    });
  }

  @override
  void dispose() {
    _router.routerDelegate.removeListener(_onRoute);
    _lifecycle.dispose();
    super.dispose();
  }

  /// Once per person per launch, then the first screen.
  void _onSignedIn(int? userId) {
    if (userId == null || _openedFor == userId) return;
    _openedFor = userId;
    _analytics.trackAndFlush(AnalyticsEvent.appOpened);
    _lastScreen = null;
    _onRoute();
  }

  void _onRoute() {
    final config = _router.routerDelegate.currentConfiguration;
    if (config.isEmpty) return;
    _trackScreen(config.fullPath);
  }

  void _trackScreen(String? screen, {bool force = false}) {
    if (screen == null || screen.isEmpty || (!force && screen == _lastScreen)) return;
    _lastScreen = screen;
    if (ref.read(sessionControllerProvider).value == null) return;
    _analytics.track(AnalyticsEvent.screenView, screen: screen);
    final started = AnalyticsScope.startedOn(screen);
    if (started != null) _analytics.track(started, screen: screen);
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(sessionControllerProvider.select((s) => s.value?.user.id), (_, id) => _onSignedIn(id))
      ..listen(onlineStatusProvider, (previous, next) {
        final was = previous?.value;
        final now = next.value;
        if (was == null || now == null || was == now) return;
        if (now) {
          _analytics.trackAndFlush(AnalyticsEvent.wentOnline);
        } else {
          _analytics.track(AnalyticsEvent.wentOffline);
        }
      });
    return widget.child;
  }
}
