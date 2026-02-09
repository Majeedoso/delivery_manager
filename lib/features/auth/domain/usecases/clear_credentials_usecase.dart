import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_secure_storage_repository.dart';

/// Use case for clearing saved user credentials from secure storage
/// 
/// This use case removes any previously saved email and password credentials
/// from secure storage. Used when the user disables "Remember Me" or
/// explicitly wants to clear saved credentials.
/// 
/// After clearing, the login form will not be pre-filled with saved credentials.
class ClearCredentialsUseCase implements BaseUseCase<bool, NoParameters> {
  /// The secure storage repository to clear credentials from
  final BaseSecureStorageRepository _repository;

  const ClearCredentialsUseCase(this._repository);

  /// Execute the use case to clear saved credentials
  /// 
  /// Returns:
  /// - Right(true) if credentials are cleared successfully
  /// - Left(Failure) if clearing fails
  @override
  Future<Either<Failure, bool>> call(NoParameters parameters) async {
    return await _repository.clearCredentials();
  }
}
