import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/music_player_controller.dart';

/// A place the video can be drawn — the now-playing screen, the mini
/// player, Perform's strip. There's one YouTube player for the app: the
/// newest slot on screen holds it, and the video moves there (with a
/// `GlobalKey`) without reloading, so the song plays on across screens.
/// A slot without it shows the video's thumbnail.
///
/// A slot in a covered route (its tickers off) lets go, and so does one
/// whose route is popping, while the slot it's going back to is still on
/// screen to take the video. With no slot on screen, the player pauses.
class PlayerVideoSlot extends ConsumerStatefulWidget {
  const PlayerVideoSlot({super.key, this.borderRadius = BorderRadius.zero, this.onTap});

  final BorderRadius borderRadius;

  /// A tap on the video (YouTube's own controls are off).
  final VoidCallback? onTap;

  @override
  ConsumerState<PlayerVideoSlot> createState() => _PlayerVideoSlotState();
}

class _PlayerVideoSlotState extends ConsumerState<PlayerVideoSlot> {
  late final PlayerSlots _slots = ref.read(musicPlayerProvider.notifier).slots;
  Animation<double>? _route;

  @override
  void initState() {
    super.initState();
    _slots.addListener(_onSlots);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context)?.animation;
    if (route != _route) {
      _route?.removeStatusListener(_onRoute);
      _route = route?..addStatusListener(_onRoute);
    }
    _sync();
  }

  void _onRoute(AnimationStatus _) {
    if (mounted) _sync();
  }

  /// Off when a route covers this one (or it's in a tab not shown), or when
  /// its route is leaving. Waiting until the route is gone would tear the
  /// video down before the next slot can take it, and that stops the song.
  void _sync() {
    final leaving = _route?.status == AnimationStatus.reverse;
    TickerMode.valuesOf(context).enabled && !leaving ? _slots.show(this) : _slots.hide(this);
  }

  void _onSlots() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _route?.removeStatusListener(_onRoute);
    _slots
      ..removeListener(_onSlots)
      ..hide(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.read(musicPlayerProvider.notifier).engine;
    final video = ref.watch(musicPlayerProvider.select((s) => s.current?.videoId));
    final owns = _slots.owner == this && engine != null;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (owns)
              KeyedSubtree(key: _slots.surfaceKey, child: engine.buildSurface(context))
            else if (video != null)
              Image.network(
                'https://i.ytimg.com/vi/$video/mqdefault.jpg',
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            // Taps are ours: YouTube's controls are off, and its title links
            // would leave the app.
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onTap),
            ),
          ],
        ),
      ),
    );
  }
}
