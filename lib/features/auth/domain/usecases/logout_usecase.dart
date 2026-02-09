import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';

/// Use case for user logout
/// 
/// This use case handles the logout flow:
/// 1. Notifies the backend server (non-blocking)
/// 2. Clears local user data and authentication token
/// 3. Ensures user is signed out from all authentication services
/// 
/// The backend logout request is sent in the background and does not block
/// the local cleanup process, ensuring a responsive user experience.
class LogoutUseCase extends BaseUseCase<void, NoParameters> {
  /// The authentication repository to perform logout
  final BaseAuthRepository baseAuthRepository;

  LogoutUseCase(this.baseAuthRepository);

  /// Execute the use case to logout the current user
  /// 
  /// Returns:
  /// - Right(void) if logout is successful
  /// - Left(Failure) if an error occurs during logout
  @override
  Future<Either<Failure, void>> call(NoParameters parameters) async {
    return await baseAuthRepository.logout();
  }
}
