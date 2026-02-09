import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/utils/app_constance.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';

/// Abstract interface for local authentication data source
/// 
/// Defines the contract for local data persistence:
/// - Saving and retrieving user data
/// - Saving and retrieving authentication tokens
/// - Clearing user data and tokens
/// 
/// The implementation uses SharedPreferences for storage.
abstract class BaseAuthLocalDataSource {
  /// Save user data to local storage
  Future<void> saveUser(UserModel user);
  
  /// Save authentication token to local storage
  Future<void> saveToken(String token);
  
  /// Get current user from local storage
  /// Returns null if no user is saved
  Future<UserModel?> getCurrentUser();
  
  /// Get authentication token from local storage
  /// Returns null if no token is saved
  Future<String?> getToken();
  
  /// Clear user data from local storage
  Future<void> clearUser();
  
  /// Clear authentication token from local storage
  Future<void> clearToken();
}

/// Implementation of [BaseAuthLocalDataSource]
/// 
/// Uses SharedPreferences to persist user data and tokens locally.
/// Throws [LocalDatabaseException] if storage operations fail.
class AuthLocalDataSource extends BaseAuthLocalDataSource {
  /// SharedPreferences instance for local storage
  final SharedPreferences sharedPreferences;

  AuthLocalDataSource({required this.sharedPreferences});

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await sharedPreferences.setString(AppConstance.userKey, jsonEncode(user.toJson()));
    } catch (e) {
      throw LocalDatabaseException(message: 'Failed to save user data');
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await sharedPreferences.setString(AppConstance.tokenKey, token);
    } catch (e) {
      throw LocalDatabaseException(message: 'Failed to save token');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userString = sharedPreferences.getString(AppConstance.userKey);
      if (userString != null) {
        final userJson = jsonDecode(userString);
        return UserModel.fromJson(userJson);
      }
      return null;
    } catch (e) {
      throw LocalDatabaseException(message: 'Failed to get user data');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString(AppConstance.tokenKey);
    } catch (e) {
      throw LocalDatabaseException(message: 'Failed to get token');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await sharedPreferences.remove(AppConstance.userKey);
    } catch (e) {
      throw LocalDatabaseException(message: 'Failed to clear user data');
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await sharedPreferences.remove(AppConstance.tokenKey);
    } catch (e) {
      throw LocalDatabaseException(message: 'Failed to clear token');
    }
  }
}
