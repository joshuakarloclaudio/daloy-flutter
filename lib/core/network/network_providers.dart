import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/application/session_controller.dart';
import '../config/app_config.dart';
import '../realtime/realtime_client.dart';
import '../storage/session_store.dart';
import 'api_client.dart';
import 'auth_headers_interceptor.dart';

part 'network_providers.g.dart';

/// Loaded in `main()` before the first frame and injected with an override.
@Riverpod(keepAlive: true)
SessionStore sessionStore(Ref ref) => throw UnimplementedError('sessionStoreProvider must be overridden in main()');

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio =
      Dio(
          BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
            connectTimeout: AppConfig.requestTimeout,
            receiveTimeout: AppConfig.requestTimeout,
            headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
          ),
        )
        // Dart drops an idle connection after 15s, so taps further apart than
        // that (most of a live set) each paid for a new TCP + TLS handshake.
        // Kept under the 75s nginx and most proxies allow, so the server isn't
        // the one to close it first.
        ..httpClientAdapter = IOHttpClientAdapter(
          createHttpClient: () => HttpClient()..idleTimeout = AppConfig.httpIdleTimeout,
        );

  dio.interceptors.add(
    AuthHeadersInterceptor(
      ref.watch(sessionStoreProvider),
      onUnauthorized: () => ref.read(sessionControllerProvider.notifier).handleUnauthorized(),
      socketId: () => ref.read(realtimeClientProvider).socketId,
    ),
  );
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(requestHeader: false, responseHeader: false, logPrint: (line) => debugPrint('$line')),
    );
  }

  ref.onDispose(dio.close);
  return dio;
}

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient(ref.watch(dioProvider));
