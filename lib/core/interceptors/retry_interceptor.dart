import 'dart:io';
import 'package:dio/dio.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that adds retry logic for network requests
/// Retries on network errors, timeouts, and 5xx server errors
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final LoggingService? _logger;

  RetryInterceptor({
    this.maxRetries = 3,
    Duration? retryDelay,
    LoggingService? logger,
  }) : retryDelay = retryDelay ?? const Duration(seconds: 2),
       _logger = logger;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    // Check if we should retry this error
    if (!_shouldRetry(err, retryCount)) {
      return handler.next(err);
    }

    // Increment retry count
    err.requestOptions.extra['retryCount'] = retryCount + 1;

    // Calculate delay with exponential backoff
    final delay = Duration(
      milliseconds: retryDelay.inMilliseconds * (retryCount + 1),
    );

    _logRetry(err, retryCount + 1, delay);

    // Wait before retrying
    await Future.delayed(delay);

    try {
      // Retry the request
      final response = await _retryRequest(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      // If retry failed, log the error for debugging
      if (e is DioException && e.response != null) {
        try {
          final logger = _logger ?? sl<LoggingService>();
          logger.error('RetryInterceptor: Retry failed with response: ${e.response!.statusCode} - ${e.response!.data}');
        } catch (_) {
          // Ignore logging errors
        }
      }
      // If retry failed, continue with the error
      if (e is DioException) {
        return handler.next(e);
      }
      return handler.next(err);
    }
  }

  /// Determines if an error should be retried
  bool _shouldRetry(DioException err, int retryCount) {
    // Don't retry if we've exceeded max retries
    if (retryCount >= maxRetries) {
      return false;
    }

    // Don't retry cancelled requests
    if (err.type == DioExceptionType.cancel) {
      return false;
    }

    // Retry on network errors and timeouts
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on 5xx server errors (server-side errors)
    if (err.type == DioExceptionType.badResponse) {
      final statusCode = err.response?.statusCode;
      if (statusCode != null && statusCode >= 500 && statusCode < 600) {
        return true;
      }
    }

    // Don't retry on 4xx errors (client errors)
    // Don't retry on other error types
    return false;
  }

  /// Retries the request using the original Dio instance from service locator
  /// This ensures all interceptors (auth, language, etc.) are preserved
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    // Get the original Dio instance from service locator to preserve interceptors
    Dio dio;
    try {
      dio = sl<Dio>();
    } catch (e) {
      // Fallback: create a new Dio instance if service locator is not available
      // This should rarely happen, but provides a safety net
      dio = Dio(
        BaseOptions(
          baseUrl: requestOptions.baseUrl,
          connectTimeout: requestOptions.connectTimeout,
          receiveTimeout: requestOptions.receiveTimeout,
          sendTimeout: requestOptions.sendTimeout,
          headers: Map<String, dynamic>.from(requestOptions.headers),
        ),
      );
    }

    // Copy the request options
    final options = Options(
      method: requestOptions.method,
      headers: Map<String, dynamic>.from(requestOptions.headers),
      extra: Map<String, dynamic>.from(requestOptions.extra),
      validateStatus: requestOptions.validateStatus,
      responseType: requestOptions.responseType,
      followRedirects: requestOptions.followRedirects,
      maxRedirects: requestOptions.maxRedirects,
      persistentConnection: requestOptions.persistentConnection,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
    );

    // Recreate FormData if it was a multipart request
    // FormData can only be used once, so we need to recreate it for retries
    dynamic requestData = requestOptions.data;
    if (requestData is FormData) {
      // Check if we have original data stored to recreate FormData
      final originalData = requestOptions.extra['originalData'];
      if (originalData != null && originalData is Map<String, dynamic>) {
        // Recreate FormData from original data to avoid "already finalized" error
        requestData = _recreateFormData(originalData);
      } else {
        // If we don't have original data, skip retry for this request
        // This can happen if the request was made without storing originalData
        // In this case, we'll let the error propagate
        throw DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.unknown,
          error: 'Cannot retry request: FormData already finalized and original data not available',
        );
      }
    }
    
    // Use the path from request options (it's relative to baseUrl)
    return await dio.request(
      requestOptions.path,
      data: requestData,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }

  /// Recreates FormData from original data map
  FormData _recreateFormData(Map<String, dynamic> data) {
    final formData = FormData();

    data.forEach((key, value) {
      if (value is File) {
        // Add file to form data
        formData.files.add(
          MapEntry(
            key,
            MultipartFile.fromFileSync(
              value.path,
              filename: value.path.split('/').last,
            ),
          ),
        );
      } else if (value is List) {
        // Handle arrays (like ingredients, allergens)
        for (int i = 0; i < value.length; i++) {
          formData.fields.add(MapEntry('$key[$i]', value[i].toString()));
        }
      } else if (value is Map) {
        // Handle nested objects (like nutritional_info)
        value.forEach((nestedKey, nestedValue) {
          formData.fields.add(MapEntry('$key[$nestedKey]', nestedValue.toString()));
        });
      } else if (value != null) {
        // Add regular field
        String stringValue;
        if (value is bool) {
          stringValue = value ? '1' : '0';
        } else {
          stringValue = value.toString();
        }
        formData.fields.add(MapEntry(key, stringValue));
      }
    });

    return formData;
  }

  /// Logs retry attempts
  void _logRetry(DioException err, int attempt, Duration delay) {
    final message =
        'Retrying request (attempt $attempt/$maxRetries) after ${delay.inMilliseconds}ms: ${err.requestOptions.path}';

    try {
      final logger = _logger ?? sl<LoggingService>();
      logger.warning('RetryInterceptor: $message');
    } catch (e) {
      // Fallback if logger not available via SL
      try {
        final logger = LoggingService();
        logger.warning('RetryInterceptor: $message');
      } catch (_) {
        debugPrint('RetryInterceptor: $message');
      }
    }
  }
}
