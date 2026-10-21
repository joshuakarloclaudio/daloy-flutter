import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../auth/application/session_controller.dart';
import '../data/present_link.dart';
import '../data/present_trust.dart';
import 'present_remote_sheet.dart' show presentDeviceName;
import 'remote_control_screen.dart';

/// Takes over a teammate's presentation: pairs with [presenter] (the pill's,
/// or one picked from those nearby), asks for the code shown there unless
/// this device was paired before, then opens the remote.
Future<void> joinPresentation(BuildContext context, WidgetRef ref, {NearbyPresenter? presenter}) async {
  ref.read(presentDiscoveryProvider.notifier).enable();
  final keys = ref.read(presentPresenterKeysProvider);
  final analytics = ref.read(analyticsProvider);
  final remote = await showDaloySheet<PresentRemote>(
    context: context,
    builder: (_) => _JoinSheet(
      presenter: presenter,
      myName: presentDeviceName(context, ref.read(sessionControllerProvider).value?.user.name),
      deviceId: ref.read(presentDeviceIdProvider),
      workspaceId: ref.read(activeWorkspaceIdProvider),
      keys: keys,
    ),
  );
  if (remote == null) return;
  if (remote.presenterId.isNotEmpty && remote.token.isNotEmpty) {
    keys.remember(remote.presenterId, token: remote.token, name: remote.presenterName);
  }
  unawaited(analytics.track(AnalyticsEvent.presentRemotePaired));
  if (!context.mounted) return remote.dispose();
  await RemoteControlScreen.open(context, remote);
  // Unpaired there, so this key no longer opens it.
  if (remote.removed) keys.forget(remote.presenterId);
}

/// Presentations a device in [workspaceId] should offer: teammates', not its own.
List<NearbyPresenter> teamPresentations(
  List<NearbyPresenter> found, {
  required int? workspaceId,
  required String deviceId,
}) => [
  for (final p in found)
    if (p.workspaceId != null && p.workspaceId == workspaceId && p.deviceId != deviceId) p,
];

class _JoinSheet extends StatefulWidget {
  const _JoinSheet({
    required this.presenter,
    required this.myName,
    required this.deviceId,
    required this.workspaceId,
    required this.keys,
  });

  final NearbyPresenter? presenter;
  final String myName;
  final String deviceId;
  final int? workspaceId;
  final PresentKeys keys;

  @override
  State<_JoinSheet> createState() => _JoinSheetState();
}

class _JoinSheetState extends State<_JoinSheet> {
  PresentFinder? _finder;
  String? _findError;

  /// Shows the help once a short look found nothing.
  bool _lookedAWhile = false;
  Timer? _lookTimer;

  NearbyPresenter? _pairing;
  bool _connecting = false;
  String? _error;

  /// Set while the presenter is waiting for the code.
  Completer<String?>? _askingCode;
  final _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.presenter case final presenter?) {
      unawaited(_pair(presenter));
    } else {
      _look();
    }
  }

  void _look() {
    final finder = _finder ??= PresentFinder();
    unawaited(finder.start().then((e) => mounted ? setState(() => _findError = e) : null));
    _lookTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _lookedAWhile = true);
    });
  }

  @override
  void dispose() {
    _lookTimer?.cancel();
    _finder?.dispose();
    if (_askingCode case final asking? when !asking.isCompleted) asking.complete(null);
    _code.dispose();
    super.dispose();
  }

  Future<String?> _ask(String? error) {
    final asking = Completer<String?>();
    setState(() {
      _askingCode = asking;
      _connecting = false;
      _error = error;
      _code.clear();
    });
    return asking.future;
  }

  void _submitCode() {
    final asking = _askingCode;
    if (asking == null || asking.isCompleted || _code.text.length != 4) return;
    setState(() => _connecting = true);
    asking.complete(_code.text);
  }

  Future<void> _pair(NearbyPresenter presenter) async {
    setState(() {
      _pairing = presenter;
      _connecting = true;
      _error = null;
    });
    try {
      final remote = await PresentRemote.connect(
        presenter,
        name: widget.myName,
        deviceId: widget.deviceId,
        token: widget.keys.tokenFor(presenter.deviceId),
        askCode: _ask,
      );
      unawaited(HapticFeedback.mediumImpact());
      if (mounted) {
        Navigator.of(context).pop(remote);
      } else {
        remote.dispose();
      }
    } on PairingException catch (e) {
      if (!mounted || e.cancelled) return;
      setState(() {
        _connecting = false;
        _askingCode = null;
        _error = e.message;
      });
    }
  }

  void _back() {
    if (_askingCode case final asking? when !asking.isCompleted) asking.complete(null);
    if (widget.presenter != null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _pairing = null;
      _askingCode = null;
      _connecting = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pairing = _pairing;
    return SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(DaloySpace.s5, 0, DaloySpace.s5, DaloySpace.s6),
        children: [
          Text(pairing == null ? 'Control a presentation' : 'Control ${pairing.by}', style: context.text.titleMedium),
          const SizedBox(height: DaloySpace.s1),
          if (pairing == null) ...[
            Text(
              'Change the slides on a teammate’s device from this one, over the same Wi-Fi.',
              style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
            ),
            const SizedBox(height: DaloySpace.s5),
            _nearby(),
          ] else
            _pairStep(pairing),
        ],
      ),
    );
  }

  Widget _nearby() => ValueListenableBuilder(
    valueListenable: _finder!.presenters,
    builder: (context, found, _) {
      final team = teamPresentations(found, workspaceId: widget.workspaceId, deviceId: widget.deviceId);
      if (team.isEmpty) {
        return _NothingNearby(error: _findError, helping: _lookedAWhile || _findError != null);
      }
      return SettingsGroup(
        children: [
          for (final p in team)
            SettingsRow(
              leading: const SettingsGlyph(TablerIcons.presentation),
              title: p.by,
              subtitle: p.title.isEmpty ? 'Presenting' : 'Presenting “${p.title}”',
              onTap: () => _pair(p),
            ),
        ],
      );
    },
  );

  Widget _pairStep(NearbyPresenter presenter) {
    final c = context.colors;
    final asking = _askingCode != null;
    if (!asking) {
      return Padding(
        padding: const EdgeInsets.only(top: DaloySpace.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_connecting)
              Row(
                children: [
                  const DaloySpinner(size: 18),
                  const SizedBox(width: DaloySpace.s3),
                  Text('Connecting…', style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
                ],
              )
            else ...[
              if (_error case final error?) Text(error, style: context.text.bodyMedium!.copyWith(color: c.destructive)),
              const SizedBox(height: DaloySpace.s4),
              Row(
                children: [
                  DaloyButton.outline(label: 'Back', onPressed: _back),
                  const SizedBox(width: DaloySpace.s2),
                  Expanded(
                    child: DaloyButton(label: 'Try again', expand: true, onPressed: () => _pair(presenter)),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'A code just appeared on ${presenter.by}. Type it here. You’ll only need it once.',
          style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
        ),
        const SizedBox(height: DaloySpace.s4),
        DaloyTextField(
          label: 'Code',
          controller: _code,
          error: _error,
          autofocus: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.go,
          onSubmitted: (_) => _submitCode(),
          onChanged: (v) {
            if (v.length == 4) _submitCode();
          },
        ),
        const SizedBox(height: DaloySpace.s3),
        Row(
          children: [
            DaloyButton.outline(label: 'Back', onPressed: _back),
            const SizedBox(width: DaloySpace.s2),
            Expanded(
              child: DaloyButton(
                label: 'Connect',
                expand: true,
                loading: _connecting,
                onPressed: _connecting ? null : _submitCode,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NothingNearby extends StatelessWidget {
  const _NothingNearby({required this.error, required this.helping});

  final String? error;

  /// Looked long enough that it's worth saying why nothing shows.
  final bool helping;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (error == null)
              const DaloySpinner(size: 18)
            else
              Icon(TablerIcons.wifi_off, size: 18, color: c.mutedForeground),
            const SizedBox(width: DaloySpace.s3),
            Expanded(
              child: Text(
                error == null ? 'Looking for presentations nearby…' : 'Can’t look on this network.',
                style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
              ),
            ),
          ],
        ),
        if (helping) ...[const SizedBox(height: DaloySpace.s4), const LocalNetworkHelp(presenting: true)],
      ],
    );
  }
}

/// Why devices can't see each other, most likely first, with a way into
/// the Local Network setting where there is one.
class LocalNetworkHelp extends StatelessWidget {
  const LocalNetworkHelp({super.key, this.presenting = false});

  /// Looking for someone else's presentation, so "open Present there" applies.
  final bool presenting;

  static Uri? get _settings => Platform.isIOS
      ? Uri.parse('app-settings:')
      : Platform.isMacOS
      ? Uri.parse('x-apple.systempreferences:com.apple.preference.security?Privacy_LocalNetwork')
      : null;

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    return SettingsGroup(
      children: [
        if (presenting)
          const _Tip(
            icon: TablerIcons.presentation,
            title: 'Is it presenting?',
            body: 'The other device needs Present open, with Daloy in front.',
          ),
        const _Tip(icon: TablerIcons.wifi, title: 'Same Wi-Fi?', body: 'Both devices need to be on the same network.'),
        if (settings != null)
          SettingsRow(
            leading: const SettingsGlyph(TablerIcons.lock_open),
            title: 'Local Network allowed?',
            subtitle: 'Daloy needs it on both devices.',
            onTap: () => unawaited(launchUrl(settings)),
            trailing: const Text('Settings'),
          ),
        const _Tip(
          icon: TablerIcons.building_church,
          title: 'Venue Wi-Fi?',
          body: 'Some keep devices apart. Join a phone’s hotspot on both instead.',
        ),
      ],
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) =>
      SettingsRow(leading: SettingsGlyph(icon), title: title, subtitle: body, chevron: false);
}
