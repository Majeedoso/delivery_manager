import 'package:dio/dio.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/network/request_failure.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/dashboard/data/models/app_dashboard_model.dart';

abstract class BaseDashboardRemoteDataSource {
  Future<Map<String, dynamic>> getSettings({
    String? category,
    String? search,
    int page = 1,
    int perPage = 50,
  });

  Future<AppDashboardModel> updateSetting(int id, String value);
}

class DashboardRemoteDataSource implements BaseDashboardRemoteDataSource {
  final Dio dio;
  final LoggingService? _logger;

  DashboardRemoteDataSource({required this.dio, LoggingService? logger})
      : _logger = logger;

  LoggingService get logger {
    try {
      return _logger ?? sl<LoggingService>();
    } catch (_) {
      return LoggingService();
    }
  }

  /// What a failed request tells the manager: the server's reason, or that
  /// the network failed ([requestFailureOf]). An error page read as a map
  /// threw, and the page read "An unexpected error occurred: ...".
  Exception _failure(Object error, String request) {
    logger.error('$request failed', error: error);
    if (error is ServerException) return error;
    if (error is NetworkException) return error;
    return requestFailureOf(error);
  }

  @override
  Future<Map<String, dynamic>> getSettings({
    String? category,
    String? search,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'sort_by': 'category',
        'sort_order': 'asc',
      };
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        ApiConstance.managerSettingsPath,
        queryParameters: queryParams,
      );

      logger.debug('Get Settings API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<AppDashboardModel> settings = (data['data'] as List)
            .map((json) => AppDashboardModel.fromJson(json as Map<String, dynamic>))
            .toList();
        final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
        return {
          'settings': settings,
          'current_page': pagination['current_page'] ?? 1,
          'last_page': pagination['last_page'] ?? 1,
          'total': pagination['total'] ?? settings.length,
        };
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load settings',
        );
      }
    } catch (e) {
      throw _failure(e, 'Get Settings');
    }
  }

  @override
  Future<AppDashboardModel> updateSetting(int id, String value) async {
    try {
      final response = await dio.put(
        ApiConstance.managerSettingByIdPath(id),
        data: {'value': value},
      );

      logger.debug('Update Setting API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return AppDashboardModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update setting',
        );
      }
    } catch (e) {
      throw _failure(e, 'Update Setting');
    }
  }
}
