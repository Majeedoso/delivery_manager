import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/network/api_constance.dart';
import 'package:delivery_manager/core/network/request_failure.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/features/delivery_areas/data/models/delivery_area_model.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:dio/dio.dart';

abstract class BaseDeliveryAreasRemoteDataSource {
  Future<List<DeliveryAreaModel>> getAreas();

  /// Creates the zone, or changes it when the draft has an id.
  Future<DeliveryAreaModel> saveArea(DeliveryAreaDraft draft);

  /// Switches the zone on or off.
  Future<DeliveryAreaModel> switchArea(int id);

  Future<void> deleteArea(int id);
}

/// The delivery zones, on the server's `/manager/delivery-zones`.
class DeliveryAreasRemoteDataSource
    implements BaseDeliveryAreasRemoteDataSource {
  final Dio dio;
  final LoggingService _logger;

  DeliveryAreasRemoteDataSource({required this.dio, LoggingService? logger})
    : _logger = logger ?? LoggingService();

  @override
  Future<List<DeliveryAreaModel>> getAreas() async {
    try {
      final response = await dio.get(ApiConstance.managerDeliveryZonesPath);
      final zones = (response.data['data']['zones'] as List)
          .cast<Map<String, dynamic>>();
      return zones.map(DeliveryAreaModel.fromJson).toList();
    } catch (e) {
      throw _failure(e, 'get the delivery zones');
    }
  }

  @override
  Future<DeliveryAreaModel> saveArea(DeliveryAreaDraft draft) async {
    try {
      final response = draft.id == null
          ? await dio.post(
              ApiConstance.managerDeliveryZonesPath,
              data: deliveryAreaBody(draft),
            )
          : await dio.put(
              ApiConstance.managerDeliveryZonePath(draft.id!),
              data: deliveryAreaBody(draft),
            );
      return DeliveryAreaModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw _failure(e, 'save a delivery zone');
    }
  }

  @override
  Future<DeliveryAreaModel> switchArea(int id) async {
    try {
      final response = await dio.post(
        ApiConstance.managerDeliveryZoneSwitchPath(id),
      );
      return DeliveryAreaModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw _failure(e, 'switch a delivery zone');
    }
  }

  @override
  Future<void> deleteArea(int id) async {
    try {
      await dio.delete(ApiConstance.managerDeliveryZonePath(id));
    } catch (e) {
      throw _failure(e, 'delete a delivery zone');
    }
  }

  /// What a failed request tells the manager: the server's reason, or that
  /// the network failed ([requestFailureOf]).
  Exception _failure(Object error, String request) {
    _logger.error(
      'DeliveryAreasRemoteDataSource: $request failed',
      error: error,
    );
    if (error is ServerException) return error;
    if (error is NetworkException) return error;
    return requestFailureOf(error);
  }
}
