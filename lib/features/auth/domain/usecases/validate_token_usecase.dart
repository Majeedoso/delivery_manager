import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';

/// Use case for validating authentication token with the backend server
/// 
/// This use case sends the token to the backend API to verify if it's still valid.
/// Used during app startup to check if the user's session is still active.
/// 
/// Returns true if the token is valid and accepted by the server,
/// false if the token is invalid or expired.
class ValidateTokenUseCase implements BaseUseCase<bool, ValidateTokenParameters> {
  /// The token repository to validate the token through
  final BaseTokenRepository _repository;

  const ValidateTokenUseCase(this._repository);

  /// Execute the use case to validate the authentication token
  /// 
  /// Parameters:
  /// - [parameters.token]: The authentication token to validate
  /// 
  /// Returns:
  /// - Right(true) if token is valid
  /// - Right(false) if token is invalid or expired
  /// - Left(Failure) if validation request fails
  @override
  Future<Either<Failure, bool>> call(ValidateTokenParameters parameters) async {
    return await _repository.validateToken(parameters.token);
  }
}

/// Parameters for validate token use case
/// 
/// Contains the authentication token to be validated.
class ValidateTokenParameters {
  /// The authentication token to validate
  final String token;

  const ValidateTokenParameters({required this.token});
}
