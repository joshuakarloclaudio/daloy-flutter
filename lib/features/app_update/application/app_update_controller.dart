import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/prefs/device_prefs.dart';
import '../data/app_update_service.dart';

part 'app_update_controller.g.dart';

enum AppUpdateStatus {
  idle,
  checking,
  upToDate,
  available,

  /// A Play flexible update downloading in the background.
  downloading,

  /// Downloaded by Play; a restart installs it.
  readyToInstall,
  failed,
}

@immutable
class AppUpdateState {
  const AppUpdateState({
    this.status = AppUpdateStatus.idle,
    this.latestVersion,
    this.latestBuild,
    this.required = false,
    this.viaPlay = false,
    this.storeUrl,
  });

  final AppUpdateStatus status;

  /// What's in the store — null when only Play answered (it knows the build).
  final String? latestVersion;
  final int? latestBuild;

  /// This build is below the API's minimum.
  final bool required;

  /// Google Play can update in place; otherwise [storeUrl] opens the listing.
  final bool viaPlay;
  final String? storeUrl;

  bool get busy => status == AppUpdateStatus.checking || status == AppUpdateStatus.downloading;
}

/// What a check found, before anything is shown. Pure, so it can be tested
/// without Play or the network.
///
/// [remote] is the API's answer (null when it couldn't be reached), [play]
/// Google Play's (null off Android, or when the app wasn't installed from
/// Play — a debug or sideloaded build). Null when neither answered.
AppUpdateState? decideAppUpdate({required int installedBuild, AppVersion? remote, AppUpdateInfo? play}) {
  if (remote == null && play == null) return null;
  final playHas =
      play != null &&
      (play.updateAvailability == UpdateAvailability.updateAvailable ||
          play.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress);
  final storeUrl = remote?.storeUrl;
  final remoteHas = remote != null && storeUrl != null && remote.latestBuild > installedBuild;
  if (!playHas && !remoteHas) return const AppUpdateState(status: AppUpdateStatus.upToDate);

  final downloaded = playHas && play.installStatus == InstallStatus.downloaded;
  return AppUpdateState(
    status: downloaded ? AppUpdateStatus.readyToInstall : AppUpdateStatus.available,
    latestVersion: remoteHas ? remote.latestVersion : null,
    latestBuild: remoteHas ? remote.latestBuild : play?.availableVersionCode,
    required: remote != null && installedBuild < remote.minimumBuild,
    viaPlay: playHas,
    storeUrl: storeUrl,
  );
}

/// "Check for updates" on You, and the quiet check at launch. Android asks
/// Google Play first (it can update in place) and the API for the minimum
/// build; iOS only has the API, which offers nothing until there's an App
/// Store listing.
@Riverpod(keepAlive: true)
class AppUpdate extends _$AppUpdate {
  static const _checkedAtKey = 'daloy.update_checked_at';
  static const _dismissedKey = 'daloy.update_dismissed_build';
  static const automaticInterval = Duration(days: 1);

  @override
  AppUpdateState build() => const AppUpdateState();

  static String? get _platform => switch (defaultTargetPlatform) {
    TargetPlatform.android => 'android',
    TargetPlatform.iOS => 'ios',
    _ => null,
  };

  /// Checks now. [automatic] is the launch check: at most once a day, and
  /// it never shows "up to date" or a failure.
  Future<void> check({bool automatic = false, DateTime? now}) async {
    final platform = _platform;
    if (platform == null || kIsWeb || state.busy) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final at = now ?? DateTime.now();
    if (automatic) {
      final last = prefs?.getInt(_checkedAtKey);
      if (last != null && at.difference(DateTime.fromMillisecondsSinceEpoch(last)) < automaticInterval) return;
    }

    final previous = state;
    if (!automatic) state = AppUpdateState(status: AppUpdateStatus.checking, latestVersion: previous.latestVersion);
    final installed = await ref.read(installedVersionProvider.future);
    final (remote, play) = await (_remote(platform), _play()).wait;
    final result = decideAppUpdate(installedBuild: installed.build, remote: remote, play: play);
    if (!ref.mounted) return;
    if (result == null) {
      state = automatic ? previous : const AppUpdateState(status: AppUpdateStatus.failed);
      return;
    }
    await prefs?.setInt(_checkedAtKey, at.millisecondsSinceEpoch);
    state = result;
  }

  Future<AppVersion?> _remote(String platform) async {
    try {
      return await ref.read(appUpdateServiceProvider).latest(platform);
    } on ApiException {
      return null;
    }
  }

  Future<AppUpdateInfo?> _play() async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      return await InAppUpdate.checkForUpdate();
    } on PlatformException {
      return null; // Not installed from Play.
    } on MissingPluginException {
      return null;
    }
  }

  /// Whether the launch check should bring this update up: a required one
  /// always, otherwise once per build.
  bool shouldPrompt() {
    final s = state;
    if (s.status != AppUpdateStatus.available && s.status != AppUpdateStatus.readyToInstall) return false;
    if (s.required) return true;
    return ref.read(sharedPreferencesProvider)?.getInt(_dismissedKey) != s.latestBuild;
  }

  /// "Not now" on the launch prompt: quiet until a newer build.
  Future<void> dismiss() async {
    final build = state.latestBuild;
    if (build != null) await ref.read(sharedPreferencesProvider)?.setInt(_dismissedKey, build);
  }

  /// Gets the update: in place through Play where it can (downloading in the
  /// background unless it's required), else the store listing. Returns false
  /// when nothing could be opened.
  Future<bool> install() async {
    final s = state;
    if (s.status == AppUpdateStatus.readyToInstall) return _completePlay();
    if (s.viaPlay) {
      try {
        if (s.required) {
          final result = await InAppUpdate.performImmediateUpdate();
          if (result != AppUpdateResult.inAppUpdateFailed) return true;
        } else {
          state = _with(AppUpdateStatus.downloading);
          final result = await InAppUpdate.startFlexibleUpdate();
          if (!ref.mounted) return true;
          switch (result) {
            case AppUpdateResult.success:
              state = _with(AppUpdateStatus.readyToInstall);
              return true;
            case AppUpdateResult.userDeniedUpdate:
              state = _with(AppUpdateStatus.available);
              return true;
            case AppUpdateResult.inAppUpdateFailed:
              state = _with(AppUpdateStatus.available);
          }
        }
      } on PlatformException {
        if (ref.mounted) state = _with(AppUpdateStatus.available);
      }
    }
    return _openStore(s.storeUrl);
  }

  Future<bool> _completePlay() async {
    try {
      await InAppUpdate.completeFlexibleUpdate(); // The app restarts.
      return true;
    } on PlatformException {
      return _openStore(state.storeUrl);
    }
  }

  Future<bool> _openStore(String? url) async {
    final uri = url == null ? null : Uri.tryParse(url);
    return uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  AppUpdateState _with(AppUpdateStatus status) => AppUpdateState(
    status: status,
    latestVersion: state.latestVersion,
    latestBuild: state.latestBuild,
    required: state.required,
    viaPlay: state.viaPlay,
    storeUrl: state.storeUrl,
  );
}
