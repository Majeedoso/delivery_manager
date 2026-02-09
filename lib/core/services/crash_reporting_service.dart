import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Service for handling crash reporting and error tracking
/// 
/// This service provides a centralized way to report crashes and errors
/// to Firebase Crashlytics. It handles both fatal crashes and non-fatal errors.
class CrashReportingService {
  // Prevent instantiation
  CrashReportingService._();

  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      printTime: true,
    ),
  );

  /// Initialize crash reporting service
  /// 
  /// This should be called early in the app initialization process,
  /// after Firebase is initialized.
  static Future<void> initialize() async {
    try {
      // Enable crash collection in debug mode for testing
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
      
      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = (errorDetails) {
        _crashlytics.recordFlutterFatalError(errorDetails);
        // Also call the default handler
        FlutterError.presentError(errorDetails);
      };
      
      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };
      
      if (kDebugMode) {
        _logger.i('CrashReportingService: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        _logger.e('CrashReportingService: Error initializing: $e');
      }
      // Don't throw - crash reporting failure shouldn't block app startup
    }
  }

  /// Record a non-fatal error
  /// 
  /// Use this for errors that don't crash the app but should be tracked.
  /// [error] - The error object
  /// [stackTrace] - The stack trace (optional)
  /// [reason] - Additional context about the error (optional)
  /// [fatal] - Whether this error should be considered fatal (default: false)
  static Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      if (kDebugMode) {
        _logger.e('CrashReportingService: Error recording error: $e');
      }
      // Don't throw - error recording failure shouldn't affect app
    }
  }

  /// Log a message to Crashlytics
  /// 
  /// Use this to add context to crash reports.
  /// [message] - The message to log
  static Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      if (kDebugMode) {
        _logger.e('CrashReportingService: Error logging message: $e');
      }
      // Don't throw - logging failure shouldn't affect app
    }
  }

  /// Set a custom key-value pair for crash reports
  /// 
  /// Use this to add custom context to crash reports.
  /// [key] - The key
  /// [value] - The value (must be a String, int, double, or bool)
  static Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      if (kDebugMode) {
        _logger.e('CrashReportingService: Error setting custom key: $e');
      }
      // Don't throw - custom key failure shouldn't affect app
    }
  }

  /// Set user identifier for crash reports
  /// 
  /// Use this to identify which user experienced a crash.
  /// [identifier] - The user identifier (e.g., user ID, email)
  static Future<void> setUserIdentifier(String identifier) async {
    try {
      await _crashlytics.setUserIdentifier(identifier);
    } catch (e) {
      if (kDebugMode) {
        _logger.e('CrashReportingService: Error setting user identifier: $e');
      }
      // Don't throw - user identifier failure shouldn't affect app
    }
  }

  /// Check if crash collection is enabled
  static bool get isCrashlyticsCollectionEnabled {
    return _crashlytics.isCrashlyticsCollectionEnabled;
  }

  /// Enable or disable crash collection
  /// 
  /// [enabled] - Whether to enable crash collection
  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    } catch (e) {
      if (kDebugMode) {
        _logger.e('CrashReportingService: Error setting collection enabled: $e');
      }
      // Don't throw - setting failure shouldn't affect app
    }
  }
}

