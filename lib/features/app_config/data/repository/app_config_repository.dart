import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/features/app_config/data/datasource/app_config_remote_data_source.dart';
import 'package:delivery_manager/features/app_config/domain/entities/legal_urls.dart';
import 'package:delivery_manager/features/app_config/domain/entities/contact_info.dart';
import 'package:delivery_manager/features/app_config/domain/repository/base_app_config_repository.dart';

/// Implementation of app configuration repository
/// 
/// This repository coordinates between remote data sources and domain entities.
/// It handles error mapping and converts data models to domain entities.
class AppConfigRepository implements BaseAppConfigRepository {
  final BaseAppConfigRemoteDataSource remoteDataSource;

  AppConfigRepository({required this.remoteDataSource});

  @override
  Future<Either<Failure, LegalUrls>> getLegalUrls({String? languageCode}) async {
    try {
      final legalUrlsModel = await remoteDataSource.getLegalUrls(languageCode: languageCode);
      final legalUrls = legalUrlsModel.toEntity();
      return Right(legalUrls);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ContactInfo>> getContactInfo() async {
    try {
      final contactInfoModel = await remoteDataSource.getContactInfo();
      final contactInfo = contactInfoModel.toEntity();
      return Right(contactInfo);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}

