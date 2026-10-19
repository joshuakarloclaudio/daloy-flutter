import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/routes.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/application/session_controller.dart';
import '../data/os_search_index.dart';
import '../domain/search_text.dart';

part 'os_search_sync.g.dart';

/// Recently opened songs given an Android shortcut, after the next line-up.
const _shortcutSongs = 3;

@Riverpod(keepAlive: true)
OsSearchIndex osSearchIndex(Ref ref) => OsSearchIndex.instance;

/// Keeps the OS's search in step with the active workspace's songs and
/// line-ups: re-sent a few seconds after they settle (a sync writes many
/// rows at once), and only when what the OS would show actually changed.
/// A workspace switch replaces everything with the new workspace's items.
@riverpod
class OsSearchSync extends _$OsSearchSync {
  static const settle = Duration(seconds: 3);

  Timer? _timer;
  String? _lastSent;

  @override
  void build() {
    final workspaceId = ref.watch(activeWorkspaceIdProvider);
    final db = ref.watch(appDatabaseProvider);
    if (workspaceId == null) return;

    void schedule() {
      _timer?.cancel();
      _timer = Timer(settle, () => unawaited(_push(db, workspaceId)));
    }

    final sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.songs, db.lineUps, db.recentSongAccesses]))
        .listen((_) => schedule());
    schedule();
    ref.onDispose(() {
      _timer?.cancel();
      sub.cancel();
    });
  }

  Future<void> _push(AppDatabase db, int workspaceId) async {
    final index = ref.read(osSearchIndexProvider);
    final (:items, :shortcuts) = await buildOsSearchItems(db, workspaceId, now: DateTime.now());
    final signature = Object.hashAll([
      workspaceId,
      for (final i in [...items, ...shortcuts]) ...[i.id, i.title, i.subtitle, i.description],
      shortcuts.length,
    ]).toString();
    if (signature == _lastSent) return;
    _lastSent = signature;
    if (defaultTargetPlatform == TargetPlatform.android) {
      await index.setShortcuts(shortcuts);
    } else {
      await index.replaceAll(items);
    }
  }
}

/// Everything findable from outside the app for [workspaceId] ([items]: every
/// song and line-up, for Spotlight), and the few worth a launcher shortcut
/// ([shortcuts]: the next line-up, then recently opened songs). Songs and
/// line-ups still waiting for the server are left out — their pages don't
/// open yet.
Future<({List<OsSearchItem> items, List<OsSearchItem> shortcuts})> buildOsSearchItems(
  AppDatabase db,
  int workspaceId, {
  required DateTime now,
}) async {
  final songRows = await (db.select(
    db.songs,
  )..where((t) => t.workspaceId.equals(workspaceId) & t.id.isBiggerOrEqualValue(0))).get();
  final lineUpRows = await (db.select(
    db.lineUps,
  )..where((t) => t.workspaceId.equals(workspaceId) & t.id.isBiggerOrEqualValue(0))).get();

  OsSearchItem songItem(SongRow s) {
    final subtitle = s.artist?.trim().isNotEmpty == true
        ? s.artist!.trim()
        : (s.key == null ? null : 'Key of ${s.key}');
    return OsSearchItem(
      id: 'song:${s.id}',
      kind: 'song',
      title: s.title,
      path: Routes.song(s.id),
      subtitle: subtitle,
      description: _openingLine(s),
      keywords: [?s.artist, if (s.key != null) 'key of ${s.key}', 'song'],
    );
  }

  OsSearchItem lineUpItem(LineUpRow l) {
    final date = DateTime.parse('${l.date}T12:00:00');
    final leader = l.worshipLeader?.trim();
    return OsSearchItem(
      id: 'lineup:${l.id}',
      kind: 'lineup',
      title: l.title,
      path: Routes.lineUp(l.id),
      subtitle: [DateFormat.MMMEd().format(date), if (leader != null && leader.isNotEmpty) leader].join(' · '),
      keywords: [DateFormat.EEEE().format(date), DateFormat.MMMM().format(date), ?leader, 'line-up', 'setlist'],
    );
  }

  final items = [for (final s in songRows) songItem(s), for (final l in lineUpRows) lineUpItem(l)];

  final today = isoDate(now);
  final upcoming = lineUpRows.where((l) => l.date.compareTo(today) >= 0).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  final opened =
      await ((db.select(db.recentSongAccesses)
            ..where((t) => t.workspaceId.equals(workspaceId) & t.songId.isBiggerOrEqualValue(0))
            ..orderBy([(t) => OrderingTerm.desc(t.lastAccessedAt)])
            ..limit(_shortcutSongs)))
          .get();
  final songsById = {for (final s in songRows) s.id: s};
  final shortcuts = [
    if (upcoming.isNotEmpty) lineUpItem(upcoming.first),
    for (final a in opened)
      if (songsById[a.songId] case final s?) songItem(s),
  ];
  return (items: items, shortcuts: shortcuts);
}

/// The first line of words a song has — lyrics first, else the chart's.
String? _openingLine(SongRow s) {
  for (final text in [lyricsPlainText(s.lyrics ?? ''), chartPlainText(s.content ?? '')]) {
    for (final line in text.split('\n')) {
      final t = line.trim();
      if (t.isNotEmpty) return t.length > 120 ? '${t.substring(0, 117)}…' : t;
    }
  }
  return null;
}
