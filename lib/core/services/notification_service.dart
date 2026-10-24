import 'dart:async';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:delivery_manager/core/services/services_locator.dart' show sl;
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';

/// The manager app's link to Firebase Cloud Messaging (FCM).
///
/// The server sends a manager no notification, so this app creates no
/// Android channel and shows no notification itself (an app creates the
/// channels the server names for it, and no other). It keeps this phone's
/// FCM token known to the server: read at start, sent after a sign-in and
/// again whenever Firebase changes it.
class NotificationService {
  // Firebase Cloud Messaging instance for push notifications
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // FCM token for server communication
  static String? _fcmToken;

  // Track last successful token send time to prevent duplicate sends
  static DateTime? _lastTokenSendTime;
  static const Duration _tokenSendCooldown = Duration(seconds: 30);

  // Track if a token send is currently in progress to prevent concurrent calls
  static bool _isSendingToken = false;

  // Store stream subscriptions for proper cleanup
  static StreamSubscription<String>? _tokenRefreshSubscription;

  /// Whether [initialize] got through: the token is read and the app listens
  /// for its changes.
  static bool _started = false;

  @visibleForTesting
  static bool get isStarted => _started;

  /// Attaches the service to Firebase: a token that changes. Tests replace
  /// it (Firebase needs a phone); the app never does.
  @visibleForTesting
  static Future<void> Function() attachToFirebase = _attachToFirebase;

  /// Reads this device's FCM token. Tests replace it; the app never does.
  @visibleForTesting
  static Future<String?> Function() fetchFcmToken = _fetchFcmTokenFromFirebase;

  static Future<String?> _fetchFcmTokenFromFirebase() => _messaging.getToken();

  /// Clears all static state between tests (token, cooldown, listener).
  @visibleForTesting
  static Future<void> resetForTest() async {
    _fcmToken = null;
    _lastTokenSendTime = null;
    _isSendingToken = false;
    fetchFcmToken = _fetchFcmTokenFromFirebase;
    attachToFirebase = _attachToFirebase;
    _started = false;
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  /// Get logging service instance
  static LoggingService get _logger {
    try {
      return sl<LoggingService>();
    } catch (e) {
      // Fallback to a simple logger if service locator not ready
      return LoggingService();
    }
  }

  /// Initialize Firebase messaging
  ///
  /// 1. Checks notification permissions (assumes already granted by splash screen)
  /// 2. Gets FCM token for server communication
  /// 3. Configures token refresh listener
  static Future<void> initialize() async {
    try {
      _logger.debug('NotificationService: Starting initialization...');

      // Step 1: Check notification permissions. The app never asks for them
      // (the server sends a manager nothing): the service starts only when
      // the manager allowed them in the phone's settings
      final permissionStatus = await Permission.notification.status;
      _logger.debug(
        'NotificationService: Permission status: $permissionStatus',
      );

      if (permissionStatus.isGranted) {
        _logger.info(
          'NotificationService: Permissions granted, getting FCM token...',
        );

        // Step 2: Get FCM token for server communication
        // This token is sent to the backend to identify this device
        _fcmToken = await fetchFcmToken();
        _logger.info('NotificationService: FCM token obtained');

        // Note: FCM token is not sent to server here - wait for user login
        // This prevents sending tokens for unauthenticated users

        // Step 3: a token that changes
        await attachToFirebase();
        _started = true;

        _logger.info(
          'NotificationService: Initialization completed successfully',
        );
      } else {
        _logger.info(
          'NotificationService: Permissions not granted: $permissionStatus',
        );
        // Don't throw exception - just log and return
        // The app can continue without notification service
        // This is especially important in test environments where permissions may not be available
        _logger.info(
          'NotificationService: Continuing without notification service due to missing permissions',
        );
        return;
      }
    } catch (e) {
      _logger.error('NotificationService: Error initializing', error: e);
      // Don't rethrow - allow app to continue without notification service
      // This is important for graceful degradation, especially in test environments
      _logger.info(
        'NotificationService: Continuing without notification service due to initialization error',
      );
    }
  }

  static Future<void> _attachToFirebase() async {
    // Listen for FCM token refresh
    // FCM tokens can change, so we need to update the server
    // Added null safety and error handling to ensure token refresh always works
    // Cancel existing subscription if any
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((
      String newToken,
    ) {
      _logger.info(
        'NotificationService: FCM token refreshed: ${newToken.substring(0, 20)}...',
      );
      _fcmToken = newToken;
      _sendTokenToServer(newToken).catchError((error) {
        _logger.error(
          'NotificationService: Error sending refreshed token',
          error: error,
        );
        // Retry sending token if it fails
        Future.delayed(const Duration(seconds: 5), () {
          _sendTokenToServer(newToken).catchError((retryError) {
            _logger.error(
              'NotificationService: Retry failed for refreshed token',
              error: retryError,
            );
          });
        });
      });
    });
  }

  /// Send FCM token to server
  ///
  /// This method sends the FCM token to the backend server so it can send
  /// push notifications to this device. The token is sent via the auth API.
  ///
  /// Throws [ServerException] or [NetworkException] on failure.
  /// Exceptions are not caught here to allow retry logic in [sendTokenToServer] to handle them.
  static Future<void> _sendTokenToServer(String? token) async {
    if (token == null) return;

    _logger.debug('NotificationService: Sending FCM token to server');

    // Get the auth remote datasource to make API call
    final authRemoteDataSource = GetIt.instance.get<BaseAuthRemoteDataSource>();

    // Send token to backend via API
    // This will throw ServerException or NetworkException on failure
    await authRemoteDataSource.updateFcmToken(token);
    _logger.info('NotificationService: FCM token sent successfully');
  }

  /// Get current FCM token
  ///
  /// Returns the current FCM token for this device, or null if not available.
  static String? get fcmToken => _fcmToken;

  /// Check if notifications are enabled
  ///
  /// Returns true if notification permission is granted, false otherwise.
  static Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      _logger.error(
        'NotificationService: Error checking notification status',
        error: e,
      );
      return false;
    }
  }

  /// Send FCM token to server (call this after successful login)
  ///
  /// This is the public method to send the FCM token to the server.
  /// It should be called after the user successfully logs in.
  ///
  /// Includes retry logic to ensure token is sent even if network is temporarily unavailable.
  /// Also includes cooldown mechanism to prevent duplicate sends within a short time window.
  static Future<void> sendTokenToServer() async {
    // Check if a send is already in progress
    if (_isSendingToken) {
      _logger.debug(
        'NotificationService: Token send already in progress, skipping duplicate call',
      );
      return;
    }

    // Check if token was sent recently (within cooldown period)
    if (_lastTokenSendTime != null) {
      final timeSinceLastSend = clock.now().difference(_lastTokenSendTime!);
      if (timeSinceLastSend < _tokenSendCooldown) {
        _logger.debug(
          'NotificationService: Token was sent ${timeSinceLastSend.inSeconds}s ago, skipping duplicate send (cooldown: ${_tokenSendCooldown.inSeconds}s)',
        );
        return;
      }
    }

    // Check if user is authenticated before attempting to send token
    // The FCM token update endpoint requires authentication
    try {
      final tokenRepository = sl<BaseTokenRepository>();
      final tokenResult = await tokenRepository.getToken();

      final hasToken = tokenResult.fold(
        (failure) => false,
        (token) => token != null && token.isNotEmpty,
      );

      if (!hasToken) {
        _logger.debug(
          'NotificationService: User not authenticated (no token found), skipping FCM token send. Will retry after login.',
        );
        return;
      }
    } catch (e) {
      _logger.debug(
        'NotificationService: Could not check authentication token, proceeding with token send',
      );
      // Continue anyway - the API call will fail if not authenticated and retry logic will handle it
    }

    // Mark as in progress
    _isSendingToken = true;

    try {
      if (_fcmToken == null) {
        _logger.debug(
          'NotificationService: No FCM token available to send, trying to get token...',
        );
        // Try to get token if not available
        try {
          _fcmToken = await fetchFcmToken();
          _logger.debug(
            'NotificationService: Retrieved FCM token: ${_fcmToken?.substring(0, 20)}...',
          );
        } catch (e) {
          _logger.error(
            'NotificationService: Could not get FCM token',
            error: e,
          );
          return;
        }
      }

      if (_fcmToken == null) {
        _logger.debug('NotificationService: No FCM token available to send');
        return;
      }

      // Retry logic: try up to 3 times with exponential backoff
      int attempts = 0;
      const maxAttempts = 3;

      while (attempts < maxAttempts) {
        try {
          await _sendTokenToServer(_fcmToken);

          // Update last send time only on successful send
          _lastTokenSendTime = clock.now();

          _logger.info(
            'NotificationService: FCM token sent successfully on attempt ${attempts + 1}',
          );
          return; // Success, exit retry loop
        } catch (e) {
          attempts++;
          if (attempts < maxAttempts) {
            final delay = Duration(
              seconds: attempts * 2,
            ); // Exponential backoff: 2s, 4s
            _logger.debug(
              'NotificationService: Failed to send token (attempt $attempts/$maxAttempts), retrying in ${delay.inSeconds}s...',
              e,
            );
            await Future.delayed(delay);
          } else {
            _logger.error(
              'NotificationService: Failed to send token after $maxAttempts attempts',
              error: e,
            );
            // Don't update _lastTokenSendTime on failure - allow retry on next call
          }
        }
      }
    } finally {
      // Always clear the in-progress flag, even if there was an error or early return
      _isSendingToken = false;
    }
  }

  /// Force refresh and resync FCM token
  ///
  /// This method gets a fresh FCM token and sends it to the server.
  /// Useful when token might be stale or to ensure token is up to date.
  static Future<void> refreshAndSyncToken() async {
    try {
      _logger.debug('NotificationService: Refreshing FCM token...');
      _fcmToken = await fetchFcmToken();
      _logger.info(
        'NotificationService: New FCM token obtained: ${_fcmToken?.substring(0, 20)}...',
      );
      await sendTokenToServer();
    } catch (e) {
      _logger.error('NotificationService: Error refreshing token', error: e);
    }
  }

  /// Subscribe to topic (for future use)
  ///
  /// This method allows subscribing to FCM topics for targeted notifications.
  /// Currently not used in the app, but available for future features like:
  /// - Location-based notifications
  /// - Role-based notifications
  /// - Broadcast messages
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.debug('NotificationService: Subscribed to topic: $topic');
    } catch (e) {
      _logger.error(
        'NotificationService: Error subscribing to topic $topic',
        error: e,
      );
    }
  }

  /// Unsubscribe from topic (for future use)
  ///
  /// This method allows unsubscribing from FCM topics.
  /// Currently not used in the app, but available for future features.
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.debug('NotificationService: Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.error(
        'NotificationService: Error unsubscribing from topic $topic',
        error: e,
      );
    }
  }
}

/// Top-level function to handle background messages
///
/// This function is required by Firebase Cloud Messaging and must be:
/// - At the top level (not inside a class)
/// - Marked with @pragma('vm:entry-point')
/// - Registered in main.dart
///
/// This handler is called when the app receives a notification while:
/// - App is in background (minimized)
/// - App is terminated (completely closed)
///
/// Note: This handler runs in a separate isolate, so it has limited access
/// to the main app's state and services.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: This runs in a separate isolate, so we can't use the logging service via GetIt
  // Instantiate LoggingService directly for background handler logging
  final logger = LoggingService();

  logger.debug('NotificationService: ===== BACKGROUND HANDLER TRIGGERED =====');
  logger.debug('NotificationService: Message ID: ${message.messageId}');
  logger.debug('NotificationService: From: ${message.from}');
  logger.debug('NotificationService: Title: ${message.notification?.title}');
  logger.debug('NotificationService: Body: ${message.notification?.body}');
  logger.debug('NotificationService: Data: ${message.data.keys}');
  logger.debug('NotificationService: Sent Time: ${message.sentTime}');
  logger.debug('NotificationService: TTL: ${message.ttl}');
  logger.debug(
    'NotificationService: =========================================',
  );

  logger.debug(
    'NotificationService: Handling background message: ${message.messageId}',
  );
  logger.debug('NotificationService: Background message data: ${message.data.keys}');
}
