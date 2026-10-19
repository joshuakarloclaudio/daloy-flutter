import 'package:clock/clock.dart';
import 'package:daloy_flutter/core/analytics/analytics.dart';
import 'package:daloy_flutter/core/analytics/analytics_scope.dart';
import 'package:daloy_flutter/core/analytics/analytics_service.dart';
import 'package:daloy_flutter/core/network/network_providers.dart';
import 'package:daloy_flutter/core/storage/app_database.dart';
import 'package:daloy_flutter/features/auth/application/auth_form_controllers.dart';
import 'package:daloy_flutter/features/auth/application/session_controller.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

const _ios = AnalyticsClient(platform: 'ios', appVersion: '1.4.0+52', osVersion: 'iOS 26.1');

List<Map<String, dynamic>> _events(FakeApiAdapter api) => [
  for (final r in api.requests.where((r) => r.path == '/api/analytics/events'))
    ...((r.data as Map)['events'] as List).cast<Map<String, dynamic>>(),
];

Future<ProviderContainer> _signedIn(FakeApiAdapter api, {MemoryStorage? storage}) async {
  final store = storage ?? MemoryStorage();
  store.values
    ..['daloy.token'] = 'abc'
    ..['daloy.user'] = '{"id":1,"name":"Ana","email":"ana@example.com","last_workspace_id":7}'
    ..['daloy.workspace_id'] = '7';
  final container = await createTestContainer(api, storage: store, analyticsClient: _ios);
  await container.read(sessionControllerProvider.future);
  return container;
}

/// An [Analytics] over [container]'s storage whose connection [online] decides.
Analytics _analytics(ProviderContainer container, bool Function() online, {AnalyticsClient? client = _ios}) =>
    Analytics(
      db: () => container.read(appDatabaseProvider),
      session: () => container.read(sessionStoreProvider),
      service: () => AnalyticsService(container.read(apiClientProvider)),
      client: () async => client,
      isOnline: online,
    );

FakeApiAdapter _api({int status = 201}) => FakeApiAdapter({
  'POST /api/analytics/events': (_) => status < 300
      ? FakeApiAdapter.ok({'accepted': 1, 'duplicates': 0}, status: status)
      : FakeApiAdapter.error(status, 'nope'),
  'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson(lastWorkspaceId: 7)),
});

void main() {
  test('records nothing while signed out', () async {
    final api = _api();
    final container = await createTestContainer(api, analyticsClient: _ios);
    await container.read(sessionControllerProvider.future);

    await container.read(analyticsProvider).trackAndFlush(AnalyticsEvent.appOpened);

    expect(await container.read(appDatabaseProvider).analyticsQueue.count().getSingle(), 0);
    expect(_events(api), isEmpty);
  });

  test('keeps events offline with their time, then uploads them with the build', () async {
    final api = _api();
    final container = await _signedIn(api);
    var online = false;
    final analytics = _analytics(container, () => online);
    final at = DateTime.utc(2026, 10, 18, 9, 30);

    await withClock(
      Clock.fixed(at),
      () => analytics.track(AnalyticsEvent.exported, properties: {'format': 'chords_pdf'}),
    );
    await analytics.flush();
    expect(_events(api), isEmpty);

    online = true;
    await analytics.flush();

    final body = api.requests.singleWhere((r) => r.path == '/api/analytics/events').data as Map;
    expect(body['platform'], 'ios');
    expect(body['app_version'], '1.4.0+52');
    expect(body['os_version'], 'iOS 26.1');
    final event = (body['events'] as List).single as Map;
    expect(event['name'], 'exported');
    expect(event['workspace_id'], 7);
    expect(event['session_id'], analytics.sessionId);
    expect(event['properties'], {'format': 'chords_pdf'});
    expect(DateTime.parse(event['occurred_at'] as String), at);
    expect(await container.read(appDatabaseProvider).analyticsQueue.count().getSingle(), 0);
  });

  test('a server error keeps the batch; a rejected batch is dropped', () async {
    final failing = _api(status: 500);
    final container = await _signedIn(failing);
    final analytics = _analytics(container, () => true);
    final queue = container.read(appDatabaseProvider).analyticsQueue;

    await analytics.trackAndFlush(AnalyticsEvent.songCreated);
    expect(await queue.count().getSingle(), 1);

    container.read(dioProvider).httpClientAdapter = _api(status: 403);
    await analytics.flush();
    expect(await queue.count().getSingle(), 0);
  });

  test('a desktop build records nothing', () async {
    final api = _api();
    final container = await _signedIn(api);
    final analytics = _analytics(container, () => true, client: null);

    await analytics.trackAndFlush(AnalyticsEvent.appOpened);

    expect(await container.read(appDatabaseProvider).analyticsQueue.count().getSingle(), 0);
  });

  test('uploads only the signed-in user\'s events, and the queue outlives sign-out', () async {
    final api = _api();
    final container = await _signedIn(api);
    final db = container.read(appDatabaseProvider);
    await db
        .into(db.analyticsQueue)
        .insert(
          AnalyticsQueueCompanion.insert(
            id: '00000000-0000-4000-8000-000000000002',
            userId: 2,
            name: 'logout',
            sessionId: '00000000-0000-4000-8000-000000000003',
            occurredAt: DateTime(2026, 10, 1),
          ),
        );

    await _analytics(container, () => true).trackAndFlush(AnalyticsEvent.appOpened);
    expect(_events(api).map((e) => e['name']), ['app_opened']);

    await db.clearAll();
    expect(await db.analyticsQueue.count().getSingle(), 1);
  });

  test('signing in records how, and signing out records logout', () async {
    final api = FakeApiAdapter({
      'POST /api/auth/login': (_) => FakeApiAdapter.ok({'user': userJson(), 'token': 'abc'}),
      'POST /api/auth/logout': (_) => FakeApiAdapter.ok(null),
      'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      'POST /api/analytics/events': (_) => FakeApiAdapter.ok({'accepted': 1, 'duplicates': 0}, status: 201),
    });
    final container = await createTestContainer(api, analyticsClient: _ios);
    await container.read(sessionControllerProvider.future);
    container.listen(signInFormProvider, (_, _) {});

    await container.read(signInFormProvider.notifier).submit(email: 'ana@example.com', password: 'secret');
    await pumpEventQueue();
    await container.read(sessionControllerProvider.notifier).signOut();

    final events = _events(api);
    expect(events.map((e) => e['name']), ['login', 'logout']);
    expect(events.first['properties'], {'method': 'password'});
    // Logout went up before the token was revoked.
    final paths = api.requests.map((r) => r.path).toList();
    expect(paths.lastIndexOf('/api/analytics/events'), lessThan(paths.indexOf('/api/auth/logout')));
  });

  test('coming back after half an hour is a new visit', () async {
    final container = await _signedIn(_api());
    final analytics = _analytics(container, () => true);
    final start = DateTime(2026, 10, 18, 9);
    final first = analytics.sessionId;

    withClock(Clock.fixed(start), analytics.backgrounded);
    expect(withClock(Clock.fixed(start.add(const Duration(minutes: 5))), analytics.foregrounded), isFalse);
    expect(analytics.sessionId, first);

    withClock(Clock.fixed(start), analytics.backgrounded);
    expect(withClock(Clock.fixed(start.add(const Duration(minutes: 31))), analytics.foregrounded), isTrue);
    expect(analytics.sessionId, isNot(first));
  });

  test('perform, practice and present screens also count as started', () {
    expect(AnalyticsScope.startedOn('/line-ups/:id/perform'), AnalyticsEvent.performanceStarted);
    expect(AnalyticsScope.startedOn('/songs/:id/practice'), AnalyticsEvent.practiceStarted);
    expect(AnalyticsScope.startedOn('/line-ups/:id/practice'), AnalyticsEvent.practiceStarted);
    expect(AnalyticsScope.startedOn('/songs/:id/present'), AnalyticsEvent.presentStarted);
    expect(AnalyticsScope.startedOn('/songs/:id'), isNull);
  });
}
