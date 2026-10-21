import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/prefs/device_prefs.dart';
import '../../line_ups/application/line_up_detail_controller.dart';
import '../../perform/application/perform_controller.dart' show LineUpSource, PerformSource, SongSource;
import '../../songs/application/song_detail_controller.dart';
import '../../songs/data/song_detail_repository.dart';
import '../domain/present_deck.dart';

part 'present_controller.g.dart';

/// How slides look on this device: theme, font, size, lines per slide.
/// Kept across sessions (the web keeps them in localStorage).
@Riverpod(keepAlive: true)
class PresentLookController extends _$PresentLookController {
  static const _key = 'daloy.present_look';

  @override
  PresentLook build() {
    final raw = ref.watch(sharedPreferencesProvider)?.getString(_key);
    if (raw == null) return const PresentLook();
    final parts = Uri.splitQueryString(raw);
    return PresentLook.fromJson({
      'theme': parts['theme'],
      'font': parts['font'],
      'zoom': int.tryParse(parts['zoom'] ?? ''),
      'linesPerSlide': int.tryParse(parts['lines'] ?? ''),
    });
  }

  void set(PresentLook look) {
    if (look == state) return;
    state = look;
    final value = Uri(
      queryParameters: {
        'theme': look.theme.name,
        'font': look.font.name,
        'zoom': '${look.zoom}',
        'lines': '${look.linesPerSlide}',
      },
    ).query;
    ref.read(sharedPreferencesProvider)?.setString(_key, value);
  }
}

/// Where the room is: the slide on the wall (found again when slides are
/// rebuilt) and whether the screen is blanked. Kept apart from
/// [PresentDeckController], which rebuilds on every Drift write.
@riverpod
class PresentCursor extends _$PresentCursor {
  @override
  ({PresentSlide? at, int index, bool blanked}) build(PerformSource source) => (at: null, index: 0, blanked: false);

  void moveTo(List<PresentSlide> slides, int index) {
    if (slides.isEmpty) return;
    final i = index.clamp(0, slides.length - 1);
    state = (at: slides[i], index: i, blanked: state.blanked);
  }

  void toggleBlank() => state = (at: state.at, index: state.index, blanked: !state.blanked);
}

/// Present's screen: the deck, or why there isn't one yet.
@immutable
class PresentView {
  const PresentView({required this.deck, this.isLoading = false, this.notFound = false, this.songsMissing = false});

  final PresentDeckState deck;
  final bool isLoading;
  final bool notFound;

  /// The line-up exists but its songs haven't reached this device.
  final bool songsMissing;
}

/// The deck for a line-up (its keys and section order) or a single song —
/// built from what's on this device, so it presents offline. Every control
/// surface (touch, pedal, a paired remote) goes through [apply].
@riverpod
class PresentDeckController extends _$PresentDeckController {
  /// What the slides were built from, for saving an edit back.
  var _songs = const <PresentSong>[];

  @override
  PresentView build(PerformSource source) {
    final look = ref.watch(presentLookControllerProvider);
    final cursor = ref.watch(presentCursorProvider(source));

    final String title;
    final List<PresentSong> songs;
    var isLoading = false;
    var notFound = false;
    var songsMissing = false;

    switch (source) {
      case LineUpSource(:final id):
        final detail = ref.watch(lineUpDetailControllerProvider(id));
        title = detail.lineUp?.title ?? '';
        isLoading = detail.isLoading;
        notFound = detail.notFound;
        songsMissing = detail.songsMissing;
        songs = [
          for (final row in detail.songs)
            PresentSong(
              key: 'song-${row.entry.lineUpSongId ?? 'p${row.position}'}',
              title: row.title,
              songId: row.entry.song.id,
              lyrics: row.entry.song.lyrics,
              displayKey: row.displayKey,
              tempo: row.tempo,
              arrangement: row.entry.sectionArrangement?.lyrics,
            ),
        ];
      case SongSource(:final id):
        final detail = ref.watch(songDetailControllerProvider(id));
        final song = detail.song;
        title = song?.title ?? '';
        isLoading = detail.isLoading;
        notFound = !detail.isLoading && song == null;
        songs = [
          if (song != null)
            PresentSong(
              key: 'song-${song.id}',
              title: song.title,
              songId: song.id,
              lyrics: song.lyrics,
              displayKey: detail.displayKey,
              tempo: [if (song.bpm case final bpm?) '$bpm BPM', ?song.timeSignature].join(' · '),
            ),
        ];
    }

    _songs = songs;
    final slides = buildSlides(songs, linesPerSlide: look.linesPerSlide);
    return PresentView(
      deck: PresentDeckState(
        title: title,
        slides: slides,
        index: locateSlide(cursor.at, cursor.index, slides),
        blanked: cursor.blanked,
        look: look,
      ),
      isLoading: isLoading,
      notFound: notFound,
      songsMissing: songsMissing,
    );
  }

  void apply(PresentCommand command) {
    final deck = state.deck;
    final cursor = ref.read(presentCursorProvider(source).notifier);
    switch (command) {
      case PresentNext():
        if (deck.hasNext) cursor.moveTo(deck.slides, deck.index + 1);
      case PresentPrev():
        if (deck.hasPrev) cursor.moveTo(deck.slides, deck.index - 1);
      case PresentJump(:final index):
        cursor.moveTo(deck.slides, index);
      case PresentToggleBlank():
        cursor.toggleBlank();
      case PresentSetLook(:final look):
        ref.read(presentLookControllerProvider.notifier).set(look);
      case PresentEditSection():
        _saveSection(command);
    }
  }

  /// Writes the section into the song on this device (or the first lyrics
  /// into a song without any); Drift's update rebuilds the slides, which
  /// reach the screen and every remote.
  void _saveSection(PresentEditSection edit) {
    if (edit.songIndex < 0 || edit.songIndex >= _songs.length) return;
    final song = _songs[edit.songIndex];
    final songId = song.songId;
    if (songId == null) return;
    final blank = song.lyrics?.trim().isEmpty ?? true;
    final lyrics = blank
        ? (edit.sectionId == blankSectionId(song.key) ? edit.lines.join('\n').trim() : null)
        : replaceSection(song.lyrics!, song.key, edit.sectionId, label: edit.label, lines: edit.lines);
    if (lyrics == null || lyrics.isEmpty || lyrics == song.lyrics) return;
    unawaited(ref.read(songDetailRepositoryProvider).setLyrics(songId, lyrics));
  }
}
