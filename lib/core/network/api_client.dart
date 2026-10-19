import 'package:dio/dio.dart';

import 'api_exception.dart';

typedef JsonMap = Map<String, dynamic>;
typedef Decoder<T> = T Function(Object? json);

/// Typed wrapper over Dio — the Flutter twin of `lib/api-client.ts`.
///
/// Every call unwraps the `{ success, data, message }` envelope and hands
/// `data` to [Decoder]. `getDirect` skips unwrapping for the few endpoints
/// that return a raw Laravel paginator (`GET /api/songs`).
/// Auth and workspace headers are attached by `AuthHeadersInterceptor`.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<T> get<T>(String path, Decoder<T> decode, {JsonMap? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: query), decode);

  Future<T> getDirect<T>(String path, Decoder<T> decode, {JsonMap? query}) =>
      _send(() => _dio.get<Object?>(path, queryParameters: query), decode, unwrap: false);

  Future<T> post<T>(String path, Decoder<T> decode, {Object? body}) =>
      _send(() => _dio.post<Object?>(path, data: body), decode);

  Future<T> patch<T>(String path, Decoder<T> decode, {Object? body}) =>
      _send(() => _dio.patch<Object?>(path, data: body), decode);

  Future<T> put<T>(String path, Decoder<T> decode, {Object? body}) =>
      _send(() => _dio.put<Object?>(path, data: body), decode);

  Future<void> delete(String path, {Object? body}) => _send(() => _dio.delete<Object?>(path, data: body), (_) {});

  /// A DELETE whose answer carries data (e.g. the line-up after a removal).
  Future<T> deleteWith<T>(String path, Decoder<T> decode) => _send(() => _dio.delete<Object?>(path), decode);

  Future<T> _send<T>(Future<Response<Object?>> Function() request, Decoder<T> decode, {bool unwrap = true}) async {
    try {
      final response = await request();
      final body = response.data;
      return decode(unwrap && body is JsonMap ? body['data'] : body);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}

/// Decoders for the common shapes, so services stay one-liners.
abstract final class Decode {
  static T Function(Object?) object<T>(T Function(JsonMap) fromJson) =>
      (json) => fromJson(json! as JsonMap);

  static T? Function(Object?) nullable<T>(T Function(JsonMap) fromJson) =>
      (json) => json == null ? null : fromJson(json as JsonMap);

  static List<T> Function(Object?) list<T>(T Function(JsonMap) fromJson) =>
      (json) => (json! as List).cast<JsonMap>().map(fromJson).toList();
}
