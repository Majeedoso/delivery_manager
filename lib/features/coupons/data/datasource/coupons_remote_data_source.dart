import 'package:dio/dio.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:delivery_manager/features/coupons/data/models/coupon_model.dart';
import 'package:delivery_manager/features/coupons/data/models/delivery_zone_model.dart';

/// Abstract class for coupons remote data source operations.
abstract class BaseCouponsRemoteDataSource {
  /// Get paginated list of coupons.
  Future<Map<String, dynamic>> getCoupons({
    String? status,
    String? issuerType,
    String? search,
    String? discountTarget,
    int page = 1,
    int perPage = 20,
  });

  /// Get coupon zones for manager selection.
  Future<List<DeliveryZoneModel>> getDeliveryZones();

  /// Get restaurants for coupon targeting.
  Future<List<Map<String, dynamic>>> getRestaurants({
    String? search,
    int page = 1,
    int perPage = 50,
  });

  /// Create a new delivery zone.
  Future<DeliveryZoneModel> createDeliveryZone(Map<String, dynamic> data);

  /// Update an existing delivery zone.
  Future<DeliveryZoneModel> updateDeliveryZone(int id, Map<String, dynamic> data);

  /// Delete a delivery zone.
  Future<void> deleteDeliveryZone(int id);

  /// Create a new coupon.
  Future<CouponModel> createCoupon(Map<String, dynamic> data);

  /// Update an existing coupon.
  Future<CouponModel> updateCoupon(int id, Map<String, dynamic> data);
}

/// Implementation of coupons remote data source.
class CouponsRemoteDataSource implements BaseCouponsRemoteDataSource {
  final Dio dio;
  final LoggingService? _logger;

  CouponsRemoteDataSource({required this.dio, LoggingService? logger})
    : _logger = logger;

  LoggingService get logger {
    try {
      return _logger ?? sl<LoggingService>();
    } catch (_) {
      return LoggingService();
    }
  }

  @override
  Future<Map<String, dynamic>> getCoupons({
    String? status,
    String? issuerType,
    String? search,
    String? discountTarget,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};
      if (status != null) queryParams['status'] = status;
      if (issuerType != null) queryParams['issuer_type'] = issuerType;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (discountTarget != null && discountTarget.isNotEmpty) {
        queryParams['discount_target'] = discountTarget;
      }

      final response = await dio.get(
        ApiConstance.managerCouponsPath,
        queryParameters: queryParams,
      );

      logger.debug('Get Coupons API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final List<CouponModel> coupons = (data['data'] as List)
            .map((json) => CouponModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'coupons': coupons,
          'current_page': data['current_page'],
          'last_page': data['last_page'],
          'total': data['total'],
        };
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load coupons',
        );
      }
    } on DioException catch (e) {
      logger.error('Get Coupons API DioException: ${e.message}');
      if (e.response != null) {
        throw ServerException(
          message: e.response!.data['message'] ?? 'Failed to load coupons',
        );
      } else {
        throw NetworkException(
          message:
              'Cannot connect to server. Please check your internet connection.',
        );
      }
    } catch (e) {
      logger.error('Get Coupons unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<List<DeliveryZoneModel>> getDeliveryZones() async {
    try {
      final response = await dio.get(ApiConstance.managerCouponZonesPath);

      logger.debug(
        'Get coupon zones API Response Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final zones = data is List ? data : (data['zones'] as List?) ?? [];
        return zones
            .map(
              (json) => DeliveryZoneModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load coupon zones',
        );
      }
    } on DioException catch (e) {
      logger.error('Get coupon zones API DioException: ${e.message}');
      if (e.response != null) {
        throw ServerException(
          message: e.response!.data['message'] ?? 'Failed to load coupon zones',
        );
      } else {
        throw NetworkException(
          message:
              'Cannot connect to server. Please check your internet connection.',
        );
      }
    } catch (e) {
      logger.error('Get coupon zones unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<DeliveryZoneModel> createDeliveryZone(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        ApiConstance.managerCouponZonesPath,
        data: data,
      );

      logger.debug(
        'Create delivery zone API Response Status: ${response.statusCode}',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return DeliveryZoneModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create zone',
        );
      }
    } on DioException catch (e) {
      logger.error('Create delivery zone API DioException: ${e.message}');
      if (e.response != null) {
        throw ServerException(
          message: e.response!.data['message'] ?? 'Failed to create zone',
        );
      } else {
        throw NetworkException(
          message:
              'Cannot connect to server. Please check your internet connection.',
        );
      }
    } catch (e) {
      logger.error('Create delivery zone unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<DeliveryZoneModel> updateDeliveryZone(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dio.put(
        ApiConstance.managerCouponZoneByIdPath(id),
        data: data,
      );

      logger.debug(
        'Update delivery zone API Response Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        return DeliveryZoneModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update zone',
        );
      }
    } on DioException catch (e) {
      logger.error('Update delivery zone API DioException: ${e.message}');
      if (e.response != null) {
        throw ServerException(
          message: e.response!.data['message'] ?? 'Failed to update zone',
        );
      } else {
        throw NetworkException(
          message:
              'Cannot connect to server. Please check your internet connection.',
        );
      }
    } catch (e) {
      logger.error('Update delivery zone unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteDeliveryZone(int id) async {
    try {
      final response = await dio.delete(
        ApiConstance.managerCouponZoneByIdPath(id),
      );

      logger.debug(
        'Delete delivery zone API Response Status: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete zone',
        );
      }
    } on DioException catch (e) {
      logger.error('Delete delivery zone API DioException: ${e.message}');
      if (e.response != null) {
        throw ServerException(
          message: e.response!.data['message'] ?? 'Failed to delete zone',
        );
      } else {
        throw NetworkException(
          message:
              'Cannot connect to server. Please check your internet connection.',
        );
      }
    } catch (e) {
      logger.error('Delete delivery zone unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<CouponModel> createCoupon(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        ApiConstance.managerCouponsPath,
        data: data,
      );

      logger.debug('Create Coupon API Response Status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return CouponModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create coupon',
        );
      }
    } on DioException catch (e) {
      logger.error('Create Coupon API DioException: ${e.message}');
      if (e.response != null) {
        final message =
            e.response!.data['message'] ?? 'Failed to create coupon';
        throw ServerException(message: message);
      } else {
        throw NetworkException(
          message:
              'Cannot connect to server. Please check your internet connection.',
        );
      }
    } catch (e) {
      logger.error('Create Coupon unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<CouponModel> updateCoupon(int id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        ApiConstance.managerCouponByIdPath(id),
        data: data,
      );

      logger.debug('Update Coupon API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return CouponModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update coupon',
        );
      }
    } on DioException catch (e) {
      logger.error('Update Coupon API DioException: ${e.message}');
      if (e.response != null) {
        final message =
            e.response!.data['message'] ?? 'Failed to update coupon';
        throw ServerException(message: message);
      } else {
        throw NetworkException(
          message:
              'Cannot connect to server. Please check your internet connection.',
        );
      }
    } catch (e) {
      logger.error('Update Coupon unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRestaurants({
    String? search,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'per_page': perPage};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await dio.get(
        ApiConstance.restaurantsPath,
        queryParameters: queryParams,
      );

      logger.debug(
        'Get Restaurants API Response Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List?;
        final restaurants = data ?? [];
        return restaurants
            .map((json) => json as Map<String, dynamic>)
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to load restaurants',
        );
      }
    } on DioException catch (e) {
      logger.error('Get Restaurants API DioException: ${e.message}');
      if (e.response != null) {
        throw ServerException(
          message: e.response!.data['message'] ?? 'Failed to load restaurants',
        );
      } else {
        throw NetworkException(
          message:
              'Cannot connect to server. Please check your internet connection.',
        );
      }
    } catch (e) {
      logger.error('Get Restaurants unexpected error: $e');
      rethrow;
    }
  }
}
