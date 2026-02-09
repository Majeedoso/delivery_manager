import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/auth/domain/entities/auth_response.dart';
import 'package:delivery_manager/features/auth/domain/entities/resend_verification_email_response.dart';
import 'package:delivery_manager/features/auth/domain/entities/resend_password_reset_otp_response.dart';
import 'package:delivery_manager/features/auth/domain/entities/verify_email_otp_response.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';

/// Abstract repository interface for authentication operations
/// 
/// This repository defines the contract for all authentication-related operations:
/// - User registration and login with email/password
/// - Google Sign-In and Sign-Up
/// - User logout
/// - Retrieving current authenticated user
/// 
/// The implementation is responsible for:
/// - Communicating with remote backend API
/// - Managing local data storage (user data, tokens)
/// - Handling error conversion (exceptions to failures)
/// 
/// This follows the Repository Pattern to abstract data sources from business logic.
abstract class BaseAuthRepository {
  /// Register a new user with email and password
  /// 
  /// Parameters:
  /// - [name]: User's full name
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [role]: User's role (operator, restaurant, delivery, manager, customer)
  /// - [phone]: User's phone number
  /// 
  /// Returns:
  /// - Right(AuthResponse) with user data and token upon success
  /// - Left(Failure) if registration fails
  /// 
  /// The implementation should save user data and token locally upon success.
  Future<Either<Failure, AuthResponse>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String phone,
  });

  /// Login with email and password
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// 
  /// Returns:
  /// - Right(AuthResponse) with user data and token upon success
  /// - Left(Failure) if login fails (invalid credentials, network error, etc.)
  /// 
  /// The implementation should save user data and token locally upon success.
  Future<Either<Failure, AuthResponse>> login({
    required String email,
    required String password,
  });

  /// Logout the current user
  /// 
  /// Returns:
  /// - Right(void) if logout is successful
  /// - Left(Failure) if logout fails
  /// 
  /// The implementation should:
  /// - Call backend logout API (non-blocking)
  /// - Clear local user data and authentication token
  /// - Sign out from all authentication services (Firebase, Google, etc.)
  Future<Either<Failure, void>> logout();

  /// Get the currently authenticated user
  /// 
  /// Returns:
  /// - Right(User?) with current user data (null if no user is authenticated)
  /// - Left(Failure) if retrieval fails
  /// 
  /// The implementation should:
  /// - First try to get user from local storage
  /// - Attempt to fetch fresh user data from server
  /// - Fallback to local data if server fetch fails
  Future<Either<Failure, User?>> getCurrentUser();

  /// Sign in with Google (for existing users)
  /// 
  /// Returns:
  /// - Right(User) with user data and token if user exists
  /// - Left(Failure) if sign-in fails or user doesn't exist
  /// 
  /// The implementation should:
  /// - Initiate Google Sign-In via Firebase
  /// - Send user data to backend API
  /// - Save user data and token locally upon success
  Future<Either<Failure, User>> googleSignIn();
  
  /// Sign up with Google (for new users)
  /// 
  /// Returns:
  /// - Right(User) with user data and token upon successful registration
  /// - Left(Failure) if sign-up fails
  /// 
  /// The implementation should:
  /// - Initiate Google Sign-In via Firebase
  /// - Send user data to backend API to create account
  /// - Save user data and token locally upon success
  Future<Either<Failure, User>> googleSignUp();
  
  /// Sign out from Google authentication
  /// 
  /// Returns:
  /// - Right(void) if sign-out is successful
  /// - Left(Failure) if sign-out fails
  /// 
  /// The implementation should:
  /// - Sign out from Firebase Authentication
  /// - Sign out from Google Sign-In service
  /// - Clear local user data and token
  Future<Either<Failure, void>> googleSignOut();
  
  /// Resend email verification OTP
  /// 
  /// Returns:
  /// - Right(ResendVerificationEmailResponse) with email, expiresIn, and resendCountdown if OTP is sent successfully
  /// - Left(Failure) if resend fails (e.g., email already verified, network error, rate limit)
  Future<Either<Failure, ResendVerificationEmailResponse>> resendVerificationEmail();
  
  /// Resend password reset OTP (from login page)
  /// 
  /// Parameters:
  /// - [email]: The email address to send the password reset OTP to
  /// 
  /// Returns:
  /// - Right(ResendPasswordResetOtpResponse) with email, expiresIn, and resendCountdown if OTP is sent successfully
  /// - Left(Failure) if resend fails (e.g., email not found, network error, rate limit)
  Future<Either<Failure, ResendPasswordResetOtpResponse>> resendPasswordResetOtp(String email);
  
  /// Send password reset OTP (authenticated users)
  /// 
  /// Sends a password reset OTP to the authenticated user's email.
  /// No email parameter is required as it uses the authenticated user's email.
  /// 
  /// Returns:
  /// - Right(ResendPasswordResetOtpResponse) with email, expiresIn, and resendCountdown if OTP is sent successfully
  /// - Left(Failure) if send fails (e.g., network error, rate limit)
  Future<Either<Failure, ResendPasswordResetOtpResponse>> sendPasswordResetOtpAuthenticated();
  
  /// Verify email OTP
  /// 
  /// Parameters:
  /// - [email]: The email address to verify
  /// - [otp]: The 6-digit OTP code
  /// 
  /// Returns:
  /// - Right(VerifyEmailOtpResponse) with updated user and message if OTP is valid
  /// - Left(Failure) if verification fails (e.g., invalid OTP, expired OTP)
  /// 
  /// The implementation should update local user data after successful verification.
  Future<Either<Failure, VerifyEmailOtpResponse>> verifyEmailOtp({
    required String email,
    required String otp,
  });
  
  /// Verify password reset OTP (from login page)
  /// 
  /// Parameters:
  /// - [email]: The email address
  /// - [otp]: The 6-digit OTP code
  /// 
  /// Returns:
  /// - Right(void) if OTP is valid
  /// - Left(Failure) if verification fails (e.g., invalid OTP, expired OTP)
  Future<Either<Failure, void>> verifyPasswordResetOtp({
    required String email,
    required String otp,
  });
  
  /// Reset password (from login page)
  /// 
  /// Parameters:
  /// - [email]: The email address
  /// - [otp]: The 6-digit OTP code
  /// - [password]: The new password
  /// - [passwordConfirmation]: The password confirmation
  /// 
  /// Returns:
  /// - Right(String) with success message if password is reset successfully
  /// - Left(Failure) if reset fails (e.g., invalid OTP, password validation)
  Future<Either<Failure, String>> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
  
  /// Verify password reset OTP (authenticated users)
  /// 
  /// Parameters:
  /// - [otp]: The 6-digit OTP code
  /// 
  /// Returns:
  /// - Right(void) if OTP is valid
  /// - Left(Failure) if verification fails (e.g., invalid OTP, expired OTP)
  Future<Either<Failure, void>> verifyPasswordResetOtpAuthenticated({
    required String otp,
  });
  
  /// Reset password (authenticated users)
  /// 
  /// Parameters:
  /// - [otp]: The 6-digit OTP code
  /// - [newPassword]: The new password
  /// - [newPasswordConfirmation]: The password confirmation
  /// 
  /// Returns:
  /// - Right(String) with success message if password is reset successfully
  /// - Left(Failure) if reset fails (e.g., invalid OTP, password validation)
  Future<Either<Failure, String>> resetPasswordAuthenticated({
    required String otp,
    required String newPassword,
    required String newPasswordConfirmation,
  });
}
