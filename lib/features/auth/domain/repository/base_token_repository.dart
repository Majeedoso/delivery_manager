import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';

/// Abstract repository interface for authentication token management
/// 
/// This repository defines the contract for managing authentication tokens:
/// - Saving tokens to secure storage
/// - Retrieving tokens from secure storage
/// - Clearing tokens
/// - Checking token existence
/// - Validating tokens with the backend server
/// 
/// The implementation should use Flutter Secure Storage to ensure tokens
/// are stored securely and encrypted on the device.
/// 
/// This follows the Repository Pattern to abstract token storage from business logic.
abstract class BaseTokenRepository {
  /// Save authentication token securely
  /// 
  /// Parameters:
  /// - [token]: The authentication token to save
  /// 
  /// Returns:
  /// - Right(true) if token is saved successfully
  /// - Left(Failure) if saving fails
  /// 
  /// The token should be stored in secure storage (Flutter Secure Storage)
  /// to ensure it's encrypted and protected.
  Future<Either<Failure, bool>> saveToken(String token);

  /// Get saved authentication token
  /// 
  /// Returns:
  /// - Right(String?) with the token (null if no token exists)
  /// - Left(Failure) if retrieval fails
  /// 
  /// Retrieves the token from secure storage. Returns null if no token
  /// has been saved previously.
  Future<Either<Failure, String?>> getToken();

  /// Clear saved authentication token
  /// 
  /// Returns:
  /// - Right(true) if token is cleared successfully
  /// - Left(Failure) if clearing fails
  /// 
  /// Removes the token from secure storage. Used during logout or
  /// when authentication needs to be cleared.
  Future<Either<Failure, bool>> clearToken();

  /// Check if token exists
  /// 
  /// Returns:
  /// - Right(true) if a token exists and is not empty
  /// - Right(false) if no token exists
  /// - Left(Failure) if check fails
  /// 
  /// Verifies if a token has been saved without retrieving it.
  Future<Either<Failure, bool>> hasToken();

  /// Validate token with server
  /// 
  /// Parameters:
  /// - [token]: The authentication token to validate
  /// 
  /// Returns:
  /// - Right(true) if token is valid and accepted by server
  /// - Right(false) if token is invalid or expired
  /// - Left(Failure) if validation request fails
  /// 
  /// Sends the token to the backend API to verify if it's still valid.
  /// Used during app startup to check if the user's session is active.
  Future<Either<Failure, bool>> validateToken(String token);
}
