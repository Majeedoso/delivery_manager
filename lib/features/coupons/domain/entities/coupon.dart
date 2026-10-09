import 'package:clock/clock.dart';
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

  /// Whether the coupon's last day has passed. The server keeps the days
  /// (sent at midnight UTC) and accepts the coupon until the end of the
  /// last one: it read "Expired" all that day.
  bool get isExpired {
    final now = clock.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(DateTime(endDate.year, endDate.month, endDate.day));
  }

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
