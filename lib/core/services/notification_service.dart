import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:delivery_manager/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:delivery_manager/core/services/services_locator.dart' show sl;
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:delivery_manager/main.dart' show navigatorKey;
import 'package:delivery_manager/core/routes/app_routes.dart';

/// NotificationService handles both Firebase Cloud Messaging (FCM) and Local Notifications
///
/// This service provides a comprehensive notification system that works in all app states:
/// - **Foreground**: Shows local notifications with custom sounds
/// - **Background**: FCM handles system notifications automatically
/// - **Terminated**: FCM handles system notifications automatically
///
/// Key Features:
/// - Custom notification sounds (notification1.mp3, order_alert.wav, urgent_beep.wav)
/// - Real-time badge updates for pending orders
/// - Notification channels for Android sound customization
/// - Callback mechanism for UI updates
/// - FCM token management for server communication
class NotificationService {
  // Firebase Cloud Messaging instance for push notifications
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Local notifications plugin for custom notifications in foreground
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // FCM token for server communication
  static String? _fcmToken;

  // Track last successful token send time to prevent duplicate sends
  static DateTime? _lastTokenSendTime;
  static const Duration _tokenSendCooldown = Duration(seconds: 30);

  // Track if a token send is currently in progress to prevent concurrent calls
  static bool _isSendingToken = false;

  // Callback function to refresh orders when new order notification is received
  // This allows the UI to update the badge count in real-time
  static VoidCallback? _onNewOrderCallback;

  // Track last processed message ID to prevent duplicate handling
  static String? _lastProcessedMessageId;

  // Store stream subscriptions for proper cleanup
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _onMessageSubscription;
  static StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  /// Get logging service instance
  static LoggingService get _logger {
    try {
      return sl<LoggingService>();
    } catch (e) {
      // Fallback to a simple logger if service locator not ready
      return LoggingService();
    }
  }

  /// Initialize Firebase messaging and request permissions
  ///
  /// This method sets up the entire notification system:
  /// 1. Checks notification permissions (assumes already granted by splash screen)
  /// 2. Initializes local notifications for custom sounds
  /// 3. Gets FCM token for server communication
  /// 4. Sets up message handlers for different app states
  /// 5. Configures token refresh listener
  static Future<void> initialize() async {
    try {
      _logger.debug('NotificationService: Starting initialization...');

      // Step 1: Check notification permissions
      // Permission should already be granted by splash screen
      final permissionStatus = await Permission.notification.status;
      _logger.debug(
        'NotificationService: Permission status: $permissionStatus',
      );

      if (permissionStatus.isGranted) {
        _logger.info(
          'NotificationService: Permissions granted, getting FCM token...',
        );

        // Step 2: Initialize local notifications for custom sounds
        // This creates notification channels for Android sound customization
        await _initializeLocalNotifications();

        // Step 3: Get FCM token for server communication
        // This token is sent to the backend to identify this device
        _fcmToken = await _messaging.getToken();
        _logger.info('NotificationService: FCM Token: $_fcmToken');

        // Note: FCM token is not sent to server here - wait for user login
        // This prevents sending tokens for unauthenticated users

        // Step 4: Set up message handlers for different app states
        // This handles notifications when app is foreground, background, or terminated
        _setupMessageHandlers();

        // Step 5: Listen for FCM token refresh
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

        _logger.info(
          'NotificationService: Initialization completed successfully',
        );

        // Check if app was launched from a notification
        _checkNotificationAppLaunch();
      } else {
        _logger.warning(
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

  /// Check if app was launched from a notification tap
  /// This handles cases where the app was completely closed and opened via notification
  static Future<void> _checkNotificationAppLaunch() async {
    try {
      _logger.debug(
        'NotificationService: Checking if app was launched from notification...',
      );
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();

      if (notificationAppLaunchDetails != null &&
          notificationAppLaunchDetails.didNotificationLaunchApp) {
        _logger.info(
          'NotificationService: App was launched from notification!',
        );
        _logger.debug(
          'NotificationService: Notification ID: ${notificationAppLaunchDetails.notificationResponse?.id}',
        );

        // Navigate to pending orders screen after app is ready
        _navigateToPendingOrdersScreen(initialDelay: 1500);
      } else {
        _logger.debug(
          'NotificationService: App was not launched from notification',
        );
      }
    } catch (e) {
      _logger.error(
        'NotificationService: Error checking notification app launch',
        error: e,
      );
    }
  }

  /// Initialize local notifications for creating notification channels
  ///
  /// This method sets up the local notification system which is used for:
  /// - Custom notification sounds in foreground
  /// - Notification channels for Android sound customization
  /// - Fallback notifications when FCM doesn't work
  static Future<void> _initializeLocalNotifications() async {
    try {
      _logger.debug(
        'NotificationService: ===== INITIALIZING LOCAL NOTIFICATIONS =====',
      );

      // Android initialization settings
      // Uses the app's launcher icon for notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      // Permissions are already requested in the main initialize() method
      // So we set these to false to avoid duplicate permission requests
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: false, // Already requested above
            requestBadgePermission: false, // Already requested above
            requestSoundPermission: false, // Already requested above
          );

      // Combine Android and iOS settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      _logger.debug(
        'NotificationService: Calling _localNotifications.initialize()...',
      );
      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _logger.debug(
            'NotificationService: Local notification tapped: ${response.id}',
          );
          _logger.debug('NotificationService: Payload: ${response.payload}');
          // Navigate to pending orders screen when local notification is tapped
          if (response.payload == 'new_order' || response.payload == null) {
            _navigateToPendingOrdersScreen(initialDelay: 300);
          }
        },
      );
      _logger.debug(
        'NotificationService: _localNotifications.initialize() completed',
      );

      // Create notification channels for custom sounds
      // This is essential for Android to play custom notification sounds
      _logger.debug('NotificationService: Creating notification channels...');
      await _createNotificationChannels();
      _logger.info('NotificationService: Notification channels created');

      _logger.info(
        'NotificationService: ===== LOCAL NOTIFICATIONS INITIALIZED SUCCESSFULLY =====',
      );
    } catch (e) {
      _logger.error(
        'NotificationService: ===== ERROR INITIALIZING LOCAL NOTIFICATIONS =====',
        error: e,
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Create notification channels for custom sounds
  ///
  /// Android requires notification channels to play custom sounds.
  /// Each channel can have its own sound, importance level, and behavior.
  /// This method creates three channels for different types of notifications:
  /// - new_orders: For new delivery orders (notification1.mp3)
  /// - order_alerts: For order alerts (order_alert.wav)
  /// - urgent_orders: For urgent orders (urgent_beep.wav)
  static Future<void> _createNotificationChannels() async {
    try {
      _logger.debug('NotificationService: Creating notification channels...');

      // Channel for new orders (notification1)
      // This is the most commonly used channel for new delivery orders
      const AndroidNotificationChannel newOrdersChannel =
          AndroidNotificationChannel(
            'new_orders', // Channel ID (must match backend)
            'New Orders', // User-visible channel name
            description: 'Notifications for new delivery orders',
            importance:
                Importance.high, // High importance = heads-up notification
            sound: RawResourceAndroidNotificationSound(
              'notification1',
            ), // Custom sound file
            playSound: true, // Enable sound
            enableVibration: true, // Enable vibration
          );

      // Channel for order alerts (notification2)
      // Used for order status updates and alerts
      const AndroidNotificationChannel orderAlertsChannel =
          AndroidNotificationChannel(
            'order_alerts', // Channel ID
            'Order Alerts', // User-visible channel name
            description: 'Notifications for order alerts',
            importance:
                Importance.high, // High importance = heads-up notification
            sound: RawResourceAndroidNotificationSound(
              'order_alert',
            ), // Custom sound file
            playSound: true, // Enable sound
            enableVibration: true, // Enable vibration
          );

      // Channel for urgent orders (notification3)
      // Used for urgent or priority orders
      const AndroidNotificationChannel urgentOrdersChannel =
          AndroidNotificationChannel(
            'urgent_orders', // Channel ID
            'Urgent Orders', // User-visible channel name
            description: 'Notifications for urgent delivery orders',
            importance:
                Importance.high, // High importance = heads-up notification
            sound: RawResourceAndroidNotificationSound(
              'urgent_beep',
            ), // Custom sound file
            playSound: true, // Enable sound
            enableVibration: true, // Enable vibration
          );

      // Create channels on Android
      // Note: iOS doesn't use channels, it uses the sound file directly
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(newOrdersChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(orderAlertsChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(urgentOrdersChannel);

      _logger.info(
        'NotificationService: Notification channels created successfully',
      );
    } catch (e) {
      _logger.error(
        'NotificationService: Error creating notification channels',
        error: e,
      );
    }
  }

  /// Setup message handlers for different app states
  ///
  /// This method configures three different message handlers:
  /// 1. **Foreground**: When app is active and visible
  /// 2. **Background**: When app is minimized but still running
  /// 3. **Terminated**: When app is completely closed
  ///
  /// Each handler processes notifications differently based on app state.
  static Future<void> _setupMessageHandlers() async {
    _logger.debug(
      'NotificationService: ===== SETTING UP MESSAGE HANDLERS =====',
    );
    _logger.debug(
      'NotificationService: FirebaseMessaging instance: $_messaging',
    );
    _logger.debug(
      'NotificationService: Registering foreground message handler...',
    );

    // Add a test listener to verify Firebase is working
    _logger.debug('NotificationService: Testing Firebase connection...');
    _messaging
        .getToken()
        .then((token) {
          _logger.debug(
            'NotificationService: Firebase is connected, token available: ${token?.substring(0, 20)}...',
          );
        })
        .catchError((error) {
          _logger.error(
            'NotificationService: Firebase connection error',
            error: error,
          );
        });

    // Handler 1: Messages when app is in foreground
    // In foreground, FCM doesn't show system notifications automatically
    // So we need to show local notifications to ensure user sees them
    _logger.debug(
      'NotificationService: Creating onMessage stream subscription...',
    );
    _logger.debug(
      'NotificationService: FirebaseMessaging.onMessage stream: ${FirebaseMessaging.onMessage}',
    );
    final subscription = FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        _logger.debug(
          'NotificationService: ===== FOREGROUND MESSAGE RECEIVED =====',
        );
        _logger.debug(
          'NotificationService: LISTENER TRIGGERED - Message received!',
        );
        _logger.debug('NotificationService: Message ID: ${message.messageId}');
        _logger.debug('NotificationService: From: ${message.from}');
        _logger.debug(
          'NotificationService: Title: ${message.notification?.title}',
        );
        _logger.debug(
          'NotificationService: Body: ${message.notification?.body}',
        );
        _logger.debug('NotificationService: Data: ${message.data}');
        _logger.debug('NotificationService: Data keys: ${message.data.keys}');
        _logger.debug('NotificationService: Sent Time: ${message.sentTime}');
        _logger.debug('NotificationService: TTL: ${message.ttl}');
        _logger.debug(
          'NotificationService: Notification: ${message.notification}',
        );
        _logger.debug(
          'NotificationService: Has notification: ${message.notification != null}',
        );
        _logger.debug(
          'NotificationService: Data type: ${message.data['type']}',
        );
        _logger.debug('NotificationService: Message hash: ${message.hashCode}');
        _logger.debug(
          'NotificationService: ==========================================',
        );
        _handleForegroundMessage(message);
      },
      onError: (error) {
        _logger.error(
          'NotificationService: ===== ERROR IN FOREGROUND HANDLER =====',
          error: error,
        );
        _logger.debug('NotificationService: Error type: ${error.runtimeType}');
        _logger.debug(
          'NotificationService: ==========================================',
        );
      },
      onDone: () {
        _logger.debug(
          'NotificationService: ===== FOREGROUND HANDLER STREAM CLOSED =====',
        );
      },
      cancelOnError: false,
    );
    _logger.debug(
      'NotificationService: onMessage subscription created: $_onMessageSubscription',
    );

    _logger.debug('NotificationService: Foreground handler registered');

    // Handler 2: Messages when app is opened from background
    // This fires when user taps a notification while app is in background
    // The system notification was already shown, we just need to refresh data
    _logger.debug(
      'NotificationService: Registering onMessageOpenedApp handler...',
    );
    _logger.debug(
      'NotificationService: onMessageOpenedApp stream: ${FirebaseMessaging.onMessageOpenedApp}',
    );
    // Cancel existing subscription if any
    await _onMessageOpenedAppSubscription?.cancel();
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) {
        _logger.info(
          'NotificationService: ===== APP OPENED FROM NOTIFICATION TAP =====',
        );
        _logger.debug('NotificationService: onMessageOpenedApp TRIGGERED!');
        _logger.debug('NotificationService: Message ID: ${message.messageId}');
        _logger.debug('NotificationService: From: ${message.from}');
        _logger.debug(
          'NotificationService: Title: ${message.notification?.title}',
        );
        _logger.debug(
          'NotificationService: Body: ${message.notification?.body}',
        );
        _logger.debug('NotificationService: Data: ${message.data}');
        _logger.debug('NotificationService: Sent Time: ${message.sentTime}');
        _logger.debug(
          'NotificationService: ============================================',
        );
        _handleBackgroundMessage(message);
      },
      onError: (error) {
        _logger.error(
          'NotificationService: ===== ERROR IN onMessageOpenedApp HANDLER =====',
          error: error,
        );
        _logger.debug(
          'NotificationService: ================================================',
        );
      },
    );
    _logger.debug(
      'NotificationService: onMessageOpenedApp handler registered successfully',
    );

    _logger.debug('NotificationService: Background handler registered');

    // Handler 3: Messages when app is opened from terminated state
    // This fires when user taps a notification while app is completely closed
    // The system notification was already shown, we just need to refresh data
    _logger.debug(
      'NotificationService: Checking for initial message (terminated state)...',
    );
    _messaging
        .getInitialMessage()
        .then((RemoteMessage? message) {
          if (message != null) {
            _logger.info(
              'NotificationService: ===== TERMINATED MESSAGE FOUND =====',
            );
            _logger.debug(
              'NotificationService: Message ID: ${message.messageId}',
            );
            _logger.debug('NotificationService: From: ${message.from}');
            _logger.debug(
              'NotificationService: Title: ${message.notification?.title}',
            );
            _logger.debug(
              'NotificationService: Body: ${message.notification?.body}',
            );
            _logger.debug('NotificationService: Data: ${message.data}');
            _logger.debug(
              'NotificationService: Sent Time: ${message.sentTime}',
            );
            _logger.debug(
              'NotificationService: =====================================',
            );
            _handleTerminatedMessage(message);
          } else {
            _logger.debug('NotificationService: No initial message found');
          }
        })
        .catchError((error) {
          _logger.error(
            'NotificationService: ===== ERROR GETTING INITIAL MESSAGE =====',
            error: error,
          );
          _logger.debug(
            'NotificationService: ==========================================',
          );
        });

    _logger.info(
      'NotificationService: ===== MESSAGE HANDLERS SETUP COMPLETED =====',
    );
    _logger.debug(
      'NotificationService: All handlers are now listening for messages',
    );

    // Test the subscription is active by checking if it's paused
    _logger.debug(
      'NotificationService: Subscription isPaused: ${subscription.isPaused}',
    );
    _logger.debug(
      'NotificationService: Subscription hashCode: ${subscription.hashCode}',
    );

    // Additional debugging: Check if we can get the current token
    _messaging
        .getToken()
        .then((token) {
          _logger.debug(
            'NotificationService: Current FCM token verified: ${token?.substring(0, 20)}...',
          );
          _logger.debug('NotificationService: Token length: ${token?.length}');
        })
        .catchError((error) {
          _logger.error(
            'NotificationService: Error getting token for verification',
            error: error,
          );
        });
  }

  /// Handle notification when app is in foreground
  ///
  /// In foreground state, FCM doesn't automatically show system notifications.
  /// This method:
  /// 1. Refreshes the orders list to update the badge count
  /// 2. Shows a local notification to ensure the user sees the notification
  /// 3. Uses custom notification sounds via notification channels
  static void _handleForegroundMessage(RemoteMessage message) async {
    _logger.debug(
      'NotificationService: Received foreground message: ${message.notification?.title}',
    );
    _logger.debug('NotificationService: Message data: ${message.data}');

    // Only process new order notifications (type: 'notification1')
    if (message.data['type'] == 'notification1') {
      _logger.info(
        'NotificationService: ===== PROCESSING NEW ORDER NOTIFICATION =====',
      );
      _logger.info(
        'NotificationService: Message type: ${message.data['type']}',
      );
      _logger.info('NotificationService: Message data: ${message.data}');
      _logger.info(
        'NotificationService: Notification title: ${message.notification?.title}',
      );
      _logger.info(
        'NotificationService: Notification body: ${message.notification?.body}',
      );

      // Step 1: Refresh orders to update badge count in real-time
      // This triggers the callback to update the UI immediately
      _refreshOrders();

      // Step 2: Show local notification to ensure user notices
      // FCM doesn't show system notifications in foreground, so we need local notifications
      _logger.debug(
        'NotificationService: About to call _showLocalNotification...',
      );

      // Test if local notifications are available before using them
      try {
        _logger.debug(
          'NotificationService: Testing local notifications availability...',
        );
        // Try a simple test call to verify the plugin is working
        await _localNotifications.getNotificationAppLaunchDetails();
        _logger.debug('NotificationService: Local notifications are available');
      } catch (e) {
        _logger.warning(
          'NotificationService: Local notifications not available',
          e,
        );
      }

      // Show the local notification with custom sound
      try {
        // Create a modified message with notification data if missing
        final modifiedMessage = message.notification != null
            ? message
            : RemoteMessage(
                notification: RemoteNotification(
                  title: message.data['title'] ?? 'New Order Available',
                  body:
                      message.data['body'] ?? 'You have a new order to process',
                ),
                data: message.data,
                messageId: message.messageId,
                sentTime: message.sentTime,
                from: message.from,
              );

        await _showLocalNotification(modifiedMessage);
        _logger.debug(
          'NotificationService: _showLocalNotification completed successfully',
        );
      } catch (e) {
        _logger.error(
          'NotificationService: Error calling _showLocalNotification',
          error: e,
          stackTrace: StackTrace.current,
        );
      }
    } else {
      _logger.debug(
        'NotificationService: Message type is not notification1, ignoring. Type: ${message.data['type']}',
      );
    }
  }

  /// Handle notification when app is opened from background
  ///
  /// This method is called when the user taps a notification while the app is in background.
  /// The system notification was already shown, so we only need to refresh the data.
  static void _handleBackgroundMessage(RemoteMessage message) {
    _logger.info(
      'NotificationService: Received background message: ${message.notification?.title}',
    );
    _logger.debug('NotificationService: Message data: ${message.data}');

    // Prevent duplicate processing of the same message
    final messageId = message.messageId ?? message.sentTime?.toString();
    if (messageId != null && messageId == _lastProcessedMessageId) {
      _logger.debug(
        'NotificationService: Message already processed, skipping duplicate handling',
      );
      return;
    }

    // Get notification_type from data (for ready_for_pickup and food_ready notifications)
    final notificationType = message.data['notification_type'] as String?;

    // Check if this is a ready for pickup or food ready notification
    if (notificationType == 'ready_for_pickup' ||
        notificationType == 'food_ready') {
      _logger.info(
        'NotificationService: Processing $notificationType notification from background',
      );

      // Mark message as processed
      if (messageId != null) {
        _lastProcessedMessageId = messageId;
      }

      // Refresh orders to update the UI with latest data
      _refreshOrders();

      // Navigate to ready orders screen with proper stack
      _navigateToReadyOrdersScreen();
    }
    // Handle new order notifications (type: 'notification1' without ready notification_type)
    else if (message.data['type'] == 'notification1') {
      _logger.info(
        'NotificationService: Processing new order notification from background',
      );

      // Mark message as processed
      if (messageId != null) {
        _lastProcessedMessageId = messageId;
      }

      // Refresh orders to update the UI with latest data
      _refreshOrders();

      // Navigate to pending orders screen after a short delay to ensure app is ready
      _navigateToPendingOrdersScreen();
    }
  }

  /// Handle notification when app is opened from terminated state
  ///
  /// This method is called when the user taps a notification while the app is completely closed.
  /// The system notification was already shown, so we only need to refresh the data.
  static void _handleTerminatedMessage(RemoteMessage message) {
    _logger.info(
      'NotificationService: Received terminated message: ${message.notification?.title}',
    );
    _logger.debug('NotificationService: Message data: ${message.data}');

    // Prevent duplicate processing of the same message
    final messageId = message.messageId ?? message.sentTime?.toString();
    if (messageId != null && messageId == _lastProcessedMessageId) {
      _logger.debug(
        'NotificationService: Message already processed, skipping duplicate handling',
      );
      return;
    }

    // Get notification_type from data (for ready_for_pickup and food_ready notifications)
    final notificationType = message.data['notification_type'] as String?;

    // Check if this is a ready for pickup or food ready notification
    if (notificationType == 'ready_for_pickup' ||
        notificationType == 'food_ready') {
      _logger.info(
        'NotificationService: Processing $notificationType notification from terminated state',
      );

      // Mark message as processed
      if (messageId != null) {
        _lastProcessedMessageId = messageId;
      }

      // Refresh orders to update the UI with latest data
      _refreshOrders();

      // Navigate to ready orders screen with proper stack (longer delay for terminated state)
      _navigateToReadyOrdersScreen(initialDelay: 1000);
    }
    // Handle new order notifications (type: 'notification1' without ready notification_type)
    else if (message.data['type'] == 'notification1') {
      _logger.info(
        'NotificationService: Processing new order notification from terminated state',
      );

      // Mark message as processed
      if (messageId != null) {
        _lastProcessedMessageId = messageId;
      }

      // Refresh orders to update the UI with latest data
      _refreshOrders();

      // Navigate to pending orders screen after a delay to ensure app is fully loaded
      _navigateToPendingOrdersScreen(initialDelay: 1000);
    }
  }

  /// Show local notification for new orders
  ///
  /// This method creates and displays a local notification with custom sound.
  /// It's used in foreground state when FCM doesn't automatically show notifications.
  ///
  /// The notification uses:
  /// - Custom notification1.mp3 sound
  /// - High importance for heads-up display
  /// - App launcher icon
  /// - Unique ID based on message hash
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      _logger.debug(
        'NotificationService: ===== SHOWING LOCAL NOTIFICATION =====',
      );
      _logger.debug(
        'NotificationService: Message title: ${message.notification?.title}',
      );
      _logger.debug(
        'NotificationService: Message body: ${message.notification?.body}',
      );

      // Android notification details with custom sound
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'new_orders', // Channel ID (must match the channel we created)
            'New Orders', // Channel name
            channelDescription: 'Notifications for new orders',
            importance:
                Importance.high, // High importance = heads-up notification
            priority: Priority.high, // High priority = show immediately
            sound: RawResourceAndroidNotificationSound(
              'notification1',
            ), // Custom sound file
            icon: '@mipmap/ic_launcher', // App icon for notification
            showWhen: true, // Show timestamp
            when: DateTime.now().millisecondsSinceEpoch, // Current time
          );

      // Platform-specific notification details
      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        // iOS will use default settings
      );

      // Display the notification
      _logger.debug(
        'NotificationService: Calling _localNotifications.show()...',
      );
      await _localNotifications.show(
        message
            .hashCode, // Unique ID based on message hash (prevents duplicates)
        message.notification?.title ?? 'New Order Available', // Fallback title
        message.notification?.body ??
            'You have a new order to process', // Fallback body
        platformDetails,
        payload: 'new_order', // Payload to identify notification type
      );

      _logger.info(
        'NotificationService: ===== LOCAL NOTIFICATION DISPLAYED SUCCESSFULLY =====',
      );
    } catch (e) {
      _logger.error(
        'NotificationService: ===== ERROR SHOWING LOCAL NOTIFICATION =====',
        error: e,
        stackTrace: StackTrace.current,
      );
    }
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

    _logger.debug('NotificationService: Sending FCM token to server: $token');

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
      final timeSinceLastSend = DateTime.now().difference(_lastTokenSendTime!);
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
          _fcmToken = await _messaging.getToken();
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
        _logger.warning('NotificationService: No FCM token available to send');
        return;
      }

      // Retry logic: try up to 3 times with exponential backoff
      int attempts = 0;
      const maxAttempts = 3;

      while (attempts < maxAttempts) {
        try {
          await _sendTokenToServer(_fcmToken);

          // Update last send time only on successful send
          _lastTokenSendTime = DateTime.now();

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
            _logger.warning(
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
      _fcmToken = await _messaging.getToken();
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

  /// Set callback for new order notifications
  ///
  /// This method allows the UI to register a callback function that will be called
  /// whenever a new order notification is received. This enables real-time UI updates
  /// without tight coupling between the notification service and UI components.
  static void setOnNewOrderCallback(VoidCallback callback) {
    _onNewOrderCallback = callback;
  }

  /// Refresh orders by dispatching event to OrderBloc
  ///
  /// This method updates the orders list when a new order notification is received.
  /// It uses a callback mechanism for better performance and loose coupling.
  ///
  /// Priority:
  /// 1. Use callback if available (preferred - faster and more reliable)
  /// 2. Fallback to direct OrderBloc access if callback not set
  static void _refreshOrders() {
    try {
      _logger.debug('NotificationService: Refreshing data...');

      // Use callback if available
      if (_onNewOrderCallback != null) {
        _onNewOrderCallback!();
        _logger.debug('NotificationService: Data refreshed via callback');
      } else {
        _logger.debug(
          'NotificationService: No callback available, skipping refresh',
        );
      }
    } catch (e) {
      _logger.error('NotificationService: Error refreshing data', error: e);
    }
  }

  /// Navigate to pending orders screen (stub - not used in manager app)
  static void _navigateToPendingOrdersScreen({int initialDelay = 2000}) {
    _logger.debug(
      'NotificationService: Pending orders navigation not supported in manager app',
    );
    // Pending orders feature not available in manager app
    // Just navigate to main screen instead
    _navigateToMainScreen();
  }

  /// Navigate to ready orders screen (stub - not used in manager app)
  static void _navigateToReadyOrdersScreen({int initialDelay = 2000}) {
    _logger.debug(
      'NotificationService: Ready orders navigation not supported in manager app',
    );
    // Ready orders feature not available in manager app
    // Just navigate to main screen instead
    _navigateToMainScreen();
  }

  /// Navigate to main screen with retry logic
  static void _navigateToMainScreen({int attempt = 1, int maxAttempts = 5}) {
    if (navigatorKey.currentState == null) {
      _logger.debug(
        'NotificationService: Navigator key not ready (attempt $attempt/$maxAttempts)',
      );
      if (attempt < maxAttempts) {
        final delay = Duration(milliseconds: 1000 * attempt);
        Future.delayed(delay, () {
          _navigateToMainScreen(attempt: attempt + 1, maxAttempts: maxAttempts);
        });
      }
      return;
    }

    try {
      final currentRoute = ModalRoute.of(
        navigatorKey.currentContext!,
      )?.settings.name;

      if (currentRoute == '/splash' || currentRoute == '/login') {
        if (attempt < maxAttempts) {
          Future.delayed(const Duration(milliseconds: 2000), () {
            _navigateToMainScreen(
              attempt: attempt + 1,
              maxAttempts: maxAttempts,
            );
          });
        }
        return;
      }

      if (currentRoute != AppRoutes.main) {
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          AppRoutes.main,
          (route) => false,
        );
      }
    } catch (e) {
      _logger.error('NotificationService: Navigation error', error: e);
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
  logger.debug('NotificationService: Data: ${message.data}');
  logger.debug('NotificationService: Sent Time: ${message.sentTime}');
  logger.debug('NotificationService: TTL: ${message.ttl}');
  logger.debug(
    'NotificationService: =========================================',
  );

  logger.debug(
    'NotificationService: Handling background message: ${message.messageId}',
  );
  logger.debug('NotificationService: Background message data: ${message.data}');

  // Handle background message logic here if needed
  // Note: This handler has limited capabilities compared to the main app handlers
  // It's mainly used for logging and basic processing
  if (message.data['type'] == 'notification1') {
    logger.debug(
      'NotificationService: Background handler - Processing new order notification',
    );
  }
}
