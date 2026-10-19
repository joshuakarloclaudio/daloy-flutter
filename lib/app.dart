import 'package:flutter/cupertino.dart' show CupertinoScrollBehavior;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/analytics/analytics_scope.dart';
import 'core/prefs/device_prefs.dart';
import 'core/router/app_router.dart';
import 'core/router/incoming_links.dart';
import 'core/theme/daloy_theme.dart';
import 'features/lock/app_lock.dart';

class DaloyApp extends ConsumerWidget {
  const DaloyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(devicePrefsControllerProvider);
    // Read while the themes below are built, so the typeface choice reaches
    // every text style made from them.
    DaloyFonts.system = prefs.font == AppFont.system;
    return MaterialApp.router(
      title: 'Daloy',
      debugShowCheckedModeBanner: false,
      theme: DaloyTheme.light(),
      darkTheme: DaloyTheme.dark(),
      themeMode: prefs.themeMode,
      // iOS bounce everywhere: no Android glow or stretch.
      scrollBehavior: const CupertinoScrollBehavior(),
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) => IncomingLinks(
        child: AnalyticsScope(child: AppLock(child: child ?? const SizedBox.shrink())),
      ),
    );
  }
}
