import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/widgets/daloy_toast.dart';
import 'workspace_realtime.dart';

/// Starts [WorkspaceRealtime] under the app shell, and catches up after the
/// app was in the background a while (sockets sleep there, pings get lost).
class RealtimeScope extends ConsumerStatefulWidget {
  const RealtimeScope({super.key, required this.child});

  final Widget child;

  /// Away at least this long: run a sync on return.
  static const catchUpAfter = Duration(seconds: 10);

  @override
  ConsumerState<RealtimeScope> createState() => _RealtimeScopeState();
}

class _RealtimeScopeState extends ConsumerState<RealtimeScope> {
  late final AppLifecycleListener _lifecycle;
  DateTime? _hiddenAt;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => _hiddenAt = DateTime.now(),
      onShow: () {
        final at = _hiddenAt;
        _hiddenAt = null;
        if (at != null && DateTime.now().difference(at) >= RealtimeScope.catchUpAfter) {
          ref.read(workspaceRealtimeProvider.notifier).catchUp().catchError((Object _) {});
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(workspaceRealtimeProvider);
    return widget.child;
  }
}

/// In a screen's build: a quiet toast when the song or line-up it shows is
/// changed from another device. The screen redraws from Drift on its own;
/// this says why. Lists don't call it.
void listenRemoteChanges(WidgetRef ref, BuildContext context, RemoteKind kind, int id) {
  ref.listen(remoteChangesProvider, (_, next) {
    final change = next.value;
    if (change == null || change.kind != kind || change.id != id) return;
    showDaloyToast(ScaffoldMessenger.maybeOf(context), change.message);
  });
}
