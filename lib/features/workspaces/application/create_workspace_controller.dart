import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/application/session_controller.dart';
import '../data/workspaces_repository.dart';

part 'create_workspace_controller.freezed.dart';
part 'create_workspace_controller.g.dart';

@freezed
abstract class CreateWorkspaceState with _$CreateWorkspaceState {
  const factory CreateWorkspaceState({@Default(false) bool pending, String? error}) = _CreateWorkspaceState;
}

/// The new-workspace sheet and the first-run setup screen
/// (web: `use-workspaces-page.ts` create mutation).
@riverpod
class CreateWorkspace extends _$CreateWorkspace {
  static const maxLength = 255;

  @override
  CreateWorkspaceState build() => const CreateWorkspaceState();

  static bool isValid(String name) => name.trim().isNotEmpty && name.trim().length <= maxLength;

  /// Creates the workspace and switches into it. `true` on success.
  Future<bool> submit(String rawName) async {
    final name = rawName.trim();
    if (state.pending) return false;
    if (name.isEmpty) {
      state = const CreateWorkspaceState(error: 'Give your workspace a name.');
      return false;
    }
    if (name.length > maxLength) {
      state = const CreateWorkspaceState(error: 'Keep the name under $maxLength characters.');
      return false;
    }

    state = const CreateWorkspaceState(pending: true);
    try {
      final workspace = await ref.read(workspacesRepositoryProvider).create(name);
      await ref.read(sessionControllerProvider.notifier).selectWorkspace(workspace.id);
      if (ref.mounted) state = const CreateWorkspaceState();
      return true;
    } on ApiValidationException catch (e) {
      if (ref.mounted) state = CreateWorkspaceState(error: e.firstErrorFor('name') ?? e.message);
    } on NetworkException {
      if (ref.mounted) {
        state = const CreateWorkspaceState(error: "You're offline. Connect to the internet to create a workspace.");
      }
    } on ApiException catch (e) {
      if (ref.mounted) state = CreateWorkspaceState(error: e.message);
    }
    return false;
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(error: null);
  }
}

/// Re-pulls the workspace list for the setup screen, so someone invited
/// after signing in can pick that workspace instead of creating one.
@riverpod
Future<void> refreshWorkspaces(Ref ref) => ref.read(workspacesRepositoryProvider).sync();
