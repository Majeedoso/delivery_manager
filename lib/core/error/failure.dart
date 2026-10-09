import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  /// The server's own name for the refusal (ROLE_MISMATCH, INVALID_CREDENTIALS...),
  /// when it gave one: the app decides on it, never on the words of [message]
  String? get errorCode => null;

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  @override
  final String? errorCode;

  const ServerFailure(super.message, {this.errorCode});

  @override
  List<Object> get props => [message, if (errorCode != null) errorCode!];
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
