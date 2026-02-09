import 'package:dio/dio.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/core/interceptors/retry_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  late final Dio _dio;
  final String baseUrl;
  final LoggingService? _logger;

  ApiService({required this.baseUrl, LoggingService? logger})
    : _logger = logger {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add language interceptor to include Accept-Language header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add Accept-Language header based on current app language
          try {
            final sharedPreferences = sl<SharedPreferences>();
            final languageCode = sharedPreferences.getString('selected_language') ?? 'ar';
            // Validate language code (must be one of: ar, en, fr)
            final validLanguages = ['ar', 'en', 'fr'];
            final validLanguageCode = validLanguages.contains(languageCode) ? languageCode : 'ar';
            options.headers['Accept-Language'] = validLanguageCode;
          } catch (e) {
            // If language retrieval fails, default to Arabic
            options.headers['Accept-Language'] = 'ar';
          }
          handler.next(options);
        },
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        maxRetries: 3,
        retryDelay: const Duration(seconds: 2),
        logger: _logger,
      ),
    );

    // Add interceptors - only log in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) {
            try {
              final logger = _logger ?? sl<LoggingService>();
              logger.debug('ApiService: $object');
            } catch (e) {
              // Fallback if logger not available via SL
              try {
                final logger = LoggingService();
                logger.debug('ApiService: $object');
              } catch (_) {
                // Last resort: print to console
                debugPrint('ApiService: $object');
              }
            }
          },
        ),
      );
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        return Exception('Server error: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        return Exception(
          'Connection error. Please check your internet connection.',
        );
      default:
        return Exception('An unexpected error occurred: ${e.message}');
    }
  }

  // Add authentication token to requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authentication token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
