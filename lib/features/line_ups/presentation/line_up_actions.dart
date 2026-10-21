import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/config/app_config.dart';
import '../../../core/connectivity/online_status.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/routes.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../export/presentation/export_actions.dart';
import '../../present/presentation/present_join_sheet.dart';
import '../application/line_up_detail_controller.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up.dart';

/// A line-up's actions — from a row's touch-and-hold, or the details
/// screen's ⋯ button ([onDetails]: Edit is already a button there). A
/// line-up that never reached the server can only be edited or discarded;
/// [error] is why the server last refused it, if it did.
List<DaloyMenuItem> lineUpMenuItems(
  BuildContext context,
  WidgetRef ref,
  LineUp lineUp, {
  String? error,
  bool onDetails = false,
}) {
  final edit = DaloyMenuItem(
    icon: TablerIcons.pencil,
    label: 'Edit',
    onSelected: () => context.push(Routes.lineUpEdit(lineUp.id)),
  );

  if (lineUp.isPending) {
    return [
      edit,
      DaloyMenuItem.divider,
      DaloyMenuItem(
        icon: TablerIcons.trash,
        label: 'Discard',
        destructive: true,
        onSelected: () => ref.read(lineUpsRepositoryProvider).discardPending(lineUp.id),
      ),
    ];
  }

  final live = ref.read(activeLiveSessionProvider).value?.lineUpId == lineUp.id;
  return [
    if (!onDetails) edit,
    DaloyMenuItem(
      icon: TablerIcons.adjustments_horizontal,
      label: 'Prepare notes & sections',
      onSelected: () => context.push(Routes.lineUpPrepare(lineUp.id)),
    ),
    DaloyMenuItem(
      icon: TablerIcons.device_mobile_share,
      label: 'Control a presentation…',
      onSelected: () => joinPresentation(context, ref),
    ),
    if (!live && ref.read(isOnlineProvider))
      DaloyMenuItem(
        icon: TablerIcons.broadcast,
        label: 'Go live',
        onSelected: () => context.push(Routes.performLive(lineUp.id)),
      ),
    DaloyMenuItem(
      icon: TablerIcons.share_2,
      label: 'Share link…',
      onSelected: () => shareLineUpLink(context, ref, lineUp),
    ),
    DaloyMenuItem(
      icon: TablerIcons.link,
      label: 'Copy share link',
      onSelected: () => copyLineUpLink(context, ref, lineUp),
    ),
    DaloyMenuItem(
      icon: TablerIcons.link_off,
      label: 'Revoke share link',
      onSelected: () => revokeLineUpLink(context, ref, lineUp),
    ),
    DaloyMenuItem.divider,
    DaloyMenuItem(
      icon: TablerIcons.file_export,
      label: 'Export…',
      onSelected: () => exportLineUp(context, ref, lineUp),
    ),
    DaloyMenuItem.divider,
    DaloyMenuItem(
      icon: TablerIcons.trash,
      label: 'Delete',
      destructive: true,
      onSelected: () => deleteLineUpWithUndo(context, ref, lineUp, leaveDetails: onDetails),
    ),
  ];
}

void _toast(
  ScaffoldMessengerState messenger,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) => showDaloyToast(messenger, message, actionLabel: actionLabel, onAction: onAction, duration: duration);

/// Turns the public link on (if it isn't) and returns its address, or tells
/// the user why not and returns null.
Future<Uri?> _resolveLink(BuildContext context, WidgetRef ref, LineUp lineUp, String verb) async {
  final messenger = ScaffoldMessenger.of(context);
  if (!ref.read(isOnlineProvider)) {
    _toast(messenger, 'Connect to the internet to $verb a share link.');
    return null;
  }
  final analytics = ref.read(analyticsProvider);
  try {
    final link = await ref.read(lineUpsServiceProvider).enableShareLink(lineUp.id);
    final path = link.sharePath;
    if (link.enabled && path != null) {
      unawaited(analytics.trackAndFlush(AnalyticsEvent.shareLinkCreated, properties: {'via': verb}));
      return Uri.parse('${AppConfig.siteUrl}$path');
    }
    _toast(messenger, "Couldn't create a share link.");
  } on NetworkException {
    _toast(messenger, 'Connect to the internet to $verb a share link.');
  } on ApiException {
    _toast(messenger, "Couldn't create a share link.");
  }
  return null;
}

/// The system share sheet with a read-only link anyone can open. [origin]
/// anchors the popover on iPad.
Future<void> shareLineUpLink(BuildContext context, WidgetRef ref, LineUp lineUp, {Rect? origin}) async {
  final url = await _resolveLink(context, ref, lineUp, 'share');
  if (url == null || !context.mounted) return;
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      uri: url,
      subject: lineUp.title,
      sharePositionOrigin: origin ?? (box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null),
    ),
  );
}

Future<void> copyLineUpLink(BuildContext context, WidgetRef ref, LineUp lineUp) async {
  final messenger = ScaffoldMessenger.of(context);
  final url = await _resolveLink(context, ref, lineUp, 'copy');
  if (url == null) return;
  await Clipboard.setData(ClipboardData(text: url.toString()));
  await HapticFeedback.lightImpact();
  _toast(messenger, 'Share link copied.');
}

Future<void> revokeLineUpLink(BuildContext context, WidgetRef ref, LineUp lineUp) async {
  final messenger = ScaffoldMessenger.of(context);
  if (!ref.read(isOnlineProvider)) {
    _toast(messenger, 'Connect to the internet to revoke a share link.');
    return;
  }
  try {
    await ref.read(lineUpsServiceProvider).revokeShareLink(lineUp.id);
    _toast(messenger, 'Share link revoked. The old link no longer opens.');
  } on NetworkException {
    _toast(messenger, 'Connect to the internet to revoke a share link.');
  } on ApiException {
    _toast(messenger, "Couldn't revoke the share link.");
  }
}

/// Removes the line-up now, with a few seconds to undo before the server
/// hears of it (the web's `deleteLineUpWithUndo`). [leaveDetails] pops its
/// details screen first; Undo brings that screen back.
Future<void> deleteLineUpWithUndo(
  BuildContext context,
  WidgetRef ref,
  LineUp lineUp, {
  bool leaveDetails = false,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  if (!ref.read(isOnlineProvider)) {
    _toast(messenger, 'Connect to the internet to delete line-ups.');
    return;
  }

  final deletions = ref.read(lineUpDeletionsProvider.notifier);
  if (leaveDetails && router.canPop()) router.pop();
  final started = await deletions.start(
    lineUp.id,
    onFailed: (message) => _toast(messenger, "Couldn't delete “${lineUp.title}”. $message"),
  );
  if (!started) return;
  await HapticFeedback.mediumImpact();

  _toast(
    messenger,
    'Deleted “${lineUp.title}”.',
    duration: LineUpDeletions.undoWindow,
    actionLabel: 'Undo',
    onAction: () async {
      await deletions.undo(lineUp.id);
      if (leaveDetails) unawaited(router.push(Routes.lineUp(lineUp.id)));
    },
  );
}
