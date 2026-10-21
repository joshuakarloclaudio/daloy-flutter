import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../core/theme/daloy_theme.dart';
import '../features/auth/application/session_controller.dart';
import '../features/present/data/present_link.dart';
import '../features/present/data/present_trust.dart';
import '../features/present/presentation/present_join_sheet.dart';
import '../shared/widgets/daloy_glass.dart';
import '../shared/widgets/pressable.dart';
import 'floating_tab_bar.dart';

/// "Ana's iPad is presenting", docked with the live bar: a teammate's
/// presentation on this Wi-Fi, one tap from controlling it. Looks only while
/// Daloy is in front, and only once this device has opened Present or the
/// remote before (`presentDiscoveryProvider`), so the Local Network prompt
/// never greets someone who's never presented.
class NearbyPresentationBar extends ConsumerStatefulWidget {
  const NearbyPresentationBar({super.key});

  @override
  ConsumerState<NearbyPresentationBar> createState() => _NearbyPresentationBarState();
}

class _NearbyPresentationBarState extends ConsumerState<NearbyPresentationBar> {
  final _finder = PresentFinder();
  late final AppLifecycleListener _lifecycle;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => _setForeground(true), onHide: () => _setForeground(false));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _finder.dispose();
    super.dispose();
  }

  void _setForeground(bool foreground) {
    _foreground = foreground;
    _sync(ref.read(presentDiscoveryProvider));
  }

  void _sync(bool enabled) {
    if (enabled && _foreground) {
      if (!_finder.isRunning) unawaited(_finder.start());
    } else if (_finder.isRunning) {
      unawaited(_finder.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(presentDiscoveryProvider);
    _sync(enabled);
    final workspaceId = ref.watch(activeWorkspaceIdProvider);
    final deviceId = ref.watch(presentDeviceIdProvider);

    return ValueListenableBuilder(
      valueListenable: _finder.presenters,
      builder: (context, found, _) {
        final team = enabled
            ? teamPresentations(found, workspaceId: workspaceId, deviceId: deviceId)
            : const <NearbyPresenter>[];
        return AnimatedSize(
          duration: DaloyMotion.medium,
          curve: DaloyMotion.ease,
          alignment: Alignment.bottomCenter,
          child: team.isEmpty
              ? const SizedBox(width: double.infinity)
              : _Bar(
                  title: team.length == 1 ? '${team.first.by} is presenting' : '${team.length} presentations nearby',
                  subtitle: team.length == 1 && team.first.title.isNotEmpty ? team.first.title : 'On this Wi-Fi',
                  onControl: () => joinPresentation(context, ref, presenter: team.length == 1 ? team.first : null),
                ),
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.title, required this.subtitle, required this.onControl});

  final String title;
  final String subtitle;
  final VoidCallback onControl;

  static const _height = 52.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          FloatingGlassTabBar.side,
          DaloySpace.s2,
          FloatingGlassTabBar.side,
          DaloySpace.s2,
        ),
        child: DaloyGlass.capsule(
          child: SizedBox(
            height: _height,
            child: Padding(
              padding: const EdgeInsets.only(left: DaloySpace.s2, right: DaloySpace.s1_5),
              child: Row(
                children: [
                  Expanded(
                    child: Pressable(
                      onPressed: onControl,
                      pressedScale: 0.99,
                      semanticLabel: '$title. Control it',
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: c.primary.withValues(alpha: 0.14)),
                            child: Icon(TablerIcons.presentation, size: 18, color: c.primaryInk),
                          ),
                          const SizedBox(width: DaloySpace.s2_5),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleSmall!.copyWith(color: c.foreground),
                                ),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: DaloySpace.s2),
                  Pressable(
                    onPressed: onControl,
                    semanticLabel: 'Control',
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: c.primary, borderRadius: DaloyRadii.all(DaloyRadii.full)),
                      child: Text('Control', style: context.text.labelLarge!.copyWith(color: c.primaryForeground)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
