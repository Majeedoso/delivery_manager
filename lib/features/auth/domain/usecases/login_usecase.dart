import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/entities/auth_response.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';
import 'package:equatable/equatable.dart';

/// Use case for user login with email and password
/// 
/// This use case handles the authentication flow for email/password login:
/// 1. Sends credentials to the backend API
/// 2. Receives authentication token and user data
/// 3. Repository automatically saves token and user data locally
/// 
/// Returns an [AuthResponse] containing user information and authentication token.
class LoginUseCase extends BaseUseCase<AuthResponse, LoginParameters> {
  /// The authentication repository to perform login
  final BaseAuthRepository baseAuthRepository;

  LoginUseCase(this.baseAuthRepository);

  /// Execute the use case to login with email and password
  /// 
  /// Parameters:
  /// - [parameters.email]: User's email address
  /// - [parameters.password]: User's password
  /// 
  /// Returns:
  /// - Right(AuthResponse) if login is successful
  /// - Left(Failure) if login fails (invalid credentials, network error, etc.)
  @override
  Future<Either<Failure, AuthResponse>> call(LoginParameters parameters) async {
    return await baseAuthRepository.login(
      email: parameters.email,
      password: parameters.password,
    );
  }
}

/// Parameters for login use case
/// 
/// Contains the email and password required for authentication.
class LoginParameters extends Equatable {
  /// User's email address
  final String email;
  
  /// User's password
  final String password;

  const LoginParameters({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}
