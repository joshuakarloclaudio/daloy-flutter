import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/application/session_controller.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/help/chord_syntax_guide_screen.dart';
import '../../features/line_ups/presentation/line_up_detail_screen.dart';
import '../../features/line_ups/presentation/line_up_edit_screen.dart';
import '../../features/line_ups/presentation/line_up_prepare_screen.dart';
import '../../features/line_ups/presentation/line_ups_screen.dart';
import '../../features/perform/application/perform_controller.dart';
import '../../features/perform/presentation/perform_screen.dart';
import '../../features/present/presentation/present_screen.dart';
import '../../features/player/presentation/mini_player.dart';
import '../../features/player/presentation/now_playing_screen.dart';
import '../../features/profile/presentation/storage_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/songs/presentation/song_detail_screen.dart';
import '../../features/songs/presentation/song_edit_screen.dart';
import '../../features/songs/presentation/songs_screen.dart';
import '../../features/team/application/join_controller.dart';
import '../../features/team/application/pending_link.dart';
import '../../features/team/presentation/join_screen.dart';
import '../../features/team/presentation/team_screen.dart';
import '../../features/workspaces/presentation/workspace_setup_screen.dart';
import '../../shell/app_shell.dart';
import '../../shell/branch_switcher.dart';
import '../../shell/floating_tab_bar.dart';
import 'routes.dart';

part 'app_router.g.dart';

final _rootKey = GlobalKey<NavigatorState>();

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Re-run redirects whenever sign-in state changes, without rebuilding the router.
  final authChanges = ValueNotifier<AsyncValue<Object?>>(const AsyncLoading());
  ref
    ..listen(sessionControllerProvider, (_, next) => authChanges.value = next, fireImmediately: true)
    ..onDispose(authChanges.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.home,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      if (session.isLoading && !session.hasValue) return null;
      final signedIn = session.value != null;
      final location = state.matchedLocation;
      // The reset link works whoever opens it; so does a join link, which
      // asks the signed out to sign in on its own screen.
      if (location == Routes.resetPassword || Routes.isJoin(location)) return null;
      final atAuthScreen = Routes.signedOut.contains(location);
      if (!signedIn) return atAuthScreen ? null : Routes.signIn;

      // A join link opened before signing in is picked up once they're in.
      final pending = ref.read(pendingLinkProvider);
      final needsWorkspace = session.value!.workspaceId == null;
      final atSetup = location == Routes.workspaceSetup;
      if (pending != null && (atAuthScreen || atSetup)) {
        Future.microtask(() => ref.read(pendingLinkProvider.notifier).take());
        return pending;
      }
      if (needsWorkspace) return atSetup ? null : Routes.workspaceSetup;
      if (atAuthScreen || atSetup) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.signIn, pageBuilder: (_, state) => _page(state, const SignInScreen())),
      GoRoute(path: Routes.register, pageBuilder: (_, state) => _page(state, const RegisterScreen())),
      GoRoute(path: Routes.forgotPassword, pageBuilder: (_, state) => _page(state, const ForgotPasswordScreen())),
      GoRoute(path: Routes.workspaceSetup, pageBuilder: (_, state) => _page(state, const WorkspaceSetupScreen())),
      GoRoute(
        path: Routes.resetPassword,
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, state) => _page(
          state,
          ResetPasswordScreen(token: state.uri.queryParameters['token'], email: state.uri.queryParameters['email']),
        ),
      ),
      GoRoute(
        path: '/join/:token',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, state) =>
            _page(state, JoinScreen(kind: JoinKind.link, token: state.pathParameters['token'] ?? '')),
      ),
      GoRoute(
        path: '/invite/:token',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, state) =>
            _page(state, JoinScreen(kind: JoinKind.invitation, token: state.pathParameters['token'] ?? '')),
      ),
      StatefulShellRoute(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        navigatorContainerBuilder: (context, shell, children) =>
            BranchSwitcher(currentIndex: shell.currentIndex, children: children),
        branches: [
          StatefulShellBranch(
            observers: [ShellCover.observer()],
            routes: [GoRoute(path: Routes.home, pageBuilder: (_, state) => _page(state, const DashboardScreen()))],
          ),
          StatefulShellBranch(
            observers: [ShellCover.observer()],
            routes: [GoRoute(path: Routes.songs, pageBuilder: (_, state) => _page(state, const SongsScreen()))],
          ),
          StatefulShellBranch(
            observers: [ShellCover.observer()],
            routes: [
              GoRoute(
                path: Routes.lineUps,
                pageBuilder: (_, state) =>
                    _page(state, LineUpsScreen(startNew: state.uri.queryParameters['new'] == '1')),
              ),
            ],
          ),
          StatefulShellBranch(
            observers: [ShellCover.observer()],
            routes: [GoRoute(path: Routes.profile, pageBuilder: (_, state) => _page(state, const ProfileScreen()))],
          ),
        ],
      ),
      // Search is a page over the tabs, opened from the magnifier on each. A
      // tablet searches in a panel over the current screen instead
      // (`openSearch`).
      GoRoute(
        path: Routes.search,
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, state) => _page(state, const SearchScreen()),
      ),
      GoRoute(
        path: Routes.team,
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, state) => _page(state, const TeamScreen()),
      ),
      GoRoute(
        path: Routes.storage,
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, state) => _page(state, const StorageScreen()),
      ),
      GoRoute(
        path: Routes.chordSyntaxGuide,
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, state) => _page(state, const ChordSyntaxGuideScreen()),
      ),
      // Detail screens cover the shell (no tab bar), like the web's
      // full-screen detail/edit routes.
      GoRoute(
        path: '/songs/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, state) => _page(
          state,
          MiniPlayerFrame(
            child: SongDetailScreen(
              songId: _id(state),
              focusLine: int.tryParse(state.uri.queryParameters['line'] ?? ''),
              focusView: state.uri.queryParameters['view'],
            ),
          ),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (_, state) => _page(state, MiniPlayerFrame(child: SongEditScreen(songId: _id(state)))),
          ),
          GoRoute(path: 'listen', pageBuilder: (_, state) => _listenPage(state, PerformSource.song(_id(state)))),
          GoRoute(
            path: 'present',
            pageBuilder: (_, state) => _page(state, PresentScreen(source: PerformSource.song(_id(state)))),
          ),
          GoRoute(
            path: 'practice',
            pageBuilder: (_, state) =>
                _page(state, PerformScreen(source: PerformSource.song(_id(state)), practice: true)),
          ),
        ],
      ),
      GoRoute(
        path: '/line-ups/:id',
        parentNavigatorKey: _rootKey,
        pageBuilder: (_, state) => _page(state, MiniPlayerFrame(child: LineUpDetailScreen(lineUpId: _id(state)))),
        routes: [
          GoRoute(
            path: 'edit',
            pageBuilder: (_, state) => _page(state, MiniPlayerFrame(child: LineUpEditScreen(lineUpId: _id(state)))),
          ),
          GoRoute(
            path: 'prepare',
            pageBuilder: (_, state) => _page(
              state,
              MiniPlayerFrame(
                child: LineUpPrepareScreen(
                  lineUpId: _id(state),
                  focusSongId: int.tryParse(state.uri.queryParameters['song'] ?? ''),
                  notes: state.uri.queryParameters['tab'] == 'notes',
                ),
              ),
            ),
          ),
          GoRoute(
            path: 'perform',
            pageBuilder: (_, state) => _page(
              state,
              PerformScreen(source: PerformSource.lineUp(_id(state)), goLive: state.uri.queryParameters['live'] == '1'),
            ),
          ),
          GoRoute(
            path: 'practice',
            pageBuilder: (_, state) =>
                _page(state, PerformScreen(source: PerformSource.lineUp(_id(state)), practice: true)),
          ),
          GoRoute(
            path: 'present',
            pageBuilder: (_, state) => _page(state, PresentScreen(source: PerformSource.lineUp(_id(state)))),
          ),
          GoRoute(path: 'listen', pageBuilder: (_, state) => _listenPage(state, PerformSource.lineUp(_id(state)))),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

/// Every screen is a [MaterialPage], so it moves the platform's way: the
/// theme's Cupertino slide (with edge swipe-back) on iOS, predictive back on
/// Android. go_router can't pick this itself — it looks for `material_ui`'s
/// `MaterialApp`, not Flutter's, and falls back to [NoTransitionPage]: no
/// animation and no swipe-back.
Page<void> _page(GoRouterState state, Widget child) =>
    MaterialPage<void>(key: state.pageKey, name: state.name, restorationId: state.pageKey.value, child: child);

int _id(GoRouterState state) => int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

/// The now-playing screen slides up over what was there, and back down. It
/// slides itself (with a drag, and the screen under it showing through
/// dimmed and blurred), so the route is see-through and adds no transition.
Page<void> _listenPage(GoRouterState state, PerformSource source) => CustomTransitionPage<void>(
  key: state.pageKey,
  opaque: false,
  child: NowPlayingScreen(source: source),
  transitionDuration: const Duration(milliseconds: 320),
  reverseTransitionDuration: const Duration(milliseconds: 260),
  transitionsBuilder: (_, _, _, child) => child,
);
