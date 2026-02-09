import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/user.dart';
import '../repository/base_auth_repository.dart';

/// Use case for Google Sign-In authentication
/// 
/// This use case handles the Google Sign-In flow for existing users:
/// 1. Initiates Google Sign-In via Firebase
/// 2. Authenticates with Firebase using Google credentials
/// 3. Sends user data to backend API for authentication
/// 4. Repository automatically saves token and user data locally
/// 
/// Returns a [User] entity with authentication token if the user already
/// exists in the system. For new users, use [GoogleSignUpUseCase] instead.
class GoogleSignInUseCase implements BaseUseCase<User, NoParameters> {
  /// The authentication repository to perform Google Sign-In
  final BaseAuthRepository _baseAuthRepository;

  GoogleSignInUseCase(this._baseAuthRepository);

  /// Execute the use case to sign in with Google
  /// 
  /// Returns:
  /// - Right(User) if Google Sign-In is successful and user exists
  /// - Left(Failure) if sign-in fails (cancelled, network error, user doesn't exist, etc.)
  @override
  Future<Either<Failure, User>> call(NoParameters parameters) async {
    return await _baseAuthRepository.googleSignIn();
  }
}
