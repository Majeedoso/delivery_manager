import 'package:dio/dio.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:flutter/foundation.dart';

/// Abstract interface for token remote data source
/// 
/// Defines the contract for token validation with the backend API.
/// Used to verify if an authentication token is still valid.
abstract class BaseTokenRemoteDataSource {
  /// Validate token with backend API
  /// 
  /// Parameters:
  /// - [token]: Authentication token to validate
  /// 
  /// Returns:
  /// - true if token is valid
  /// - false if token is invalid or expired
  /// 
  /// Throws:
  /// - [ServerException] for API errors
  /// - [NetworkException] for network errors (timeout, connection failure)
  Future<bool> validateToken(String token);
}

/// Implementation of [BaseTokenRemoteDataSource]
/// 
/// Validates authentication tokens by making a GET request to the user endpoint
/// with the token in the Authorization header. Uses shorter timeouts for
/// faster validation during app startup.
class TokenRemoteDataSource implements BaseTokenRemoteDataSource {
  /// Dio instance for making HTTP requests
  final Dio dio;
  final LoggingService? _logger;

  TokenRemoteDataSource({required this.dio, LoggingService? logger}) : _logger = logger;
  
  LoggingService get logger {
    try {
      return _logger ?? sl<LoggingService>();
    } catch (e) {
      return LoggingService();
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      // Use shorter timeouts for faster token validation during splash screen
      final response = await dio.get(
        ApiConstance.userPath,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          if (kDebugMode) {
            logger.warning('TokenRemoteDataSource: Token validation timed out after 8 seconds');
          }
          throw ServerException(message: 'Token validation timed out');
        },
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return false; // Token is invalid
      }
      
      // Handle timeout and connection errors
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout || 
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Request timeout. Please check your internet connection and try again.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Cannot connect to server. Please check your internet connection.');
      } else {
        throw ServerException(message: 'Token validation failed: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Token validation failed: ${e.toString()}');
    }
  }
}
