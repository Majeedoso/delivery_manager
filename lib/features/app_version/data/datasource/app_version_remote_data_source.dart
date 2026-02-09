import 'package:dio/dio.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';

/// Abstract interface for remote app version data source
/// 
/// Defines the contract for app version API operations:
/// - Check app version from server
/// 
/// The implementation is responsible for making HTTP requests to the backend API
/// and handling network-related exceptions.
abstract class BaseAppVersionRemoteDataSource {
  /// Check app version from server
  /// 
  /// Returns:
  /// - [AppVersion] containing version information
  /// 
  /// Throws:
  /// - [ServerException] for API errors
  /// - [NetworkException] for network errors (timeout, connection failure)
  Future<AppVersion> checkAppVersion();
}

/// Implementation of remote app version data source
/// 
/// This class handles communication with the backend API to retrieve
/// app version information.
class AppVersionRemoteDataSource implements BaseAppVersionRemoteDataSource {
  final Dio dio;
  final LoggingService? _logger;
  
  AppVersionRemoteDataSource({required this.dio, LoggingService? logger}) : _logger = logger;
  
  LoggingService get logger {
    try {
      return _logger ?? sl<LoggingService>();
    } catch (e) {
      return LoggingService();
    }
  }

  @override
  Future<AppVersion> checkAppVersion() async {
    try {
      // App type for restaurant app
      const appType = 'restaurant';
      
      final response = await dio.get(
        ApiConstance.appVersionPath,
        queryParameters: {'app_type': appType},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-App-Type': appType,
          },
        ),
      );

      logger.debug('AppVersionDataSource: API request - URL: ${response.requestOptions.uri}, Status: ${response.statusCode}');
      logger.debug('AppVersionDataSource: API response received: ${response.data}');
      
      if (response.statusCode == 200) {
        // Handle different response structures
        Map<String, dynamic> data;
        if (response.data is Map<String, dynamic>) {
          // Check if data is wrapped in 'data' key
          if (response.data.containsKey('data')) {
            final dataValue = response.data['data'];
            if (dataValue is Map<String, dynamic>) {
              data = dataValue;
            } else {
              logger.warning('AppVersionDataSource: Response data["data"] is not a Map, type: ${dataValue.runtimeType}, value: $dataValue');
              // If 'data' is not a Map, try using response.data directly
              data = response.data as Map<String, dynamic>;
            }
          } else {
            logger.warning('AppVersionDataSource: Response does not contain "data" key, using response.data directly');
            // No 'data' wrapper, use response.data directly
            data = response.data as Map<String, dynamic>;
          }
        } else {
          logger.error('AppVersionDataSource: Response data is not a Map, type: ${response.data.runtimeType}');
          throw ServerException(
            message: 'Invalid response format from server: Expected Map, got ${response.data.runtimeType}',
          );
        }
        
        logger.debug('AppVersionDataSource: Parsed data - keys: ${data.keys.toList()}, minimum_version: ${data['minimum_version']}, current_version: ${data['current_version']}');
        
        // Check if required fields exist
        if (!data.containsKey('minimum_version') || !data.containsKey('current_version')) {
          logger.error('AppVersionDataSource: Missing required fields. Available keys: ${data.keys.toList()}');
          throw ServerException(
            message: 'Invalid response format: Missing minimum_version or current_version fields',
          );
        }
        
        // Safely extract version strings with fallbacks
        final minimumVersion = data['minimum_version']?.toString() ?? '1.0.0';
        final currentVersion = data['current_version']?.toString() ?? '1.0.0';
        
        final appVersion = AppVersion(
          minimumVersion: minimumVersion,
          currentVersion: currentVersion,
          updateUrlIos: data['update_url_ios']?.toString(),
          updateUrlAndroid: data['update_url_android']?.toString(),
        );
        logger.info('AppVersionDataSource: Created AppVersion entity: min=${appVersion.minimumVersion}, current=${appVersion.currentVersion}');
        return appVersion;
      } else {
        logger.error('AppVersionDataSource: Non-200 status code: ${response.statusCode}, Response: ${response.data}');
        throw ServerException(
          message: response.data?['message']?.toString() ?? 'Failed to check app version (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      logger.error('AppVersionDataSource: DioException - Type: ${e.type}, Message: ${e.message}');
      logger.error('AppVersionDataSource: DioException - Response: ${e.response?.data}, Status: ${e.response?.statusCode}');
      logger.error('AppVersionDataSource: DioException - Request: ${e.requestOptions.uri}');
      
      // CRITICAL: Log the underlying error - this will show SSL/certificate issues
      logger.error('AppVersionDataSource: DioException - Underlying error: ${e.error}');
      logger.error('AppVersionDataSource: DioException - Error type: ${e.error?.runtimeType}');
      logger.error('AppVersionDataSource: DioException - StackTrace: ${e.stackTrace}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        logger.warning('AppVersionDataSource: Network error detected');
        throw NetworkException(
          message: 'Network error. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.badResponse) {
        final errorMessage = e.response?.data?['message']?.toString() ?? 
                            e.response?.data?.toString() ?? 
                            'Server error occurred (Status: ${e.response?.statusCode})';
        logger.error('AppVersionDataSource: Bad response - $errorMessage');
        throw ServerException(
          message: errorMessage,
        );
      } else if (e.type == DioExceptionType.unknown) {
        // Handle unknown errors - often SSL/certificate issues on Android
        final underlyingError = e.error?.toString() ?? e.message ?? 'Unknown error';
        logger.error('AppVersionDataSource: Unknown DioException - Underlying: $underlyingError');
        
        // Check for SSL/certificate errors
        final errorStr = underlyingError.toString().toLowerCase();
        if (errorStr.contains('certificate') || 
            errorStr.contains('ssl') ||
            errorStr.contains('handshake') ||
            errorStr.contains('certificate_verify_failed')) {
          throw NetworkException(
            message: 'SSL certificate validation failed. Please check server certificate.',
          );
        }
        
        throw ServerException(
          message: 'Failed to check app version: $underlyingError',
        );
      } else {
        logger.error('AppVersionDataSource: Other DioException - ${e.message}, Error: ${e.error}');
        throw ServerException(
          message: e.message ?? 'Failed to check app version',
        );
      }
    } catch (e) {
      logger.error('AppVersionDataSource: Unexpected error - ${e.toString()}');
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }
      throw ServerException(
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}

