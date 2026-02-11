import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/coupons/data/datasource/coupons_remote_data_source.dart';
import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';
import 'package:delivery_manager/features/coupons/domain/entities/delivery_zone.dart';
import 'package:delivery_manager/features/coupons/domain/repository/base_coupons_repository.dart';

/// Implementation of the coupons repository.
class CouponsRepository implements BaseCouponsRepository {
  final BaseCouponsRemoteDataSource remoteDataSource;

  CouponsRepository({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCoupons({
    String? status,
    String? issuerType,
    String? search,
    String? discountTarget,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final result = await remoteDataSource.getCoupons(
        status: status,
        issuerType: issuerType,
        search: search,
        discountTarget: discountTarget,
        page: page,
        perPage: perPage,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DeliveryZone>>> getDeliveryZones() async {
    try {
      final result = await remoteDataSource.getDeliveryZones();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getRestaurants({
    String? search,
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final result = await remoteDataSource.getRestaurants(
        search: search,
        page: page,
        perPage: perPage,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, DeliveryZone>> createDeliveryZone({
    required String name,
    String? description,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      final data = <String, dynamic>{'name': name};

      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (radiusKm != null) data['radius_km'] = radiusKm;

      final result = await remoteDataSource.createDeliveryZone(data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, DeliveryZone>> updateDeliveryZone({
    required int id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    double? radiusKm,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (radiusKm != null) data['radius_km'] = radiusKm;
      if (isActive != null) data['is_active'] = isActive;

      final result = await remoteDataSource.updateDeliveryZone(id, data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDeliveryZone(int id) async {
    try {
      await remoteDataSource.deleteDeliveryZone(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, Coupon>> createCoupon({
    required String code,
    required String type,
    required int value,
    required String status,
    required DateTime startDate,
    required DateTime endDate,
    int? restaurantId,
    String discountTarget = 'subtotal',
    int? maxUsesTotal,
    int? maxUsesPerCustomer,
    int? minOrderValue,
    int? maxDiscountAmount,
    String? description,
    List<int>? deliveryZoneIds,
  }) async {
    try {
      final data = <String, dynamic>{
        'code': code,
        'type': type,
        'value': value,
        'status': status,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
      };

      if (maxUsesTotal != null) data['max_uses_total'] = maxUsesTotal;
      if (maxUsesPerCustomer != null) {
        data['max_uses_per_customer'] = maxUsesPerCustomer;
      }
      if (minOrderValue != null) data['min_order_value'] = minOrderValue;
      if (maxDiscountAmount != null) {
        data['max_discount_amount'] = maxDiscountAmount;
      }
      if (description != null && description.isNotEmpty) {
        data['description'] = description;
      }
      if (restaurantId != null) {
        data['restaurant_id'] = restaurantId;
      }
      if (discountTarget.isNotEmpty) {
        data['discount_target'] = discountTarget;
      }
      if (deliveryZoneIds != null && deliveryZoneIds.isNotEmpty) {
        data['zone_ids'] = deliveryZoneIds;
      }

      final result = await remoteDataSource.createCoupon(data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final data = <String, dynamic>{};

      if (code != null) data['code'] = code;
      if (type != null) data['type'] = type;
      if (value != null) data['value'] = value;
      if (status != null) data['status'] = status;
      if (startDate != null) {
        data['start_date'] = startDate.toIso8601String().split('T').first;
      }
      if (endDate != null) {
        data['end_date'] = endDate.toIso8601String().split('T').first;
      }
      if (maxUsesTotal != null) data['max_uses_total'] = maxUsesTotal;
      if (maxUsesPerCustomer != null) {
        data['max_uses_per_customer'] = maxUsesPerCustomer;
      }
      if (minOrderValue != null) data['min_order_value'] = minOrderValue;
      if (maxDiscountAmount != null) {
        data['max_discount_amount'] = maxDiscountAmount;
      }
      if (description != null) data['description'] = description;
      data['restaurant_id'] = restaurantId;
      if (discountTarget != null && discountTarget.isNotEmpty) {
        data['discount_target'] = discountTarget;
      }
      if (deliveryZoneIds != null) {
        data['zone_ids'] = deliveryZoneIds;
      }

      final result = await remoteDataSource.updateCoupon(id, data);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred: $e'));
    }
  }
}
