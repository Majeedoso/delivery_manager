import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/delivery_areas/data/datasource/delivery_areas_remote_data_source.dart';
import 'package:delivery_manager/features/delivery_areas/domain/entities/delivery_area.dart';
import 'package:delivery_manager/features/delivery_areas/domain/repository/base_delivery_areas_repository.dart';

class DeliveryAreasRepositoryImpl implements BaseDeliveryAreasRepository {
  final BaseDeliveryAreasRemoteDataSource remoteDataSource;

  DeliveryAreasRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DeliveryArea>>> getAreas() =>
      _guard(remoteDataSource.getAreas);

  @override
  Future<Either<Failure, DeliveryArea>> saveArea(DeliveryAreaDraft draft) =>
      _guard(() => remoteDataSource.saveArea(draft));

  @override
  Future<Either<Failure, DeliveryArea>> switchArea(int id) =>
      _guard(() => remoteDataSource.switchArea(id));

  @override
  Future<Either<Failure, Unit>> deleteArea(int id) => _guard(() async {
    await remoteDataSource.deleteArea(id);
    return unit;
  });

  static Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } catch (error) {
      return Left(_failureOf(error));
    }
  }

  static Failure _failureOf(Object error) => switch (error) {
    ServerException(:final message, :final errorCode) => ServerFailure(
      message,
      errorCode: errorCode,
    ),
    NetworkException(:final message) => NetworkFailure(message),
    _ => ServerFailure(error.toString()),
  };
}
