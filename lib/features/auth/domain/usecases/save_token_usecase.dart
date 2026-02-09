import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';

/// Use case for saving authentication token securely
/// 
/// This use case saves the authentication token to secure storage
/// (Flutter Secure Storage) for persistent authentication across app sessions.
/// 
/// The token is stored securely and can be retrieved later to validate
/// the user's authentication status without requiring login.
class SaveTokenUseCase implements BaseUseCase<bool, SaveTokenParameters> {
  /// The token repository to save the token
  final BaseTokenRepository _repository;

  const SaveTokenUseCase(this._repository);

  /// Execute the use case to save the authentication token
  /// 
  /// Parameters:
  /// - [parameters.token]: The authentication token to save
  /// 
  /// Returns:
  /// - Right(true) if token is saved successfully
  /// - Left(Failure) if saving fails
  @override
  Future<Either<Failure, bool>> call(SaveTokenParameters parameters) async {
    return await _repository.saveToken(parameters.token);
  }
}

/// Parameters for save token use case
/// 
/// Contains the authentication token to be saved.
class SaveTokenParameters {
  /// The authentication token to save
  final String token;

  const SaveTokenParameters({required this.token});
}
