import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';

/// Use case for retrieving authentication token from secure storage
/// 
/// This use case retrieves the saved authentication token from secure storage.
/// Returns null if no token is saved.
/// 
/// Used to get the token for making authenticated API requests or
/// checking if the user has a saved authentication token.
class GetTokenUseCase implements BaseUseCase<String?, NoParameters> {
  /// The token repository to retrieve the token from
  final BaseTokenRepository _repository;

  const GetTokenUseCase(this._repository);

  /// Execute the use case to get the authentication token
  /// 
  /// Returns:
  /// - Right(String?) if successful (null if no token exists)
  /// - Left(Failure) if retrieval fails
  @override
  Future<Either<Failure, String?>> call(NoParameters parameters) async {
    return await _repository.getToken();
  }
}
