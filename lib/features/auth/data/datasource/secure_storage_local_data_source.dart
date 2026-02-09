import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract interface for secure credential storage local data source
/// 
/// Defines the contract for storing user credentials (email/password) securely:
/// - Saving credentials when "Remember Me" is enabled
/// - Loading saved credentials
/// - Clearing saved credentials
/// - Checking if credentials are saved
/// 
/// The implementation uses Flutter Secure Storage for encrypted storage.
abstract class BaseSecureStorageLocalDataSource {
  /// Save user credentials to secure storage
  /// 
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [rememberMe]: Whether to save credentials (true) or clear existing ones (false)
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  });

  /// Load saved credentials from secure storage
  /// 
  /// Returns a map with 'email', 'password', and 'rememberMe' keys.
  /// Values may be null if credentials were not saved.
  Future<Map<String, String?>> loadCredentials();

  /// Clear saved credentials from secure storage
  Future<void> clearCredentials();

  /// Check if credentials are saved
  /// 
  /// Returns true if credentials are saved, false otherwise
  Future<bool> hasSavedCredentials();
}

/// Implementation of [BaseSecureStorageLocalDataSource]
/// 
/// Uses Flutter Secure Storage to store user credentials securely.
/// Credentials are encrypted on Android (using EncryptedSharedPreferences)
/// and stored in iOS Keychain.
class SecureStorageLocalDataSource implements BaseSecureStorageLocalDataSource {
  /// Flutter Secure Storage instance with platform-specific options
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Storage keys for credentials
  static const String _emailKey = 'saved_email';
  static const String _passwordKey = 'saved_password';
  static const String _rememberMeKey = 'remember_me';

  @override
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (rememberMe) {
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _passwordKey, value: password);
      await _storage.write(key: _rememberMeKey, value: 'true');
    } else {
      await clearCredentials();
    }
  }

  @override
  Future<Map<String, String?>> loadCredentials() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    final rememberMe = await _storage.read(key: _rememberMeKey);

    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe == 'true' ? 'true' : null,
    };
  }

  @override
  Future<void> clearCredentials() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
    await _storage.delete(key: _rememberMeKey);
  }

  @override
  Future<bool> hasSavedCredentials() async {
    final rememberMe = await _storage.read(key: _rememberMeKey);
    return rememberMe == 'true';
  }
}
