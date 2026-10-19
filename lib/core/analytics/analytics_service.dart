import 'dart:convert';

import '../network/api_client.dart';
import '../storage/app_database.dart';

/// Which build sent a batch; the admin reads app and web apart by it.
class AnalyticsClient {
  const AnalyticsClient({required this.platform, this.appVersion, this.osVersion});

  /// `ios` or `android`.
  final String platform;
  final String? appVersion;
  final String? osVersion;
}

/// `POST /api/analytics/events` — the twin of the web's `services/analytics.ts`.
class AnalyticsService {
  const AnalyticsService(this._api);

  final ApiClient _api;

  Future<void> send(List<AnalyticsQueueRow> events, AnalyticsClient client) => _api.post(
    '/api/analytics/events',
    (_) {},
    body: {
      'platform': client.platform,
      'app_version': ?client.appVersion,
      'os_version': ?client.osVersion,
      'events': [
        for (final e in events)
          {
            'client_event_id': e.id,
            'name': e.name,
            'screen': e.screen,
            'workspace_id': e.workspaceId,
            'session_id': e.sessionId,
            'properties': e.properties == null ? null : jsonDecode(e.properties!),
            'occurred_at': e.occurredAt.toUtc().toIso8601String(),
          },
      ],
    },
  );
}
