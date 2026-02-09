import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repository/base_auth_repository.dart';

/// Use case for Google Sign-Out
/// 
/// This use case handles signing out from Google authentication:
/// 1. Signs out from Firebase Authentication
/// 2. Signs out from Google Sign-In service
/// 3. Clears local user data and authentication token
/// 
/// Used when a user who signed in with Google wants to log out or switch accounts.
class GoogleSignOutUseCase implements BaseUseCase<void, NoParameters> {
  /// The authentication repository to perform Google Sign-Out
  final BaseAuthRepository _baseAuthRepository;

  GoogleSignOutUseCase(this._baseAuthRepository);

  /// Execute the use case to sign out from Google
  /// 
  /// Returns:
  /// - Right(void) if sign-out is successful
  /// - Left(Failure) if an error occurs during sign-out
  @override
  Future<Either<Failure, void>> call(NoParameters parameters) async {
    return await _baseAuthRepository.googleSignOut();
  }
}
