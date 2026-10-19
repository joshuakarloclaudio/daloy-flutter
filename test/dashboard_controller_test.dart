import 'package:daloy_flutter/core/network/network_providers.dart';
import 'package:daloy_flutter/core/utils/formatters.dart';
import 'package:daloy_flutter/features/dashboard/application/dashboard_controller.dart';
import 'package:daloy_flutter/features/sync/workspace_sync_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

Map<String, dynamic> _song(int id) => {
  'id': id,
  'title': 'Song $id',
  'artist': null,
  'key': 'G',
  'transposition': 0,
  'bpm': 72,
  'time_signature': '4/4',
  'content': null,
  'lyrics': null,
  'youtube_url': null,
  'spotify_url': null,
  'apple_music_url': null,
  'other_url': null,
  'is_public': false,
  'created_at': DateTime.now().subtract(Duration(days: 20 - id)).toUtc().toIso8601String(),
};

Map<String, dynamic> _lineUp(int id, int dayOffset) => {
  'id': id,
  'title': 'Line-up $id',
  'date': isoDate(DateTime.now().add(Duration(days: dayOffset))),
  'worship_leader': null,
  'songs_count': 3,
};

void main() {
  test('a sync pulls the workspace into Drift and feeds Home', () async {
    final api = FakeApiAdapter({
      'GET /api/auth/me': (_) => FakeApiAdapter.ok(userJson()),
      'GET /api/workspaces': (_) => FakeApiAdapter.ok([
        {'id': 1, 'name': 'Grace Community Church', 'role': 'admin', 'is_member': true},
      ]),
      'GET /api/songs': (_) => (
        status: 200,
        body: {
          'data': [for (var id = 1; id <= 8; id++) _song(id)],
          'meta': {'current_page': 1, 'last_page': 1, 'per_page': 10, 'total': 8},
        },
      ),
      'GET /api/line-ups': (_) => FakeApiAdapter.ok({
        'line_ups': [_lineUp(4, -7), _lineUp(10, -3), _lineUp(12, 0)],
      }),
      'GET /api/live-session': (_) => FakeApiAdapter.ok(null),
    });
    final storage = MemoryStorage()
      ..values.addAll({
        'daloy.token': 'token',
        'daloy.workspace_id': '1',
        'daloy.user': '{"id":1,"name":"Ana Reyes","email":"ana@example.com"}',
      });
    final container = await createTestContainer(api, storage: storage);

    final sub = container.listen(dashboardControllerProvider, (_, _) {});
    container.listen(workspaceSyncProvider, (_, _) {});

    for (var i = 0; i < 100 && container.read(workspaceSyncProvider).status != SyncStatus.done; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final page = sub.read();
    expect(container.read(workspaceSyncProvider).status, SyncStatus.done);
    expect(page.workspaceId, 1);
    expect(page.workspaceName, 'Grace Community Church');
    expect(page.showSkeletons, isFalse);
    expect(page.recentSongs, hasLength(5));
    expect(page.featuredLineUp?.id, 12);
    expect(page.recentLineUps.map((l) => l.id), isNot(contains(12)));
    expect(api.requests.where((r) => r.path == '/api/songs').first.headers['Authorization'], 'Bearer token');
    expect(container.read(sessionStoreProvider).workspaceId, 1);
  });
}
