import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_glass.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/settings_group.dart';
import '../data/present_link.dart';
import '../data/present_trust.dart';
import '../domain/present_deck.dart';
import 'present_join_sheet.dart' show LocalNetworkHelp;

/// "Ana's iPad": how this device is named to others nearby.
String presentDeviceName(BuildContext context, String? userName) {
  final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
  final kind = Platform.isMacOS
      ? 'Mac'
      : Platform.isWindows
      ? 'PC'
      : Platform.isIOS
      ? (tablet ? 'iPad' : 'iPhone')
      : (tablet ? 'tablet' : 'phone');
  final first = userName?.trim().split(RegExp(r'\s+')).first ?? '';
  return first.isEmpty ? 'Daloy $kind' : '$first’s $kind';
}

/// "4 8 2 1": a code spaced for reading aloud.
String spacedCode(String code) => code.split('').join(' ');

/// This device's presentation, open to teammates' devices on the same
/// network from the moment it starts: the server, the code for new devices,
/// who's asking, who's paired and who's driving.
class RemoteHosting extends ChangeNotifier {
  RemoteHosting({
    required this.deviceName,
    required String deviceId,
    required int? workspaceId,
    required this.trusted,
    required ValueChanged<PresentCommand> onCommand,
    this.onPaired,
  }) : _host = PresentHost(
         deviceName: deviceName,
         deviceId: deviceId,
         workspaceId: workspaceId,
         trusted: trusted,
         onCommand: onCommand,
       ) {
    _host.codeChanged = (_) => notifyListeners();
    _host.onPaired = _paired;
    _host.requests.addListener(notifyListeners);
    _host.controllers.addListener(notifyListeners);
    _host.driver.addListener(notifyListeners);
  }

  final String deviceName;
  final PresentKeys trusted;

  /// A device paired; [remembered] when it came back with its key.
  final void Function(PresentPeer peer, {required bool remembered})? onPaired;

  final PresentHost _host;
  bool _starting = false;
  bool _disposed = false;
  String? _error;
  String _title = '';

  bool get running => _host.isRunning;

  /// The port it serves on, while [running].
  int? get port => _host.port;
  bool get starting => _starting;
  String? get error => _error;
  String get code => _host.code;
  List<PresentPeer> get requests => _host.requests.value;
  List<PresentPeer> get controllers => _host.controllers.value;
  PresentPeer? get driver => _host.driver.value;

  /// Paired before but not here now.
  List<PresentPeer> get remembered => [
    for (final d in trusted.all)
      if (!controllers.any((c) => c.id == d.id)) PresentPeer(id: d.id, name: d.name),
  ];

  /// Opens this presentation to the network; [error] says why it couldn't
  /// (and stays until [retry]).
  Future<void> start(String title) async {
    _title = title;
    if (_host.isRunning || _starting || _error != null) return;
    _starting = true;
    _error = null;
    notifyListeners();
    try {
      await _host.start(title);
    } on Object {
      _error = "Other devices can't reach this one. Check Wi-Fi and Daloy's Local Network permission.";
    }
    if (_disposed) return;
    _starting = false;
    notifyListeners();
  }

  Future<void> retry() {
    _error = null;
    return start(_title);
  }

  void _paired(PresentPeer peer, {required bool remembered}) => onPaired?.call(peer, remembered: remembered);

  void broadcast(PresentDeckState deck) => _host.broadcast(deck);

  void decline(String id) => _host.decline(id);

  /// Unpairs [id]; it needs the code again next time.
  void disconnect(String id) {
    _host.disconnect(id);
    notifyListeners();
  }

  void forget(String id) {
    trusted.forget(id);
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _host.requests.removeListener(notifyListeners);
    _host.controllers.removeListener(notifyListeners);
    _host.driver.removeListener(notifyListeners);
    _host.dispose();
    super.dispose();
  }
}

/// Who can control this presentation: the code for new devices, the
/// devices paired now (one drives) and the ones remembered from before.
Future<void> showPresentRemoteSheet(BuildContext context, {required RemoteHosting hosting, Rect? anchor}) =>
    showDaloySheet<void>(
      context: context,
      anchor: anchor,
      builder: (_) => ListenableBuilder(
        listenable: hosting,
        builder: (context, _) => _RemoteSheet(hosting: hosting),
      ),
    );

class _RemoteSheet extends StatelessWidget {
  const _RemoteSheet({required this.hosting});

  final RemoteHosting hosting;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final muted = context.text.bodyMedium!.copyWith(color: c.mutedForeground);
    final controllers = hosting.controllers;
    final remembered = hosting.remembered;
    return SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s6),
        children: [
          Text('Remote control', style: context.text.titleMedium),
          const SizedBox(height: DaloySpace.s1),
          Text(
            'Teammates on this Wi-Fi see that ${hosting.deviceName} is presenting, '
            'and can take over the slides from Daloy. No internet needed.',
            style: muted,
          ),
          const SizedBox(height: DaloySpace.s5),
          if (hosting.starting)
            const Center(child: DaloySpinner())
          else if (hosting.error case final error?) ...[
            Text(error, style: context.text.bodyMedium!.copyWith(color: c.destructive)),
            const SizedBox(height: DaloySpace.s3),
            const LocalNetworkHelp(),
            const SizedBox(height: DaloySpace.s3),
            DaloyButton.outline(label: 'Try again', onPressed: hosting.retry),
          ] else ...[
            const _Label('Code for a new device'),
            Text(
              spacedCode(hosting.code),
              style: context.text.displaySmall!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
              semanticsLabel: 'Code ${spacedCode(hosting.code)}',
            ),
            const SizedBox(height: DaloySpace.s1),
            Text(
              'Asked for once per device. After that it connects by itself.',
              style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
            ),
          ],
          if (controllers.isNotEmpty) ...[
            const SizedBox(height: DaloySpace.s6),
            const _Label('Connected'),
            SettingsGroup(
              children: [
                for (final peer in controllers)
                  SettingsRow(
                    leading: const SettingsGlyph(TablerIcons.device_mobile),
                    title: peer.name,
                    subtitle: hosting.driver?.id == peer.id ? 'Has control' : 'Watching',
                    chevron: false,
                    trailing: DaloyButton(
                      label: 'Disconnect',
                      variant: ButtonVariant.destructive,
                      size: ControlSize.sm,
                      onPressed: () => hosting.disconnect(peer.id),
                    ),
                  ),
              ],
            ),
          ],
          if (remembered.isNotEmpty) ...[
            const SizedBox(height: DaloySpace.s6),
            const _Label('Paired before'),
            SettingsGroup(
              children: [
                for (final peer in remembered)
                  SettingsRow(
                    leading: const SettingsGlyph(TablerIcons.device_mobile_off),
                    title: peer.name,
                    subtitle: 'Connects without the code',
                    chevron: false,
                    trailing: DaloyButton(
                      label: 'Forget',
                      variant: ButtonVariant.plain,
                      onPressed: () => hosting.forget(peer.id),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// "Ben's phone wants to control the slides · 4 8 2 1": the code shows only
/// while someone's asking, here on the presenter and never on the output.
class PresentJoinRequestBanner extends StatelessWidget {
  const PresentJoinRequestBanner({super.key, required this.hosting, this.glass = false});

  final RemoteHosting hosting;

  /// Over the slides, rather than in the control panel.
  final bool glass;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: hosting,
    builder: (context, _) {
      final asking = hosting.requests.firstOrNull;
      final c = context.colors;
      final Widget child;
      if (asking == null) {
        child = const SizedBox(width: double.infinity);
      } else {
        final content = Padding(
          padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s3, DaloySpace.s2, DaloySpace.s3),
          child: Row(
            children: [
              Icon(TablerIcons.device_mobile_share, size: 20, color: c.primaryInk),
              const SizedBox(width: DaloySpace.s3),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hosting.requests.length > 1
                          ? '${asking.name} and ${hosting.requests.length - 1} more want control'
                          : '${asking.name} wants to control the slides',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium!.copyWith(color: c.foreground),
                    ),
                    Text(
                      'Code  ${spacedCode(hosting.code)}',
                      semanticsLabel: 'Code ${spacedCode(hosting.code)}',
                      style: context.text.titleLarge!.copyWith(
                        color: c.foreground,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              DaloyButton(label: 'Decline', variant: ButtonVariant.plain, onPressed: () => hosting.decline(asking.id)),
            ],
          ),
        );
        child = Semantics(
          liveRegion: true,
          child: glass
              ? DaloyGlass(child: content)
              : Container(
                  decoration: BoxDecoration(
                    color: c.primary.withValues(alpha: 0.1),
                    borderRadius: DaloyRadii.all(DaloyRadii.xl),
                  ),
                  child: content,
                ),
        );
      }
      return AnimatedSize(
        duration: DaloyMotion.medium,
        curve: DaloyMotion.ease,
        alignment: Alignment.topCenter,
        child: child,
      );
    },
  );
}

/// "Ben's phone has control": on the presenter while a paired device is
/// driving. Opens the remote sheet.
class PresentDriverChip extends StatelessWidget {
  const PresentDriverChip({super.key, required this.hosting, required this.onPressed, this.glass = false});

  final RemoteHosting hosting;
  final VoidCallback onPressed;
  final bool glass;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: hosting,
    builder: (context, _) {
      final driver = hosting.driver;
      if (driver == null) return const SizedBox.shrink();
      final c = context.colors;
      final glyphColor = glass ? Colors.white : c.foreground;
      final label = Padding(
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(TablerIcons.device_mobile_share, size: 16, color: glyphColor),
            const SizedBox(width: DaloySpace.s1_5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                '${driver.name} has control',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelMedium!.copyWith(color: glyphColor),
              ),
            ),
          ],
        ),
      );
      return Semantics(
        button: true,
        label: '${driver.name} has control. Remote control',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onPressed,
          child: glass
              ? DaloyGlass.capsule(child: label)
              : Container(
                  decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.full)),
                  child: label,
                ),
        ),
      );
    },
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: DaloySpace.s2),
    child: Text(text.toUpperCase(), style: context.text.labelSmall!.copyWith(color: context.colors.mutedForeground)),
  );
}
