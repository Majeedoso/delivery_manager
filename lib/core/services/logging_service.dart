import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Service for centralized logging throughout the application
///
/// This service provides a consistent logging interface that:
/// - Uses the logger package for formatted console output
/// - Integrates with Firebase Crashlytics for error tracking
/// - Respects debug/release mode settings
/// - Provides different log levels (debug, info, warning, error)
class LoggingService {
  final Logger _logger;
  final bool _isDebugMode;

  LoggingService({Logger? logger, bool? isDebugMode})
    : _logger =
          logger ??
          Logger(
            printer: PrettyPrinter(
              methodCount: 2,
              errorMethodCount: 8,
              lineLength: 120,
              colors: true,
              printEmojis: true,
              printTime: true,
            ),
          ),
      _isDebugMode = isDebugMode ?? kDebugMode;

  /// Log a debug message
  ///
  /// Use this for detailed information that is only useful during development.
  /// These messages are shown in both debug and release modes.
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  ///
  /// Use this for general informational messages about app flow.
  /// These messages are shown in both debug and release modes.
  void info(String message) {
    _logger.i(message);
  }

  /// Log a warning message
  ///
  /// Use this for potentially problematic situations that don't prevent the app from functioning.
  /// These messages are shown in both debug and release modes.
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);

    // Log warnings to Crashlytics in production
    if (!_isDebugMode) {
      _logToCrashlytics(
        message,
        error: error,
        stackTrace: stackTrace,
        fatal: false,
      );
    }
  }

  /// Log an error message
  ///
  /// Use this for errors that don't crash the app but should be tracked.
  /// These are automatically sent to Firebase Crashlytics.
  /// These messages are shown in both debug and release modes.
  void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    _logger.e(message, error: error, stackTrace: stackTrace);

    // Always log errors to Crashlytics
    _logToCrashlytics(
      message,
      error: error,
      stackTrace: stackTrace,
      fatal: fatal,
    );
  }

  /// Log a fatal error
  ///
  /// Use this for critical errors that should be treated as fatal crashes.
  /// These messages are shown in both debug and release modes.
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);

    // Always log fatal errors to Crashlytics
    _logToCrashlytics(
      message,
      error: error,
      stackTrace: stackTrace,
      fatal: true,
    );
  }

  /// Internal method to log to Firebase Crashlytics
  Future<void> _logToCrashlytics(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) async {
    try {
      // Combine message with error if both exist
      final errorToReport = error ?? message;
      final stackToReport = stackTrace ?? StackTrace.current;

      await FirebaseCrashlytics.instance.recordError(
        errorToReport,
        stackToReport,
        reason: message.toString(), // Ensure string
        fatal: fatal,
      );
    } catch (e) {
      // Silently fail - we don't want logging failures to crash the app
      // In debug mode, we can still see the error in console
      if (_isDebugMode) {
        _logger.e('Failed to log to Crashlytics: $e');
      }
    }
  }

  /// Log a message to Crashlytics (for context)
  ///
  /// Use this to add context to crash reports.
  Future<void> logToCrashlytics(String message) async {
    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      // Silently fail - we don't want logging failures to crash the app
      if (_isDebugMode) {
        _logger.e('Failed to log message to Crashlytics: $e');
      }
    }
  }
}
