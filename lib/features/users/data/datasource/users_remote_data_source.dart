import 'package:dio/dio.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:delivery_manager/features/users/data/models/user_management_model.dart';

abstract class BaseUsersRemoteDataSource {
  Future<UsersPage> getUsers({
    int page = 1,
    int perPage = 20,
    UserRole? role,
    String? status,
    String? search,
  });

  Future<UserManagementModel> getUserById(int id);
  Future<void> approveUser(int userId);
  Future<void> rejectUser(int userId, String reason);
  Future<void> suspendUser(int userId, String reason);
  Future<void> activateUser(int userId);
}

class UsersPage {
  final List<UserManagementModel> users;
  final int currentPage;
  final int totalPages;
  final bool hasMorePages;
  final int total;

  const UsersPage({
    required this.users,
    required this.currentPage,
    required this.totalPages,
    required this.hasMorePages,
    required this.total,
  });
}

class UsersRemoteDataSourceImpl implements BaseUsersRemoteDataSource {
  final Dio dio;
  final BaseTokenRepository tokenRepository;
  final LoggingService _logger = LoggingService();

  UsersRemoteDataSourceImpl({
    required this.dio,
    required this.tokenRepository,
  });

  Future<Map<String, String>> _getAuthHeaders() async {
    final tokenResult = await tokenRepository.getToken();
    final token = tokenResult.fold(
      (failure) => throw ServerException(message: 'Failed to get token'),
      (token) => token,
    );

    if (token == null || token.isEmpty) {
      throw ServerException(message: 'No authentication token found');
    }

    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<UsersPage> getUsers({
    int page = 1,
    int perPage = 20,
    UserRole? role,
    String? status,
    String? search,
  }) async {
    _logger.debug(
      'UsersRemoteDataSource: Fetching users page=$page, perPage=$perPage, role=$role, status=$status, search=$search',
    );

    try {
      final headers = await _getAuthHeaders();
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (role != null) {
        queryParams['role'] = role.roleName;
      }

      if (status != null) {
        queryParams['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await dio.get(
        ApiConstance.managerUsersPath,
        options: Options(headers: headers),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        if (response.data is Map && response.data['success'] == false) {
          final message =
              response.data['message']?.toString() ?? 'Failed to load users';
          throw ServerException(message: message);
        }

        final payload = _extractData(response.data);
        final usersJson = payload['users'] ?? payload['data'] ?? [];
        final users = _parseUsers(usersJson);

        final pagination = _extractPagination(response.data, payload);
        final currentPage = _parseInt(
          pagination?['current_page'] ?? page,
          defaultValue: page,
        );
        final totalPages = _parseInt(
          pagination?['last_page'] ?? currentPage,
          defaultValue: currentPage,
        );
        final hasMorePages = currentPage < totalPages;
        final total = _parseInt(
          pagination?['total'] ?? users.length,
          defaultValue: users.length,
        );

        _logger.debug(
          'UsersRemoteDataSource: Loaded ${users.length} users',
        );

        return UsersPage(
          users: users,
          currentPage: currentPage,
          totalPages: totalPages,
          hasMorePages: hasMorePages,
          total: total,
        );
      }

      throw ServerException(
        message: 'Failed to load users: ${response.statusCode}',
      );
    } on DioException catch (e) {
      _logger.error('UsersRemoteDataSource: DioException', error: e);
      _handleDioException(e);
      rethrow;
    } catch (e) {
      _logger.error('UsersRemoteDataSource: Unexpected error', error: e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<UserManagementModel> getUserById(int id) async {
    _logger.debug('UsersRemoteDataSource: Fetching user $id');

    try {
      final headers = await _getAuthHeaders();
      final response = await dio.get(
        ApiConstance.managerUserByIdPath(id),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final payload = _extractData(response.data);
        final userJson = payload['user'] ?? payload;
        return UserManagementModel.fromJson(userJson);
      }

      throw ServerException(
        message: 'Failed to load user: ${response.statusCode}',
      );
    } on DioException catch (e) {
      _logger.error('UsersRemoteDataSource: DioException', error: e);
      _handleDioException(e);
      rethrow;
    } catch (e) {
      _logger.error('UsersRemoteDataSource: Unexpected error', error: e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> approveUser(int userId) async {
    _logger.debug('UsersRemoteDataSource: Approving user $userId');

    try {
      final headers = await _getAuthHeaders();
      final response = await dio.post(
        ApiConstance.managerApproveUserPath(userId),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final success = response.data is Map &&
            (response.data['success'] == null ||
                response.data['success'] == true);
        if (success) return;

        String message = 'Failed to approve user';
        if (response.data is Map && response.data['message'] != null) {
          message = response.data['message'].toString();
        }
        throw ServerException(message: message);
      }

      throw ServerException(
        message: 'Failed to approve user: ${response.statusCode}',
      );
    } on DioException catch (e) {
      _logger.error('UsersRemoteDataSource: DioException', error: e);
      _handleDioException(e);
      rethrow;
    } catch (e) {
      _logger.error('UsersRemoteDataSource: Unexpected error', error: e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> rejectUser(int userId, String reason) async {
    _logger.debug('UsersRemoteDataSource: Rejecting user $userId');

    try {
      final headers = await _getAuthHeaders();
      final response = await dio.post(
        ApiConstance.managerRejectUserPath(userId),
        options: Options(headers: headers),
        data: {'reason': reason},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final success = response.data is Map &&
            (response.data['success'] == null ||
                response.data['success'] == true);
        if (success) return;

        String message = 'Failed to reject user';
        if (response.data is Map && response.data['message'] != null) {
          message = response.data['message'].toString();
        }
        throw ServerException(message: message);
      }

      throw ServerException(
        message: 'Failed to reject user: ${response.statusCode}',
      );
    } on DioException catch (e) {
      _logger.error('UsersRemoteDataSource: DioException', error: e);
      _handleDioException(e);
      rethrow;
    } catch (e) {
      _logger.error('UsersRemoteDataSource: Unexpected error', error: e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> suspendUser(int userId, String reason) async {
    _logger.debug('UsersRemoteDataSource: Suspending user $userId');

    try {
      final headers = await _getAuthHeaders();
      final response = await dio.post(
        ApiConstance.managerSuspendUserPath(userId),
        options: Options(headers: headers),
        data: {'reason': reason},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final success = response.data is Map &&
            (response.data['success'] == null ||
                response.data['success'] == true);
        if (success) return;

        String message = 'Failed to suspend user';
        if (response.data is Map && response.data['message'] != null) {
          message = response.data['message'].toString();
        }
        throw ServerException(message: message);
      }

      throw ServerException(
        message: 'Failed to suspend user: ${response.statusCode}',
      );
    } on DioException catch (e) {
      _logger.error('UsersRemoteDataSource: DioException', error: e);
      _handleDioException(e);
      rethrow;
    } catch (e) {
      _logger.error('UsersRemoteDataSource: Unexpected error', error: e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  @override
  Future<void> activateUser(int userId) async {
    _logger.debug('UsersRemoteDataSource: Activating user $userId');

    try {
      final headers = await _getAuthHeaders();
      final response = await dio.post(
        ApiConstance.managerActivateUserPath(userId),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final success = response.data is Map &&
            (response.data['success'] == null ||
                response.data['success'] == true);
        if (success) return;

        String message = 'Failed to activate user';
        if (response.data is Map && response.data['message'] != null) {
          message = response.data['message'].toString();
        }
        throw ServerException(message: message);
      }

      throw ServerException(
        message: 'Failed to activate user: ${response.statusCode}',
      );
    } on DioException catch (e) {
      _logger.error('UsersRemoteDataSource: DioException', error: e);
      _handleDioException(e);
      rethrow;
    } catch (e) {
      _logger.error('UsersRemoteDataSource: Unexpected error', error: e);
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  // Helper methods
  Map<String, dynamic> _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['data'] is Map<String, dynamic>
          ? responseData['data'] as Map<String, dynamic>
          : responseData;
    }
    if (responseData is Map) {
      final map = responseData.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final data = map['data'];
      if (data is Map) {
        return data.map((key, value) => MapEntry(key.toString(), value));
      }
      return map;
    }
    return {};
  }

  List<UserManagementModel> _parseUsers(dynamic usersJson) {
    if (usersJson is! List) return [];

    return usersJson
        .map((item) {
          if (item is Map<String, dynamic>) {
            return UserManagementModel.fromJson(item);
          }
          if (item is Map) {
            return UserManagementModel.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            );
          }
          return null;
        })
        .whereType<UserManagementModel>()
        .toList();
  }

  Map<String, dynamic>? _extractPagination(
    dynamic responseData,
    Map<String, dynamic> payload,
  ) {
    if (responseData is Map<String, dynamic>) {
      if (responseData['meta'] is Map &&
          (responseData['meta'] as Map)['pagination'] is Map) {
        return (responseData['meta'] as Map)['pagination']
            .map((key, value) => MapEntry(key.toString(), value));
      }
      if (responseData['pagination'] is Map) {
        return (responseData['pagination'] as Map)
            .map((key, value) => MapEntry(key.toString(), value));
      }
    }
    if (payload['pagination'] is Map) {
      return (payload['pagination'] as Map)
          .map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  int _parseInt(dynamic value, {required int defaultValue}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  void _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw NetworkException(message: 'Network connection error');
    }

    final response = e.response;
    if (response != null) {
      String message = 'Server error occurred';
      if (response.data is Map && response.data['message'] != null) {
        message = response.data['message'].toString();
      }
      throw ServerException(message: message);
    }
    throw ServerException(message: e.message ?? 'Unknown error occurred');
  }
}
