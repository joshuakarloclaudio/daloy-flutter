import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_menu.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/daloy_top_bar.dart';

/// An exported PDF, full screen: pages to scroll and pinch, then Print (the
/// system dialog), Share (AirDrop, Files, Messages) or the same sheet as
/// plain text. Everything here works offline.
class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({
    super.key,
    required this.title,
    required this.fileName,
    required this.bytes,
    required this.text,
  });

  final String title;
  final String fileName;
  final Uint8List bytes;

  /// The sheet as plain text, built when asked for.
  final String Function() text;

  static Future<void> open(
    BuildContext context, {
    required String title,
    required String fileName,
    required Uint8List bytes,
    required String Function() text,
  }) => Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => PdfPreviewScreen(title: title, fileName: fileName, bytes: bytes, text: text),
    ),
  );

  Future<void> _print() => Printing.layoutPdf(onLayout: (_) async => bytes, name: fileName);

  Future<void> _share(Rect origin) => SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'application/pdf', name: fileName)],
      fileNameOverrides: [fileName],
      subject: title,
      sharePositionOrigin: origin,
    ),
  );

  Future<void> _shareText(Rect origin) =>
      SharePlus.instance.share(ShareParams(text: text(), subject: title, sharePositionOrigin: origin));

  Future<void> _copyText(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text()));
    await HapticFeedback.lightImpact();
    showDaloyToast(messenger, 'Copied as text.');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return Scaffold(
      backgroundColor: c.muted,
      appBar: DaloyTopBar(
        title: title,
        actions: [
          TopBarIconButton(icon: TablerIcons.printer, tooltip: 'Print', onPressed: _print),
          Builder(
            builder: (button) => TopBarIconButton(
              icon: isIOS ? TablerIcons.share_2 : TablerIcons.share,
              tooltip: 'Share PDF',
              onPressed: () => _share(anchorOf(button)),
            ),
          ),
          Builder(
            builder: (button) => DaloyMenuButton(
              tooltip: 'More',
              items: [
                DaloyMenuItem(
                  icon: TablerIcons.text_caption,
                  label: 'Share as Text',
                  onSelected: () => _shareText(anchorOf(button)),
                ),
                DaloyMenuItem(icon: TablerIcons.copy, label: 'Copy as Text', onSelected: () => _copyText(context)),
              ],
            ),
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) async => bytes,
        useActions: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: fileName,
        scrollViewDecoration: BoxDecoration(color: c.muted),
        pdfPreviewPageDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: DaloyRadii.all(DaloyRadii.sm),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4))],
        ),
        loadingWidget: const Center(child: DaloySpinner(size: 28)),
      ),
    );
  }
}
