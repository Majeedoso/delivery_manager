import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';

/// Use case for retrieving the currently authenticated user
/// 
/// This use case fetches the current user from the authentication repository.
/// Returns null if no user is currently authenticated.
/// 
/// The repository implementation handles:
/// - Local storage retrieval
/// - Remote server synchronization to get fresh user data
/// - Fallback to local data if remote fetch fails
class GetCurrentUserUseCase extends BaseUseCase<User?, NoParameters> {
  /// The authentication repository to fetch user data from
  final BaseAuthRepository baseAuthRepository;

  GetCurrentUserUseCase(this.baseAuthRepository);

  /// Execute the use case to get the current user
  /// 
  /// Returns:
  /// - Right(User?) if successful (null if no user is authenticated)
  /// - Left(Failure) if an error occurs
  @override
  Future<Either<Failure, User?>> call(NoParameters parameters) async {
    return await baseAuthRepository.getCurrentUser();
  }
}
