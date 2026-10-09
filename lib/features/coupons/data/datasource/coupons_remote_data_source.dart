import 'package:dio/dio.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/network/request_failure.dart';
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

  /// The restaurants a coupon can target: every one, by name (the
  /// manager's list; the customers' only has those open at that moment).
  Future<List<Map<String, dynamic>>> getRestaurants({
    String? search,
    int page = 1,
    int perPage = 100,
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

  /// What a failed request tells the manager: the server's reason, or that
  /// the network failed ([requestFailureOf]). An error page read as a map
  /// threw, and the page read "An unexpected error occurred: type 'String'
  /// is not a subtype...".
  Exception _failure(Object error, String request) {
    logger.error('$request failed', error: error);
    if (error is ServerException) return error;
    if (error is NetworkException) return error;
    return requestFailureOf(error);
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
    } catch (e) {
      throw _failure(e, 'Get Coupons');
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
    } catch (e) {
      throw _failure(e, 'Get coupon zones');
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
    } catch (e) {
      throw _failure(e, 'Create delivery zone');
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
    } catch (e) {
      throw _failure(e, 'Update delivery zone');
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
    } catch (e) {
      throw _failure(e, 'Delete delivery zone');
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
    } catch (e) {
      throw _failure(e, 'Create Coupon');
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
    } catch (e) {
      throw _failure(e, 'Update Coupon');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRestaurants({
    String? search,
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        'sort_by': 'name',
        'sort_order': 'asc',
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      // The manager's list: every restaurant. The customers' list
      // (/restaurants) only has those open at that moment: at night
      // none, and the coupon went out for every restaurant
      final response = await dio.get(
        ApiConstance.managerRestaurantsPath,
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
    } catch (e) {
      throw _failure(e, 'Get Restaurants');
    }
  }
}
