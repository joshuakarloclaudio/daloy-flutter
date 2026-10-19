import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../connectivity/online_status.dart';
import '../network/api_exception.dart';
import '../network/network_providers.dart';
import '../storage/app_database.dart';
import '../storage/session_store.dart';
import '../utils/uuid.dart';
import 'analytics_event.dart';
import 'analytics_service.dart';

export 'analytics_event.dart';

part 'analytics.g.dart';

/// Usage events, the twin of the web's `lib/analytics.ts`: recorded on the
/// device (offline too, with the time they happened) and uploaded in batches.
///
/// Nothing here throws or waits on the network — analytics must never break
/// the app or slow a tap down.
class Analytics {
  /// Dependencies are read when used, inside the guard: a screen tested
  /// without a session store or database still runs.
  Analytics({
    required AppDatabase Function() db,
    required SessionStore Function() session,
    required AnalyticsService Function() service,
    required Future<AnalyticsClient?> Function() client,
    required this._isOnline,
  }) : _readDb = db,
       _readSession = session,
       _readService = service,
       _loadClient = client;

  final AppDatabase Function() _readDb;
  final SessionStore Function() _readSession;
  final AnalyticsService Function() _readService;
  final Future<AnalyticsClient?> Function() _loadClient;
  final bool Function() _isOnline;

  static const batchSize = 100;

  /// Stops a long-offline device from queueing without bound.
  static const maxQueued = 5000;

  /// Back after this long in the background counts as a new visit.
  static const newVisitAfter = Duration(minutes: 30);

  String _sessionId = uuidV4();
  DateTime? _backgroundedAt;
  Future<AnalyticsClient?>? _client;
  Future<void>? _flushing;

  /// Groups events into visits in the admin.
  String get sessionId => _sessionId;

  /// Records [event] for the signed-in user. Unsigned-in events are dropped.
  Future<void> track(AnalyticsEvent event, {String? screen, AnalyticsProperties? properties}) async {
    try {
      final db = _readDb();
      final session = _readSession();
      final userId = _userIdOf(session);
      if (userId == null || session.token == null) return;
      if (await _clientInfo() == null) return;
      final queued = await db.analyticsQueue.count().getSingle();
      if (queued >= maxQueued) return;
      await db
          .into(db.analyticsQueue)
          .insert(
            AnalyticsQueueCompanion.insert(
              id: uuidV4(),
              userId: userId,
              name: event.wire,
              screen: Value(screen),
              workspaceId: Value(session.workspaceId),
              sessionId: _sessionId,
              properties: Value(properties == null ? null : jsonEncode(properties)),
              occurredAt: clock.now(),
            ),
          );
    } catch (_) {
      // Analytics must never break the app.
    }
  }

  /// Track, then try to upload right away.
  Future<void> trackAndFlush(AnalyticsEvent event, {String? screen, AnalyticsProperties? properties}) =>
      track(event, screen: screen, properties: properties).then((_) => flush());

  /// Uploads this user's queue; rows go only once the server accepts them.
  Future<void> flush() {
    if (!_isOnline()) return Future.value();
    return _flushing ??= _flush().whenComplete(() => _flushing = null);
  }

  /// The app went to the background.
  void backgrounded() => _backgroundedAt = clock.now();

  /// The app came back. Returns `true` when that started a new visit.
  bool foregrounded() {
    final at = _backgroundedAt;
    _backgroundedAt = null;
    if (at == null || clock.now().difference(at) < newVisitAfter) return false;
    _sessionId = uuidV4();
    return true;
  }

  static int? _userIdOf(SessionStore session) => switch (session.user?['id']) {
    final int id => id,
    _ => null,
  };

  Future<AnalyticsClient?> _clientInfo() => _client ??= _loadClient().catchError((Object _) => null);

  Future<void> _flush() async {
    try {
      final db = _readDb();
      final session = _readSession();
      final service = _readService();
      final userId = _userIdOf(session);
      final client = await _clientInfo();
      if (userId == null || session.token == null || client == null) return;

      for (;;) {
        final batch =
            await (db.select(db.analyticsQueue)
                  ..where((t) => t.userId.equals(userId))
                  ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)])
                  ..limit(batchSize))
                .get();
        if (batch.isEmpty) return;

        try {
          await service.send(batch, client);
        } on ApiException catch (error) {
          // A rejected batch never succeeds, so drop it rather than block
          // everything behind it. Network and server errors retry later.
          if (!_isRejected(error)) return;
        }
        await (db.delete(db.analyticsQueue)..where((t) => t.id.isIn(batch.map((e) => e.id)))).go();
      }
    } catch (_) {
      // Retry on the next trigger.
    }
  }

  static bool _isRejected(ApiException error) => switch (error) {
    ApiValidationException() => true,
    ApiHttpException(:final status) => status >= 400 && status < 500 && status != 401 && status != 429,
    _ => false,
  };
}

/// This build's platform and versions; null where the API has no platform
/// for it (desktop), which turns analytics off there.
Future<AnalyticsClient?> loadAnalyticsClient() async {
  final platform = switch (defaultTargetPlatform) {
    TargetPlatform.iOS => 'ios',
    TargetPlatform.android => 'android',
    _ => null,
  };
  if (platform == null) return null;
  final package = await PackageInfo.fromPlatform();
  final device = DeviceInfoPlugin();
  final os = Platform.isIOS
      ? 'iOS ${(await device.iosInfo).systemVersion}'
      : Platform.isAndroid
      ? 'Android ${(await device.androidInfo).version.release}'
      : null;
  String cap(String value, int max) => value.length <= max ? value : value.substring(0, max);
  return AnalyticsClient(
    platform: platform,
    appVersion: cap('${package.version}+${package.buildNumber}', 32),
    osVersion: os == null ? null : cap(os, 64),
  );
}

@Riverpod(keepAlive: true)
Analytics analytics(Ref ref) => Analytics(
  db: () => ref.read(appDatabaseProvider),
  session: () => ref.read(sessionStoreProvider),
  service: () => AnalyticsService(ref.read(apiClientProvider)),
  client: loadAnalyticsClient,
  isOnline: () {
    try {
      return ref.read(isOnlineProvider);
    } catch (_) {
      return false;
    }
  },
);
