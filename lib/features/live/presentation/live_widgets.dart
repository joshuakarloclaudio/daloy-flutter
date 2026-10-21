import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_alert.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/hairline.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../auth/application/session_controller.dart';
import '../../perform/application/perform_controller.dart';
import '../../perform/data/perform_prefs_repository.dart';
import '../../perform/domain/perform_sections.dart';
import '../../perform/domain/perform_theme.dart';
import '../../perform/presentation/widgets/perform_sheets.dart';
import '../../perform/presentation/widgets/perform_themed.dart';
import '../application/live_session_controller.dart';
import '../domain/live_cue.dart';
import '../domain/live_state.dart';

// -- Top bar -----------------------------------------------------------------------

/// Perform's live control, at the right of the top bar: "Go live" alone,
/// "Join" when the team is live without you, and the session (with how many
/// are in) once you're in it.
class PerformLiveAction extends ConsumerWidget {
  const PerformLiveAction({super.key, required this.lineUpId, required this.onGoLive, required this.onOpen});

  final int lineUpId;
  final VoidCallback onGoLive;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveSessionControllerProvider(lineUpId));
    final online = ref.watch(isOnlineProvider);
    final c = context.colors;
    final palette = PerformPaletteScope.of(context);

    if (live.status == LiveStatus.connecting) {
      return _LivePill(
        label: 'Joining',
        semanticLabel: 'Joining the live session',
        leading: DaloySpinner(size: 12, color: c.mutedForeground),
        foreground: c.mutedForeground,
        border: c.border,
        onPressed: null,
      );
    }
    if (live.isIn) {
      final count = live.count;
      if (live.status == LiveStatus.reconnecting) {
        return _LivePill(
          label: 'Reconnecting',
          semanticLabel: 'Live session, reconnecting. Open session',
          leading: Icon(TablerIcons.wifi_off, size: 14, color: c.mutedForeground),
          foreground: c.mutedForeground,
          border: c.border,
          onPressed: onOpen,
        );
      }
      if (!live.following) {
        return _LivePill(
          label: 'Live · paused',
          semanticLabel: 'Live session, not following. Open session',
          leading: Icon(TablerIcons.player_pause, size: 14, color: palette.highlight),
          foreground: palette.highlight,
          border: palette.highlight,
          onPressed: onOpen,
        );
      }
      return _LivePill(
        label: '${live.leading ? 'Leading' : 'Live'}${count > 0 ? ' · $count' : ''}',
        semanticLabel:
            '${live.leading ? 'Leading the live session' : 'Live session'}, ${peopleLabel(count)}. Open session',
        leading: PulseDot(color: palette.highlightForeground, size: 6),
        foreground: palette.highlightForeground,
        background: palette.highlight,
        border: palette.highlight,
        onPressed: onOpen,
      );
    }
    if (live.invite != null && online) {
      return _LivePill(
        label: 'Join live',
        semanticLabel: 'The team is live. Join',
        leading: PulseDot(color: palette.highlight, size: 6),
        foreground: palette.highlight,
        border: palette.highlight,
        onPressed: onGoLive,
      );
    }
    if (!online) return const SizedBox.shrink();
    return TopBarIconButton(icon: TablerIcons.broadcast, tooltip: 'Go live', onPressed: onGoLive);
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill({
    required this.label,
    required this.semanticLabel,
    required this.leading,
    required this.foreground,
    required this.border,
    required this.onPressed,
    this.background,
  });

  final String label;
  final String semanticLabel;
  final Widget leading;
  final Color foreground;
  final Color border;
  final Color? background;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s1),
    child: Pressable(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: DaloyRadii.all(DaloyRadii.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: DaloySpace.s1_5),
            Text(label.toUpperCase(), style: context.text.labelSmall!.copyWith(color: foreground, letterSpacing: 0.8)),
          ],
        ),
      ),
    ),
  );
}

// -- The session ---------------------------------------------------------------------

/// Who's in, whether you're following, and the way out.
Future<void> showLiveSessionSheet(
  BuildContext context, {
  required int lineUpId,
  required VoidCallback onLeft,
  required VoidCallback onEnded,
}) {
  final live = ProviderScope.containerOf(context).read(liveSessionControllerProvider(lineUpId));
  final by = live.session?.startedByUserName;
  return showPerformSheet<void>(
    context,
    title: 'Live session',
    description: by == null ? null : 'Started by $by',
    builder: (_) => _LiveSession(lineUpId: lineUpId, onLeft: onLeft, onEnded: onEnded),
  );
}

class _LiveSession extends ConsumerWidget {
  const _LiveSession({required this.lineUpId, required this.onLeft, required this.onEnded});

  final int lineUpId;
  final VoidCallback onLeft;

  /// Ended for everyone from here.
  final VoidCallback onEnded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final live = ref.watch(liveSessionControllerProvider(lineUpId));
    final controller = ref.read(liveSessionControllerProvider(lineUpId).notifier);
    final autoReturn = ref.watch(performPrefsProvider).value?.liveAutoReturn ?? true;
    final me = ref.watch(sessionControllerProvider).value?.user.id;

    if (!live.isIn) {
      // Ended while the sheet was open.
      return Padding(
        padding: const EdgeInsets.only(bottom: DaloySpace.s2),
        child: Text('The session has ended.', style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (live.status == LiveStatus.reconnecting) ...[
          _Notice(
            icon: TablerIcons.wifi_off,
            text: 'Reconnecting. Your chart keeps working, and you’ll catch up with the team when you’re back.',
          ),
          const SizedBox(height: DaloySpace.s5),
        ],
        PerformSheetLabel('In the session · ${live.count}'),
        if (live.participants.isEmpty)
          Text('Just a moment…', style: context.text.bodySmall!.copyWith(color: c.mutedForeground))
        else
          Wrap(
            spacing: DaloySpace.s1_5,
            runSpacing: DaloySpace.s1_5,
            children: [
              for (final p in live.participants)
                _Person(
                  name: [p.name, if (p.userId == me) '(you)', if (p.userId == live.leaderId) '· leading'].join(' '),
                  initials: workspaceInitials(p.name),
                ),
            ],
          ),
        const SizedBox(height: DaloySpace.s5),
        const PerformSheetLabel('Leading'),
        _Leading(state: live, controller: controller),
        const SizedBox(height: DaloySpace.s5),
        const PerformSheetLabel('Moving together'),
        PerformSwitchGroup(
          children: [
            PerformSwitchRow(
              label: 'Follow live',
              detail: live.isLed
                  ? 'Move with the leader.'
                  : 'Move with the team. Changing songs or sections moves them too.',
              value: live.following,
              onChanged: controller.setFollowing,
            ),
            PerformSwitchRow(
              label: 'Back to live on its own',
              detail: 'Following a leader: after you scroll away, return when you’ve been still for a few seconds.',
              value: autoReturn,
              onChanged: ref.read(performPrefsRepositoryProvider).setLiveAutoReturn,
            ),
          ],
        ),
        const SizedBox(height: DaloySpace.s6),
        DaloyButton.outline(
          label: 'Leave session',
          icon: TablerIcons.logout,
          expand: true,
          onPressed: () {
            Navigator.of(context).pop();
            unawaited(controller.leave());
            onLeft();
          },
        ),
        const SizedBox(height: DaloySpace.s2),
        DaloyButton(
          label: 'End for everyone',
          variant: ButtonVariant.ghost,
          expand: true,
          onPressed: () async {
            final end = await confirmInPerform(
              context,
              title: 'End the session for everyone?',
              body: 'Everyone keeps their chart, but they stop moving together.',
              confirm: 'End session',
              destructive: true,
            );
            if (end != true || !context.mounted) return;
            Navigator.of(context).pop();
            unawaited(controller.endForAll());
            onEnded();
          },
        ),
      ],
    );
  }
}

/// Shared by default; anyone can take the lead, and take it over.
class _Leading extends StatelessWidget {
  const _Leading({required this.state, required this.controller});

  final LiveState state;
  final LiveSessionController controller;

  Future<void> _run(BuildContext context, Future<bool> Function() action) async {
    unawaited(HapticFeedback.selectionClick());
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (!await action()) {
      showDaloyToast(messenger, 'That didn’t go through. Check your connection.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final (text, label, action) = state.leading
        ? ('You’re leading. Only your moves go to the team.', 'Stop leading', controller.stepDown)
        : state.isLed
        ? ('${state.leaderName ?? 'Someone'} is leading. Their moves go to everyone.', 'Take over', controller.takeLead)
        : ('No one is leading: everyone following moves the team.', 'Lead the session', controller.takeLead);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(text, style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
        const SizedBox(height: DaloySpace.s2),
        DaloyButton.outline(
          label: label,
          icon: state.leading ? TablerIcons.flag_off : TablerIcons.flag,
          expand: true,
          onPressed: () => _run(context, action),
        ),
      ],
    );
  }
}

class _Person extends StatelessWidget {
  const _Person({required this.name, required this.initials});

  final String name;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      height: 36,
      padding: const EdgeInsets.only(left: 4, right: DaloySpace.s3),
      decoration: BoxDecoration(color: c.muted, borderRadius: DaloyRadii.all(DaloyRadii.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: c.primary.withValues(alpha: 0.14),
            child: Text(initials, style: context.text.labelSmall!.copyWith(color: c.primaryInk)),
          ),
          const SizedBox(width: DaloySpace.s2),
          Text(name, style: context.text.labelLarge),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(DaloySpace.s3),
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: c.mutedForeground),
          const SizedBox(width: DaloySpace.s2),
          Expanded(
            child: Text(text, style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
          ),
        ],
      ),
    );
  }
}

// -- Cues ------------------------------------------------------------------------------

/// The cues as a chat on a phone: a tall sheet over the chart. Stays open
/// as you send; swipe down to get back to Perform.
Future<void> showCueChat(BuildContext context, {required int lineUpId, required ValueChanged<bool> onSent}) {
  return showPerformModal<void>(
    context,
    builder: (themed) {
      final c = themed.colors;
      final media = MediaQuery.of(themed);
      return Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SizedBox(
          height: (media.size.height - media.padding.top - media.viewInsets.bottom) * 0.85,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.cueSurface,
              border: Border.all(color: c.cueEdge),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(DaloyRadii.xl3)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(DaloyRadii.xl3)),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: DaloySpace.s2),
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(color: c.border, borderRadius: DaloyRadii.all(DaloyRadii.full)),
                    ),
                  ),
                  Expanded(
                    child: CueChat(lineUpId: lineUpId, onSent: onSent, onClose: () => Navigator.of(themed).pop()),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// The cues, docked beside the chart on a tablet, as a chat: the session's
/// cues above (yours on the right, the team's on the left, late joiners
/// included), the way to send one below. Its left edge drags to resize.
class CuePanel extends ConsumerWidget {
  const CuePanel({
    super.key,
    required this.lineUpId,
    required this.width,
    required this.onSent,
    required this.onClose,
    required this.onResize,
    required this.onResizeEnd,
  });

  final int lineUpId;
  final double width;
  final ValueChanged<bool> onSent;
  final VoidCallback onClose;

  /// The drag's change in width (positive widens), while it moves and when it lets go.
  final ValueChanged<double> onResize;
  final VoidCallback onResizeEnd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final media = MediaQuery.of(context);

    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.cueSurface,
                border: Border(left: BorderSide(color: c.cueEdge)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: media.padding.top,
                  right: media.padding.right,
                  bottom: media.padding.bottom + media.viewInsets.bottom,
                ),
                child: CueChat(lineUpId: lineUpId, onSent: onSent, onClose: onClose),
              ),
            ),
          ),
          // The left edge: drag to make the panel wider or narrower.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 20,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (d) => onResize(-d.delta.dx),
                onHorizontalDragEnd: (_) => onResizeEnd(),
                onHorizontalDragCancel: onResizeEnd,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 4,
                    height: 44,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: c.mutedForeground.withValues(alpha: 0.35),
                      borderRadius: DaloyRadii.all(DaloyRadii.full),
                    ),
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

/// The chat itself, wherever it lives (the tablet's panel, the phone's
/// sheet): the session's cues above, who's typing, the way to send below.
class CueChat extends ConsumerWidget {
  const CueChat({super.key, required this.lineUpId, required this.onSent, required this.onClose});

  final int lineUpId;
  final ValueChanged<bool> onSent;
  final VoidCallback onClose;

  static bool _sameSender(LiveCue a, LiveCue b) =>
      a.senderId != null ? a.senderId == b.senderId : a.senderName == b.senderName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cues = ref.watch(liveSessionControllerProvider(lineUpId).select((s) => s.cues));
    final typing = ref.watch(liveSessionControllerProvider(lineUpId).select((s) => s.typing));
    final me = ref.watch(sessionControllerProvider.select((s) => s.value?.user));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(DaloySpace.s4, DaloySpace.s3, DaloySpace.s2, DaloySpace.s2),
          child: Row(
            children: [
              Expanded(child: Text('Cues', style: context.text.titleMedium)),
              IconButton(tooltip: 'Close cues', onPressed: onClose, icon: const Icon(TablerIcons.x, size: 18)),
            ],
          ),
        ),
        const Hairline(),
        Expanded(
          child: cues.isEmpty && typing.isEmpty
              ? const Center(
                  child: Padding(padding: EdgeInsets.all(DaloySpace.s6), child: _NoCues(centered: true)),
                )
              : ListView.builder(
                  // Newest at the bottom, where the eye (and the keys) are.
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s3),
                  itemCount: cues.length + (typing.isEmpty ? 0 : 1),
                  itemBuilder: (_, i) {
                    if (typing.isNotEmpty) {
                      if (i == 0) return _TypingBubble(people: typing);
                      i -= 1;
                    }
                    final index = cues.length - 1 - i;
                    final cue = cues[index];
                    final previous = index > 0 ? cues[index - 1] : null;
                    final mine = cue.senderId != null
                        ? cue.senderId == me?.id
                        : cue.senderName != null && cue.senderName == me?.name;
                    return _CueBubble(cue: cue, mine: mine, continued: previous != null && _sameSender(previous, cue));
                  },
                ),
        ),
        const Hairline(),
        _ChatInput(lineUpId: lineUpId, onSent: onSent),
      ],
    );
  }
}

/// "Maria is typing" with three dots breathing in a bubble, on the team's side.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble({required this.people});

  final List<LiveParticipant> people;

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _label {
    final names = widget.people.map((p) => p.name).toList();
    return switch (names.length) {
      1 => '${names[0]} is typing',
      2 => '${names[0]} and ${names[1]} are typing',
      _ => '${names.length} people are typing',
    };
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: DaloySpace.s3),
      child: Semantics(
        liveRegion: true,
        label: _label,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: DaloySpace.s2, bottom: 2),
              child: Text(_label, style: context.text.bodySmall!.copyWith(color: c.mutedForeground)),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: c.cueBubble,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DaloyRadii.xl),
                  topRight: Radius.circular(DaloyRadii.xl),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(DaloyRadii.xl),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s3),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 0 : 4),
                          child: Opacity(
                            // Each dot a third of a beat behind the last.
                            opacity: 0.35 + 0.65 * (0.5 + 0.5 * math.sin((_controller.value - i / 3) * 2 * math.pi)),
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(color: c.mutedForeground, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One cue in the chat. Emoji stand on their own, big; everything else sits
/// in a bubble — [mine] on the right, in the accent, the team's on the left
/// under their name.
class _CueBubble extends StatelessWidget {
  const _CueBubble({required this.cue, required this.mine, required this.continued});

  final LiveCue cue;
  final bool mine;

  /// Same sender as the cue above: no name repeated, tighter gap.
  final bool continued;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = context.text;
    final showName = !mine && !continued && cue.senderName != null;

    return Padding(
      padding: EdgeInsets.only(top: continued ? DaloySpace.s1 : DaloySpace.s3),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showName)
            Padding(
              padding: const EdgeInsets.only(left: DaloySpace.s2, bottom: 2),
              child: Text(cue.senderName!, style: text.bodySmall!.copyWith(color: c.mutedForeground)),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.5),
            child: cue.isEmoji
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s2),
                    child: Text(cue.body, style: const TextStyle(fontSize: 32)),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: mine ? c.primary : c.cueBubble,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(DaloyRadii.xl),
                        topRight: const Radius.circular(DaloyRadii.xl),
                        bottomLeft: Radius.circular(mine ? DaloyRadii.xl : 4),
                        bottomRight: Radius.circular(mine ? 4 : DaloyRadii.xl),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2),
                      child: Text(
                        cue.body,
                        style: (cue.kind == LiveCueKind.preset ? text.titleSmall : text.bodyMedium)!.copyWith(
                          color: mine ? c.primaryForeground : c.foreground,
                        ),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: DaloySpace.s2, right: DaloySpace.s2),
            child: Text(
              cueAge(cue.createdAt, DateTime.now()),
              style: text.bodySmall!.copyWith(color: c.mutedForeground, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// The chat's bottom: one scrolling row of calls and emoji, then a line of text.
class _ChatInput extends ConsumerStatefulWidget {
  const _ChatInput({required this.lineUpId, required this.onSent});

  final int lineUpId;
  final ValueChanged<bool> onSent;

  @override
  ConsumerState<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<_ChatInput> {
  static const _chipHeight = 36.0;

  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send(LiveCueKind kind, String body) {
    if (body.trim().isEmpty) return;
    unawaited(HapticFeedback.mediumImpact());
    final controller = ref.read(liveSessionControllerProvider(widget.lineUpId).notifier);
    if (kind == LiveCueKind.text) _text.clear();
    unawaited(controller.sendCue(kind, body).then(widget.onSent));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final chips = [
      for (final preset in liveCuePresets)
        _CueChip(label: preset.label, onPressed: () => _send(LiveCueKind.preset, preset.body)),
      for (final emoji in liveEmojiCues)
        _CueChip(label: emoji, emoji: true, onPressed: () => _send(LiveCueKind.emoji, emoji)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 2 * _chipHeight + DaloySpace.s2 + 2 * DaloySpace.s2,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3, vertical: DaloySpace.s2),
            children: [
              // Two chips to a column, widest sets the column, so the rows line up.
              for (var i = 0; i < chips.length; i += 2)
                Padding(
                  padding: const EdgeInsets.only(right: DaloySpace.s2),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        chips[i],
                        if (i + 1 < chips.length) ...[const SizedBox(height: DaloySpace.s2), chips[i + 1]],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(DaloySpace.s3, 0, DaloySpace.s3, DaloySpace.s3),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  maxLength: 500,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      ref.read(liveSessionControllerProvider(widget.lineUpId).notifier).typing();
                    }
                  },
                  onSubmitted: (value) => _send(LiveCueKind.text, value),
                  decoration: const InputDecoration(hintText: 'Message the team', counterText: ''),
                ),
              ),
              const SizedBox(width: DaloySpace.s2),
              ListenableBuilder(
                listenable: _text,
                builder: (context, _) => IconButton.filled(
                  tooltip: 'Send',
                  onPressed: _text.text.trim().isEmpty ? null : () => _send(LiveCueKind.text, _text.text),
                  style: IconButton.styleFrom(backgroundColor: c.primary, foregroundColor: c.primaryForeground),
                  icon: const Icon(TablerIcons.send, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CueChip extends StatelessWidget {
  const _CueChip({required this.label, required this.onPressed, this.emoji = false});

  final String label;
  final bool emoji;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onPressed: onPressed,
      semanticLabel: 'Send $label',
      child: Container(
        height: _ChatInputState._chipHeight,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s3),
        decoration: BoxDecoration(
          color: c.cueBubble,
          border: Border.all(color: c.cueEdge),
          borderRadius: DaloyRadii.all(DaloyRadii.full),
        ),
        child: Text(
          label,
          style: emoji ? const TextStyle(fontSize: 18) : context.text.labelLarge!.copyWith(color: c.foreground),
        ),
      ),
    );
  }
}

class _NoCues extends StatelessWidget {
  const _NoCues({this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) => Text(
    'Nothing yet. Cues you and the team send show up here.',
    textAlign: centered ? TextAlign.center : null,
    style: context.text.bodySmall!.copyWith(color: context.colors.mutedForeground),
  );
}

/// The cue chat's surfaces, mixed from the Perform palette's ink so they hold
/// on every theme (paper and e-ink included). The chart's own background and
/// hairline vanish beside it, so the panel sits a step off the chart, with a
/// visible edge, and the team's bubbles a clear step off the panel.
extension on DaloyColors {
  Color get cueSurface => Color.alphaBlend(foreground.withValues(alpha: 0.04), background);
  Color get cueBubble => Color.alphaBlend(foreground.withValues(alpha: 0.1), cueSurface);
  Color get cueEdge => foreground.withValues(alpha: 0.14);
}

/// "now", "3 min", "1 h".
String cueAge(DateTime at, DateTime now) {
  final minutes = now.difference(at).inMinutes;
  if (minutes < 1) return 'now';
  if (minutes < 60) return '$minutes min';
  return '${minutes ~/ 60} h';
}

/// A cue from the team, big enough to read from a music stand: the
/// theme's highlight, under the chrome (or the top edge when it's hidden).
/// It leaves on its own; a tap opens the cue pad.
class LiveCueBanner extends StatefulWidget {
  const LiveCueBanner({super.key, required this.cue, required this.onOpen, required this.onDone});

  static const showFor = Duration(seconds: 6);

  final LiveCue? cue;
  final VoidCallback onOpen;
  final VoidCallback onDone;

  @override
  State<LiveCueBanner> createState() => _LiveCueBannerState();
}

class _LiveCueBannerState extends State<LiveCueBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _arm();
  }

  @override
  void didUpdateWidget(LiveCueBanner old) {
    super.didUpdateWidget(old);
    if (old.cue?.id != widget.cue?.id) _arm();
  }

  void _arm() {
    _timer?.cancel();
    if (widget.cue != null) _timer = Timer(LiveCueBanner.showFor, widget.onDone);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = PerformPaletteScope.of(context);
    final still = palette.flat || MediaQuery.disableAnimationsOf(context);
    final cue = widget.cue;

    return AnimatedSwitcher(
      duration: still ? Duration.zero : DaloyMotion.medium,
      switchInCurve: DaloyMotion.ease,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.3), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: cue == null
          ? const SizedBox.shrink()
          : Semantics(
              key: ValueKey(cue.id),
              liveRegion: true,
              label: '${cue.senderName ?? 'Team'}: ${cue.body}',
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Pressable(
                  onPressed: widget.onOpen,
                  pressedScale: 0.98,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s3, DaloySpace.s5, DaloySpace.s3_5),
                    decoration: BoxDecoration(
                      color: palette.highlight,
                      borderRadius: DaloyRadii.all(DaloyRadii.xl2),
                      boxShadow: palette.flat
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (cue.senderName != null)
                          Text(
                            cue.senderName!,
                            style: context.text.labelMedium!.copyWith(
                              color: palette.highlightForeground.withValues(alpha: 0.8),
                            ),
                          ),
                        Text(
                          cue.body,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: cue.isEmoji
                              ? const TextStyle(fontSize: 44, height: 1.2)
                              : context.text.headlineSmall!.copyWith(
                                  color: palette.highlightForeground,
                                  fontWeight: FontWeight.w700,
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

// -- Drifted ----------------------------------------------------------------------------

/// "Back to live", floating above the transport while you've scrolled away
/// from where the team is.
class BackToLivePill extends ConsumerWidget {
  const BackToLivePill({super.key, required this.lineUpId});

  final int lineUpId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveSessionControllerProvider(lineUpId));
    final perform = ref.watch(performControllerProvider(PerformSource.lineUp(lineUpId)));
    final position = live.position;
    final show = live.drifted && position != null && (live.missed || position.songIndex != perform.songIndex);
    final palette = PerformPaletteScope.of(context);
    final still = palette.flat || MediaQuery.disableAnimationsOf(context);

    String? where;
    if (show && position.songIndex < perform.songs.length) {
      final song = perform.songs[position.songIndex];
      final sectionId = position.sectionFor(perform.viewMode);
      final i = song.sections.indexWhere((s) => s.id == sectionId);
      where = [
        '${position.songIndex + 1}. ${song.row.title}',
        if (i >= 0) sectionChipLabel(song.sections[i], i),
      ].join(' · ');
    }

    return AnimatedSwitcher(
      duration: still ? Duration.zero : DaloyMotion.medium,
      child: !show
          ? const SizedBox.shrink()
          : Pressable(
              key: const ValueKey('back-to-live'),
              semanticLabel: 'Back to live${where == null ? '' : ', $where'}',
              onPressed: () {
                unawaited(HapticFeedback.selectionClick());
                ref.read(liveSessionControllerProvider(lineUpId).notifier).backToLive();
              },
              child: PerformGlass(
                borderRadius: DaloyRadii.all(DaloyRadii.full),
                border: Border.all(color: palette.highlight),
                child: Container(
                  height: 44,
                  constraints: const BoxConstraints(maxWidth: 360),
                  padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(TablerIcons.arrow_back_up, size: 16, color: palette.highlight),
                      const SizedBox(width: DaloySpace.s2),
                      Text(
                        'Back to live',
                        style: context.text.labelLarge!.copyWith(color: palette.highlight).weight(FontWeight.w700),
                      ),
                      if (where != null) ...[
                        const SizedBox(width: DaloySpace.s2),
                        Flexible(
                          child: Text(
                            where,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall!.copyWith(color: context.colors.mutedForeground),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// -- Dialogs ------------------------------------------------------------------------------

/// A yes/no in Perform's theme. True when confirmed.
Future<bool?> confirmInPerform(
  BuildContext context, {
  required String title,
  String? body,
  required String confirm,
  String cancel = 'Cancel',
  bool destructive = false,
}) => confirmAlert(
  context,
  title: title,
  message: body,
  confirmLabel: confirm,
  cancelLabel: cancel,
  destructive: destructive,
  // Drawn in Perform's palette, so not UIKit's.
  native: false,
  wrap: (child) => PerformThemed(child: child),
);
