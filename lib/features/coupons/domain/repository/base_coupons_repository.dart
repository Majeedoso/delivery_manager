import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';
import 'package:delivery_manager/features/coupons/domain/entities/delivery_zone.dart';

/// Abstract repository interface for coupon operations.
abstract class BaseCouponsRepository {
  /// Get paginated list of coupons for the restaurant.
  /// [status] - Filter by status (optional): 'draft', 'active', 'disabled'
  /// [page] - Page number for pagination
  /// [perPage] - Number of items per page
  Future<Either<Failure, Map<String, dynamic>>> getCoupons({
    String? status,
    String? issuerType,
    String? search,
    String? discountTarget,
    int page = 1,
    int perPage = 20,
  });

  /// Get coupon zones for manager selection.
  Future<Either<Failure, List<DeliveryZone>>> getDeliveryZones();

  /// Get restaurants for coupon targeting.
  Future<Either<Failure, List<Map<String, dynamic>>>> getRestaurants({
    String? search,
    int page = 1,
    int perPage = 50,
  });

  /// Create a new delivery zone.
  Future<Either<Failure, DeliveryZone>> createDeliveryZone({
    required String name,
    String? description,
    double? latitude,
    double? longitude,
    double? radiusKm,
  });

  /// Update an existing delivery zone.
  Future<Either<Failure, DeliveryZone>> updateDeliveryZone({
    required int id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    double? radiusKm,
    bool? isActive,
  });

  /// Delete a delivery zone.
  Future<Either<Failure, void>> deleteDeliveryZone(int id);

  /// Create a new coupon.
  Future<Either<Failure, Coupon>> createCoupon({
    required String code,
    required String type,
    required int value,
    required String status,
    required DateTime startDate,
    required DateTime endDate,
    int? restaurantId,
    String discountTarget,
    int? maxUsesTotal,
    int? maxUsesPerCustomer,
    int? minOrderValue,
    int? maxDiscountAmount,
    String? description,
    List<int>? deliveryZoneIds,
  });

  /// Update an existing coupon.
  Future<Either<Failure, Coupon>> updateCoupon({
    required int id,
    String? code,
    String? type,
    int? value,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? restaurantId,
    String? discountTarget,
    int? maxUsesTotal,
    int? maxUsesPerCustomer,
    int? minOrderValue,
    int? maxDiscountAmount,
    String? description,
    List<int>? deliveryZoneIds,
  });
}
