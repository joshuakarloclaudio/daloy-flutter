import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/connectivity/online_status.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/application/session_controller.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up.dart';
import '../domain/line_up_list_query.dart';

part 'add_song_to_line_up.g.dart';

/// A heading in the line-up picker and the line-ups under it.
class LineUpPickGroup {
  const LineUpPickGroup(this.label, this.lineUps);

  final String label;
  final List<LineUp> lineUps;
}

/// The picker's groups: Today, Tomorrow and Upcoming (soonest first), then
/// Past (latest first). [search] narrows them. Port of the web's
/// `groupLineUpsForPicker`.
({List<LineUpPickGroup> coming, List<LineUp> past}) groupLineUpsForPicker(
  List<LineUp> lineUps, {
  String search = '',
  DateTime? now,
}) {
  final today = isoDate(now ?? DateTime.now());
  final matches = search.trim().isEmpty ? lineUps : lineUps.where((l) => lineUpMatchesSearch(l, search));
  final todayList = <LineUp>[], tomorrow = <LineUp>[], upcoming = <LineUp>[], past = <LineUp>[];
  for (final l in matches) {
    switch (lineUpDayChip(l.date, now)) {
      case DayChip.today:
        todayList.add(l);
      case DayChip.tomorrow:
        tomorrow.add(l);
      case null:
        (l.date.compareTo(today) >= 0 ? upcoming : past).add(l);
    }
  }
  int asc(LineUp a, LineUp b) => a.date.compareTo(b.date) != 0 ? a.date.compareTo(b.date) : a.id.compareTo(b.id);
  return (
    coming: [
      if (todayList.isNotEmpty) LineUpPickGroup('Today', todayList..sort(asc)),
      if (tomorrow.isNotEmpty) LineUpPickGroup('Tomorrow', tomorrow..sort(asc)),
      if (upcoming.isNotEmpty) LineUpPickGroup('Upcoming', upcoming..sort(asc)),
    ],
    past: past..sort((a, b) => asc(b, a)),
  );
}

enum AddToLineUpOutcome {
  added,
  alreadyIn,

  /// The set isn't on this device and there's no connection to fetch it.
  needsConnection,
}

@riverpod
Stream<Set<int>> lineUpsWithSong(Ref ref, int songId) =>
    ref.watch(lineUpsRepositoryProvider).watchLineUpsWithSong(songId);

/// Kept alive: an add outlives the sheet it started from.
@Riverpod(keepAlive: true)
SongLineUpAdder songLineUpAdder(Ref ref) => SongLineUpAdder(ref);

/// Puts a song at the end of a line-up's set — on the device at once, then
/// through the line-up outbox, so it works offline once the set is here.
class SongLineUpAdder {
  SongLineUpAdder(this._ref);

  final Ref _ref;

  Future<AddToLineUpOutcome> add(int lineUpId, int songId) async {
    final repo = _ref.read(lineUpsRepositoryProvider);
    final workspaceId = _ref.read(activeWorkspaceIdProvider);
    var result = await repo.addSong(lineUpId, songId);
    if (result == AddSongResult.notLoaded && workspaceId != null && _ref.read(isOnlineProvider)) {
      try {
        await repo.refreshDetail(lineUpId, workspaceId);
      } on ApiException {
        return AddToLineUpOutcome.needsConnection;
      }
      result = await repo.addSong(lineUpId, songId);
    }
    switch (result) {
      case AddSongResult.added:
        if (workspaceId != null) unawaited(repo.flushOutbox(workspaceId).catchError((Object _) {}));
        return AddToLineUpOutcome.added;
      case AddSongResult.alreadyIn:
        return AddToLineUpOutcome.alreadyIn;
      case AddSongResult.notLoaded:
        return AddToLineUpOutcome.needsConnection;
    }
  }
}
