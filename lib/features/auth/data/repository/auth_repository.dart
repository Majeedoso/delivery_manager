import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/google_auth_remote_data_source.dart';
import 'package:delivery_manager/features/auth/domain/entities/auth_response.dart';
import 'package:delivery_manager/features/auth/domain/entities/resend_verification_email_response.dart';
import 'package:delivery_manager/features/auth/domain/entities/resend_password_reset_otp_response.dart';
import 'package:delivery_manager/features/auth/domain/entities/verify_email_otp_response.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';
import 'package:delivery_manager/features/auth/data/models/verify_email_otp_response_model.dart';

/// Implementation of [BaseAuthRepository]
/// 
/// This repository coordinates between remote and local data sources
/// to provide a unified authentication interface:
/// - Remote data sources: API calls for login, register, logout, Google auth
/// - Local data sources: Persistent storage for user data and tokens
/// - Token repository: Secure token management
/// 
/// Handles error conversion from exceptions to failures and ensures
/// local data is synchronized with remote operations.
class AuthRepository extends BaseAuthRepository {
  /// Remote data source for authentication API calls
  final BaseAuthRemoteDataSource baseAuthRemoteDataSource;
  
  /// Local data source for caching user data
  final BaseAuthLocalDataSource baseAuthLocalDataSource;
  
  /// Remote data source for Google authentication
  final BaseGoogleAuthRemoteDataSource baseGoogleAuthRemoteDataSource;
  
  /// Repository for managing authentication tokens securely
  final BaseTokenRepository baseTokenRepository;

  AuthRepository({
    required this.baseAuthRemoteDataSource,
    required this.baseAuthLocalDataSource,
    required this.baseGoogleAuthRemoteDataSource,
    required this.baseTokenRepository,
  });

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    try {
      final result = await baseAuthRemoteDataSource.register(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
      );

      // Save user data and token locally
      await baseAuthLocalDataSource.saveUser(result.user as UserModel);
      await baseAuthLocalDataSource.saveToken(result.token);

      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } on LocalDatabaseException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await baseAuthRemoteDataSource.login(
        email: email,
        password: password,
      );

      // Save user data and token locally
      await baseAuthLocalDataSource.saveUser(result.user as UserModel);
      await baseAuthLocalDataSource.saveToken(result.token);

      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } on LocalDatabaseException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Get token before clearing local data
      final token = await baseAuthLocalDataSource.getToken();
      
      // Call logout API with token (non-blocking)
      if (token != null) {
        // Don't await - let it run in background
        _logoutWithToken(token);
      }
      
      // Clear local data immediately
      await baseAuthLocalDataSource.clearUser();
      await baseAuthLocalDataSource.clearToken();

      return const Right(null);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } on LocalDatabaseException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  Future<void> _logoutWithToken(String token) async {
    // This would be a separate method in the remote data source
    // For now, we'll implement it here
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10), // 10 seconds to establish connection
        receiveTimeout: const Duration(seconds: 10), // 10 seconds to receive response
        sendTimeout: const Duration(seconds: 10), // 10 seconds to send request
      ));
      
      // Get current language for Accept-Language header
      String languageCode = 'ar'; // Default to Arabic
      try {
        final sharedPreferences = await SharedPreferences.getInstance();
        final savedLanguageCode = sharedPreferences.getString('selected_language');
        if (savedLanguageCode != null && ['ar', 'en', 'fr'].contains(savedLanguageCode)) {
          languageCode = savedLanguageCode;
        }
      } catch (e) {
        // If language retrieval fails, use default
      }

      await dio.post(
        ApiConstance.logoutPath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Accept-Language': languageCode,
          },
        ),
      );
    } on DioException {
      // Handle timeout and connection errors
      // Note: Logging is handled by the data source layer
      // We don't need to log here as logout should always succeed locally
    } catch (e) {
      // Log the error but don't fail the logout process
      // Note: Logging is handled by the data source layer
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // First try to get user from local storage
      final localUser = await baseAuthLocalDataSource.getCurrentUser();
      
      // If no local user, return null
      if (localUser == null) {
        return const Right(null);
      }
      
      // Get token to make API call
      final tokenResult = await baseTokenRepository.getToken();
      final token = tokenResult.fold(
        (failure) => null,
        (token) => token,
      );
      
      // If no token, return local user
      if (token == null || token.isEmpty) {
        return Right(localUser);
      }
      
      // Fetch fresh user data from server
      try {
        // Use the configured Dio instance from service locator (has baseUrl and interceptors)
        final dio = sl<Dio>();
        final response = await dio.get(
          ApiConstance.userPath,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
        
        if (response.statusCode == 200 && response.data['success'] == true) {
          final userData = response.data['data'];
          final freshUser = UserModel.fromJson(userData);
          
          // Update local storage with fresh data
          await baseAuthLocalDataSource.saveUser(freshUser);
          
          return Right(freshUser);
        } else {
          // API call succeeded but response format is unexpected
          // Log and return local user as fallback
          return Right(localUser);
        }
      } catch (e) {
        // If API call fails, log the error but still return local user as fallback
        // This allows offline access, but user should be aware data might be stale
        // Note: Logging is handled by the data source layer
        // During hot restart, if API fails, we use local data which might be stale
        // This is acceptable for offline scenarios, but for hot restart we should ensure API works
        return Right(localUser);
      }
    } on LocalDatabaseException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, User>> googleSignIn() async {
    try {
      final result = await baseGoogleAuthRemoteDataSource.signInWithGoogle();
      
      // Convert User to UserModel for local storage
      final userModel = UserModel(
        id: result.id,
        name: result.name,
        email: result.email,
        phone: result.phone,
        role: result.role,
        token: result.token,
        googleId: result.googleId,
      );
      
      // Save user data locally
      await baseAuthLocalDataSource.saveUser(userModel);
      
      // Save token if available using TokenRepository (FlutterSecureStorage)
      if (result.token != null) {
        await baseTokenRepository.saveToken(result.token!);
      }
      
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } on LocalDatabaseException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, User>> googleSignUp() async {
    try {
      final result = await baseGoogleAuthRemoteDataSource.signUpWithGoogle();
      
      // Convert User to UserModel for local storage
      final userModel = UserModel(
        id: result.id,
        name: result.name,
        email: result.email,
        phone: result.phone,
        role: result.role,
        token: result.token,
        googleId: result.googleId,
      );
      
      // Save user data locally
      await baseAuthLocalDataSource.saveUser(userModel);
      
      // Save token if available using TokenRepository (FlutterSecureStorage)
      if (result.token != null) {
        await baseTokenRepository.saveToken(result.token!);
      }
      
      return Right(result);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } on LocalDatabaseException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> googleSignOut() async {
    try {
      await baseGoogleAuthRemoteDataSource.signOutFromGoogle();
      
      // Clear local data
      await baseAuthLocalDataSource.clearUser();
      await baseAuthLocalDataSource.clearToken();
      
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } on LocalDatabaseException catch (failure) {
      return Left(DatabaseFailure(failure.message));
    }
  }

  @override
  Future<Either<Failure, ResendVerificationEmailResponse>> resendVerificationEmail() async {
    try {
      final response = await baseAuthRemoteDataSource.resendVerificationEmail();
      return Right(response);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ResendPasswordResetOtpResponse>> resendPasswordResetOtp(String email) async {
    try {
      final response = await baseAuthRemoteDataSource.resendPasswordResetOtp(email);
      return Right(response);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ResendPasswordResetOtpResponse>> sendPasswordResetOtpAuthenticated() async {
    try {
      final response = await baseAuthRemoteDataSource.sendPasswordResetOtpAuthenticated();
      return Right(response);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, VerifyEmailOtpResponse>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      // Get current user to preserve token
      final currentUserResult = await getCurrentUser();
      final currentUser = currentUserResult.fold(
        (failure) => null,
        (user) => user,
      );
      
      final response = await baseAuthRemoteDataSource.verifyEmailOtp(
        email: email,
        otp: otp,
      );
      
      // Preserve token from current user if available
      final userModel = response.user as UserModel;
      if (currentUser != null && currentUser.token != null) {
        final updatedUser = UserModel(
          id: userModel.id,
          name: userModel.name,
          email: userModel.email,
          phone: userModel.phone,
          role: userModel.role,
          token: currentUser.token,
          googleId: userModel.googleId,
          emailVerifiedAt: userModel.emailVerifiedAt,
          hasPassword: userModel.hasPassword,
        );
        
        // Save updated user to local storage
        await baseAuthLocalDataSource.saveUser(updatedUser);
        
        return Right(VerifyEmailOtpResponseModel(
          user: updatedUser,
          message: response.message,
        ));
      } else {
        // Save user without token (shouldn't happen in normal flow)
        await baseAuthLocalDataSource.saveUser(userModel);
        return Right(response);
      }
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await baseAuthRemoteDataSource.verifyPasswordResetOtp(
        email: email,
        otp: otp,
      );
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final message = await baseAuthRemoteDataSource.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return Right(message);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPasswordResetOtpAuthenticated({
    required String otp,
  }) async {
    try {
      await baseAuthRemoteDataSource.verifyPasswordResetOtpAuthenticated(
        otp: otp,
      );
      return const Right(null);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> resetPasswordAuthenticated({
    required String otp,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final message = await baseAuthRemoteDataSource.resetPasswordAuthenticated(
        otp: otp,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      return Right(message);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
