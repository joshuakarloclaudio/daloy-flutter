import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_sheet.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/hairline.dart';
import '../../../shared/widgets/mode_button.dart';
import '../../../shared/widgets/settings_group.dart';
import '../../../shared/widgets/sheet_nav_bar.dart';
import '../../../shared/widgets/suggestion_pill.dart';
import '../application/create_song_controller.dart';
import '../chart/chordpro.dart';
import '../data/songs_repository.dart';
import '../domain/new_song.dart';
import 'widgets/song_artwork.dart';
import 'widgets/song_field_sheets.dart';
import 'widgets/song_music_tile.dart';

/// Presents the new-song sheet. Resolves to the new song's local id once it is
/// saved on this device, or null if dismissed.
Future<int?> showNewSongSheet(BuildContext context) => showDaloySheet<int>(
  context: context,
  toolbar: true,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (_) => const _NewSongSheet(),
);

/// Cancel · New song · Save, then only what a song needs to exist, laid out
/// like the song's edit screen: a preview of the song as it's typed, Details
/// (title, artist) and Music (key · tempo · time as tiles opening the same
/// pickers). Chords and lyrics are added afterwards, unless a ChordPro file
/// brings them. Saving never waits on the network — the song lands in the
/// library at once.
class _NewSongSheet extends ConsumerStatefulWidget {
  const _NewSongSheet();

  @override
  ConsumerState<_NewSongSheet> createState() => _NewSongSheetState();
}

class _NewSongSheetState extends ConsumerState<_NewSongSheet> {
  static const _suggestionLimit = 5;

  /// The new song has no id yet, so the preview borrows a fixed palette.
  static const _previewId = 0;

  final _title = TextEditingController();
  final _artist = TextEditingController();
  final _artistFocus = FocusNode();

  String? _key;
  String _bpm = '';
  String? _timeSignature;
  bool _saving = false;

  /// What a ChordPro import brought: the chart and lyrics, and where from.
  ChordProSong? _imported;
  String? _importedFrom;

  @override
  void initState() {
    super.initState();
    _title.addListener(() => setState(() {}));
    _artist.addListener(() => setState(() {}));
    _artistFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _artist.dispose();
    _artistFocus.dispose();
    super.dispose();
  }

  bool get _canSave => NewSong.isValidTitle(_title.text) && !_saving;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    final artist = _artist.text.trim();
    final id = await ref
        .read(createSongProvider.notifier)
        .submit(
          NewSong(
            title: _title.text.trim(),
            artist: artist.isEmpty ? null : artist,
            key: _key,
            // The tempo sheet only hands back a tempo in range.
            bpm: int.tryParse(_bpm),
            timeSignature: _timeSignature,
            content: _blank(_imported?.content),
            lyrics: _blank(_imported?.lyrics),
          ),
        );
    await HapticFeedback.mediumImpact();
    if (mounted) Navigator.of(context).pop(id);
  }

  static String? _blank(String? v) => v == null || v.trim().isEmpty ? null : v;

  /// Fills the form from ChordPro text: what the file says replaces what's typed.
  void _importChordPro(String text, {String? fileName}) {
    final messenger = ScaffoldMessenger.of(context);
    final parsed = parseChordPro(text);
    if (parsed.isEmpty) {
      showDaloyToast(
        messenger,
        fileName == null ? 'No ChordPro song on the clipboard.' : 'No song in $fileName we can read.',
      );
      return;
    }
    final fallbackTitle = fileName?.replaceFirst(RegExp(r'\.[^.]+$'), '').trim() ?? '';
    final title = parsed.title ?? (_title.text.trim().isEmpty ? fallbackTitle : _title.text.trim());
    _title.value = TextEditingValue(
      text: title,
      selection: TextSelection.collapsed(offset: title.length),
    );
    if (parsed.artist case final artist?) _artist.text = artist;
    setState(() {
      _key = parsed.key ?? _key;
      _bpm = parsed.bpm?.toString() ?? _bpm;
      _timeSignature = parsed.timeSignature ?? _timeSignature;
      _imported = parsed;
      _importedFrom = fileName;
    });
    if (parsed.skippedSongs > 0) {
      showDaloyToast(messenger, 'Imported the first song. ${parsed.skippedSongs} more in the file were left out.');
    }
  }

  Future<void> _chooseChordProFile() async {
    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    // Any type: Android filters custom extensions by MIME type, and `.cho` has none.
    final files = await FilePicker.pickFiles();
    final file = files.firstOrNull;
    if (file == null || !mounted) return;
    try {
      _importChordPro(utf8.decode(await file.readAsBytes(), allowMalformed: true), fileName: file.name);
    } on Object {
      showDaloyToast(messenger, "Couldn't read ${file.name}.");
    }
  }

  Future<void> _pasteChordPro() async {
    FocusScope.of(context).unfocus();
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (!mounted) return;
    if (!looksLikeChordPro(text)) {
      showDaloyToast(ScaffoldMessenger.of(context), 'Copy a ChordPro song first, then paste it here.');
      return;
    }
    _importChordPro(text);
  }

  String get _importSummary {
    final imported = _imported!;
    final parts = [if (imported.content.isNotEmpty) 'chart', if (imported.lyrics.isNotEmpty) 'lyrics'];
    final what = parts.isEmpty ? 'details only' : parts.join(' and ');
    return '${_importedFrom ?? 'From the clipboard'} · $what';
  }

  Future<void> _pickKey() async {
    FocusScope.of(context).unfocus();
    final picked = await showSongKeyPicker(context, _key);
    if (picked != null) setState(() => _key = picked.value);
  }

  Future<void> _pickTempo() async {
    FocusScope.of(context).unfocus();
    final picked = await showTempoSheet(context, _bpm);
    if (picked != null) setState(() => _bpm = picked.bpm);
  }

  Future<void> _pickTimeSignature() async {
    FocusScope.of(context).unfocus();
    final picked = await showTimeSignaturePicker(context, _timeSignature);
    if (picked != null) setState(() => _timeSignature = picked.value);
  }

  /// Matching artists already in the library — everything most-used first
  /// while the field is empty, then whatever contains what's typed.
  List<String> _suggestions(List<String> artists) {
    if (!_artistFocus.hasFocus) return const [];
    final typed = _artist.text.trim().toLowerCase();
    return [
      for (final a in artists)
        if (a.toLowerCase() != typed && (typed.isEmpty || a.toLowerCase().contains(typed))) a,
    ].take(_suggestionLimit).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final suggestions = _suggestions(ref.watch(libraryArtistsProvider).value ?? const []);
    final enabled = !_saving;

    return PopScope(
      canPop: !_saving,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SheetNavBar(
                title: 'New song',
                onCancel: _saving ? null : () => Navigator.of(context).pop(),
                actionLabel: 'Save',
                onAction: _canSave ? _save : null,
                pending: _saving,
              ),
              Hairline(),
              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(DaloySpace.s5, DaloySpace.s5, DaloySpace.s5, DaloySpace.s6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Preview(id: _previewId, title: _title.text, artist: _artist.text, musicalKey: _key),
                      const SizedBox(height: DaloySpace.s6),
                      const SectionLabel('Import ChordPro'),
                      const SizedBox(height: DaloySpace.s3),
                      SettingsGroup(
                        children: [
                          SettingsRow(
                            leading: const SettingsGlyph(TablerIcons.file_import),
                            title: 'Choose file',
                            subtitle: _imported != null && _importedFrom != null
                                ? _importSummary
                                : '.cho, .chopro, .pro',
                            onTap: enabled ? _chooseChordProFile : null,
                          ),
                          SettingsRow(
                            leading: const SettingsGlyph(TablerIcons.clipboard_text),
                            title: 'Paste from clipboard',
                            subtitle: _imported != null && _importedFrom == null ? _importSummary : null,
                            onTap: enabled ? _pasteChordPro : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: DaloySpace.s6),
                      const SectionLabel('Details'),
                      const SizedBox(height: DaloySpace.s3),
                      DaloyTextField(
                        label: 'Title',
                        hint: 'Song title',
                        controller: _title,
                        enabled: enabled,
                        autofocus: true,
                        maxLength: NewSong.maxTextLength,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: DaloySpace.s4),
                      DaloyTextField(
                        label: 'Artist',
                        hint: 'Optional',
                        controller: _artist,
                        focusNode: _artistFocus,
                        enabled: enabled,
                        maxLength: NewSong.maxTextLength,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _save(),
                      ),
                      SuggestionPills(
                        labels: suggestions,
                        semanticPrefix: 'Use artist',
                        onSelected: (artist) {
                          _artist.value = TextEditingValue(
                            text: artist,
                            selection: TextSelection.collapsed(offset: artist.length),
                          );
                          _artistFocus.unfocus();
                        },
                      ),
                      const SizedBox(height: DaloySpace.s6),
                      const SectionLabel('Music'),
                      const SizedBox(height: DaloySpace.s3),
                      Row(
                        children: [
                          Expanded(
                            child: SongMusicTile(label: 'Key', value: _key, enabled: enabled, onTap: _pickKey),
                          ),
                          const SizedBox(width: DaloySpace.s2),
                          Expanded(
                            child: SongMusicTile(
                              label: 'Tempo',
                              value: _bpm.isEmpty ? null : _bpm,
                              unit: 'BPM',
                              enabled: enabled,
                              onTap: _pickTempo,
                            ),
                          ),
                          const SizedBox(width: DaloySpace.s2),
                          Expanded(
                            child: SongMusicTile(
                              label: 'Time',
                              value: _timeSignature,
                              enabled: enabled,
                              onTap: _pickTimeSignature,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DaloySpace.s4),
                      Text(
                        _imported?.content.isNotEmpty ?? false
                            ? 'The chart and lyrics are saved with the song. Edit them after saving.'
                            : 'You can add chords and lyrics after saving.',
                        style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The song as it will look: its artwork (which takes the key you pick) beside
/// the title and artist as typed — the edit screen's hero, sheet-sized.
class _Preview extends StatelessWidget {
  const _Preview({required this.id, required this.title, required this.artist, required this.musicalKey});

  final int id;
  final String title;
  final String artist;
  final String? musicalKey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = title.trim();
    final a = artist.trim();
    return Row(
      children: [
        SongArtwork(songId: id, keyName: musicalKey, width: 88, shadow: true),
        const SizedBox(width: DaloySpace.s4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.isEmpty ? 'Untitled' : t,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.displaySmall!.copyWith(fontSize: 22, color: t.isEmpty ? c.mutedForeground : null),
              ),
              if (a.isNotEmpty) ...[
                const SizedBox(height: DaloySpace.s1),
                Text(
                  a,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyLarge!.copyWith(color: c.mutedForeground),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
