import 'package:daloy_flutter/features/app_update/application/app_update_controller.dart';
import 'package:daloy_flutter/features/app_update/data/app_update_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_update/in_app_update.dart';

AppVersion _remote({
  int latest = 5,
  int minimum = 0,
  String? store = 'https://play.google.com/store/apps/details?id=pro.daloy.app',
}) => AppVersion(latestVersion: '1.1.0', latestBuild: latest, minimumBuild: minimum, storeUrl: store);

AppUpdateInfo _play(UpdateAvailability availability, {InstallStatus status = InstallStatus.unknown}) => AppUpdateInfo(
  updateAvailability: availability,
  immediateUpdateAllowed: true,
  immediateAllowedPreconditions: null,
  flexibleUpdateAllowed: true,
  flexibleAllowedPreconditions: null,
  availableVersionCode: 9,
  installStatus: status,
  packageName: 'pro.daloy.app',
  clientVersionStalenessDays: null,
  updatePriority: 0,
);

void main() {
  group('decideAppUpdate', () {
    test('nothing answered: no verdict', () {
      expect(decideAppUpdate(installedBuild: 4), isNull);
    });

    test('a newer build in the store is offered through the listing', () {
      final s = decideAppUpdate(installedBuild: 4, remote: _remote())!;
      expect(s.status, AppUpdateStatus.available);
      expect(s.latestVersion, '1.1.0');
      expect(s.viaPlay, isFalse);
      expect(s.required, isFalse);
    });

    test('the same build is up to date; so is any build without a store listing', () {
      expect(decideAppUpdate(installedBuild: 5, remote: _remote())!.status, AppUpdateStatus.upToDate);
      expect(decideAppUpdate(installedBuild: 4, remote: _remote(store: null))!.status, AppUpdateStatus.upToDate);
    });

    test('below the minimum build, the update is required', () {
      expect(decideAppUpdate(installedBuild: 4, remote: _remote(minimum: 5))!.required, isTrue);
    });

    test('Play updates in place, and says when its download is ready', () {
      final available = decideAppUpdate(installedBuild: 4, play: _play(UpdateAvailability.updateAvailable))!;
      expect(available.viaPlay, isTrue);
      expect(available.latestBuild, 9);
      final downloaded = decideAppUpdate(
        installedBuild: 4,
        remote: _remote(latest: 4),
        play: _play(UpdateAvailability.developerTriggeredUpdateInProgress, status: InstallStatus.downloaded),
      )!;
      expect(downloaded.status, AppUpdateStatus.readyToInstall);
    });

    test('Play saying no update wins over nothing in the API', () {
      final s = decideAppUpdate(
        installedBuild: 5,
        remote: _remote(),
        play: _play(UpdateAvailability.updateNotAvailable),
      );
      expect(s!.status, AppUpdateStatus.upToDate);
    });
  });
}
