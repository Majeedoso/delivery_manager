import 'package:delivery_manager/features/coupons/domain/entities/coupon.dart';

/// Model class for parsing coupon data from API responses.
class CouponModel extends Coupon {
  const CouponModel({
    required super.id,
    required super.code,
    required super.type,
    required super.value,
    required super.status,
    required super.startDate,
    required super.endDate,
    super.maxUsesTotal,
    super.maxUsesPerCustomer,
    super.minOrderValue,
    super.maxDiscountAmount,
    super.description,
    super.usagesCount,
    required super.createdAt,
    super.issuerType,
    super.issuerName,
    super.restaurantId,
    super.restaurantName,
    super.discountTarget,
    super.deliveryZoneIds,
  });

  /// Create a CouponModel from JSON data.
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    final issuer = json['issuer'] as Map<String, dynamic>?;
    final restaurants = json['restaurants'] as List<dynamic>?;
    final firstRestaurant =
        restaurants != null && restaurants.isNotEmpty
            ? restaurants.first as Map<String, dynamic>
            : null;
    final couponZones = json['coupon_zones'] as List<dynamic>?;
    final zoneIdsFromZones = couponZones != null
        ? couponZones
              .map((z) => int.tryParse((z as Map<String, dynamic>)['id'].toString()) ?? 0)
              .where((id) => id > 0)
              .toList()
        : <int>[];
    final deliveryZoneIdsRaw = json['delivery_zone_ids'];
    final zoneIdsFromColumn = deliveryZoneIdsRaw is List
        ? deliveryZoneIdsRaw
              .map((id) => int.tryParse(id.toString()) ?? 0)
              .where((id) => id > 0)
              .toList()
        : <int>[];
    final deliveryZoneIds =
        zoneIdsFromZones.isNotEmpty ? zoneIdsFromZones : zoneIdsFromColumn;

    return CouponModel(
      id: json['id'] as int,
      code: json['code'] as String,
      type: json['type'] as String,
      value: json['value'] as int,
      status: json['status'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      maxUsesTotal: json['max_uses_total'] as int?,
      maxUsesPerCustomer: json['max_uses_per_customer'] as int?,
      minOrderValue: json['min_order_value'] as int?,
      maxDiscountAmount: json['max_discount_amount'] as int?,
      description: json['description'] as String?,
      usagesCount: json['usages_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      issuerType: json['issuer_type'] as String?,
      issuerName: issuer?['name'] as String?,
      restaurantId: firstRestaurant?['id'] as int?,
      restaurantName: firstRestaurant?['name'] as String?,
      discountTarget: json['discount_target'] as String? ?? 'subtotal',
      deliveryZoneIds: deliveryZoneIds,
    );
  }

  /// Convert the model to a JSON map for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'value': value,
      'status': status,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate.toIso8601String().split('T').first,
      if (maxUsesTotal != null) 'max_uses_total': maxUsesTotal,
      if (maxUsesPerCustomer != null)
        'max_uses_per_customer': maxUsesPerCustomer,
      if (minOrderValue != null) 'min_order_value': minOrderValue,
      if (maxDiscountAmount != null) 'max_discount_amount': maxDiscountAmount,
      if (description != null) 'description': description,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (discountTarget.isNotEmpty) 'discount_target': discountTarget,
      if (deliveryZoneIds.isNotEmpty)
        'delivery_zone_ids': deliveryZoneIds,
    };
  }
}
