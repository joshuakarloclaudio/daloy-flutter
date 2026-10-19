import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/router/routes.dart';
import '../../core/storage/app_database.dart';
import '../../core/utils/formatters.dart';
import '../auth/application/session_controller.dart';
import '../line_ups/data/line_ups_repository.dart';
import '../songs/chart/chord_math.dart';
import '../workspaces/data/workspaces_repository.dart';

part 'home_screen_widget.g.dart';

/// The App Group the iOS widget extension reads from. Must match
/// `DaloyWidget.entitlements` and `Runner.entitlements`.
const homeWidgetAppGroup = 'group.pro.daloy.app';

/// The one key the native widgets read: [HomeWidgetSnapshot] as JSON.
const homeWidgetDataKey = 'next_line_ups';

const _androidProvider = 'pro.daloy.app.NextLineUpWidget';
const _iosKind = 'NextLineUpWidget';

/// Line-ups handed over, so the widget can move on to the next one at
/// midnight without the app running.
const _lineUpCount = 3;

/// Songs listed per line-up — as many as the large widget shows.
const _songCount = 8;

/// What the home-screen widget shows, written for `NextLineUpWidget.kt` and
/// `ios/DaloyWidget`. The native side picks the first line-up dated today or
/// later, so a passed one drops off on its own.
@immutable
class HomeWidgetSnapshot {
  const HomeWidgetSnapshot({this.workspace, this.lineUps = const []});

  /// Null when signed out or without a workspace: the widget just opens the app.
  final String? workspace;
  final List<HomeWidgetLineUp> lineUps;

  Map<String, Object?> toJson() => {
    'workspace': workspace,
    'lineUps': [for (final l in lineUps) l.toJson()],
    'newLineUpPath': Routes.newLineUp,
  };
}

@immutable
class HomeWidgetLineUp {
  const HomeWidgetLineUp({
    required this.id,
    required this.title,
    required this.date,
    this.leader,
    required this.songsCount,
    this.songs,
  });

  final int id;
  final String title;

  /// `YYYY-MM-DD`.
  final String date;
  final String? leader;
  final int songsCount;

  /// Null when this device hasn't fetched the set yet (only the count).
  final List<({String title, String? key})>? songs;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'date': date,
    'leader': leader,
    'songsCount': songsCount,
    'path': Routes.lineUp(id),
    'songs': songs == null
        ? null
        : [
            for (final s in songs!) {'title': s.title, 'key': s.key},
          ],
  };
}

/// The next [_lineUpCount] line-ups in [workspaceId] from [now]'s date on,
/// each with its songs in this line-up's keys. Ones still waiting for the
/// server are left out — their pages don't open from outside yet.
Future<List<HomeWidgetLineUp>> upcomingForHomeWidget(AppDatabase db, int workspaceId, {required DateTime now}) async {
  final rows =
      await (db.select(db.lineUps)
            ..where(
              (t) =>
                  t.workspaceId.equals(workspaceId) &
                  t.id.isBiggerOrEqualValue(0) &
                  t.date.isBiggerOrEqualValue(isoDate(now)),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.date), (t) => OrderingTerm.asc(t.id)])
            ..limit(_lineUpCount))
          .get();

  final out = <HomeWidgetLineUp>[];
  for (final row in rows) {
    List<({String title, String? key})>? songs;
    if (row.songsLoaded || row.songsCount == 0) {
      final l = db.lineUpSongs;
      final s = db.songs;
      final joined =
          await (db.select(l).join([innerJoin(s, s.id.equalsExp(l.songId))])
                ..where(l.lineUpId.equals(row.id))
                ..orderBy([OrderingTerm.asc(l.position)])
                ..limit(_songCount))
              .get();
      songs = [
        for (final r in joined)
          (
            title: r.readTable(s).title,
            key: switch (r.readTable(s).key?.trim()) {
              final k? when k.isNotEmpty => transposeKey(k, r.readTable(l).transposition),
              _ => null,
            },
          ),
      ];
    }
    final leader = row.worshipLeader?.trim();
    out.add(
      HomeWidgetLineUp(
        id: row.id,
        title: row.title,
        date: row.date,
        leader: leader == null || leader.isEmpty ? null : leader,
        songsCount: row.songsCount,
        songs: songs,
      ),
    );
  }
  return out;
}

/// Writes [snapshot] where the native widgets read it and asks them to
/// redraw. Quiet where there are no widgets (desktop, tests).
Future<void> publishHomeWidget(HomeWidgetSnapshot snapshot) async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) return;
  if (!_hasBinding) return; // A plain Dart test.
  try {
    if (defaultTargetPlatform == TargetPlatform.iOS) await HomeWidget.setAppGroupId(homeWidgetAppGroup);
    await HomeWidget.saveWidgetData<String>(homeWidgetDataKey, jsonEncode(snapshot.toJson()));
    await HomeWidget.updateWidget(qualifiedAndroidName: _androidProvider, iOSName: _iosKind);
  } on PlatformException {
    // No widget placed, or (iOS) no App Group to write to.
  } on MissingPluginException {
    // Tests.
  }
}

/// Keeps the home-screen widget in step with the active workspace's coming
/// line-ups: re-sent a couple of seconds after the rows settle, and only
/// when what it would show changed. Lives under the app shell, beside the
/// OS search sync; signing out clears it (`SessionController`).
@riverpod
class HomeWidgetSync extends _$HomeWidgetSync {
  static const settle = Duration(seconds: 2);

  Timer? _timer;
  String? _lastSent;

  /// Line-ups whose songs were fetched for the widget, so a failure isn't
  /// retried on every write.
  final _fetched = <int>{};

  @override
  void build() {
    final workspaceId = ref.watch(activeWorkspaceIdProvider);
    final workspace = ref.watch(activeWorkspaceProvider).value;
    final db = ref.watch(appDatabaseProvider);
    if (workspaceId == null) return;

    void schedule() {
      _timer?.cancel();
      _timer = Timer(settle, () => unawaited(_push(db, workspaceId, workspace?.name)));
    }

    final sub = db
        .tableUpdates(TableUpdateQuery.onAllTables([db.lineUps, db.lineUpSongs, db.songs]))
        .listen((_) => schedule());
    schedule();
    ref.onDispose(() {
      _timer?.cancel();
      sub.cancel();
    });
  }

  Future<void> _push(AppDatabase db, int workspaceId, String? workspaceName) async {
    final lineUps = await upcomingForHomeWidget(db, workspaceId, now: DateTime.now());
    // The next set is the one the widget lists; fetching it lands in Drift
    // and comes back through the table listener.
    if (lineUps.firstOrNull case final next? when next.songs == null && _fetched.add(next.id)) {
      unawaited(ref.read(lineUpsRepositoryProvider).refreshDetail(next.id, workspaceId).catchError((Object _) {}));
    }
    final snapshot = HomeWidgetSnapshot(workspace: workspaceName ?? 'Daloy', lineUps: lineUps);
    final json = jsonEncode(snapshot.toJson());
    if (json == _lastSent) return;
    _lastSent = json;
    await publishHomeWidget(snapshot);
  }
}

bool get _hasBinding {
  try {
    ServicesBinding.instance;
    return true;
  } on Object {
    return false;
  }
}

/// Android launchers that can pin a widget from inside the app ("Add to
/// home screen" on You). iOS has no such API.
@riverpod
Future<bool> canPinHomeWidget(Ref ref) async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
  try {
    return await HomeWidget.isRequestPinWidgetSupported() ?? false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}

Future<void> requestPinHomeWidget() async {
  try {
    await HomeWidget.requestPinWidget(qualifiedAndroidName: _androidProvider);
  } on PlatformException {
    // The launcher said no; nothing to tell.
  }
}
