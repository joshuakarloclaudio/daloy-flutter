import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home_screen_widget/home_screen_widget.dart';
import '../application/os_search_sync.dart';

/// Under the app shell (signed in, in a workspace): keeps the OS's search
/// index and the home-screen widget current. What a Spotlight hit or shortcut opens is handled above
/// the router, by `IncomingLinks`.
class OsSearchScope extends ConsumerWidget {
  const OsSearchScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(osSearchSyncProvider);
    ref.watch(homeWidgetSyncProvider);
    return child;
  }
}
