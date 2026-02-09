/// Centralized timeout constants for the application
/// 
/// This file contains all timeout values used throughout the app
/// to ensure consistency and easy maintenance.
class AppTimeouts {
  // Prevent instantiation
  AppTimeouts._();

  // Initialization timeouts
  /// Timeout for Firebase initialization
  static const Duration firebaseInit = Duration(seconds: 10);
  
  /// Timeout for service locator initialization
  static const Duration serviceLocatorInit = Duration(seconds: 15);
  
  /// Timeout for theme service initialization
  static const Duration themeServiceInit = Duration(seconds: 5);
  
  /// Timeout for notification service initialization
  static const Duration notificationServiceInit = Duration(seconds: 10);

  // Network timeouts
  /// Timeout for internet connection check
  static const Duration internetCheck = Duration(seconds: 25);
  
  /// Timeout for API requests (connect, receive, send)
  static const Duration apiRequest = Duration(seconds: 60);
  
  /// Timeout for version check
  static const Duration versionCheck = Duration(seconds: 10);

  // Authentication timeouts
  /// Timeout for logout operation
  static const Duration logout = Duration(seconds: 5);
  
  /// Timeout for authentication status check
  static const Duration authStatusCheck = Duration(seconds: 10);

  // Notification timeouts
  /// Timeout for notification permission check
  static const Duration notificationPermissionCheck = Duration(seconds: 2);
}

