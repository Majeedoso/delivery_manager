import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// The server of a build made for the end-to-end tests on the emulators
  /// (`--dart-define=E2E_API=http://10.0.2.2:8011/api`, see
  /// delivery_backend/tests/E2E/README.md). Empty in every other build, where
  /// `.env` decides.
  static String e2eApi = const String.fromEnvironment('E2E_API');

  static String get baseUrl {
    if (e2eApi.isNotEmpty) return e2eApi;
    return dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8001/api';
  }

  /// Get the host URL (base URL without /api)
  /// Used for constructing image URLs from relative paths
  /// First checks for HOST_URL in .env, otherwise derives from BASE_URL
  static String get hostUrl {
    // Check if HOST_URL is explicitly set in .env
    final explicitHostUrl = e2eApi.isEmpty ? dotenv.env['HOST_URL'] : null;
    if (explicitHostUrl != null && explicitHostUrl.isNotEmpty) {
      // Remove trailing slash if present
      return explicitHostUrl.endsWith('/') 
          ? explicitHostUrl.substring(0, explicitHostUrl.length - 1) 
          : explicitHostUrl;
    }
    
    // Otherwise derive from BASE_URL
    final base = baseUrl;
    // Remove /api suffix if present
    if (base.endsWith('/api')) {
      return base.substring(0, base.length - 4);
    }
    // Also handle case where base URL ends with /api/
    if (base.endsWith('/api/')) {
      return base.substring(0, base.length - 5);
    }
    // Remove trailing slash if present
    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }

  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }
}
