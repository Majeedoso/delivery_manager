import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:delivery_manager/features/delivery_areas/domain/repository/base_delivery_areas_repository.dart';

/// The delivery zones, by name.
class GetDeliveryAreasUseCase
    extends BaseUseCase<List<DeliveryArea>, NoParameters> {
  final BaseDeliveryAreasRepository repository;

  GetDeliveryAreasUseCase(this.repository);

  @override
  Future<Either<Failure, List<DeliveryArea>>> call(NoParameters parameters) =>
      repository.getAreas();
}

/// A new zone, or a zone changed.
class SaveDeliveryAreaUseCase
    extends BaseUseCase<DeliveryArea, DeliveryAreaDraft> {
  final BaseDeliveryAreasRepository repository;

  SaveDeliveryAreaUseCase(this.repository);

  @override
  Future<Either<Failure, DeliveryArea>> call(DeliveryAreaDraft parameters) =>
      repository.saveArea(parameters);
}

/// A zone switched on or off (its id).
class SwitchDeliveryAreaUseCase extends BaseUseCase<DeliveryArea, int> {
  final BaseDeliveryAreasRepository repository;

  SwitchDeliveryAreaUseCase(this.repository);

  @override
  Future<Either<Failure, DeliveryArea>> call(int parameters) =>
      repository.switchArea(parameters);
}

/// A zone deleted (its id).
class DeleteDeliveryAreaUseCase extends BaseUseCase<Unit, int> {
  final BaseDeliveryAreasRepository repository;

  DeleteDeliveryAreaUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int parameters) =>
      repository.deleteArea(parameters);
}
