import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';

/// A delivery zone as `/manager/delivery-zones` sends it. MySQL's decimals
/// come as strings ("36.75380000").
class DeliveryAreaModel extends DeliveryArea {
  const DeliveryAreaModel({
    required super.id,
    required super.name,
    super.description,
    required super.latitude,
    required super.longitude,
    required super.radiusKm,
    required super.isActive,
  });

  factory DeliveryAreaModel.fromJson(Map<String, dynamic> json) {
    double number(Object? value) => double.tryParse('${value ?? ''}') ?? 0;
    final description = json['description'] as String?;

    return DeliveryAreaModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: description == null || description.trim().isEmpty
          ? null
          : description,
      latitude: number(json['latitude']),
      longitude: number(json['longitude']),
      radiusKm: number(json['radius_km']),
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}

/// What the server is sent for a zone the manager wrote.
Map<String, dynamic> deliveryAreaBody(DeliveryAreaDraft draft) => {
  'name': draft.name,
  'description': draft.description,
  'latitude': draft.latitude,
  'longitude': draft.longitude,
  'radius_km': draft.radiusKm,
  'is_active': draft.isActive,
};
