import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'online_status.g.dart';

/// Network reachability, the twin of `use-online-status.ts`. Connectivity is
/// a hint, not a guarantee — requests still fail gracefully when it lies.
@Riverpod(keepAlive: true)
Stream<bool> onlineStatus(Ref ref) async* {
  final connectivity = Connectivity();
  yield _hasNetwork(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_hasNetwork).distinct();
}

/// Optimistic until the first reading arrives.
@riverpod
bool isOnline(Ref ref) => ref.watch(onlineStatusProvider).value ?? true;

bool _hasNetwork(List<ConnectivityResult> results) => results.any((r) => r != ConnectivityResult.none);
