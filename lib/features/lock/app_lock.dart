import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../core/prefs/device_prefs.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/daloy_theme.dart';
import '../../shared/widgets/daloy_button.dart';
import '../auth/application/session_controller.dart';
import 'lock_authenticator.dart';

/// Covers the app with a lock screen until Face ID / the fingerprint / the
/// passcode says it's the owner — on opening the app, and again after it has
/// sat in the background longer than the chosen delay.
///
/// It never cuts in on a performance: on Perform or Practice the lock waits,
/// since a stage tablet must not ask for a face mid-song.
class AppLock extends ConsumerStatefulWidget {
  const AppLock({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLock> createState() => _AppLockState();
}

class _AppLockState extends ConsumerState<AppLock> with WidgetsBindingObserver {
  // Covered from the first frame when the lock is on, before it's known who
  // (if anyone) is signed in; opened again below if nobody is.
  late bool _locked = ref.read(devicePrefsControllerProvider).lockEnabled;
  bool _asking = false;
  bool _startDecided = false;
  DateTime? _leftAt;

  bool _shouldLock() =>
      ref.read(devicePrefsControllerProvider).lockEnabled && ref.read(sessionControllerProvider).value != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual(sessionControllerProvider, (_, session) => _decideStart(session), fireImmediately: true);
  }

  /// Once the stored session has loaded: ask to unlock if someone is signed
  /// in, otherwise there is nothing to protect.
  void _decideStart(AsyncValue<Object?> session) {
    if (_startDecided || (session.isLoading && !session.hasValue)) return;
    _startDecided = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (session.value == null) {
        if (_locked) setState(() => _locked = false);
      } else if (_locked) {
        unawaited(_unlock());
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool get _performing {
    final path = ref.read(appRouterProvider).routeInformationProvider.value.uri.path;
    return path.endsWith('/perform') || path.endsWith('/practice');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The prompt itself backgrounds and foregrounds the app; ignore that.
    if (_asking) return;
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.hidden:
        _leftAt ??= DateTime.now();
      case AppLifecycleState.resumed:
        final left = _leftAt;
        _leftAt = null;
        if (left == null || _locked || !_shouldLock() || _performing) return;
        final away = DateTime.now().difference(left);
        if (away >= ref.read(devicePrefsControllerProvider).lockDelay.duration) {
          setState(() => _locked = true);
          unawaited(_unlock());
        }
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _unlock() async {
    if (_asking) return;
    setState(() => _asking = true);
    final ok = await ref.read(lockAuthenticatorProvider).authenticate('Unlock Daloy');
    if (!mounted) return;
    if (ok) unawaited(HapticFeedback.lightImpact());
    setState(() {
      _asking = false;
      if (ok) {
        _locked = false;
        _leftAt = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Turning the lock off, or signing out, opens it.
    ref.listen(devicePrefsControllerProvider.select((p) => p.lockEnabled), (_, on) {
      if (!on && _locked) setState(() => _locked = false);
    });
    ref.listen(sessionControllerProvider.select((s) => s.value == null), (_, signedOut) {
      if (signedOut && _locked) setState(() => _locked = false);
    });

    return Stack(
      children: [
        widget.child,
        if (_locked)
          Positioned.fill(
            child: _LockScreen(asking: _asking, onUnlock: _unlock),
          ),
      ],
    );
  }
}

class _LockScreen extends ConsumerWidget {
  const _LockScreen({required this.asking, required this.onUnlock});

  final bool asking;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Material(
      color: c.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(DaloySpace.s8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(color: c.primary, borderRadius: DaloyRadii.all(DaloyRadii.xl2)),
                  child: Icon(TablerIcons.lock, size: 32, color: c.primaryForeground),
                ),
                const SizedBox(height: DaloySpace.s5),
                Text('Daloy is locked', style: context.text.displaySmall!.copyWith(fontSize: 26)),
                const SizedBox(height: DaloySpace.s2),
                Text(
                  'Your songs and line-ups stay private.',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                ),
                const SizedBox(height: DaloySpace.s6),
                FutureBuilder<String>(
                  future: ref.read(lockAuthenticatorProvider).label(),
                  builder: (context, snapshot) => DaloyButton(
                    label: 'Unlock with ${snapshot.data ?? 'Face ID'}',
                    icon: TablerIcons.lock_open,
                    size: ControlSize.lg,
                    loading: asking,
                    onPressed: asking ? null : onUnlock,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
