import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8001/api';
  }

  /// Get the host URL (base URL without /api)
  /// Used for constructing image URLs from relative paths
  /// First checks for HOST_URL in .env, otherwise derives from BASE_URL
  static String get hostUrl {
    // Check if HOST_URL is explicitly set in .env
    final explicitHostUrl = dotenv.env['HOST_URL'];
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

  static String get mapboxAccessToken {
    return dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  }

  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }
}
