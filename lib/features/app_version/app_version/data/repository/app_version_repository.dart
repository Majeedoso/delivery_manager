import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/app_version/data/datasource/app_version_remote_data_source.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/app_version/domain/repository/base_app_version_repository.dart';

/// Implementation of [BaseAppVersionRepository]
/// 
/// This repository coordinates with the remote data source to provide
/// app version checking functionality:
/// - Remote data source: API calls to check app version
/// 
/// Handles error conversion from exceptions to failures.
class AppVersionRepository implements BaseAppVersionRepository {
  /// Remote data source for app version API calls
  final BaseAppVersionRemoteDataSource remoteDataSource;

  AppVersionRepository({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, AppVersion>> checkAppVersion() async {
    try {
      final appVersion = await remoteDataSource.checkAppVersion();
      return Right(appVersion);
    } on ServerException catch (failure) {
      return Left(ServerFailure(failure.message));
    } on NetworkException catch (failure) {
      return Left(NetworkFailure(failure.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}

