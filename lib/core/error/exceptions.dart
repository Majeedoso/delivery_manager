
/// What a failure tells the user: the server's reason, or that the network
/// failed (the exceptions' own texts are for developers).
String failureText(Object error) => switch (error) {
  ServerException(:final message) => message,
  NetworkException(:final message) => message,
  _ => 'Server error occurred',
};

class ServerException implements Exception {
  final String message;

  /// The server's own name for the refusal (ROLE_MISMATCH, INVALID_CREDENTIALS...),
  /// when it gives one: the app decides on it, never on the words of [message],
  /// which the server writes in the app's language
  final String? errorCode;

  const ServerException({
    required this.message,
    this.errorCode,
  });
}

/// The `error_code` of a server's answer, when it has one.
String? serverErrorCodeOf(dynamic responseData) =>
    responseData is Map ? responseData['error_code']?.toString() : null;

class LocalDatabaseException implements Exception {
  final String message;

  const LocalDatabaseException({
    required this.message,
  });
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    required this.message,
  });
}

class AuthException implements Exception {
  final String message;

  const AuthException({
    required this.message,
  });
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache error occurred']);
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({
    required this.message,
  });
}
