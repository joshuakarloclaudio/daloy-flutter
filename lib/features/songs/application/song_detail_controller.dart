import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/data/auth_service.dart';
import '../../line_ups/domain/line_up.dart';
import '../chart/chord_math.dart';
import '../chart/nashville.dart';
import '../data/song_detail_repository.dart';
import '../data/songs_repository.dart';
import '../domain/display_prefs.dart';
import '../domain/song.dart';
import 'song_sync.dart';

part 'song_detail_controller.g.dart';

const maxCapo = 11;

/// Everything the song details screen draws, derived from Drift.
class SongDetailState {
  const SongDetailState({
    this.song,
    this.isLoading = true,
    this.capo = 0,
    this.prefs = const ChartPrefs(),
    this.accountNotation = ChordNotation.letters,
    this.upcomingLineUps = const [],
    this.isOnline = true,
    this.sync,
  });

  final Song? song;
  final bool isLoading;
  final int capo;
  final ChartPrefs prefs;
  final ChordNotation accountNotation;
  final List<LineUp> upcomingLineUps;
  final bool isOnline;

  /// Where the song's changes stand with the server; null once synced.
  final SongSync? sync;

  /// Per-song transposition in semitones, as saved.
  int get transposition => song?.transposition ?? 0;

  /// What the chart is shifted by: the key change, less what the capo gives back.
  int get chartTransposition => transposition - capo;

  String? get originalKey => _blank(song?.key);

  String? get displayKey => originalKey == null ? null : transposeKey(originalKey!, transposition);

  bool get canTranspose => originalKey != null;

  bool get canShowNumbers => canUseNumbers(originalKey);

  ChordNotation get notation {
    final wanted = prefs.notation ?? accountNotation;
    return wanted == ChordNotation.numbers && canShowNumbers ? ChordNotation.numbers : ChordNotation.letters;
  }

  /// "1 = A" in numbers mode. Numbers are measured from the *written* key
  /// but the badge names the *sounding* key — what the band is playing.
  String? get numberingReference => notation == ChordNotation.numbers ? numberingLabel(displayKey) : null;

  bool get hasChords => (song?.content ?? '').trim().isNotEmpty;
  bool get hasLyrics => (song?.lyrics ?? '').trim().isNotEmpty;

  bool get hasStreamingLinks =>
      [song?.youtubeUrl, song?.spotifyUrl, song?.appleMusicUrl, song?.otherUrl].any((u) => _blank(u) != null);

  static String? _blank(String? value) => value == null || value.trim().isEmpty ? null : value.trim();
}

/// What opening a song does once: counts as using it, and pulls what only the
/// server knows (capo, upcoming line-ups). Watches *only* the connection and
/// workspace, so writing those results to Drift can't re-trigger it.
@riverpod
Future<void> songDetailRefresh(Ref ref, int songId) async {
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  final online = ref.watch(isOnlineProvider);

  if (workspaceId != null) await ref.read(songsRepositoryProvider).recordOpened(songId, workspaceId);
  if (!online || songId <= 0) return;

  final repo = ref.read(songDetailRepositoryProvider);
  await Future.wait([repo.refreshCapo(songId), repo.refreshUpcomingLineUps(songId)]);
}

/// All of the song details screen's state and actions — the twin of
/// `use-song-detail-page.ts`. Everything is read from Drift, so it works
/// offline; edits land in Drift first and reach the server when they can.
@riverpod
class SongDetailController extends _$SongDetailController {
  static const _flushDelay = Duration(milliseconds: 1500);

  Timer? _flushTimer;

  @override
  SongDetailState build(int songId) {
    final online = ref.watch(isOnlineProvider);
    final song = ref.watch(songByIdProvider(songId));
    final accountNotation = ChordNotation.parse(ref.watch(sessionControllerProvider).value?.user.chordNotation);

    // Kept alive for as long as the screen is, without rebuilding it.
    ref.listen(songDetailRefreshProvider(songId), (_, _) {});

    final today = todayIsoLocal();
    return SongDetailState(
      song: song.value,
      isLoading: !song.hasValue,
      capo: ref.watch(songCapoProvider(songId)).value ?? 0,
      prefs: ref.watch(chartPrefsProvider).value ?? const ChartPrefs(),
      accountNotation: accountNotation,
      upcomingLineUps: [
        for (final l in ref.watch(songUpcomingLineUpsProvider(songId)).value ?? const <LineUp>[])
          if (l.date.compareTo(today) >= 0) l,
      ],
      isOnline: online,
      sync: ref.watch(songSyncProvider.select((all) => all[songId])),
    );
  }

  SongDetailRepository get _repo => ref.read(songDetailRepositoryProvider);

  void transposeUp() => _transpose(1);
  void transposeDown() => _transpose(-1);

  void _transpose(int by) {
    if (!state.canTranspose) return;
    unawaited(_repo.setTransposition(songId, state.transposition + by));
    _scheduleFlush();
  }

  /// Back to the key the song is written in.
  void resetKey() {
    if (state.transposition == 0) return;
    unawaited(_repo.setTransposition(songId, 0));
    _scheduleFlush();
  }

  void capoUp() => _setCapo(state.capo + 1);
  void capoDown() => _setCapo(state.capo - 1);

  void _setCapo(int capo) {
    final clamped = capo.clamp(0, maxCapo);
    if (clamped != state.capo) unawaited(_repo.setCapo(songId, clamped));
  }

  /// Taps arrive faster than requests should: send once they pause. The
  /// timer is deliberately not tied to this notifier's lifetime — it rebuilds
  /// on every Drift write, and leaving the screen mid-wait should still send.
  void _scheduleFlush() {
    _flushTimer?.cancel();
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId == null || !state.isOnline) return;
    final repo = _repo;
    _flushTimer = Timer(_flushDelay, () => unawaited(repo.flush(workspaceId)));
  }

  Future<void> setViewMode(SongViewMode mode) => _repo.setViewMode(mode);

  Future<void> setZoom(int zoom) => _repo.setZoom(zoom);

  Future<void> zoomIn() => setZoom(state.prefs.zoom + ChartPrefs.zoomStep);

  Future<void> zoomOut() => setZoom(state.prefs.zoom - ChartPrefs.zoomStep);

  /// Switches on this device at once; the account catches up when it can.
  Future<void> setNotation(ChordNotation notation) async {
    await _repo.setNotation(notation);
    try {
      await ref.read(authServiceProvider).updateChordNotation(notation.name);
    } on ApiException {
      // The device copy already took effect; the account is only a default.
    }
  }
}
