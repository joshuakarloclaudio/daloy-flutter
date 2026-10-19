import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/application/session_controller.dart';
import '../data/line_ups_repository.dart';
import '../domain/line_up.dart';
import '../domain/line_up_list_query.dart';

part 'line_up_list_controller.g.dart';

/// What the Line-ups screen is currently searching, filtering and sorting
/// by. Kept alive so the choices survive switching tabs.
@Riverpod(keepAlive: true)
class LineUpListController extends _$LineUpListController {
  @override
  LineUpListQuery build() => const LineUpListQuery();

  void setSearch(String value) => state = state.copyWith(search: value);
  void setSort(LineUpSort sort) => state = state.copyWith(sort: sort);

  /// Tapping the active filter turns it off.
  void toggleTiming(LineUpTiming timing) =>
      state = state.withFilters(timing: state.timing == timing ? null : timing, content: state.content);
  void toggleContent(LineUpContent content) =>
      state = state.withFilters(timing: state.timing, content: state.content == content ? null : content);

  void clearFilters() => state = state.withFilters();
}

/// The library for the current [LineUpListController] query. Rebuilds keep
/// the previous list as `value` while the next one loads.
@riverpod
Stream<List<LineUp>> libraryLineUps(Ref ref) {
  final workspaceId = ref.watch(activeWorkspaceIdProvider);
  final query = ref.watch(lineUpListControllerProvider);
  if (workspaceId == null) return Stream.value(const []);
  return ref.watch(lineUpsRepositoryProvider).watchLibrary(workspaceId, query);
}
