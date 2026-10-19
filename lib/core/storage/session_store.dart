import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The persisted sign-in: bearer token, active workspace and the last-known
/// user, kept in the Keychain / Android Keystore. The web keeps the same
/// trio in IndexedDB (`db.authSessions`).
///
/// Reads are served from memory after the first [load], so the HTTP
/// interceptor can attach headers synchronously on every request.
class SessionStore {
  SessionStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'daloy.token';
  static const _workspaceKey = 'daloy.workspace_id';
  static const _userKey = 'daloy.user';

  String? _token;
  int? _workspaceId;
  Map<String, dynamic>? _user;
  bool _loaded = false;

  String? get token => _token;
  int? get workspaceId => _workspaceId;
  Map<String, dynamic>? get user => _user;

  Future<void> load() async {
    if (_loaded) return;
    final values = await _storage.readAll();
    _token = values[_tokenKey];
    _workspaceId = int.tryParse(values[_workspaceKey] ?? '');
    final rawUser = values[_userKey];
    _user = rawUser == null ? null : jsonDecode(rawUser) as Map<String, dynamic>;
    _loaded = true;
  }

  Future<void> save({required String token, required Map<String, dynamic> user, int? workspaceId}) async {
    _token = token;
    _user = user;
    _workspaceId = workspaceId;
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _userKey, value: jsonEncode(user)),
      if (workspaceId != null)
        _storage.write(key: _workspaceKey, value: '$workspaceId')
      else
        _storage.delete(key: _workspaceKey),
    ]);
  }

  /// Uses [token] for requests before the session is saved, e.g. to look up
  /// a workspace right after sign-in. [save] or [clear] replaces it.
  void stageToken(String token) => _token = token;

  Future<void> saveUser(Map<String, dynamic> user) async {
    _user = user;
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }

  Future<void> saveWorkspaceId(int workspaceId) async {
    _workspaceId = workspaceId;
    await _storage.write(key: _workspaceKey, value: '$workspaceId');
  }

  Future<void> clear() async {
    _token = null;
    _workspaceId = null;
    _user = null;
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _workspaceKey),
      _storage.delete(key: _userKey),
    ]);
  }
}
