import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';

abstract class BaseDeliveryAreasRepository {
  Future<Either<Failure, List<DeliveryArea>>> getAreas();

  /// Creates the zone, or changes it when the draft has an id.
  Future<Either<Failure, DeliveryArea>> saveArea(DeliveryAreaDraft draft);

  /// Switches the zone on or off.
  Future<Either<Failure, DeliveryArea>> switchArea(int id);

  Future<Either<Failure, Unit>> deleteArea(int id);
}
