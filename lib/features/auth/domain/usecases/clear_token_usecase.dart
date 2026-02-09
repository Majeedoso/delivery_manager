import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';

/// Use case for clearing authentication token from secure storage
/// 
/// This use case removes the saved authentication token from secure storage.
/// Used during logout or when authentication needs to be cleared.
/// 
/// After clearing the token, the user will need to login again
/// to access authenticated features.
class ClearTokenUseCase implements BaseUseCase<bool, NoParameters> {
  /// The token repository to clear the token from
  final BaseTokenRepository _repository;

  const ClearTokenUseCase(this._repository);

  /// Execute the use case to clear the authentication token
  /// 
  /// Returns:
  /// - Right(true) if token is cleared successfully
  /// - Left(Failure) if clearing fails
  @override
  Future<Either<Failure, bool>> call(NoParameters parameters) async {
    return await _repository.clearToken();
  }
}
