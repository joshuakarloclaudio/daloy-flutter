import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/theme/daloy_theme.dart';
import '../../../shared/widgets/daloy_button.dart';
import '../../../shared/widgets/daloy_spinner.dart';
import '../../../shared/widgets/daloy_text_field.dart';
import '../../../shared/widgets/daloy_toast.dart';
import '../../../shared/widgets/discard_changes_dialog.dart';
import '../../../shared/widgets/flow_artwork.dart';
import '../../../shared/widgets/hero_top_bar.dart';
import '../../../shared/widgets/list_states.dart';
import '../../../shared/widgets/mode_button.dart';
import '../../../shared/widgets/pressable.dart';
import '../../auth/application/session_controller.dart';
import '../application/song_edit_controller.dart';
import '../application/song_sync.dart';
import '../chart/nashville.dart';
import '../data/song_detail_repository.dart';
import '../domain/new_song.dart';
import '../domain/song_fields.dart';
import 'editor/chart_editor_screen.dart';
import 'editor/lyrics_editor_screen.dart';
import 'widgets/sectioned_sheet.dart';
import 'widgets/song_artwork.dart';
import 'widgets/song_conflict_banner.dart';
import 'widgets/song_field_sheets.dart';
import 'widgets/song_music_tile.dart';
import 'widgets/song_sync_badge.dart';

/// Edit a song as one form, dressed like the song's page: a live preview of
/// the song up top, then Details, Music (key · tempo · time as tiles opening
/// sheets), the chord chart and the lyrics as previews that open their own
/// full-screen editors, and Links. Works on a draft; Save writes it on this
/// device and syncs behind the scenes. The top bar reads "Saved" until
/// something changes, and leaving with edits asks first.
class SongEditScreen extends ConsumerStatefulWidget {
  const SongEditScreen({super.key, required this.songId});

  final int songId;

  @override
  ConsumerState<SongEditScreen> createState() => _SongEditScreenState();
}

class _SongEditScreenState extends ConsumerState<SongEditScreen> {
  final _title = TextEditingController();
  final _artist = TextEditingController();
  final _links = List.generate(4, (_) => TextEditingController());
  final _hero = HeroScrollState();
  bool _filled = false;

  SongEditProvider get _provider => songEditProvider(widget.songId);
  SongEdit get _controller => ref.read(_provider.notifier);

  @override
  void initState() {
    super.initState();
    // The text fields own their text; seed them once, when the draft loads.
    ref.listenManual(_provider, (_, next) {
      final f = next.value?.fields;
      if (f == null || _filled) return;
      _filled = true;
      _title.text = f.title;
      _artist.text = f.artist;
      _links[0].text = f.youtubeUrl;
      _links[1].text = f.spotifyUrl;
      _links[2].text = f.appleMusicUrl;
      _links[3].text = f.otherUrl;
    }, fireImmediately: true);
    // Fields that followed a change from another device: show it.
    ref.listenManual(_provider, (prev, next) {
      final was = prev?.value?.remoteRevision;
      final now = next.value;
      if (now == null || was == null || was == now.remoteRevision) return;
      final f = now.fields;
      void put(TextEditingController c, String text) {
        if (c.text != text) c.text = text;
      }

      put(_title, f.title);
      put(_artist, f.artist);
      put(_links[0], f.youtubeUrl);
      put(_links[1], f.spotifyUrl);
      put(_links[2], f.appleMusicUrl);
      put(_links[3], f.otherUrl);
    });
  }

  @override
  void dispose() {
    for (final c in [_title, _artist, ..._links]) {
      c.dispose();
    }
    _hero.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!await _controller.save() || !mounted) return;
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    // The messenger outlives this screen, so the confirmation lands on the
    // song you return to.
    showDaloyToast(
      ScaffoldMessenger.of(context),
      ref.read(isOnlineProvider) ? 'Song saved.' : "Saved on this device. It'll sync when you're back online.",
    );
    Navigator.of(context).pop();
  }

  ChordNotation get _notation => ChordNotation.parse(ref.read(sessionControllerProvider).value?.user.chordNotation);

  Future<void> _editChords() async {
    FocusScope.of(context).unfocus();
    final fields = ref.read(_provider).value?.fields;
    if (fields == null) return;
    final edited = await showChartEditor(context, content: fields.chords, musicalKey: fields.key, notation: _notation);
    if (edited != null) _controller.change((f) => f.copyWith(chords: edited));
  }

  Future<void> _editLyrics() async {
    FocusScope.of(context).unfocus();
    final fields = ref.read(_provider).value?.fields;
    if (fields == null) return;
    final edited = await showLyricsEditor(context, lyrics: fields.lyrics);
    if (edited != null) _controller.change((f) => f.copyWith(lyrics: edited));
  }

  Future<void> _pickKey(String? current) async {
    FocusScope.of(context).unfocus();
    final picked = await showSongKeyPicker(context, current);
    if (picked != null) _controller.setKey(picked.value);
  }

  Future<void> _pickTimeSignature(String? current) async {
    FocusScope.of(context).unfocus();
    final picked = await showTimeSignaturePicker(context, current);
    if (picked != null) _controller.change((f) => f.copyWith(timeSignature: picked.value));
  }

  Future<void> _pickTempo(String current) async {
    FocusScope.of(context).unfocus();
    final picked = await showTempoSheet(context, current);
    if (picked != null) _controller.change((f) => f.copyWith(bpm: picked.bpm));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_provider);
    final draft = state.value;
    final barBottom = MediaQuery.paddingOf(context).top + DaloyChrome.topBarHeight;

    return PopScope(
      canPop: !(draft?.isDirty ?? false) || (draft?.saving ?? false),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmDiscardChanges(context) && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        // Laid out like the song's page: the artwork's wash under a floating
        // top bar, so editing reads as the same song, opened up.
        body: Stack(
          children: [
            Positioned.fill(
              child: switch (state) {
                AsyncData(:final value) => NotificationListener<ScrollNotification>(
                  onNotification: (n) => _hero.handle(context, n),
                  child: _form(context, value),
                ),
                AsyncError(:final error) => _Missing(notFound: error is SongNotFound),
                _ => Padding(
                  padding: EdgeInsets.only(top: barBottom),
                  child: const ListSkeleton(),
                ),
              },
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: HeroTopBar(
                title: draft == null || draft.fields.title.trim().isEmpty ? 'Edit song' : draft.fields.title.trim(),
                scrolled: _hero.scrolled,
                titleHidden: _hero.titleHidden,
                onBack: () => Navigator.of(context).maybePop(),
                actions: [
                  if (draft != null)
                    Padding(
                      padding: const EdgeInsets.only(right: DaloySpace.s2),
                      child: _SaveAction(
                        draft: draft,
                        sync: ref.watch(songSyncProvider.select((all) => all[widget.songId])),
                        onSave: _save,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form(BuildContext context, SongEditState draft) {
    final c = context.colors;
    final gutter = DaloySpace.gutter(context);
    final top = MediaQuery.paddingOf(context).top + DaloyChrome.topBarHeight;
    final f = draft.fields;
    final saved = draft.saved;
    final enabled = !draft.saving;

    Widget link(int i, IconData icon, String name, String? error, SongFields Function(SongFields, String) set) =>
        Padding(
          padding: const EdgeInsets.only(bottom: DaloySpace.s4),
          child: DaloyTextField(
            label: name,
            icon: icon,
            hint: 'https://',
            controller: _links[i],
            enabled: enabled,
            error: error,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            onChanged: (v) => _controller.change((f) => set(f, v)),
          ),
        );

    Widget edited(bool show) => show ? const _EditedTag() : const SizedBox.shrink();

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + 260,
            child: ArtworkWash(palette: SongArtwork.paletteFor(widget.songId), background: c.background),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              gutter,
              top + DaloySpace.s3,
              gutter,
              DaloySpace.s10 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EditHero(songId: widget.songId, fields: f, dirty: draft.isDirty, titleKey: _hero.titleKey),
                    _Conflicts(songId: widget.songId, draft: draft, controller: _controller),
                    const SizedBox(height: DaloySpace.s8),
                    const SectionLabel('Details'),
                    const SizedBox(height: DaloySpace.s3),
                    DaloyTextField(
                      label: 'Title',
                      controller: _title,
                      enabled: enabled,
                      maxLength: NewSong.maxTextLength,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onChanged: (v) => _controller.change((f) => f.copyWith(title: v)),
                      error: f.titleError,
                    ),
                    const SizedBox(height: DaloySpace.s4),
                    DaloyTextField(
                      label: 'Artist',
                      hint: 'Optional',
                      controller: _artist,
                      enabled: enabled,
                      maxLength: NewSong.maxTextLength,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onChanged: (v) => _controller.change((f) => f.copyWith(artist: v)),
                    ),
                    const SizedBox(height: DaloySpace.s8),
                    const SectionLabel('Music'),
                    const SizedBox(height: DaloySpace.s3),
                    // Three short picks, read at a glance like the song page's pills.
                    Row(
                      children: [
                        Expanded(
                          child: SongMusicTile(
                            label: 'Key',
                            value: f.key,
                            enabled: enabled,
                            onTap: () => _pickKey(f.key),
                          ),
                        ),
                        const SizedBox(width: DaloySpace.s2),
                        Expanded(
                          child: SongMusicTile(
                            label: 'Tempo',
                            value: f.bpm.trim().isEmpty ? null : f.bpm.trim(),
                            unit: 'BPM',
                            enabled: enabled,
                            error: f.bpmError != null,
                            onTap: () => _pickTempo(f.bpm),
                          ),
                        ),
                        const SizedBox(width: DaloySpace.s2),
                        Expanded(
                          child: SongMusicTile(
                            label: 'Time',
                            value: f.timeSignature,
                            enabled: enabled,
                            onTap: () => _pickTimeSignature(f.timeSignature),
                          ),
                        ),
                      ],
                    ),
                    if (f.bpmError case final error?) ...[
                      const SizedBox(height: DaloySpace.s2),
                      Text(error, style: context.text.bodySmall!.copyWith(color: c.destructive)),
                    ],
                    if (draft.showKeyNotice) ...[
                      const SizedBox(height: DaloySpace.s3),
                      const _Notice(
                        icon: TablerIcons.info_circle,
                        text: "Changing the key doesn't rewrite your chords. Edit the chart yourself, or leave it and transpose when you play.",
                      ),
                    ],
                    const SizedBox(height: DaloySpace.s8),
                    SectionLabel(
                      'Chords',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          edited(f.chords != saved.chords),
                          if (f.chords.trim().isNotEmpty) _EditButton(enabled: enabled, onPressed: _editChords),
                        ],
                      ),
                    ),
                    const SizedBox(height: DaloySpace.s2),
                    _PreviewCard(
                      enabled: enabled,
                      onTap: _editChords,
                      semanticLabel: 'Edit chords',
                      empty: f.chords.trim().isEmpty
                          ? const _EmptyPreview(icon: TablerIcons.music, text: 'No chords yet', action: 'Add chords')
                          : null,
                      // Sectioned like Perform / Practice, through the shared formatter.
                      child: SectionedSheet.chords(text: f.chords, zoom: 85, musicalKey: f.key, notation: _notation),
                    ),
                    const SizedBox(height: DaloySpace.s6),
                    SectionLabel(
                      'Lyrics',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          edited(f.lyrics != saved.lyrics),
                          if (f.lyrics.trim().isNotEmpty) _EditButton(enabled: enabled, onPressed: _editLyrics),
                        ],
                      ),
                    ),
                    const SizedBox(height: DaloySpace.s2),
                    _PreviewCard(
                      enabled: enabled,
                      onTap: _editLyrics,
                      semanticLabel: 'Edit lyrics',
                      empty: f.lyrics.trim().isEmpty
                          ? const _EmptyPreview(
                              icon: TablerIcons.align_left,
                              text: 'No lyrics yet',
                              action: 'Add lyrics',
                            )
                          : null,
                      child: SectionedSheet.lyrics(text: f.lyrics, zoom: 90),
                    ),
                    const SizedBox(height: DaloySpace.s8),
                    const SectionLabel('Links'),
                    const SizedBox(height: DaloySpace.s3),
                    link(
                      0,
                      TablerIcons.brand_youtube,
                      'YouTube',
                      SongFields.urlError(f.youtubeUrl),
                      (f, v) => f.copyWith(youtubeUrl: v),
                    ),
                    link(
                      1,
                      TablerIcons.brand_spotify,
                      'Spotify',
                      SongFields.urlError(f.spotifyUrl),
                      (f, v) => f.copyWith(spotifyUrl: v),
                    ),
                    link(
                      2,
                      TablerIcons.brand_apple,
                      'Apple Music',
                      SongFields.urlError(f.appleMusicUrl),
                      (f, v) => f.copyWith(appleMusicUrl: v),
                    ),
                    link(
                      3,
                      TablerIcons.link,
                      'Other link',
                      SongFields.urlError(f.otherUrl),
                      (f, v) => f.copyWith(otherUrl: v),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Save, and whether there's anything to save: the filled button once the
/// draft differs from the song; otherwise where the saved song stands — a
/// quiet "Saved", or "On device" / "Syncing" / "Synced" / "Not synced" while
/// it makes its way to the server.
class _SaveAction extends StatelessWidget {
  const _SaveAction({required this.draft, required this.sync, required this.onSave});

  final SongEditState draft;
  final SongSync? sync;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget status(SongSync? sync) {
      final (Widget lead, String label, String semantics, Color color) = switch (sync?.status) {
        null => (
          Icon(TablerIcons.circle_check, size: 16, color: c.mutedForeground),
          'Saved',
          'No unsaved changes',
          c.mutedForeground,
        ),
        SongSyncStatus.onDevice => (
          Icon(TablerIcons.cloud_off, size: 16, color: c.mutedForeground),
          'On device',
          'Saved on this device, not synced yet',
          c.mutedForeground,
        ),
        SongSyncStatus.syncing => (
          DaloySpinner(size: 12, color: c.mutedForeground),
          'Syncing',
          'Syncing',
          c.mutedForeground,
        ),
        SongSyncStatus.synced => (
          Icon(TablerIcons.check, size: 16, color: c.primaryInk),
          'Synced',
          'Synced',
          c.primaryInk,
        ),
        SongSyncStatus.failed => (
          Icon(TablerIcons.alert_circle, size: 16, color: c.destructive),
          'Not synced',
          "Couldn't sync: ${sync!.error}",
          c.destructive,
        ),
      };
      return Semantics(
        key: ValueKey(sync?.status),
        label: semantics,
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              lead,
              const SizedBox(width: DaloySpace.s1),
              Text(label, style: context.text.labelMedium!.copyWith(color: color)),
            ],
          ),
        ),
      );
    }

    return SongSyncBuilder(
      sync: sync,
      builder: (context, sync) => AnimatedSwitcher(
        duration: DaloyMotion.fast,
        child: draft.isDirty || draft.saving
            ? DaloyButton(
                key: const ValueKey('save'),
                label: 'Save',
                size: ControlSize.sm,
                loading: draft.saving,
                onPressed: draft.canSave ? onSave : null,
              )
            : status(sync),
      ),
    );
  }
}

/// The song as it will look, following the edits: its artwork (which takes
/// the key you pick), the title and artist as typed, and the tempo and metre.
class _EditHero extends StatelessWidget {
  const _EditHero({required this.songId, required this.fields, required this.dirty, required this.titleKey});

  final int songId;
  final SongFields fields;
  final bool dirty;
  final Key titleKey;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final wide = MediaQuery.sizeOf(context).width >= DaloyBreakpoints.tablet;
    final title = fields.title.trim();
    final artist = fields.artist.trim();
    final bpm = fields.bpm.trim();
    final metre = fields.timeSignature ?? '';
    return Row(
      children: [
        SongArtwork(songId: songId, keyName: fields.key, width: wide ? 132 : 104, animate: true, shadow: true),
        const SizedBox(width: DaloySpace.s5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.isEmpty ? 'Untitled' : title,
                key: titleKey,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.displaySmall!.copyWith(
                  fontSize: wide ? 28 : 24,
                  color: title.isEmpty ? c.mutedForeground : null,
                ),
              ),
              if (artist.isNotEmpty) ...[
                const SizedBox(height: DaloySpace.s1),
                Text(
                  artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyLarge!.copyWith(color: c.mutedForeground),
                ),
              ],
              const SizedBox(height: DaloySpace.s2_5),
              Wrap(
                spacing: DaloySpace.s1_5,
                runSpacing: DaloySpace.s1_5,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (bpm.isNotEmpty) _Pill('$bpm BPM'),
                  if (metre.isNotEmpty) _Pill(metre),
                  AnimatedSwitcher(
                    duration: DaloyMotion.fast,
                    child: dirty
                        ? Row(
                            key: const ValueKey('dirty'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: DaloySpace.s1_5),
                              Text(
                                'Unsaved changes',
                                style: context.text.bodySmall!.copyWith(color: c.mutedForeground),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(key: ValueKey('clean')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.muted.withValues(alpha: 0.7), borderRadius: DaloyRadii.all(DaloyRadii.md)),
      child: Text(
        label,
        style: context.text.labelMedium!.copyWith(
          fontWeight: FontWeight.w600,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _EditedTag extends StatelessWidget {
  const _EditedTag();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(right: DaloySpace.s1),
      padding: const EdgeInsets.symmetric(horizontal: DaloySpace.s2, vertical: 2),
      decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.12), borderRadius: DaloyRadii.all(DaloyRadii.xl)),
      child: Text('Edited', style: context.text.labelSmall!.copyWith(color: c.primaryInk)),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => DaloyButton(
    variant: ButtonVariant.ghost,
    size: ControlSize.sm,
    icon: TablerIcons.pencil,
    label: 'Edit',
    onPressed: enabled ? onPressed : null,
  );
}

/// A bordered, tappable preview capped in height, fading out at the bottom
/// when there's more than fits.
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.enabled,
    required this.onTap,
    required this.semanticLabel,
    required this.child,
    this.empty,
  });

  static const _maxHeight = 220.0;

  final bool enabled;
  final VoidCallback onTap;
  final String semanticLabel;
  final Widget child;

  /// Shown instead of [child] when there's nothing yet.
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onPressed: enabled ? onTap : null,
      pressedScale: 0.99,
      semanticLabel: semanticLabel,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: empty == null ? c.card : null,
          border: Border.all(color: c.border),
          borderRadius: DaloyRadii.all(DaloyRadii.xl2),
        ),
        child:
            empty ??
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: _maxHeight),
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [Colors.black, Colors.black, Colors.transparent],
                  stops: [0, rect.height < _maxHeight ? 1 : 0.75, 1],
                ).createShader(rect),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(DaloySpace.s4),
                  child: IgnorePointer(child: child),
                ),
              ),
            ),
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.icon, required this.text, required this.action});

  final IconData icon;
  final String text;
  final String action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DaloySpace.s6, horizontal: DaloySpace.s4),
      child: Column(
        children: [
          Icon(icon, size: 22, color: c.mutedForeground),
          const SizedBox(height: DaloySpace.s2),
          Text(text, style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
          const SizedBox(height: DaloySpace.s1),
          Text(action, style: context.text.labelLarge!.copyWith(color: c.primaryInk)),
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
      padding: const EdgeInsets.all(DaloySpace.s4),
      decoration: BoxDecoration(
        border: Border.all(color: c.border),
        borderRadius: DaloyRadii.all(DaloyRadii.xl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: c.mutedForeground),
          const SizedBox(width: DaloySpace.s3),
          Expanded(
            child: Text(text, style: context.text.bodyMedium!.copyWith(color: c.mutedForeground)),
          ),
        ],
      ),
    );
  }
}

class _Missing extends StatelessWidget {
  const _Missing({required this.notFound});

  final bool notFound;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(DaloySpace.s6),
      child: Text(
        notFound ? "This song isn't on this device." : "Couldn't open this song.",
        textAlign: TextAlign.center,
        style: context.text.bodyLarge!.copyWith(color: context.colors.mutedForeground),
      ),
    ),
  );
}

/// The conflict banner: fields changed here and elsewhere while editing,
/// and fields the server refused from an earlier save.
class _Conflicts extends ConsumerWidget {
  const _Conflicts({required this.songId, required this.draft, required this.controller});

  final int songId;
  final SongEditState draft;
  final SongEdit controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refused = ref.watch(songConflictsProvider(songId)).value ?? const {};
    final repository = ref.read(songDetailRepositoryProvider);
    Future<void> settle(Future<void> Function() action) async {
      await action();
      if (ref.read(activeWorkspaceIdProvider) case final ws?) await repository.flush(ws);
    }

    final conflicts = [
      for (final MapEntry(key: field, value: theirs) in draft.conflicts.entries)
        SongConflict(
          field: field,
          theirs: theirs,
          onKeepMine: () => controller.keepMine(field),
          onTakeTheirs: () => controller.takeTheirs(field),
        ),
      for (final MapEntry(key: field, value: theirs) in refused.entries)
        if (!draft.conflicts.containsKey(field))
          SongConflict(
            field: field,
            theirs: theirs,
            onKeepMine: () => settle(() => repository.keepMine(songId, field)),
            onTakeTheirs: () => settle(() => repository.takeTheirs(songId, field)),
          ),
    ];
    if (conflicts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: DaloySpace.s6),
      child: SongConflictBanner(conflicts: conflicts, changedBy: draft.changedBy),
    );
  }
}
