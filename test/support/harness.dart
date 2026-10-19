import 'package:daloy_flutter/core/analytics/analytics.dart';
import 'package:daloy_flutter/core/analytics/analytics_service.dart';
import 'package:daloy_flutter/core/connectivity/online_status.dart';
import 'package:daloy_flutter/core/network/network_providers.dart';
import 'package:daloy_flutter/core/realtime/realtime_client.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/core/storage/session_store.dart';
import 'package:daloy_flutter/features/line_ups/data/line_ups_repository.dart';
import 'package:daloy_flutter/features/line_ups/domain/live_session.dart';
import 'package:daloy_flutter/features/search/application/os_search_sync.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// A [ProviderContainer] on in-memory storage whose HTTP goes to [api].
/// The real interceptors (auth headers, 401 handling) still run. Realtime
/// is [realtime] (a silent [FakeRealtime] by default), and the workspace's
/// running session is [liveSession] unless [stubLive] is off. Analytics
/// records nothing unless [analyticsClient] says which build is sending.
Future<ProviderContainer> createTestContainer(
  FakeApiAdapter api, {
  MemoryStorage? storage,
  List<Override> overrides = const [],
  FakeRealtime? realtime,
  FakeOsSearchIndex? osSearchIndex,
  LiveSession? liveSession,
  bool stubLive = true,
  AnalyticsClient? analyticsClient,
}) async {
  final store = SessionStore(storage ?? MemoryStorage());
  await store.load();
  final container = ProviderContainer(
    overrides: [
      sessionStoreProvider.overrideWithValue(store),
      appDatabaseProvider.overrideWithValue(AppDatabase(NativeDatabase.memory())),
      onlineStatusProvider.overrideWith((ref) => Stream.value(true)),
      realtimeClientProvider.overrideWithValue(realtime ?? FakeRealtime()),
      osSearchIndexProvider.overrideWithValue(osSearchIndex ?? FakeOsSearchIndex()),
      analyticsProvider.overrideWith(
        (ref) => Analytics(
          db: () => ref.read(appDatabaseProvider),
          session: () => ref.read(sessionStoreProvider),
          service: () => AnalyticsService(ref.read(apiClientProvider)),
          client: () async => analyticsClient,
          isOnline: () => ref.read(isOnlineProvider),
        ),
      ),
      if (stubLive) activeLiveSessionProvider.overrideWith(() => StubLiveSession(liveSession)),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  container.read(dioProvider).httpClientAdapter = api;
  return container;
}

Map<String, dynamic> userJson({int? lastWorkspaceId = 1, String email = 'ana@example.com'}) => {
  'id': 1,
  'name': 'Ana Reyes',
  'email': email,
  'last_workspace_id': lastWorkspaceId,
  'is_superadmin': false,
  'preferred_view': 'chords',
  'chord_notation': 'letters',
};
