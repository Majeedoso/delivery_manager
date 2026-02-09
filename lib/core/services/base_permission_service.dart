/// Abstract base class for permission service
/// 
/// This interface allows for dependency injection and mocking in tests
abstract class BasePermissionService {
  /// Check if notification permission is currently granted
  /// 
  /// Returns true if notifications are enabled, false otherwise
  Future<bool> isNotificationPermissionGranted();

  /// Request notification permission from the user
  /// 
  /// This will show the system permission dialog
  /// Returns true if permission is granted, false otherwise
  Future<bool> requestNotificationPermission();

  /// Check if notification permission is permanently denied
  /// 
  /// When permission is permanently denied, user must enable it in app settings
  /// Returns true if permission is permanently denied, false otherwise
  Future<bool> isPermissionPermanentlyDenied();
}

