import 'package:equatable/equatable.dart';

/// Entity representing a delivery zone.
///
/// Managed by managers and used for coupon delivery area restrictions.
class DeliveryZone extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final bool isActive;

  const DeliveryZone({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.isActive = true,
  });

  /// Returns true if this zone has location data.
  bool get hasLocation => latitude != null && longitude != null;

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
