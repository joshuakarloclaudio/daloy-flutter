import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';

part 'app_update_service.g.dart';

/// `AppVersionData` from `GET /api/app-version`: what the store has for one
/// platform, set in `api/config/app_versions.php`.
@immutable
class AppVersion {
  const AppVersion({required this.latestVersion, required this.latestBuild, required this.minimumBuild, this.storeUrl});

  factory AppVersion.fromJson(JsonMap json) => AppVersion(
    latestVersion: json['latest_version'] as String,
    latestBuild: json['latest_build'] as int,
    minimumBuild: json['minimum_build'] as int,
    storeUrl: json['store_url'] as String?,
  );

  /// Shown to people, e.g. `1.2.0`.
  final String latestVersion;
  final int latestBuild;

  /// Builds below this have to update before carrying on.
  final int minimumBuild;

  /// Null until the platform has a store listing.
  final String? storeUrl;
}

/// This build, as `pubspec.yaml` named it: `1.0.0` and its build number `4`.
@immutable
class InstalledVersion {
  const InstalledVersion({required this.version, required this.build});

  final String version;
  final int build;

  /// `1.0.0 (4)`.
  String get label => '$version ($build)';
}

class AppUpdateService {
  AppUpdateService(this._api);

  final ApiClient _api;

  Future<AppVersion> latest(String platform) =>
      _api.get('/api/app-version', Decode.object(AppVersion.fromJson), query: {'platform': platform});
}

@riverpod
AppUpdateService appUpdateService(Ref ref) => AppUpdateService(ref.watch(apiClientProvider));

@Riverpod(keepAlive: true)
Future<InstalledVersion> installedVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return InstalledVersion(version: info.version, build: int.tryParse(info.buildNumber) ?? 0);
}
