import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/utils/platform.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../line_ups/domain/line_up.dart';
import '../../songs/domain/song.dart';
import '../application/export_sources.dart';
import '../data/pdf_export.dart';
import '../data/pptx_export.dart';
import '../domain/export_sheet.dart';
import 'export_sheet.dart';
import 'pdf_preview_screen.dart';

/// Export a song: pick chords or lyrics, then preview the PDF or share the slides.
Future<void> exportSong(BuildContext context, WidgetRef ref, Song song, {Rect? anchor}) async {
  final source = await songExportSource(ref, song);
  if (!context.mounted) return;
  await _export(context, source, ref.read(analyticsProvider), kind: 'song', anchor: anchor);
}

/// Export a line-up's whole set, in its keys and section order.
Future<void> exportLineUp(BuildContext context, WidgetRef ref, LineUp lineUp, {Rect? anchor}) async {
  final messenger = ScaffoldMessenger.of(context);
  final source = await lineUpExportSource(ref, lineUp);
  if (source == null) {
    showDaloyToast(
      messenger,
      lineUp.isEmpty
          ? 'Add songs to “${lineUp.title}” to export it.'
          : 'Open the line-up once online to export its songs.',
    );
    return;
  }
  if (!context.mounted) return;
  await _export(context, source, ref.read(analyticsProvider), kind: 'line_up', anchor: anchor);
}

Future<void> _export(
  BuildContext context,
  ExportSource source,
  Analytics analytics, {
  required String kind,
  Rect? anchor,
}) async {
  final set = source.set;
  final messenger = ScaffoldMessenger.of(context);
  // The share sheet needs somewhere to point on an iPad.
  final box = context.findRenderObject() as RenderBox?;
  final origin = anchor ?? (box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null);
  final choice = await showExportSheet(
    context,
    title: set.title,
    notation: source.notation,
    canShowNumbers: set.canShowNumbers,
    isLineUp: set.isLineUp,
    anchor: anchor,
  );
  if (choice == null || !context.mounted) return;
  unawaited(
    analytics.trackAndFlush(
      AnalyticsEvent.exported,
      properties: {
        'kind': kind,
        'format': switch (choice.format) {
          ExportFormat.chordsPdf => 'chords_pdf',
          ExportFormat.lyricsPdf => 'lyrics_pdf',
          ExportFormat.lyricsPptx => 'lyrics_pptx',
          ExportFormat.chordPro => 'chordpro',
          ExportFormat.chordProCopy => 'chordpro_copy',
        },
        if (choice.format == ExportFormat.chordsPdf) 'notation': choice.notation.name,
      },
    ),
  );
  final fileName = set.fileName(choice.format, notation: choice.notation);

  try {
    switch (choice.format) {
      case ExportFormat.chordsPdf || ExportFormat.lyricsPdf:
        final chords = choice.format == ExportFormat.chordsPdf;
        final bytes = await buildSheetPdf(set, chords: chords, notation: choice.notation, fonts: await PdfFonts.load());
        if (!context.mounted) return;
        unawaited(HapticFeedback.lightImpact());
        await PdfPreviewScreen.open(
          context,
          title: set.title,
          fileName: fileName,
          bytes: bytes,
          text: () => exportText(set, chords: chords, notation: choice.notation),
        );
      case ExportFormat.chordPro:
        await _deliver(
          bytes: Uint8List.fromList(utf8.encode(chordProText(set))),
          mimeType: 'text/plain',
          fileName: fileName,
          title: set.title,
          origin: origin,
        );
      case ExportFormat.chordProCopy:
        await Clipboard.setData(ClipboardData(text: chordProText(set)));
        unawaited(HapticFeedback.lightImpact());
        showDaloyToast(messenger, 'Copied as ChordPro.');
      case ExportFormat.lyricsPptx:
        final bytes = buildLyricsPptx(set);
        await _deliver(
          bytes: bytes,
          mimeType: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
          fileName: fileName,
          title: set.title,
          origin: origin,
        );
    }
  } on Object catch (e, stack) {
    FlutterError.reportError(FlutterErrorDetails(exception: e, stack: stack, library: 'export'));
    showDaloyToast(messenger, "Couldn't export “${set.title}”. Try again.");
  }
}

/// Hand a generated file to the user: the Save As dialog on Windows, where the
/// share sheet has nowhere to put it, the system share sheet elsewhere.
Future<void> _deliver({
  required Uint8List bytes,
  required String mimeType,
  required String fileName,
  required String title,
  required Rect? origin,
}) async {
  if (isWindows) {
    await FilePicker.saveFile(fileName: fileName, bytes: bytes, mimeType: mimeType, dialogTitle: 'Save $fileName');
    return;
  }
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: mimeType, name: fileName)],
      fileNameOverrides: [fileName],
      subject: title,
      sharePositionOrigin: origin,
    ),
  );
}
