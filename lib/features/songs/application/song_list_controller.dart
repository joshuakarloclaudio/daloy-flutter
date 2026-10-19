import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/prefs/device_prefs.dart';
import '../../auth/application/session_controller.dart';
import '../data/songs_repository.dart';
import '../domain/song.dart';
import '../domain/song_list_query.dart';

part 'song_list_controller.g.dart';

/// What the Songs screen is currently searching, filtering and sorting by.
/// Kept alive so the choices survive switching tabs; the sort is also
/// remembered on this device.
@Riverpod(keepAlive: true)
class SongListController extends _$SongListController {
  static const _sortKey = 'daloy.song_sort';

  @override
  SongListQuery build() {
    final stored = ref.read(sharedPreferencesProvider)?.getString(_sortKey);
    return SongListQuery(sort: SongSort.values.asNameMap()[stored] ?? SongSort.az);
  }

  void setSearch(String value) => state = state.copyWith(search: value);

  void setSort(SongSort sort) {
    state = state.copyWith(sort: sort);
    ref.read(sharedPreferencesProvider)?.setString(_sortKey, sort.name);
  }

  void setKey(String? key) => state = state.withFilters(key: key, content: state.content);

  /// Tapping the active content filter turns it off.
  void toggleContent(SongContentFilter filter) =>
      state = state.withFilters(key: state.key, content: state.content == filter ? null : filter);

  void clearFilters() => state = state.withFilters();

  Future<void> recordOpened(Song song) async {
    final workspaceId = ref.read(activeWorkspaceIdProvider);
    if (workspaceId == null) return;
    await ref.read(songsRepositoryProvider).recordOpened(song.id, workspaceId);
  }
}

/// The library for the current [SongListController] query. A query change
/// rebuilds this provider, which keeps the previous list as `value` while
/// the next one loads — so the list never flashes empty mid-typing.
@riverpod
Stream<List<Song>> librarySongs(Ref ref) {
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  final query = ref.watch(songListControllerProvider);
  if (workspaceId == null) return Stream.value(const []);
  return ref.watch(songsRepositoryProvider).watchLibrary(workspaceId, query);
}
