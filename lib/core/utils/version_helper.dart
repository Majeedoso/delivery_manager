import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:flutter/foundation.dart';

/// Utility class for version comparison
/// 
/// Provides methods to compare semantic version strings (e.g., "1.2.3")
/// and determine if a version meets minimum requirements.
class VersionHelper {
  static LoggingService? _logger;
  
  static LoggingService get logger {
    if (_logger != null) return _logger!;
    try {
      _logger = sl<LoggingService>();
      return _logger!;
    } catch (e) {
      _logger = LoggingService();
      return _logger!;
    }
  }
  /// Compare two version strings
  /// 
  /// Returns:
  /// - Negative value if version1 < version2
  /// - Zero if version1 == version2
  /// - Positive value if version1 > version2
  /// 
  /// Example:
  /// - compareVersions("1.0.0", "1.0.1") returns -1
  /// - compareVersions("1.2.0", "1.2.0") returns 0
  /// - compareVersions("2.0.0", "1.9.9") returns 1
  static int compareVersions(String version1, String version2) {
    final v1Parts = _parseVersion(version1);
    final v2Parts = _parseVersion(version2);
    
    // Compare major, minor, and patch versions
    for (int i = 0; i < 3; i++) {
      final v1Part = v1Parts[i];
      final v2Part = v2Parts[i];
      
      if (v1Part < v2Part) return -1;
      if (v1Part > v2Part) return 1;
    }
    
    return 0;
  }
  
  /// Check if a version meets the minimum requirement
  /// 
  /// Returns true if currentVersion >= minimumVersion
  /// 
  /// Example:
  /// - isVersionSupported("1.0.0", "1.0.0") returns true
  /// - isVersionSupported("1.0.1", "1.0.0") returns true
  /// - isVersionSupported("0.9.9", "1.0.0") returns false
  static bool isVersionSupported(String currentVersion, String minimumVersion) {
    final comparison = compareVersions(currentVersion, minimumVersion);
    if (kDebugMode) {
      logger.debug('VersionHelper: Comparing "$currentVersion" with "$minimumVersion" -> result: $comparison');
    }
    final isSupported = comparison >= 0;
    if (kDebugMode) {
      logger.debug('VersionHelper: isVersionSupported: $isSupported');
    }
    return isSupported;
  }
  
  /// Parse a version string into parts
  /// 
  /// Handles versions in format: "major.minor.patch" or "major.minor.patch.build"
  /// Returns a list of [major, minor, patch]
  static List<int> _parseVersion(String version) {
    // Remove any non-numeric characters except dots
    final cleanedVersion = version.replaceAll(RegExp(r'[^0-9.]'), '');
    final parts = cleanedVersion.split('.').map((part) {
      try {
        return int.parse(part);
      } catch (e) {
        return 0;
      }
    }).toList();
    
    // Ensure we have at least 3 parts (major, minor, patch)
    final result = <int>[];
    for (int i = 0; i < 3; i++) {
      result.add(i < parts.length ? parts[i] : 0);
    }
    
    return result;
  }
}

