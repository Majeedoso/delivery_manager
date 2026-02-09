import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:flutter/material.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/services/base_permission_service.dart';

/// PermissionService handles notification permission requests and checks
///
/// This service provides a centralized way to:
/// - Check if notification permission is granted
/// - Request notification permission from the user
/// - Handle permission states (granted, denied, permanently denied)
/// - Open app settings for permission management
/// - Show user-friendly permission dialogs
class PermissionService implements BasePermissionService {
  final LoggingService _logger;

  /// Creates an instance of PermissionService
  /// 
  /// [logger] is optional - if not provided, will use service locator
  PermissionService({LoggingService? logger})
      : _logger = logger ?? _getLogger();

  /// Get logging service instance (static helper for backward compatibility)
  static LoggingService _getLogger() {
    try {
      return sl<LoggingService>();
    } catch (e) {
      // Fallback to a simple logger if service locator not ready
      return LoggingService();
    }
  }

  /// Static instance for backward compatibility
  /// 
  /// This allows existing code using static methods to continue working
  static final PermissionService _instance = PermissionService();

  /// Check if notification permission is currently granted
  ///
  /// Returns true if notifications are enabled, false otherwise
  @override
  Future<bool> isNotificationPermissionGranted() async {
    try {
      final status = await permission_handler.Permission.notification.status;
      _logger.debug('PermissionService: Notification permission status: $status');
      return status.isGranted;
    } catch (e) {
      _logger.error('PermissionService: Error checking notification permission', error: e);
      return false;
    }
  }

  /// Request notification permission from the user
  ///
  /// This will show the system permission dialog
  /// Returns true if permission is granted, false otherwise
  @override
  Future<bool> requestNotificationPermission() async {
    try {
      _logger.debug('PermissionService: Requesting notification permission...');
      final status = await permission_handler.Permission.notification.request();
      _logger.info('PermissionService: Permission request result: $status');
      return status.isGranted;
    } catch (e) {
      _logger.error('PermissionService: Error requesting notification permission', error: e);
      return false;
    }
  }

  /// Check if notification permission is permanently denied
  ///
  /// When permission is permanently denied, user must enable it in app settings
  /// Returns true if permission is permanently denied, false otherwise
  @override
  Future<bool> isPermissionPermanentlyDenied() async {
    try {
      final status = await permission_handler.Permission.notification.status;
      return status.isPermanentlyDenied;
    } catch (e) {
      _logger.error('PermissionService: Error checking if permission is permanently denied', error: e);
      return false;
    }
  }

  // Static methods for backward compatibility
  /// Check if notification permission is currently granted (static)
  static Future<bool> isNotificationPermissionGrantedStatic() async {
    return await _instance.isNotificationPermissionGranted();
  }

  /// Request notification permission from the user (static)
  static Future<bool> requestNotificationPermissionStatic() async {
    return await _instance.requestNotificationPermission();
  }

  /// Check if notification permission is permanently denied (static)
  static Future<bool> isPermissionPermanentlyDeniedStatic() async {
    return await _instance.isPermissionPermanentlyDenied();
  }

  /// Open the app settings page
  ///
  /// This allows users to manually enable notifications in system settings
  Future<bool> openAppSettings() async {
    try {
      _logger.debug('PermissionService: Opening app settings...');
      // Use permission_handler's openAppSettings function
      final result = await permission_handler.openAppSettings();
      _logger.info('PermissionService: App settings opened: $result');
      return result;
    } catch (e) {
      _logger.error('PermissionService: Error opening app settings', error: e);
      return false;
    }
  }

  /// Open the app settings page (static method for backward compatibility)
  static Future<bool> openAppSettingsStatic() async {
    return await _instance.openAppSettings();
  }

  /// Show a permission explanation dialog
  ///
  /// This dialog explains why notification permission is needed
  /// and provides options to enable it or exit the app
  Future<bool> showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.notifications_off,
              color: Colors.orange,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('Notifications Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This app needs notification permission to:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Alert you about new delivery orders'),
            Text('• Notify you of order status updates'),
            Text('• Send important delivery alerts'),
            SizedBox(height: 16),
            Text(
              'Without notifications, you won\'t receive new orders and the app cannot function properly.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Exit App'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
            child: Text('Enable Notifications'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Show a settings redirect dialog for permanently denied permissions
  ///
  /// This dialog appears when permission is permanently denied
  /// and guides the user to enable it in app settings
  Future<bool> showSettingsDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.settings,
              color: Colors.blue,
              size: 28,
            ),
            SizedBox(width: 12),
            Text('Enable in Settings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification permission was denied. To enable it:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Tap "Open Settings" below'),
            Text('2. Find "Notifications" in the app settings'),
            Text('3. Enable "Allow notifications"'),
            Text('4. Return to the app'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The app will automatically detect when you enable notifications.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Exit App'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await _instance.openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Get a user-friendly description of the current permission status
  ///
  /// Returns a string describing the current permission state
  Future<String> getPermissionStatusDescription() async {
    try {
      final status = await permission_handler.Permission.notification.status;
      
      switch (status) {
        case permission_handler.PermissionStatus.granted:
          return 'Notifications are enabled';
        case permission_handler.PermissionStatus.denied:
          return 'Notifications are disabled';
        case permission_handler.PermissionStatus.permanentlyDenied:
          return 'Notifications are permanently disabled';
        case permission_handler.PermissionStatus.restricted:
          return 'Notifications are restricted';
        case permission_handler.PermissionStatus.limited:
          return 'Notifications are limited';
        case permission_handler.PermissionStatus.provisional:
          return 'Notifications are provisional';
      }
    } catch (e) {
      return 'Unable to check notification status';
    }
  }
}
