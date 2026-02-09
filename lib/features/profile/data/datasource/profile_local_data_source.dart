import 'package:shared_preferences/shared_preferences.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/features/profile/data/models/profile_model.dart';
import 'dart:convert';

abstract class BaseProfileLocalDataSource {
  Future<ProfileModel> getCachedProfile();
  Future<void> cacheProfile(ProfileModel profile);
  Future<void> clearCachedProfile();
}

class ProfileLocalDataSource implements BaseProfileLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedProfileKey = 'CACHED_PROFILE';

  ProfileLocalDataSource({required this.sharedPreferences});

  @override
  Future<ProfileModel> getCachedProfile() async {
    try {
      final cachedProfile = sharedPreferences.getString(cachedProfileKey);
      if (cachedProfile != null) {
        return ProfileModel.fromJson(json.decode(cachedProfile));
      } else {
        throw CacheException('No cached profile found');
      }
    } catch (e) {
      throw CacheException('Failed to get cached profile: $e');
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    try {
      await sharedPreferences.setString(
        cachedProfileKey,
        json.encode(profile.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache profile: $e');
    }
  }

  @override
  Future<void> clearCachedProfile() async {
    try {
      await sharedPreferences.remove(cachedProfileKey);
    } catch (e) {
      throw CacheException('Failed to clear cached profile: $e');
    }
  }
}
