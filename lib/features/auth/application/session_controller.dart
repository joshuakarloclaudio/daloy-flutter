import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/app_database.dart';
import '../../home_screen_widget/home_screen_widget.dart';
import '../../search/application/os_search_sync.dart';
import '../../workspaces/data/workspaces_repository.dart';
import '../data/auth_service.dart';
import '../data/google_sign_in.dart';
import '../domain/auth_session.dart';
import '../domain/auth_user.dart';

part 'session_controller.g.dart';

/// Who is signed in, and into which workspace. The router redirects on it,
/// and the HTTP layer reads the same credentials from [SessionStore].
///
/// Offline-first: a stored session is trusted immediately, then the user is
/// refreshed from `/api/auth/me` in the background when reachable.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<AuthSession?> build() async {
    final store = ref.watch(sessionStoreProvider);
    final token = store.token;
    final userJson = store.user;
    if (token == null || userJson == null) return null;

    final user = AuthUser.fromJson(userJson);
    unawaited(Future.microtask(_refreshUser));
    return AuthSession(token: token, user: user, workspaceId: store.workspaceId ?? user.lastWorkspaceId);
  }

  Future<void> signIn({required String email, required String password}) async {
    final result = await ref.read(authServiceProvider).login(email: email, password: password);
    await _persist(result, method: 'password');
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await ref
        .read(authServiceProvider)
        .register(name: name, email: email, password: password, passwordConfirmation: passwordConfirmation);
    await _persist(result, method: 'register');
  }

  /// Returns `false` when the user closed the Google sheet.
  /// Throws [GoogleSignInException] or [ApiException].
  Future<bool> signInWithGoogle() async {
    final exchange = await ref.read(googleSignInProvider).authorize();
    if (exchange == null) return false;
    try {
      await _persist(await ref.read(authServiceProvider).exchangeGoogle(exchange), method: 'google');
    } on ApiHttpException catch (e) {
      // Expired or replayed exchange key (422) reads better as a retry prompt.
      if (e.status == 403) rethrow;
      throw GoogleSignInException.fromCode('auth_failed');
    } on ApiValidationException {
      throw GoogleSignInException.fromCode('auth_failed');
    }
    return true;
  }

  Future<void> signOut() async {
    // Sent while the token still works; whatever can't go waits for next time.
    await ref
        .read(analyticsProvider)
        .trackAndFlush(AnalyticsEvent.logout)
        .timeout(const Duration(seconds: 3), onTimeout: () {});
    try {
      await ref.read(authServiceProvider).logout();
    } on ApiException {
      // Signing out locally still matters when the server can't be reached.
    }
    await _dropSession();
  }

  /// Deletes the account on the server, then leaves like a sign-out.
  /// Throws [ApiException] (wrong password, a workspace that needs another admin).
  Future<void> deleteAccount({String? password, String? confirmEmail}) async {
    await ref.read(authServiceProvider).deleteAccount(password: password, confirmEmail: confirmEmail);
    await _dropSession();
  }

  /// The server's latest copy of the signed-in user, after a change to it.
  Future<void> updateUser(AuthUser user) async {
    final current = state.value;
    if (current == null) return;
    await ref.read(sessionStoreProvider).saveUser(user.toJson());
    if (ref.mounted) state = AsyncData(current.copyWith(user: user));
  }

  Future<void> selectWorkspace(int workspaceId) async {
    final current = state.value;
    if (current == null || current.workspaceId == workspaceId) return;
    await ref.read(sessionStoreProvider).saveWorkspaceId(workspaceId);
    state = AsyncData(current.copyWith(workspaceId: workspaceId));
    unawaited(ref.read(authServiceProvider).setLastWorkspace(workspaceId).then((_) {}, onError: (_) {}));
  }

  /// Called by the HTTP interceptor on any 401.
  void handleUnauthorized() {
    if (state.value == null) return;
    unawaited(_dropSession());
  }

  Future<void> _persist(AuthResult result, {required String method}) async {
    final workspaceId = result.user.lastWorkspaceId ?? await _firstWorkspaceId(result.token);
    await ref
        .read(sessionStoreProvider)
        .save(token: result.token, user: result.user.toJson(), workspaceId: workspaceId);
    state = AsyncData(AuthSession(token: result.token, user: result.user, workspaceId: workspaceId));
    unawaited(ref.read(analyticsProvider).trackAndFlush(AnalyticsEvent.login, properties: {'method': method}));
  }

  /// A user without a last workspace (new account, or just invited) lands in
  /// their first one — the web sends them to the workspace picker instead.
  Future<int?> _firstWorkspaceId(String token) async {
    final store = ref.read(sessionStoreProvider);
    try {
      // Requests read the token from the store, so stage it before asking.
      store.stageToken(token);
      final workspaces = await WorkspacesService(ref.read(apiClientProvider)).list();
      final first = workspaces.where((w) => w.isMember).firstOrNull;
      if (first != null) {
        unawaited(ref.read(authServiceProvider).setLastWorkspace(first.id).then((_) {}, onError: (_) {}));
      }
      return first?.id;
    } on ApiException {
      return null;
    }
  }

  Future<void> _dropSession() async {
    await ref.read(sessionStoreProvider).clear();
    await ref.read(appDatabaseProvider).clearAll();
    // Nothing of this account stays findable in Spotlight or the launcher.
    await ref.read(osSearchIndexProvider).clear();
    await publishHomeWidget(const HomeWidgetSnapshot());
    state = const AsyncData(null);
  }

  Future<void> _refreshUser() async {
    try {
      final user = await ref.read(authServiceProvider).me();
      if (!ref.mounted) return;
      await ref.read(sessionStoreProvider).saveUser(user.toJson());
      final current = state.value;
      if (current != null) state = AsyncData(current.copyWith(user: user));
    } on ApiException {
      // Offline or server down — keep the cached user.
    }
  }
}

@riverpod
int? activeWorkspaceId(Ref ref) => ref.watch(sessionControllerProvider.select((s) => s.value?.workspaceId));
