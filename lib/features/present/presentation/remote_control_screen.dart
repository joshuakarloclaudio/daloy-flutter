import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_top_bar.dart';
import '../data/present_link.dart';
import '../domain/present_deck.dart';
import 'present_control_panel.dart';
import 'present_settings_sheet.dart';
import 'present_shortcuts.dart';

/// Driving another device's presentation: its deck, mirrored here, and the
/// same panel and keys as presenting on an external screen.
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

  @override
  void dispose() {
    _remote.dispose();
    super.dispose();
  }

  void _send(PresentCommand command) {
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
            if (ended) return _Ended(name: _remote.presenterName);
            return ValueListenableBuilder(
              valueListenable: _remote.deck,
              builder: (context, deck, _) => deck == null
                  ? const Center(child: DaloySpinner(size: 28))
                  : PresentControlPanel(deck: deck, onCommand: _send, status: 'Controlling ${_remote.presenterName}'),
            );
          },
        ),
      ),
    ),
  );
}

class _Ended extends StatelessWidget {
  const _Ended({required this.name});

  final String name;

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
            '$name stopped presenting, or left the network.',
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
