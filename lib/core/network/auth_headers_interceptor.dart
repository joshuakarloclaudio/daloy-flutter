import 'package:dio/dio.dart';

import '../storage/session_store.dart';

/// Attaches `Authorization` and `X-Workspace-ID` from the [SessionStore]
/// (plus `X-Socket-ID` while the realtime socket is up, like Echo does), and
/// reports a 401 so the session can be dropped.
class AuthHeadersInterceptor extends Interceptor {
  AuthHeadersInterceptor(this._store, {this.onUnauthorized, this.socketId});

  final SessionStore _store;
  final void Function()? onUnauthorized;
  final String? Function()? socketId;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _store.token;
    final workspaceId = _store.workspaceId;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    if (workspaceId != null) options.headers['X-Workspace-ID'] = '$workspaceId';
    if (socketId?.call() case final id?) options.headers['X-Socket-ID'] = id;
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) onUnauthorized?.call();
    handler.next(err);
  }
}
