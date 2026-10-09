import 'package:dio/dio.dart';
import 'package:delivery_manager/core/error/exceptions.dart';

/// What a failed request tells the manager: the server's reason, or that the
/// network failed. Dio's and Dart's own texts are for developers (the pages
/// read "Exception: Network error", "DioException [bad response]...").
///
/// The server writes its reasons in the app's language; the network's two
/// texts are the ones `ErrorMessageMapper` translates.
Exception requestFailureOf(Object error) {
  if (error is DioException) {
    final response = error.response;
    if (response == null) {
      return NetworkException(
        message: switch (error.type) {
          DioExceptionType.connectionTimeout ||
          DioExceptionType.sendTimeout ||
          DioExceptionType.receiveTimeout => 'Request timeout',
          _ => 'Network connection error',
        },
      );
    }
    final body = response.data;
    final message =
        _refusedFieldOf(body) ?? (body is Map ? body['message'] : null);
    if (message is String && message.trim().isNotEmpty) {
      return ServerException(
        message: message,
        errorCode: serverErrorCodeOf(body),
      );
    }
  }
  // An error page, or an answer the app cannot read
  return const ServerException(message: 'Server error occurred');
}

/// The sentence about the first field the server refused (`errors: {field:
/// [sentence]}`): the answer's own message only says "Validation failed".
String? _refusedFieldOf(Object? body) {
  final errors = body is Map ? body['errors'] : null;
  if (errors is! Map) return null;
  for (final sentences in errors.values) {
    final first = sentences is List && sentences.isNotEmpty
        ? sentences.first
        : sentences;
    if (first is String && first.trim().isNotEmpty) return first;
  }
  return null;
}
