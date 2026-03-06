import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/services/base_permission_service.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
            Text(l10n.notificationsRequired),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationPermissionNeededMessage,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(l10n.notificationBenefitNewOrders),
            Text(l10n.notificationBenefitStatusUpdates),
            Text(l10n.notificationBenefitImportantAlerts),
            SizedBox(height: 16),
            Text(
              l10n.notificationPermissionWarning,
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
            child: Text(l10n.exitApp),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
            },
            child: Text(l10n.enableNotifications),
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
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(l10n.enableInSettings),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationPermissionDeniedInstructions,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(l10n.stepTapOpenSettings),
            Text(l10n.stepFindNotificationsInSettings),
            Text(l10n.stepEnableAllowNotifications),
            Text(l10n.stepReturnToApp),
            SizedBox(height: 16),
          ],
        ),
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 40.w,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  await _instance.openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    l10n.openSettings,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
            ),
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
