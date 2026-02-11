import 'package:delivery_manager/features/coupons/domain/entities/delivery_zone.dart';

/// Data model for DeliveryZone with JSON serialization.
class DeliveryZoneModel extends DeliveryZone {
  const DeliveryZoneModel({
    required super.id,
    required super.name,
    super.description,
    super.latitude,
    super.longitude,
    super.radiusKm,
    super.isActive,
  });

  factory DeliveryZoneModel.fromJson(Map<String, dynamic> json) {
    final isActiveRaw = json['is_active'];
    final isActive = isActiveRaw is bool
        ? isActiveRaw
        : isActiveRaw?.toString() == '1' ||
            isActiveRaw?.toString().toLowerCase() == 'true' ||
            isActiveRaw == null;
    return DeliveryZoneModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      radiusKm: json['radius_km'] != null
          ? double.tryParse(json['radius_km'].toString())
          : null,
      isActive: isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusKm != null) 'radius_km': radiusKm,
      'is_active': isActive,
    };
  }

  /// Create a JSON map for creating a new zone (without id).
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusKm != null) 'radius_km': radiusKm,
    };
  }
}
