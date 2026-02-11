import 'package:equatable/equatable.dart';

/// Base class for all coupon events.
abstract class CouponsEvent extends Equatable {
  const CouponsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load coupons with optional filtering.
class LoadCouponsEvent extends CouponsEvent {
  final String? status;
  final String? discountTarget;
  final int page;
  final bool refresh;

  const LoadCouponsEvent({
    this.status,
    this.discountTarget,
    this.page = 1,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [status, discountTarget, page, refresh];
}

/// Event to load coupon zones for zone selection.
class LoadDeliveryZonesEvent extends CouponsEvent {
  const LoadDeliveryZonesEvent();
}

/// Event to load restaurants for targeting.
class LoadRestaurantsEvent extends CouponsEvent {
  final String? search;
  final int page;
  final bool refresh;

  const LoadRestaurantsEvent({
    this.search,
    this.page = 1,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [search, page, refresh];
}

/// Event to create a new delivery zone.
class CreateDeliveryZoneEvent extends CouponsEvent {
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;

  const CreateDeliveryZoneEvent({
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.radiusKm,
  });

  @override
  List<Object?> get props => [name, description, latitude, longitude, radiusKm];
}

/// Event to update an existing delivery zone.
class UpdateDeliveryZoneEvent extends CouponsEvent {
  final int id;
  final String? name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final bool? isActive;

  const UpdateDeliveryZoneEvent({
    required this.id,
    this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    latitude,
    longitude,
    radiusKm,
    isActive,
  ];
}

/// Event to delete a delivery zone.
class DeleteDeliveryZoneEvent extends CouponsEvent {
  final int id;

  const DeleteDeliveryZoneEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event to create a new coupon.
class CreateCouponEvent extends CouponsEvent {
  final String code;
  final String type;
  final int value;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final int? restaurantId;
  final int? maxUsesTotal;
  final int? maxUsesPerCustomer;
  final int? minOrderValue;
  final int? maxDiscountAmount;
  final String? description;
  final String discountTarget;
  final List<int>? deliveryZoneIds;

  const CreateCouponEvent({
    required this.code,
    required this.type,
    required this.value,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.restaurantId,
    this.maxUsesTotal,
    this.maxUsesPerCustomer,
    this.minOrderValue,
    this.maxDiscountAmount,
    this.description,
    this.discountTarget = 'subtotal',
    this.deliveryZoneIds,
  });

  @override
  List<Object?> get props => [
    code,
    type,
    value,
    status,
    startDate,
    endDate,
    restaurantId,
    maxUsesTotal,
    maxUsesPerCustomer,
    minOrderValue,
    maxDiscountAmount,
    description,
    discountTarget,
    deliveryZoneIds,
  ];
}

/// Event to update an existing coupon.
class UpdateCouponEvent extends CouponsEvent {
  final int id;
  final String? code;
  final String? type;
  final int? value;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? restaurantId;
  final int? maxUsesTotal;
  final int? maxUsesPerCustomer;
  final int? minOrderValue;
  final int? maxDiscountAmount;
  final String? description;
  final String? discountTarget;
  final List<int>? deliveryZoneIds;

  const UpdateCouponEvent({
    required this.id,
    this.code,
    this.type,
    this.value,
    this.status,
    this.startDate,
    this.endDate,
    this.restaurantId,
    this.maxUsesTotal,
    this.maxUsesPerCustomer,
    this.minOrderValue,
    this.maxDiscountAmount,
    this.description,
    this.discountTarget,
    this.deliveryZoneIds,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    type,
    value,
    status,
    startDate,
    endDate,
    restaurantId,
    maxUsesTotal,
    maxUsesPerCustomer,
    minOrderValue,
    maxDiscountAmount,
    description,
    discountTarget,
    deliveryZoneIds,
  ];
}
