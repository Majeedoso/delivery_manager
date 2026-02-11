import 'package:equatable/equatable.dart';

/// Represents a coupon managed by a manager.
class Coupon extends Equatable {
  final int id;
  final String code;
  final String type; // 'percentage' or 'fixed_amount'
  final int value;
  final String status; // 'draft', 'active', 'disabled'
  final DateTime startDate;
  final DateTime endDate;
  final int? maxUsesTotal;
  final int? maxUsesPerCustomer;
  final int? minOrderValue;
  final int? maxDiscountAmount;
  final String? description;
  final int usagesCount;
  final DateTime createdAt;
  final String? issuerType;
  final String? issuerName;
  final int? restaurantId;
  final String? restaurantName;
  final String discountTarget;
  final List<int> deliveryZoneIds;

  const Coupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.maxUsesTotal,
    this.maxUsesPerCustomer,
    this.minOrderValue,
    this.maxDiscountAmount,
    this.description,
    this.usagesCount = 0,
    required this.createdAt,
    this.issuerType,
    this.issuerName,
    this.restaurantId,
    this.restaurantName,
    this.discountTarget = 'subtotal',
    this.deliveryZoneIds = const [],
  });

  /// Returns the display text for the discount value.
  String get discountDisplay {
    if (type == 'percentage') {
      return '$value%';
    } else {
      return '$value DZD';
    }
  }

  /// Returns true if the coupon is currently active and within date range.
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return status == 'active' &&
        now.isAfter(startDate) &&
        now.isBefore(endDate);
  }

  /// Returns true if the coupon has expired.
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  /// Returns true if the coupon has reached its usage limit.
  bool get isUsageLimitReached {
    if (maxUsesTotal == null) return false;
    return usagesCount >= maxUsesTotal!;
  }

  /// Returns true if the coupon has zone restrictions.
  bool get hasZoneRestrictions => deliveryZoneIds.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    code,
    type,
    value,
    status,
    startDate,
    endDate,
    maxUsesTotal,
    maxUsesPerCustomer,
    minOrderValue,
    maxDiscountAmount,
    description,
    usagesCount,
    createdAt,
    issuerType,
    issuerName,
    restaurantId,
    restaurantName,
    discountTarget,
    deliveryZoneIds,
  ];
}
