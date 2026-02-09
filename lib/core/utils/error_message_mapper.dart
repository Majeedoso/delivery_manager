import 'package:dio/dio.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/l10n/app_localizations.dart';

/// Service for mapping technical errors to user-friendly messages
/// 
/// This class provides a centralized way to convert exceptions and failures
/// into messages that are appropriate for end users. It handles:
/// - Network errors (timeout, connection issues)
/// - Server errors (4xx, 5xx status codes)
/// - Authentication errors
/// - Validation errors
/// - Generic errors
/// 
/// All messages are localized based on the provided AppLocalizations.
class ErrorMessageMapper {
  // Prevent instantiation
  ErrorMessageMapper._();

  /// Map any error to a user-friendly message
  /// 
  /// [error] - The error object (Exception, Failure, or String)
  /// [localizations] - AppLocalizations instance for localized messages
  /// 
  /// Returns a user-friendly error message in the user's language
  static String getUserFriendlyMessage(
    dynamic error,
    AppLocalizations localizations,
  ) {
    if (error == null) {
      return localizations.errorGeneric;
    }

    // Handle String errors
    if (error is String) {
      return _cleanErrorMessage(error, localizations);
    }

    // Handle DioException first (before Exception, since DioException extends Exception)
    if (error is DioException) {
      return _mapDioExceptionToMessage(error, localizations);
    }

    // Handle Failure objects
    if (error is Failure) {
      return _mapFailureToMessage(error, localizations);
    }

    // Handle Exception objects
    if (error is Exception) {
      return _mapExceptionToMessage(error, localizations);
    }

    // Handle generic errors
    final errorString = error.toString();
    return _cleanErrorMessage(errorString, localizations);
  }

  /// Map Failure to user-friendly message
  static String _mapFailureToMessage(Failure failure, AppLocalizations localizations) {
    if (failure is NetworkFailure) {
      return _getNetworkErrorMessage(failure.message, localizations);
    }

    if (failure is ServerFailure) {
      return _getServerErrorMessage(failure.message, localizations);
    }

    if (failure is AuthFailure) {
      return _getAuthErrorMessage(failure.message, localizations);
    }

    if (failure is ValidationFailure) {
      return _getValidationErrorMessage(failure.message, localizations);
    }

    if (failure is DatabaseFailure) {
      return localizations.errorDatabaseLocal;
    }

    if (failure is CacheFailure) {
      return localizations.errorCacheLoad;
    }

    return _cleanErrorMessage(failure.message, localizations);
  }

  /// Map Exception to user-friendly message
  static String _mapExceptionToMessage(Exception exception, AppLocalizations localizations) {
    if (exception is NetworkException) {
      return _getNetworkErrorMessage(exception.message, localizations);
    }

    if (exception is ServerException) {
      return _getServerErrorMessage(exception.message, localizations);
    }

    if (exception is AuthException) {
      return _getAuthErrorMessage(exception.message, localizations);
    }

    if (exception is ValidationException) {
      return _getValidationErrorMessage(exception.message, localizations);
    }

    if (exception is LocalDatabaseException) {
      return localizations.errorDatabaseLocal;
    }

    if (exception is CacheException) {
      return localizations.errorCacheLoad;
    }

    return _cleanErrorMessage(exception.toString(), localizations);
  }

  /// Map DioException to user-friendly message
  static String _mapDioExceptionToMessage(DioException dioException, AppLocalizations localizations) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return localizations.errorNetworkTimeout;

      case DioExceptionType.connectionError:
        return localizations.errorConnectionError;

      case DioExceptionType.badResponse:
        return _handleBadResponse(dioException, localizations);

      case DioExceptionType.cancel:
        return localizations.errorRequestCancelled;

      case DioExceptionType.unknown:
      default:
        return localizations.errorNetworkGeneric;
    }
  }

  /// Handle bad HTTP response (4xx, 5xx)
  static String _handleBadResponse(DioException dioException, AppLocalizations localizations) {
    final statusCode = dioException.response?.statusCode;
    final responseData = dioException.response?.data;

    // Extract message from response if available
    String? serverMessage;
    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message']?.toString() ??
          responseData['error']?.toString();
    }

    // Map status codes to user-friendly messages
    switch (statusCode) {
      case 400:
        return serverMessage ?? localizations.errorInvalidRequest;
      case 401:
        return localizations.errorSessionExpired;
      case 403:
        return localizations.errorNoPermission;
      case 404:
        return localizations.errorNotFound;
      case 409:
        return localizations.errorConflict;
      case 422:
        return serverMessage ?? localizations.errorValidation;
      case 429:
        return localizations.errorTooManyRequests;
      case 500:
      case 502:
      case 503:
      case 504:
        return localizations.errorServerUnavailable;
      default:
        return serverMessage ?? localizations.errorServerGeneric;
    }
  }

  /// Get network error message
  static String _getNetworkErrorMessage(String? message, AppLocalizations localizations) {
    if (message == null || message.isEmpty) {
      return localizations.noInternetConnection;
    }

    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('timeout')) {
      return localizations.errorNetworkTimeout;
    }

    if (lowerMessage.contains('connection') || lowerMessage.contains('connect')) {
      return localizations.errorConnectionError;
    }

    if (lowerMessage.contains('network')) {
      return localizations.errorNetworkGeneric;
    }

    return _cleanErrorMessage(message, localizations);
  }

  /// Get server error message
  /// Trusts backend's localized messages and only sanitizes raw technical errors
  static String _getServerErrorMessage(String? message, AppLocalizations localizations) {
    if (message == null || message.isEmpty) {
      return localizations.errorServerGeneric;
    }

    // Check if it's a raw technical error that bypassed the backend's error handler
    // If so, sanitize it. Otherwise, trust the backend's localized message.
    if (_isRawTechnicalError(message)) {
      return localizations.errorServerGeneric;
    }

    final lowerMessage = message.toLowerCase();

    // Check for specific server error patterns
    if (lowerMessage.contains('maintenance') || lowerMessage.contains('down')) {
      return localizations.errorServerMaintenance;
    }

    if (lowerMessage.contains('database') || lowerMessage.contains('db')) {
      return localizations.errorDatabaseServer;
    }

    return _cleanErrorMessage(message, localizations);
  }

  /// Get authentication error message
  static String _getAuthErrorMessage(String? message, AppLocalizations localizations) {
    if (message == null || message.isEmpty) {
      return localizations.errorAuthFailed;
    }

    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('invalid') && 
        (lowerMessage.contains('email') || lowerMessage.contains('password'))) {
      return localizations.errorInvalidCredentials;
    }

    if (lowerMessage.contains('expired') || lowerMessage.contains('token')) {
      return localizations.errorSessionExpired;
    }

    if (lowerMessage.contains('unauthorized') || lowerMessage.contains('401')) {
      return localizations.errorAuthRequired;
    }

    if (lowerMessage.contains('forbidden') || lowerMessage.contains('403')) {
      return localizations.errorNoPermission;
    }

    if (lowerMessage.contains('cancelled')) {
      return localizations.errorSignInCancelled;
    }

    return _cleanErrorMessage(message, localizations);
  }

  /// Get validation error message
  static String _getValidationErrorMessage(String? message, AppLocalizations localizations) {
    if (message == null || message.isEmpty) {
      return localizations.errorValidation;
    }

    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('required') || lowerMessage.contains('empty')) {
      // Use existing localization if available, otherwise use validation error
      return localizations.errorValidation;
    }

    if (lowerMessage.contains('email')) {
      return localizations.pleaseEnterValidEmail;
    }

    if (lowerMessage.contains('password')) {
      if (lowerMessage.contains('weak') || lowerMessage.contains('short')) {
        return localizations.passwordMinLength;
      }
      if (lowerMessage.contains('match')) {
        return localizations.errorValidation;
      }
      return localizations.errorValidation;
    }

    if (lowerMessage.contains('phone')) {
      return localizations.errorValidation;
    }

    return _cleanErrorMessage(message, localizations);
  }

  /// Check if the error message is a raw technical error (PHP fatal error, etc.)
  /// that bypassed the backend's error handler
  static bool _isRawTechnicalError(String message) {
    if (message.isEmpty) return false;
    
    final lowerMessage = message.toLowerCase();
    
    // Check for raw PHP errors that bypass the error handler
    return lowerMessage.contains('call to undefined method') ||
        lowerMessage.contains('fatal error') ||
        lowerMessage.contains('parse error') ||
        lowerMessage.contains('syntax error') ||
        (lowerMessage.contains('class ') && lowerMessage.contains('not found')) ||
        (lowerMessage.contains('method ') && lowerMessage.contains('does not exist')) ||
        lowerMessage.contains('stack trace') ||
        (lowerMessage.contains('exception') && lowerMessage.contains('in ') && lowerMessage.contains('.php')) ||
        (lowerMessage.contains('error') && lowerMessage.contains('on line') && lowerMessage.contains('.php'));
  }

  /// Clean error message by removing technical details
  /// Only sanitizes raw technical errors; trusts backend's localized messages
  static String _cleanErrorMessage(String message, AppLocalizations localizations) {
    if (message.isEmpty) {
      return localizations.errorGeneric;
    }

    // Check for raw technical errors and return generic message
    if (_isRawTechnicalError(message)) {
      return localizations.errorServerGeneric;
    }

    // Remove "Instance of" prefixes
    if (message.contains('Instance of')) {
      return localizations.errorGeneric;
    }

    // Remove stack traces
    if (message.contains('Stack trace:')) {
      final stackIndex = message.indexOf('Stack trace:');
      return message.substring(0, stackIndex).trim();
    }

    // Remove technical prefixes
    final technicalPrefixes = [
      'Exception: ',
      'Error: ',
      'Failure: ',
      'DioException: ',
      'Fatal error: ',
      'Parse error: ',
      'Warning: ',
      'Notice: ',
    ];

    String cleaned = message;
    for (final prefix in technicalPrefixes) {
      if (cleaned.toLowerCase().startsWith(prefix.toLowerCase())) {
        cleaned = cleaned.substring(prefix.length);
      }
    }

    // Remove file paths and line numbers
    cleaned = cleaned.replaceAll(RegExp(r'\([^)]*\.php:\d+\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'in\s+[^\s]+\.php\s+on\s+line\s+\d+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'at\s+[^\s]+\.php:\d+'), '');

    // Remove class and method names in parentheses (e.g., "ClassName::methodName()")
    cleaned = cleaned.replaceAll(RegExp(r'\([A-Z][a-zA-Z0-9_]*::[a-zA-Z0-9_]+\)'), '');

    // Remove URLs from error messages
    cleaned = cleaned.replaceAll(
      RegExp(r'https?://[^\s]+'),
      '',
    );

    // Remove IP addresses
    cleaned = cleaned.replaceAll(
      RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
      '',
    );

    // Clean up multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // If message is still too technical, return generic message
    if (cleaned.contains('at ') && cleaned.contains('(') && cleaned.contains(')') ||
        cleaned.contains('::') ||
        cleaned.contains('->') ||
        (cleaned.contains('(') && cleaned.contains(')') && cleaned.length < 50)) {
      return localizations.errorGeneric;
    }

    return cleaned.isEmpty ? localizations.errorGeneric : cleaned;
  }

  /// Check if error should be shown to user
  /// Some errors (like user cancellation) should be silently ignored
  static bool shouldShowError(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();
    
    // Don't show errors for user cancellation
    if (errorString.contains('cancelled') || 
        errorString.contains('cancel')) {
      return false;
    }

    // Don't show errors for aborted operations
    if (errorString.contains('abort') || 
        errorString.contains('aborted')) {
      return false;
    }

    return true;
  }
}
