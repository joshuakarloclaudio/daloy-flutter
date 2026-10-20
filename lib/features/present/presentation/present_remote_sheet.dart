import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_switch.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../../../shared/widgets/settings_group.dart';
import '../data/present_link.dart';
import '../domain/present_deck.dart';

/// "Ana's iPad": how this device is named to others nearby.
String presentDeviceName(BuildContext context, String? userName) {
  final tablet = MediaQuery.sizeOf(context).shortestSide >= 600;
  final kind = Platform.isMacOS
      ? 'Mac'
      : Platform.isIOS
      ? (tablet ? 'iPad' : 'iPhone')
      : (tablet ? 'tablet' : 'phone');
  final first = userName?.trim().split(RegExp(r'\s+')).first ?? '';
  return first.isEmpty ? 'Daloy $kind' : '$first’s $kind';
}

/// This device letting others control its presentation: the server, the
/// code to show, who's paired. Off until asked for.
class RemoteHosting extends ChangeNotifier {
  RemoteHosting({required this.deviceName, required this.onCommand});

  final String deviceName;
  final ValueChanged<PresentCommand> onCommand;

  PresentHost? _host;
  bool _starting = false;
  String? _error;
  PresentDeckState? _deck;

  bool get enabled => _host != null;
  bool get starting => _starting;
  String? get error => _error;
  String? get code => _host?.code;
  List<String> get controllers => _host?.controllers.value ?? const [];

  Future<void> enable(String title) async {
    if (_host != null || _starting) return;
    _starting = true;
    _error = null;
    notifyListeners();
    final host = PresentHost(deviceName: deviceName, onCommand: onCommand);
    try {
      await host.start(title);
      host.controllers.addListener(notifyListeners);
      host.codeChanged = (_) => notifyListeners();
      if (_deck case final deck?) host.broadcast(deck);
      _host = host;
    } on Object {
      host.dispose();
      _error = "Couldn't open this device to the network. Check Wi-Fi and Daloy's Local Network permission.";
    }
    _starting = false;
    notifyListeners();
  }

  Future<void> disable() async {
    final host = _host;
    _host = null;
    notifyListeners();
    if (host == null) return;
    host.controllers.removeListener(notifyListeners);
    await host.stop();
    host.dispose();
  }

  void broadcast(PresentDeckState deck) {
    _deck = deck;
    _host?.broadcast(deck);
  }

  @override
  void dispose() {
    unawaited(disable());
    super.dispose();
  }
}

/// Remote control both ways: let another device drive this one (a code to
/// type there), or pick a presentation nearby to drive. Pops with the
/// [PresentRemote] when pairing with another device worked.
Future<PresentRemote?> showPresentRemoteSheet(
  BuildContext context, {
  required RemoteHosting hosting,
  required String title,
  required String myName,
  Rect? anchor,
}) => showDaloySheet<PresentRemote>(
  context: context,
  anchor: anchor,
  builder: (_) => _RemoteSheet(hosting: hosting, title: title, myName: myName),
);

class _RemoteSheet extends StatefulWidget {
  const _RemoteSheet({required this.hosting, required this.title, required this.myName});

  final RemoteHosting hosting;
  final String title;
  final String myName;

  @override
  State<_RemoteSheet> createState() => _RemoteSheetState();
}

class _RemoteSheetState extends State<_RemoteSheet> {
  final _finder = PresentFinder();
  String? _findError;
  NearbyPresenter? _pairing;
  final _code = TextEditingController();
  String? _pairError;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    unawaited(_finder.start().then((e) => mounted ? setState(() => _findError = e) : null));
  }

  @override
  void dispose() {
    _finder.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _pair() async {
    final presenter = _pairing;
    if (presenter == null || _code.text.length != 4 || _connecting) return;
    setState(() {
      _connecting = true;
      _pairError = null;
    });
    try {
      final remote = await PresentRemote.connect(presenter, _code.text, name: widget.myName);
      unawaited(HapticFeedback.mediumImpact());
      if (mounted) Navigator.of(context).pop(remote);
    } on PairingException catch (e) {
      if (mounted) {
        setState(() {
          _connecting = false;
          _pairError = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s6),
        children: [
          Text('Remote control', style: context.text.titleMedium),
          const SizedBox(height: DaloySpace.s1),
          Text(
            'Over this Wi-Fi, no internet needed. Both devices need Daloy open on the same network.',
            style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s5),
          _Label('This ${widget.myName.split(' ').last}'),
          ListenableBuilder(
            listenable: widget.hosting,
            builder: (context, _) => _HostingCard(hosting: widget.hosting, title: widget.title),
          ),
          const SizedBox(height: DaloySpace.s6),
          const _Label('Control another device'),
          if (_pairing case final presenter?)
            _PairForm(
              presenter: presenter,
              code: _code,
              error: _pairError,
              connecting: _connecting,
              onPair: _pair,
              onCancel: () => setState(() {
                _pairing = null;
                _pairError = null;
                _code.clear();
              }),
            )
          else
            ValueListenableBuilder(
              valueListenable: _finder.presenters,
              builder: (context, found, _) {
                final others = [
                  for (final p in found)
                    if (!(widget.hosting.enabled && p.by == widget.myName)) p,
                ];
                if (others.isEmpty) {
                  return _Searching(error: _findError);
                }
                return SettingsGroup(
                  children: [
                    for (final p in others)
                      SettingsRow(
                        leading: const SettingsGlyph(TablerIcons.presentation),
                        title: p.by,
                        subtitle: p.title.isEmpty ? 'Presenting' : 'Presenting “${p.title}”',
                        onTap: () => setState(() => _pairing = p),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _HostingCard extends StatelessWidget {
  const _HostingCard({required this.hosting, required this.title});

  final RemoteHosting hosting;
  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final controllers = hosting.controllers;
    return SettingsGroup(
      children: [
        SettingsRow(
          leading: const SettingsGlyph(TablerIcons.device_mobile_share),
          title: 'Allow remote control',
          subtitle: 'Another device can change the slides',
          chevron: false,
          trailing: hosting.starting
              ? const DaloySpinner()
              : DaloySwitch(
                  value: hosting.enabled,
                  semanticLabel: 'Allow remote control',
                  onChanged: (on) => on ? hosting.enable(title) : hosting.disable(),
                ),
          onTap: hosting.starting ? null : () => hosting.enabled ? hosting.disable() : hosting.enable(title),
        ),
        if (hosting.error case final error?)
          Padding(
            padding: const EdgeInsets.all(DaloySpace.s4),
            child: Text(error, style: context.text.bodySmall!.copyWith(color: c.destructive)),
          ),
        if (hosting.code case final code?)
          Padding(
            padding: const EdgeInsets.all(DaloySpace.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('PAIRING CODE', style: context.text.labelSmall!.copyWith(color: c.mutedForeground)),
                const SizedBox(height: DaloySpace.s1),
                Text(
                  code.split('').join(' '),
                  style: context.text.displaySmall!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  semanticsLabel: 'Pairing code ${code.split('').join(' ')}',
                ),
                const SizedBox(height: DaloySpace.s2),
                Text(
                  controllers.isEmpty
                      ? 'On the other device, open Present, tap Remote, pick ${hosting.deviceName} and type this code.'
                      : 'Controlled by ${controllers.join(', ')}.',
                  style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Searching extends StatelessWidget {
  const _Searching({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(DaloySpace.s4),
      decoration: BoxDecoration(
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
        border: Border.all(color: c.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (error == null)
            const DaloySpinner(size: 18)
          else
            Icon(TablerIcons.wifi_off, size: 18, color: c.mutedForeground),
          const SizedBox(width: DaloySpace.s3),
          Expanded(
            child: Text(
              error == null
                  ? 'Looking for presentations nearby… Turn on “Allow remote control” on the presenting device. '
                        'Some venue Wi-Fi keeps devices apart; a phone’s hotspot works instead.'
                  : "Can't look on this network. Check Wi-Fi and Daloy's Local Network permission.",
              style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
            ),
          ),
        ],
      ),
    );
  }
}

class _PairForm extends StatelessWidget {
  const _PairForm({
    required this.presenter,
    required this.code,
    required this.error,
    required this.connecting,
    required this.onPair,
    required this.onCancel,
  });

  final NearbyPresenter presenter;
  final TextEditingController code;
  final String? error;
  final bool connecting;
  final VoidCallback onPair;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Pair with ${presenter.by}', style: context.text.titleSmall),
      const SizedBox(height: DaloySpace.s3),
      DaloyTextField(
        label: 'Code shown on ${presenter.by}',
        controller: code,
        error: error,
        autofocus: true,
        keyboardType: TextInputType.number,
        maxLength: 4,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => onPair(),
        onChanged: (v) {
          if (v.length == 4) onPair();
        },
      ),
      const SizedBox(height: DaloySpace.s3),
      Row(
        children: [
          DaloyButton.outline(label: 'Back', onPressed: connecting ? null : onCancel),
          const SizedBox(width: DaloySpace.s2),
          Expanded(
            child: DaloyButton(label: 'Pair', expand: true, loading: connecting, onPressed: connecting ? null : onPair),
          ),
        ],
      ),
    ],
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
