import 'package:dio/dio.dart';

/// Everything [ApiClient] throws. Catch these in controllers, not services
/// (same rule as `ApiError` / `ApiValidationError` on the web).
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    if (response == null) {
      return switch (error.type) {
        DioExceptionType.connectionTimeout || DioExceptionType.sendTimeout || DioExceptionType.receiveTimeout =>
          const NetworkException('Request timed out. Check your connection and try again.'),
        _ => const NetworkException("Couldn't reach the server. Check your connection."),
      };
    }

    final body = response.data;
    final status = response.statusCode ?? 0;
    final errors = _validationErrors(body);
    if (status == 422 && errors != null) {
      return ApiValidationException(errors);
    }

    final message = body is Map<String, dynamic> && body['message'] is String
        ? body['message'] as String
        : 'An unexpected error occurred.';
    if (status == 409) {
      return ApiConflictException(message, body is Map<String, dynamic> ? body['data'] : null);
    }
    return ApiHttpException(status, message);
  }

  @override
  String toString() => '$runtimeType: $message';
}

/// Non-2xx response from the API.
final class ApiHttpException extends ApiException {
  const ApiHttpException(this.status, super.message);

  final int status;

  bool get isUnauthorized => status == 401;
}

/// 409: the write was based on something another device changed since.
/// [data] is the server's current copy (the envelope's `data`).
final class ApiConflictException extends ApiException {
  const ApiConflictException(super.message, this.data);

  final Object? data;
}

/// 422 with `{ data: { errors: { field: [messages] } } }`.
final class ApiValidationException extends ApiException {
  const ApiValidationException(this.errors) : super('Validation failed');

  final Map<String, List<String>> errors;

  String? firstErrorFor(String field) => errors[field]?.firstOrNull;
}

/// No response at all — offline, DNS, timeout.
final class NetworkException extends ApiException {
  const NetworkException(super.message);
}

Map<String, List<String>>? _validationErrors(Object? body) {
  if (body is! Map<String, dynamic>) return null;
  final data = body['data'];
  final raw = data is Map<String, dynamic> ? data['errors'] : body['errors'];
  if (raw is! Map<String, dynamic>) return null;
  return raw.map(
    (field, messages) => MapEntry(field, messages is List ? messages.map((m) => '$m').toList() : ['$messages']),
  );
}

/// The sentence to show for a failed call: the first field error for a 422,
/// the server's own message otherwise.
String apiErrorMessage(Object error) => switch (error) {
  ApiValidationException(:final errors) => errors.values.expand((m) => m).firstOrNull ?? error.message,
  ApiException(:final message) => message,
  _ => 'Something went wrong. Try again.',
};
