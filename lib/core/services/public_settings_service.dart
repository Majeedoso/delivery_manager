import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the manager sets on the server and the app needs: the token of the
/// maps, how long before another emailed code can be asked for… These live
/// in the backend's settings table (manager app → Settings) and are read
/// from `GET /settings/public`. None of them is written in the app or its
/// .env, so changing one needs no new build.
///
/// The last values received are kept on the phone: they are there at the
/// next start, before the server has answered.
class PublicSettingsService {
  PublicSettingsService({
    required Dio dio,
    required SharedPreferences preferences,
  }) : _dio = dio,
       _preferences = preferences {
    _values = _stored();
  }

  static const String path = '/settings/public';
  static const String _storageKey = 'public_settings';

  final Dio _dio;
  final SharedPreferences _preferences;
  Map<String, dynamic> _values = const {};
  Future<void>? _refreshing;

  /// Asks the server for the current values. When it can't be reached the
  /// last known ones stay; it never throws.
  Future<void> refresh() =>
      _refreshing ??= _fetch().whenComplete(() => _refreshing = null);

  Future<void> _fetch() async {
    try {
      final response = await _dio.get(path);
      final body = response.data;
      final list = body is Map ? body['data'] : null;
      if (list is! List) return;
      final values = <String, dynamic>{
        for (final setting in list)
          if (setting is Map && setting['key'] is String)
            setting['key'] as String: setting['value'],
      };
      _values = values;
      await _preferences.setString(_storageKey, jsonEncode(values));
    } catch (_) {
      // Offline or a server error: the last known values stay
    }
  }

  Map<String, dynamic> _stored() {
    try {
      final decoded = jsonDecode(_preferences.getString(_storageKey) ?? '');
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  /// A text setting, '' when the server has not given it.
  String text(String key) {
    final value = _values[key];
    return value is String ? value : '';
  }

  /// A whole-number setting, [fallback] when the server has not given it.
  int number(String key, {required int fallback}) {
    final value = _values[key];
    return value is num ? value.toInt() : fallback;
  }

  /// A decimal setting, [fallback] when the server has not given it.
  double decimal(String key, {required double fallback}) {
    final value = _values[key];
    return value is num ? value.toDouble() : fallback;
  }

  /// The Mapbox public token of the maps ('' until the server gave one).
  String get mapToken => text('app_mapbox_access_token');

  /// Where the map opens when no position is known yet (the service area).
  double get mapDefaultLatitude =>
      decimal('map_default_latitude', fallback: 36.247524721057616);
  double get mapDefaultLongitude =>
      decimal('map_default_longitude', fallback: 0.92113119431679);

  /// Seconds to wait before another emailed code can be requested.
  int get otpResendWaitSeconds =>
      number('otp_resend_wait_seconds', fallback: 120);
}
