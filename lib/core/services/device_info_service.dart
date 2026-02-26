import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DeviceInfoService {
  final FlutterSecureStorage _storage;
  static const _cacheKey = 'cached_device_id';

  DeviceInfoService(this._storage);

  /// Returns a stable identifier for this device/install.
  ///
  /// - Android: build fingerprint (hardware + firmware composite, no permission needed)
  /// - iOS: identifierForVendor (unique per app-vendor group per device)
  /// - Returns null silently on failure — registration still proceeds without it.
  Future<String?> getDeviceId() async {
    // Serve cached value to avoid repeated platform calls
    final cached = await _storage.read(key: _cacheKey);
    if (cached != null && cached.isNotEmpty) return cached;

    try {
      final plugin = DeviceInfoPlugin();
      String? id;

      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        id = info.fingerprint; // e.g. "google/walleye/walleye:10/QQ3A.200..."
      } else if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        id = info.identifierForVendor; // UUID string, unique per vendor per device
      }

      if (id != null && id.isNotEmpty) {
        await _storage.write(key: _cacheKey, value: id);
        return id;
      }
    } catch (_) {
      // Silently fail — device_id is optional on the backend
    }

    return null;
  }
}
