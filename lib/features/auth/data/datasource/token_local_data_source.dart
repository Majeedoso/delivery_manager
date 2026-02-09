import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Abstract interface for token local data source
///
/// Defines the contract for secure token storage:
/// - Saving tokens to secure storage
/// - Retrieving tokens from secure storage
/// - Clearing tokens
/// - Checking token existence
///
/// The implementation uses Flutter Secure Storage for encrypted storage.
abstract class BaseTokenLocalDataSource {
  /// Save authentication token to secure storage
  Future<void> saveToken(String token);

  /// Get authentication token from secure storage
  /// Returns null if no token is saved
  Future<String?> getToken();

  /// Clear authentication token from secure storage
  Future<void> clearToken();

  /// Check if a token exists in secure storage
  Future<bool> hasToken();
}

/// Implementation of [BaseTokenLocalDataSource]
///
/// Uses Flutter Secure Storage to store authentication tokens securely.
/// Tokens are encrypted on Android (using EncryptedSharedPreferences)
/// and stored in iOS Keychain.
///
/// Includes robust error recovery for corrupted Android Keystore scenarios.
/// When the keystore database is corrupted, operations will fail gracefully
/// and attempt to recover by clearing all data.
class TokenLocalDataSource implements BaseTokenLocalDataSource {
  /// Flutter Secure Storage instance with platform-specific options
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Storage key for authentication token
  static const String _tokenKey = 'auth_token';

  /// Flag to track if we've already tried to recover from storage errors
  static bool _hasAttemptedRecovery = false;

  /// Attempt to recover from storage corruption by clearing all data
  /// This is called when we detect a corrupted keystore
  Future<void> _attemptRecovery() async {
    if (_hasAttemptedRecovery) return;
    _hasAttemptedRecovery = true;

    try {
      if (kDebugMode) {
        print(
          '🔧 [TOKEN_STORAGE] Attempting to recover from corrupted storage...',
        );
      }
      // Try to delete all data to reset the storage
      await _storage.deleteAll();
      if (kDebugMode) {
        print('🔧 [TOKEN_STORAGE] Storage cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔧 [TOKEN_STORAGE] Recovery failed: $e');
      }
      // Recovery failed, but we can still continue
      // The storage might be completely inaccessible
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      if (kDebugMode) {
        print('🔴 [TOKEN_STORAGE] Error saving token: $e');
      }
      // Try recovery and retry once
      await _attemptRecovery();
      try {
        await _storage.write(key: _tokenKey, value: token);
      } catch (_) {
        // Storage is broken, silently fail
        // The token will need to be stored elsewhere (e.g., in memory)
        if (kDebugMode) {
          print('🔴 [TOKEN_STORAGE] Token save failed after recovery attempt');
        }
      }
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('🔴 [TOKEN_STORAGE] Error reading token: $e');
      }
      // Storage is corrupted, try recovery
      await _attemptRecovery();
      // Return null - caller should handle this gracefully
      return null;
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('🔴 [TOKEN_STORAGE] Error clearing token: $e');
      }
      // Try to clear all as recovery
      await _attemptRecovery();
    }
  }

  @override
  Future<bool> hasToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('🔴 [TOKEN_STORAGE] Error checking token: $e');
      }
      // Storage is corrupted, try recovery
      await _attemptRecovery();
      return false;
    }
  }
}
