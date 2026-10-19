import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/application/session_controller.dart';
import '../../workspaces/data/workspaces_repository.dart';
import '../../workspaces/domain/workspace.dart';
import '../data/team_service.dart';
import '../domain/team_models.dart';

part 'join_controller.g.dart';

/// Which kind of token a join screen holds.
enum JoinKind { link, invitation }

/// What the link offers — fetched without signing in.
@riverpod
Future<JoinPreview> joinPreview(Ref ref, JoinKind kind, String token) {
  final service = ref.watch(teamServiceProvider);
  return kind == JoinKind.link ? service.previewJoinLink(token) : service.previewInvitation(token);
}

/// Accepting it: joins the workspace, makes it the active one.
@Riverpod(keepAlive: true)
class JoinActions extends _$JoinActions {
  @override
  void build() {}

  Future<Workspace> join(JoinKind kind, String token) async {
    final service = ref.read(teamServiceProvider);
    final workspace = kind == JoinKind.link ? await service.joinWithLink(token) : await service.acceptInvitation(token);
    await ref.read(workspacesRepositoryProvider).sync();
    await ref.read(sessionControllerProvider.notifier).selectWorkspace(workspace.id);
    return workspace;
  }
}

/// True when [error] means the link is gone (turned off, replaced or expired).
bool isLinkGone(Object error) => error is ApiHttpException && error.status == 404;
