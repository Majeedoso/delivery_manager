import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';

/// Abstract repository interface for secure credential storage
/// 
/// This repository defines the contract for managing user credentials
/// (email and password) securely for "Remember Me" functionality:
/// - Saving credentials when user enables "Remember Me"
/// - Loading saved credentials to pre-fill login form
/// - Clearing credentials when user disables "Remember Me"
/// - Checking if credentials are saved
/// 
/// The implementation should use Flutter Secure Storage to ensure credentials
/// are stored securely and encrypted on the device.
/// 
/// This follows the Repository Pattern to abstract credential storage from business logic.
abstract class BaseSecureStorageRepository {
  /// Save user credentials securely
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [rememberMe]: Whether to save credentials (true) or clear existing ones (false)
  /// 
  /// Returns:
  /// - Right(true) if credentials are saved/cleared successfully
  /// - Left(Failure) if operation fails
  /// 
  /// If [rememberMe] is true, saves credentials to secure storage.
  /// If [rememberMe] is false, clears any existing saved credentials.
  Future<Either<Failure, bool>> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  });

  /// Load saved credentials
  /// 
  /// Returns:
  /// - Right(Map<String, String?>) containing:
  ///   - 'email': User's saved email (null if not saved)
  ///   - 'password': User's saved password (null if not saved)
  ///   - 'rememberMe': 'true' if credentials were saved, null otherwise
  /// - Left(Failure) if loading fails
  /// 
  /// Retrieves previously saved credentials from secure storage.
  /// Used to pre-fill the login form.
  Future<Either<Failure, Map<String, String?>>> loadCredentials();

  /// Clear saved credentials
  /// 
  /// Returns:
  /// - Right(true) if credentials are cleared successfully
  /// - Left(Failure) if clearing fails
  /// 
  /// Removes all saved credentials from secure storage.
  /// Used when user disables "Remember Me" or explicitly wants to clear credentials.
  Future<Either<Failure, bool>> clearCredentials();

  /// Check if credentials are saved
  /// 
  /// Returns:
  /// - Right(true) if credentials are saved
  /// - Right(false) if no credentials are saved
  /// - Left(Failure) if check fails
  /// 
  /// Verifies if credentials have been saved without retrieving them.
  /// Used to determine if the login form should be pre-filled.
  Future<Either<Failure, bool>> hasSavedCredentials();
}
