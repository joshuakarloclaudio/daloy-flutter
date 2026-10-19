import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/device/screen_awake.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_top_bar.dart';
import '../../../shared/widgets/glass_buttons.dart';
import '../../auth/application/session_controller.dart';
import '../../perform/application/perform_controller.dart' show LineUpSource, PerformSource, SongSource;
import '../application/present_controller.dart';
import '../data/present_display.dart';
import '../domain/present_deck.dart';
import 'present_control_panel.dart';
import 'present_remote_sheet.dart';
import 'present_settings_sheet.dart';
import 'present_shortcuts.dart';
import 'present_slide_view.dart';
import 'remote_control_screen.dart';

/// Lyrics for the big screen. With a projector or TV attached (HDMI,
/// AirPlay, Miracast) the slides go there and this device is the control
/// panel; without one, the slides fill this screen — tap or swipe the sides
/// to move, tap the middle for controls. Either way a paired device can
/// drive it over the local network.
class PresentScreen extends ConsumerStatefulWidget {
  const PresentScreen({super.key, required this.source});

  final PerformSource source;

  @override
  ConsumerState<PresentScreen> createState() => _PresentScreenState();
}

class _PresentScreenState extends ConsumerState<PresentScreen> {
  late final _provider = presentDeckControllerProvider(widget.source);
  late final ScreenAwake _awake = ref.read(screenAwakeProvider);
  late final PresentDisplayChannel _display = ref.read(presentDisplayChannelProvider);
  RemoteHosting? _hosting;

  /// What the sheets watch: the deck as it changes.
  late final _deck = ValueNotifier<PresentDeckState>(ref.read(_provider).deck);

  /// The external screen the slides are on, while they are.
  ExternalDisplay? _onDisplay;
  bool _chrome = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_awake.hold());
    _scheduleHide();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_syncDisplay(ref.read(externalDisplayProvider).value));
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    if (_onDisplay != null) unawaited(_display.hide());
    _hosting?.dispose();
    _deck.dispose();
    unawaited(_awake.release());
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    super.dispose();
  }

  RemoteHosting get _remoteHosting =>
      _hosting ??= RemoteHosting(deviceName: _myName, onCommand: _apply)..broadcast(_deck.value);

  String get _myName => presentDeviceName(context, ref.read(sessionControllerProvider).value?.user.name);

  void _apply(PresentCommand command) => ref.read(_provider.notifier).apply(command);

  void _command(PresentCommand command) {
    unawaited(HapticFeedback.selectionClick());
    _apply(command);
  }

  /// Puts the slides on [display] when one turns up; back here when it goes.
  Future<void> _syncDisplay(ExternalDisplay? display) async {
    if (display != null && _onDisplay == null) {
      final analytics = ref.read(analyticsProvider);
      final shown = await _display.show(_deck.value);
      if (mounted && shown) {
        setState(() => _onDisplay = display);
        unawaited(analytics.track(AnalyticsEvent.externalDisplayConnected));
      }
    } else if (display == null && _onDisplay != null) {
      setState(() => _onDisplay = null);
    }
  }

  void _onDeck(PresentDeckState deck) {
    _deck.value = deck;
    _hosting?.broadcast(deck);
    if (_onDisplay != null) unawaited(_display.update(deck));
  }

  void _leave() {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(switch (widget.source) {
        LineUpSource(:final id) => Routes.lineUp(id),
        SongSource(:final id) => Routes.song(id),
      });
    }
  }

  // -- Chrome (on this screen only) -----------------------------------------------

  void _setChrome(bool visible) {
    if (visible != _chrome) {
      setState(() => _chrome = visible);
      unawaited(SystemChrome.setEnabledSystemUIMode(visible ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky));
    }
    _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!_chrome) return;
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _onDisplay == null) _setChrome(false);
    });
  }

  // -- Sheets ----------------------------------------------------------------------

  void _openSettings(Rect anchor) => showPresentSettingsSheet(
    context,
    current: () => _deck.value.look,
    changes: _deck,
    onChanged: (look) => _apply(PresentSetLook(look)),
    anchor: anchor,
  );

  Future<void> _openRemote(Rect anchor) async {
    _hideTimer?.cancel();
    final analytics = ref.read(analyticsProvider);
    final remote = await showPresentRemoteSheet(
      context,
      hosting: _remoteHosting,
      title: _deck.value.title,
      myName: _myName,
      anchor: anchor,
    );
    if (remote != null) unawaited(analytics.track(AnalyticsEvent.presentRemotePaired));
    if (remote != null && mounted) await RemoteControlScreen.open(context, remote);
    _scheduleHide();
  }

  List<Widget> _actions({required bool glass}) => [
    Builder(
      builder: (button) => glass
          ? GlassIconButton(
              icon: TablerIcons.device_mobile_share,
              label: 'Remote',
              onPressed: () => _openRemote(anchorOf(button)),
            )
          : TopBarIconButton(
              icon: TablerIcons.device_mobile_share,
              tooltip: 'Remote',
              onPressed: () => _openRemote(anchorOf(button)),
            ),
    ),
    Builder(
      builder: (button) => glass
          ? GlassIconButton(
              icon: TablerIcons.adjustments_horizontal,
              label: 'Slide settings',
              onPressed: () => _openSettings(anchorOf(button)),
            )
          : TopBarIconButton(
              icon: TablerIcons.adjustments_horizontal,
              tooltip: 'Slide settings',
              onPressed: () => _openSettings(anchorOf(button)),
            ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen(_provider.select((v) => v.deck), (_, deck) => _onDeck(deck));
    ref.listen(externalDisplayProvider, (_, next) => unawaited(_syncDisplay(next.value)));

    final view = ref.watch(_provider);
    final deck = view.deck;

    if (view.isLoading && deck.slides.isEmpty) {
      return const Scaffold(body: Center(child: DaloySpinner(size: 28)));
    }
    if (view.notFound || view.songsMissing || deck.slides.isEmpty) {
      return Scaffold(
        appBar: DaloyTopBar(title: 'Present'),
        body: _Empty(
          message: view.notFound
              ? 'This is no longer here.'
              : view.songsMissing
              ? "This line-up's songs haven't reached this device yet. Open it once while online."
              : 'Nothing to present yet.',
          onBack: _leave,
        ),
      );
    }

    final display = _onDisplay;
    return PresentShortcuts(
      onCommand: _command,
      onEscape: _leave,
      child: display != null ? _panel(deck, display) : _here(deck),
    );
  }

  Widget _panel(PresentDeckState deck, ExternalDisplay display) => Scaffold(
    appBar: DaloyTopBar(title: deck.title, actions: _actions(glass: false)),
    body: SafeArea(
      top: false,
      child: PresentControlPanel(
        deck: deck,
        onCommand: _command,
        status: 'On ${display.name}',
        aspectRatio: display.aspectRatio,
      ),
    ),
  );

  Widget _here(PresentDeckState deck) {
    final size = MediaQuery.sizeOf(context);
    final current = deck.current;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) {
              final x = details.localPosition.dx / size.width;
              if (x < 0.3) {
                _command(const PresentPrev());
              } else if (x > 0.7) {
                _command(const PresentNext());
              } else {
                _setChrome(!_chrome);
              }
            },
            onHorizontalDragEnd: (details) {
              final v = details.primaryVelocity ?? 0;
              if (v < -200) _command(const PresentNext());
              if (v > 200) _command(const PresentPrev());
            },
            child: PresentSlideView(
              slide: current,
              look: deck.look,
              blanked: deck.blanked,
              aspectRatio: size.height > 0 ? size.width / size.height : 16 / 9,
            ),
          ),
          IgnorePointer(
            ignoring: !_chrome,
            child: AnimatedOpacity(
              opacity: _chrome ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(DaloySpace.s3),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GlassIconButton(icon: TablerIcons.x, label: 'Stop presenting', onPressed: _leave),
                          const Spacer(),
                          ..._actions(glass: true),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          GlassIconButton(
                            icon: TablerIcons.chevron_left,
                            label: 'Previous slide',
                            onPressed: deck.hasPrev ? () => _command(const PresentPrev()) : null,
                          ),
                          const SizedBox(width: DaloySpace.s2),
                          GlassIconButton(
                            icon: deck.blanked ? TablerIcons.eye : TablerIcons.eye_off,
                            label: deck.blanked ? 'Show slides' : 'Blank the screen',
                            prominent: deck.blanked,
                            onPressed: () => _command(const PresentToggleBlank()),
                          ),
                          const SizedBox(width: DaloySpace.s3),
                          Expanded(
                            child: Text(
                              ['${deck.index + 1} / ${deck.slides.length}', ?current?.songTitle].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelLarge!.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                shadows: const [Shadow(color: Color(0x99000000), blurRadius: 8)],
                              ),
                            ),
                          ),
                          GlassIconButton(
                            icon: TablerIcons.chevron_right,
                            label: 'Next slide',
                            prominent: true,
                            onPressed: deck.hasNext ? () => _command(const PresentNext()) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(DaloySpace.s8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(TablerIcons.presentation_off, size: 32, color: context.colors.mutedForeground),
          const SizedBox(height: DaloySpace.s3),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.text.bodyLarge!.copyWith(color: context.colors.mutedForeground),
          ),
          const SizedBox(height: DaloySpace.s5),
          DaloyButton.outline(label: 'Back', onPressed: onBack),
        ],
      ),
    ),
  );
}
