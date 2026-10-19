import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'screen_awake.g.dart';

/// Keeps the display on while a chart is up (`use-screen-wake-lock.ts`).
/// A class over the plugin so tests can swap it out.
class ScreenAwake {
  const ScreenAwake();

  Future<void> hold() => WakelockPlus.enable();

  Future<void> release() => WakelockPlus.disable();
}

@Riverpod(keepAlive: true)
ScreenAwake screenAwake(Ref ref) => const ScreenAwake();
