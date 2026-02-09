import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/user.dart';
import '../repository/base_auth_repository.dart';

/// Use case for Google Sign-Up authentication
/// 
/// This use case handles the Google Sign-Up flow for new users:
/// 1. Initiates Google Sign-In via Firebase
/// 2. Authenticates with Firebase using Google credentials
/// 3. Sends user data to backend API to create a new account
/// 4. Repository automatically saves token and user data locally
/// 
/// Returns a [User] entity with authentication token upon successful registration.
/// For existing users, use [GoogleSignInUseCase] instead.
/// 
/// Note: The implementation currently uses the same flow as Google Sign-In,
/// as the backend determines whether to create a new account or authenticate
/// an existing one based on the Google ID.
class GoogleSignUpUseCase implements BaseUseCase<User, NoParameters> {
  /// The authentication repository to perform Google Sign-Up
  final BaseAuthRepository _baseAuthRepository;

  GoogleSignUpUseCase(this._baseAuthRepository);

  /// Execute the use case to sign up with Google
  /// 
  /// Returns:
  /// - Right(User) if Google Sign-Up is successful
  /// - Left(Failure) if sign-up fails (cancelled, network error, email already exists, etc.)
  @override
  Future<Either<Failure, User>> call(NoParameters parameters) async {
    return await _baseAuthRepository.googleSignUp();
  }
}
