import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics.dart';
import '../../auth/application/session_controller.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up_draft.dart';

part 'create_line_up_controller.g.dart';

/// The new-line-up sheet's save. Written to Drift first, so it is in the
/// list (and editable) the moment the sheet closes, online or not; the push
/// to the server happens behind it and again on reconnect.
@riverpod
class CreateLineUp extends _$CreateLineUp {
  @override
  void build() {}

  /// Returns the new line-up's local id, or null when there is no active workspace.
  Future<int?> submit(LineUpDetails details) async {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId == null) return null;

    final repository = ref.read(lineUpsRepositoryProvider);
    final analytics = ref.read(analyticsProvider);
    final localId = await repository.createLocal(workspaceId, details);
    // Not awaited: the flush fails quietly when offline and is retried on reconnect.
    unawaited(repository.flushOutbox(workspaceId).catchError((Object _) {}));
    unawaited(analytics.trackAndFlush(AnalyticsEvent.lineUpCreated));
    return localId;
  }
}
