import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/daloy_alert.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/sheet_frame.dart';
import '../../workspaces/data/workspaces_repository.dart';
import '../application/team_actions.dart';
import '../data/team_service.dart';
import '../domain/team_models.dart';

/// The workspace's join link: off until an admin turns it on, then a link
/// they can share, copy or show as a QR code in the room. It lasts a week;
/// turning it off kills the old link.
class JoinLinkCard extends ConsumerWidget {
  const JoinLinkCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = ref.watch(workspaceJoinLinkProvider);
    return link.when(
      skipLoadingOnRefresh: true,
      loading: () => const SizedBox(height: 120, child: Center(child: DaloySpinner())),
      error: (e, _) => InsetPlaceholder(
        icon: TablerIcons.wifi_off,
        title: "Couldn't load the join link",
        action: DaloyButton.outline(label: 'Try again', onPressed: () => ref.invalidate(workspaceJoinLinkProvider)),
      ),
      data: (data) => data.enabled ? _OnCard(link: data) : const _OffCard(),
    );
  }
}

void _toast(BuildContext context, String message) => showDaloyToast(ScaffoldMessenger.of(context), message);

class _OffCard extends ConsumerStatefulWidget {
  const _OffCard();

  @override
  ConsumerState<_OffCard> createState() => _OffCardState();
}

class _OffCardState extends ConsumerState<_OffCard> {
  bool _pending = false;

  Future<void> _enable() async {
    setState(() => _pending = true);
    try {
      await ref.read(teamActionsProvider.notifier).enableJoinLink();
      await HapticFeedback.mediumImpact();
    } on ApiException catch (e) {
      if (mounted) _toast(context, apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) => InsetPlaceholder(
    icon: TablerIcons.link,
    title: 'Let people join with a link',
    body: 'Anyone who opens it can join as a member. Share it, or show the QR code to the room.',
    action: DaloyButton(label: 'Turn on join link', icon: TablerIcons.link, loading: _pending, onPressed: _enable),
  );
}

class _OnCard extends ConsumerStatefulWidget {
  const _OnCard({required this.link});

  final JoinLink link;

  @override
  ConsumerState<_OnCard> createState() => _OnCardState();
}

class _OnCardState extends ConsumerState<_OnCard> {
  bool _pending = false;

  String get _url => TeamService.joinUrl(widget.link);

  Future<void> _share(BuildContext buttonContext) async {
    final box = buttonContext.findRenderObject() as RenderBox?;
    final workspace = ref.read(activeWorkspaceProvider).value;
    await SharePlus.instance.share(
      ShareParams(
        uri: Uri.parse(_url),
        subject: workspace == null ? 'Join our Daloy workspace' : 'Join ${workspace.name} on Daloy',
        sharePositionOrigin: box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null,
      ),
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _url));
    await HapticFeedback.lightImpact();
    if (mounted) _toast(context, 'Join link copied.');
  }

  Future<void> _turnOff() async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Turn off the join link?',
      message: 'The current link and QR code stop working. You can make a new one any time.',
      confirmLabel: 'Turn off',
      cancelLabel: 'Keep it',
    );
    if (!confirmed || !mounted) return;
    setState(() => _pending = true);
    try {
      await ref.read(teamActionsProvider.notifier).revokeJoinLink();
    } on ApiException catch (e) {
      if (mounted) _toast(context, apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final expires = widget.link.expiresAt;
    return Container(
      padding: const EdgeInsets.all(DaloySpace.s4),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.border),
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(TablerIcons.link, size: 18, color: c.primaryInk),
              const SizedBox(width: DaloySpace.s2),
              Expanded(
                child: Text(
                  _url.replaceFirst('https://', ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium!.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          if (expires != null) ...[
            const SizedBox(height: DaloySpace.s1),
            Text(
              'Works until ${formatLineUpDate(isoDate(expires.toLocal()))}. People who open it join as members.',
              style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
            ),
          ],
          const SizedBox(height: DaloySpace.s4),
          Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (buttonContext) =>
                      DaloyButton(label: 'Share', icon: TablerIcons.share_2, onPressed: () => _share(buttonContext)),
                ),
              ),
              const SizedBox(width: DaloySpace.s2),
              Expanded(
                child: DaloyButton.outline(label: 'Copy', icon: TablerIcons.copy, onPressed: _copy),
              ),
            ],
          ),
          const SizedBox(height: DaloySpace.s2),
          Row(
            children: [
              Expanded(
                child: DaloyButton.outline(
                  label: 'QR code',
                  icon: TablerIcons.qrcode,
                  onPressed: () => showJoinQrSheet(context, url: _url),
                ),
              ),
              const SizedBox(width: DaloySpace.s2),
              Expanded(
                child: DaloyButton(
                  variant: ButtonVariant.destructive,
                  label: 'Turn off',
                  icon: TablerIcons.link_off,
                  loading: _pending,
                  onPressed: _turnOff,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The join link as a big QR code on white — scannable across a room, in
/// either theme.
Future<void> showJoinQrSheet(BuildContext context, {required String url}) => showDaloySheet<void>(
  context: context,
  fit: true,
  builder: (sheetContext) {
    final side = (MediaQuery.sizeOf(sheetContext).shortestSide - DaloySpace.s5 * 2 - 48).clamp(180.0, 320.0);
    return SheetFrame(
      title: 'Scan to join',
      description: 'Point a phone camera here. Daloy opens and asks to join.',
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(DaloySpace.s6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: DaloyRadii.all(DaloyRadii.xl2)),
            child: Semantics(
              label: 'QR code for the join link',
              child: QrImageView(
                data: url,
                size: side,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  },
);
