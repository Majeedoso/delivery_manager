import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/utils/app_constance.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';

/// Abstract interface for local authentication data source
/// 
/// Defines the contract for local data persistence:
/// - Saving and retrieving user data
/// - Clearing user data
/// - Removing the token an earlier version of the app also kept here
///
/// The implementation uses SharedPreferences for storage. It is plain, and
/// Android includes it in the phone's backups: the sign-in token is not kept
/// there, it lives in the encrypted storage (TokenLocalDataSource).
abstract class BaseAuthLocalDataSource {
  /// Save user data to local storage (without the user's token)
  Future<void> saveUser(UserModel user);

  /// Get current user from local storage
  /// Returns null if no user is saved
  Future<UserModel?> getCurrentUser();

  /// Clear user data from local storage
  Future<void> clearUser();

  /// Remove the copies of the token an earlier version kept in this plain
  /// storage: its own entry, and the one inside the saved user
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
      // Without the token a Google sign-in puts in the user: this storage is plain
      final json = user.toJson()..remove('token');
      await sharedPreferences.setString(AppConstance.userKey, jsonEncode(json));
    } catch (e) {
      throw LocalDatabaseException(message: 'Failed to save user data');
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

      final saved = sharedPreferences.getString(AppConstance.userKey);
      final user = saved == null ? null : jsonDecode(saved);
      if (user is Map<String, dynamic> && user.containsKey('token')) {
        user.remove('token');
        await sharedPreferences.setString(
          AppConstance.userKey,
          jsonEncode(user),
        );
      }
    } catch (e) {
      throw LocalDatabaseException(message: 'Failed to clear token');
    }
  }
}
