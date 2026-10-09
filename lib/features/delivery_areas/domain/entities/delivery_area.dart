import 'package:equatable/equatable.dart';

/// A delivery zone: a centre and a radius where customers can order, when it
/// is on. Not the coupons' zones, which only say where a coupon applies
/// (features/coupons).
class DeliveryArea extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final bool isActive;

  const DeliveryArea({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.isActive,
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

/// A zone as the manager writes it: a new one has no [id].
class DeliveryAreaDraft extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final bool isActive;

  const DeliveryAreaDraft({
    this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    this.isActive = true,
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
