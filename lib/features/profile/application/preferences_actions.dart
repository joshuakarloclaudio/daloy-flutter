import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_exception.dart';
import '../../auth/application/session_controller.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/domain/auth_user.dart';
import '../../songs/chart/nashville.dart';
import '../../songs/data/song_detail_repository.dart';
import '../../songs/domain/display_prefs.dart';

part 'preferences_actions.g.dart';

/// Changes to what a chart opens as. Both take effect on this device at once
/// and then follow the account, so a new device starts the same way.
@Riverpod(keepAlive: true)
class PreferencesActions extends _$PreferencesActions {
  @override
  void build() {}

  Future<void> setDefaultView(SongViewMode mode) async {
    await ref.read(songDetailRepositoryProvider).setViewMode(mode);
    await _toAccount(() => ref.read(authServiceProvider).updatePreferredView(mode.name));
  }

  Future<void> setNotation(ChordNotation notation) async {
    await ref.read(songDetailRepositoryProvider).setNotation(notation);
    await _toAccount(() => ref.read(authServiceProvider).updateChordNotation(notation.name));
  }

  /// The device copy already took effect; the account is only the default for
  /// the next device, so being offline just means it catches up later.
  Future<void> _toAccount(Future<AuthUser> Function() send) async {
    try {
      await ref.read(sessionControllerProvider.notifier).updateUser(await send());
    } on ApiException {
      // Offline or refused — nothing to undo.
    }
  }
}
