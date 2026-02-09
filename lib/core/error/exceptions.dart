
class ServerException implements Exception {
  final String message;

  const ServerException({
    required this.message,
  });
}

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
