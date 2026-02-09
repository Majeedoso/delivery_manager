import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_secure_storage_repository.dart';

/// Use case for saving user credentials securely
/// 
/// This use case saves email and password credentials to secure storage
/// when the user enables "Remember Me" functionality.
/// 
/// Credentials are stored securely using Flutter Secure Storage and can be
/// retrieved later to pre-fill the login form.
/// 
/// If rememberMe is false, any existing saved credentials are cleared.
class SaveCredentialsUseCase implements BaseUseCase<bool, SaveCredentialsParameters> {
  /// The secure storage repository to save credentials to
  final BaseSecureStorageRepository _repository;

  const SaveCredentialsUseCase(this._repository);

  /// Execute the use case to save credentials
  /// 
  /// Parameters:
  /// - [parameters.email]: User's email address
  /// - [parameters.password]: User's password
  /// - [parameters.rememberMe]: Whether to save credentials (true) or clear if false)
  /// 
  /// Returns:
  /// - Right(true) if credentials are saved/cleared successfully
  /// - Left(Failure) if operation fails
  @override
  Future<Either<Failure, bool>> call(SaveCredentialsParameters parameters) async {
    return await _repository.saveCredentials(
      email: parameters.email,
      password: parameters.password,
      rememberMe: parameters.rememberMe,
    );
  }
}

/// Parameters for save credentials use case
/// 
/// Contains the email, password, and remember me preference.
class SaveCredentialsParameters {
  /// User's email address
  final String email;
  
  /// User's password
  final String password;
  
  /// Whether to save credentials for auto-fill
  final bool rememberMe;

  const SaveCredentialsParameters({
    required this.email,
    required this.password,
    required this.rememberMe,
  });
}
