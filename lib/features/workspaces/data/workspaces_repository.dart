import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/app_database.dart';
import '../../auth/application/session_controller.dart';
import '../domain/workspace.dart';

part 'workspaces_repository.g.dart';

class WorkspacesService {
  const WorkspacesService(this._api);

  final ApiClient _api;

  Future<List<Workspace>> list() => _api.get('/api/workspaces', Decode.list(Workspace.fromJson));

  /// `WorkspaceBriefData` — `{ id, name }`; the creator is its admin.
  Future<Workspace> create(String name) => _api.post('/api/workspaces', (json) {
    final brief = json! as JsonMap;
    return Workspace(id: brief['id'] as int, name: brief['name'] as String, role: 'admin');
  }, body: {'name': name});
}

/// Workspaces the user belongs to, cached for the switcher and offline use.
class WorkspacesRepository {
  const WorkspacesRepository(this._db, this._service);

  final AppDatabase _db;
  final WorkspacesService _service;

  Stream<Workspace?> watch(int id) => (_db.select(
    _db.workspaces,
  )..where((t) => t.id.equals(id))).watchSingleOrNull().map((row) => row == null ? null : _fromRow(row));

  Stream<List<Workspace>> watchAll() => (_db.select(
    _db.workspaces,
  )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch().map((rows) => rows.map(_fromRow).toList());

  Future<void> sync() async {
    final workspaces = await _service.list();
    await _db.transaction(() async {
      await (_db.delete(_db.workspaces)..where((t) => t.id.isNotIn(workspaces.map((w) => w.id)))).go();
      await _db.batch(
        (b) => b.insertAllOnConflictUpdate(_db.workspaces, [
          for (final w in workspaces)
            WorkspacesCompanion.insert(id: Value(w.id), name: w.name, role: w.role, isMember: Value(w.isMember)),
        ]),
      );
    });
  }

  /// Creates it on the server, then caches it so the switcher shows it at once.
  Future<Workspace> create(String name) async {
    final workspace = await _service.create(name);
    await _db
        .into(_db.workspaces)
        .insertOnConflictUpdate(
          WorkspacesCompanion.insert(
            id: Value(workspace.id),
            name: workspace.name,
            role: workspace.role,
            isMember: Value(workspace.isMember),
          ),
        );
    return workspace;
  }

  static Workspace _fromRow(WorkspaceRow row) =>
      Workspace(id: row.id, name: row.name, role: row.role, isMember: row.isMember);
}

@Riverpod(keepAlive: true)
WorkspacesRepository workspacesRepository(Ref ref) =>
    WorkspacesRepository(ref.watch(appDatabaseProvider), WorkspacesService(ref.watch(apiClientProvider)));

@riverpod
Stream<Workspace?> activeWorkspace(Ref ref) {
  final id = ref.watch(activeWorkspaceIdProvider);
  if (id == null) return Stream.value(null);
  return ref.watch(workspacesRepositoryProvider).watch(id);
}

@riverpod
Stream<List<Workspace>> workspaces(Ref ref) => ref.watch(workspacesRepositoryProvider).watchAll();
