import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/daloy_top_bar.dart';
import '../data/present_link.dart';
import '../domain/present_deck.dart';
import 'present_control_panel.dart';
import 'present_settings_sheet.dart';
import 'present_shortcuts.dart';

/// Driving another device's presentation: its deck, mirrored here, and the
/// same panel and keys as presenting on an external screen. One paired
/// device drives at a time; the rest watch until they take control.
class RemoteControlScreen extends StatefulWidget {
  const RemoteControlScreen({super.key, required this.remote});

  final PresentRemote remote;

  static Future<void> open(BuildContext context, PresentRemote remote) => Navigator.of(
    context,
    rootNavigator: true,
  ).push(MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => RemoteControlScreen(remote: remote)));

  @override
  State<RemoteControlScreen> createState() => _RemoteControlScreenState();
}

class _RemoteControlScreenState extends State<RemoteControlScreen> {
  PresentRemote get _remote => widget.remote;
  late bool _wasDriving = _remote.driving.value;

  @override
  void initState() {
    super.initState();
    _remote.driving.addListener(_onDriving);
  }

  @override
  void dispose() {
    _remote.driving.removeListener(_onDriving);
    _remote.dispose();
    super.dispose();
  }

  /// Someone else took over: say who, so the slides stopping isn't a mystery.
  void _onDriving() {
    final driving = _remote.driving.value;
    if (_wasDriving && !driving && !_remote.ended.value) {
      unawaited(HapticFeedback.mediumImpact());
      showDaloyToast(
        ScaffoldMessenger.maybeOf(context),
        '${_remote.driverName.value ?? 'Another device'} took control.',
        actionLabel: 'Take back',
        onAction: _remote.takeControl,
      );
    }
    _wasDriving = driving;
  }

  void _send(PresentCommand command) {
    if (!_remote.driving.value) {
      unawaited(HapticFeedback.heavyImpact());
      return;
    }
    unawaited(HapticFeedback.selectionClick());
    _remote.send(command);
  }

  @override
  Widget build(BuildContext context) => PresentShortcuts(
    onCommand: _send,
    child: Scaffold(
      appBar: DaloyTopBar(
        title: 'Remote',
        actions: [
          Builder(
            builder: (button) => TopBarIconButton(
              icon: TablerIcons.adjustments_horizontal,
              tooltip: 'Slide settings',
              onPressed: () => showPresentSettingsSheet(
                context,
                current: () => _remote.deck.value?.look ?? const PresentLook(),
                changes: _remote.deck,
                onChanged: (look) => _send(PresentSetLook(look)),
                anchor: anchorOf(button),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder(
          valueListenable: _remote.ended,
          builder: (context, ended, _) {
            if (ended) return _Ended(name: _remote.presenterName, removed: _remote.removed);
            return ListenableBuilder(
              listenable: Listenable.merge([_remote.deck, _remote.driving, _remote.driverName]),
              builder: (context, _) {
                final deck = _remote.deck.value;
                if (deck == null) return const Center(child: DaloySpinner(size: 28));
                final driving = _remote.driving.value;
                return Column(
                  children: [
                    if (!driving)
                      _Watching(
                        driver: _remote.driverName.value,
                        presenter: _remote.presenterName,
                        onTake: () {
                          unawaited(HapticFeedback.mediumImpact());
                          _remote.takeControl();
                        },
                      ),
                    Expanded(
                      child: PresentControlPanel(
                        deck: deck,
                        onCommand: _send,
                        canEdit: driving,
                        status: driving ? 'Controlling ${_remote.presenterName}' : 'Watching ${_remote.presenterName}',
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    ),
  );
}

/// Another paired device is driving; this one follows along until it takes over.
class _Watching extends StatelessWidget {
  const _Watching({required this.driver, required this.presenter, required this.onTake});

  final String? driver;
  final String presenter;
  final VoidCallback onTake;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s2, DaloySpace.s4, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s2, DaloySpace.s2, DaloySpace.s2),
        decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.xl)),
        child: Row(
          children: [
            Icon(TablerIcons.eye, size: 18, color: c.mutedForeground),
            const SizedBox(width: DaloySpace.s3),
            Expanded(
              child: Text(
                driver == null ? 'Watching. $presenter is in control.' : '$driver has control.',
                style: context.text.bodyMedium!.copyWith(color: c.foreground),
              ),
            ),
            DaloyButton(label: 'Take control', size: ControlSize.sm, onPressed: onTake),
          ],
        ),
      ),
    );
  }
}

class _Ended extends StatelessWidget {
  const _Ended({required this.name, this.removed = false});

  final String name;

  /// The presenter disconnected this device, rather than stopping.
  final bool removed;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(DaloySpace.s8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(TablerIcons.plug_connected_x, size: 32, color: context.colors.mutedForeground),
          const SizedBox(height: DaloySpace.s3),
          Text('Disconnected', style: context.text.headlineSmall),
          const SizedBox(height: DaloySpace.s2),
          Text(
            removed
                ? '$name disconnected this device. Pair again with the code to come back.'
                : '$name stopped presenting, or left the network.',
            textAlign: TextAlign.center,
            style: context.text.bodyMedium!.copyWith(color: context.colors.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s5),
          DaloyButton.outline(label: 'Done', onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    ),
  );
}
