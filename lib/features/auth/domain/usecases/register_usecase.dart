import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/entities/auth_response.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';
import 'package:equatable/equatable.dart';

/// Use case for user registration with email and password
/// 
/// This use case handles the registration flow:
/// 1. Sends user registration data to the backend API
/// 2. Creates a new user account
/// 3. Receives authentication token and user data upon success
/// 4. Repository automatically saves token and user data locally
/// 
/// Returns an [AuthResponse] containing user information and authentication token.
class RegisterUseCase extends BaseUseCase<AuthResponse, RegisterParameters> {
  /// The authentication repository to perform registration
  final BaseAuthRepository baseAuthRepository;

  RegisterUseCase(this.baseAuthRepository);

  /// Execute the use case to register a new user
  /// 
  /// Parameters:
  /// - [parameters.name]: User's full name
  /// - [parameters.email]: User's email address
  /// - [parameters.password]: User's password
  /// - [parameters.role]: User's role (operator, restaurant, delivery, manager, customer)
  /// - [parameters.phone]: User's phone number
  /// 
  /// Returns:
  /// - Right(AuthResponse) if registration is successful
  /// - Left(Failure) if registration fails (email exists, validation error, etc.)
  @override
  Future<Either<Failure, AuthResponse>> call(RegisterParameters parameters) async {
    return await baseAuthRepository.register(
      name: parameters.name,
      email: parameters.email,
      password: parameters.password,
      role: parameters.role,
      phone: parameters.phone,
    );
  }
}

/// Parameters for registration use case
/// 
/// Contains all the information required to create a new user account.
class RegisterParameters extends Equatable {
  /// User's full name
  final String name;
  
  /// User's email address (must be unique)
  final String email;
  
  /// User's password (should meet security requirements)
  final String password;
  
  /// User's role in the system (operator, restaurant, delivery, manager, customer)
  final String role;
  
  /// User's phone number
  final String phone;

  const RegisterParameters({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.phone,
  });

  @override
  List<Object> get props => [name, email, password, role, phone];
}
