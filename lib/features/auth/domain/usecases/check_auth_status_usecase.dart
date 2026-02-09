import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';

/// Use case for checking authentication status
/// 
/// This use case verifies if the user is currently authenticated by:
/// 1. Retrieving the saved authentication token from secure storage
/// 2. Validating the token with the backend server
/// 
/// Returns true if a valid token exists and is confirmed by the server,
/// false otherwise (no token, empty token, or invalid token).
/// 
/// Used primarily during app startup in the splash screen to determine
/// if the user should be logged in automatically.
class CheckAuthStatusUseCase implements BaseUseCase<bool, NoParameters> {
  /// The token repository to check token existence and validity
  final BaseTokenRepository _repository;

  const CheckAuthStatusUseCase(this._repository);

  /// Execute the use case to check authentication status
  /// 
  /// Returns:
  /// - Right(true) if user is authenticated with a valid token
  /// - Right(false) if no token exists, token is empty, or token is invalid
  /// - Left(Failure) if an error occurs during token retrieval
  @override
  Future<Either<Failure, bool>> call(NoParameters parameters) async {
    // Get saved token
    final tokenResult = await _repository.getToken();
    
    return tokenResult.fold(
      (failure) {
        return Left(failure);
      },
      (token) async {
        if (token == null || token.isEmpty) {
          return const Right(false);
        }
        
        // Validate token with server
        final validateResult = await _repository.validateToken(token);
        return validateResult.fold(
          (failure) {
            return const Right(false);
          },
          (isValid) {
            return Right(isValid);
          },
        );
      },
    );
  }
}
