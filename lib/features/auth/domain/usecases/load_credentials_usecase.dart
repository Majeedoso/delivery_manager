import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_secure_storage_repository.dart';

/// Use case for loading saved user credentials from secure storage
/// 
/// This use case retrieves previously saved email and password credentials
/// from secure storage. Used to pre-fill the login form when the user
/// has enabled "Remember Me" functionality.
/// 
/// Returns a map with 'email', 'password', and 'rememberMe' keys.
/// Values may be null if no credentials were saved.
class LoadCredentialsUseCase implements BaseUseCase<Map<String, String?>, NoParameters> {
  /// The secure storage repository to load credentials from
  final BaseSecureStorageRepository _repository;

  const LoadCredentialsUseCase(this._repository);

  /// Execute the use case to load saved credentials
  /// 
  /// Returns:
  /// - Right(Map<String, String?>) containing 'email', 'password', and 'rememberMe' keys
  /// - Left(Failure) if loading fails
  @override
  Future<Either<Failure, Map<String, String?>>> call(NoParameters parameters) async {
    return await _repository.loadCredentials();
  }
}
