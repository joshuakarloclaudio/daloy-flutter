import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/router/incoming_link.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../core/utils/platform.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/sheet_frame.dart';

/// Scan a workspace's join QR code (or paste its link) and open the join
/// screen for it. The Mac has no camera to point, so there it only pastes.
Future<void> showJoinScanner(BuildContext context) {
  final router = GoRouter.of(context);
  return showDaloySheet<void>(
    context: context,
    fit: true,
    builder: (_) => _JoinScannerSheet(router: router),
  );
}

/// The join or invitation screen a scanned or pasted [text] points at, or null.
String? joinRouteFor(String text) {
  final route = routeForIncomingLink(text.trim());
  return route != null && Routes.isJoin(route) ? route : null;
}

class _JoinScannerSheet extends StatefulWidget {
  const _JoinScannerSheet({required this.router});

  final GoRouter router;

  @override
  State<_JoinScannerSheet> createState() => _JoinScannerSheetState();
}

class _JoinScannerSheetState extends State<_JoinScannerSheet> {
  final _controller = isMacOS
      ? null
      : MobileScannerController(formats: const [BarcodeFormat.qrCode], detectionSpeed: DetectionSpeed.noDuplicates);
  bool _handled = false;
  String? _hint;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _open(String text) async {
    if (_handled) return;
    final route = joinRouteFor(text);
    if (route == null) {
      await HapticFeedback.heavyImpact();
      if (mounted) setState(() => _hint = 'That isn’t a Daloy join code.');
      return;
    }
    _handled = true;
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    Navigator.of(context).pop();
    await widget.router.push(route);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) {
      if (mounted) setState(() => _hint = 'Copy the join link first, then paste it.');
      return;
    }
    await _open(text);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final side = (MediaQuery.sizeOf(context).shortestSide - DaloySpace.s5 * 2).clamp(220.0, 420.0);
    final controller = _controller;
    if (controller == null) {
      return SheetFrame(
        title: 'Join a workspace',
        description: 'Copy the join link an admin shared, then paste it here.',
        children: [
          if (_hint != null) ...[
            Text(
              _hint!,
              textAlign: TextAlign.center,
              style: context.text.bodySmall!.copyWith(color: c.destructive),
            ),
            const SizedBox(height: DaloySpace.s4),
          ],
          DaloyButton(
            label: 'Paste link',
            icon: TablerIcons.clipboard,
            size: ControlSize.lg,
            expand: true,
            onPressed: _paste,
          ),
        ],
      );
    }
    return SheetFrame(
      title: 'Scan to join',
      description: 'Point the camera at the QR code an admin is showing.',
      children: [
        Center(
          child: SizedBox.square(
            dimension: side,
            child: ClipRRect(
              borderRadius: DaloyRadii.all(DaloyRadii.xl2),
              child: MobileScanner(
                controller: controller,
                onDetect: (capture) {
                  final value = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
                  if (value != null) _open(value);
                },
                errorBuilder: (context, error) => ColoredBox(
                  color: c.muted,
                  child: Padding(
                    padding: const EdgeInsets.all(DaloySpace.s5),
                    child: Center(
                      child: Text(
                        error.errorCode == MobileScannerErrorCode.permissionDenied
                            ? 'Camera access is off. Turn it on in Settings, or paste the link instead.'
                            : 'The camera isn’t available. Paste the link instead.',
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium!.copyWith(color: c.mutedForeground),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_hint != null) ...[
          const SizedBox(height: DaloySpace.s3),
          Text(
            _hint!,
            textAlign: TextAlign.center,
            style: context.text.bodySmall!.copyWith(color: c.destructive),
          ),
        ],
        const SizedBox(height: DaloySpace.s4),
        DaloyButton.outline(
          label: 'Paste a link instead',
          icon: TablerIcons.clipboard,
          size: ControlSize.lg,
          expand: true,
          onPressed: _paste,
        ),
      ],
    );
  }
}
