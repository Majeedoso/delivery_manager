import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/localization/data/datasource/localization_local_data_source.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';
import 'package:delivery_manager/features/localization/domain/repository/base_localization_repository.dart';

class LocalizationRepository implements BaseLocalizationRepository {
  final BaseLocalizationLocalDataSource baseLocalizationLocalDataSource;

  const LocalizationRepository({required this.baseLocalizationLocalDataSource});

  @override
  Future<Either<Failure, Language>> getCurrentLanguage() async {
    try {
      final language = await baseLocalizationLocalDataSource
          .getCurrentLanguage();
      return Right(language);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setLanguage(Language language) async {
    try {
      await baseLocalizationLocalDataSource.setLanguage(language);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Language>>> getSupportedLanguages() async {
    try {
      final languages = await baseLocalizationLocalDataSource
          .getSupportedLanguages();
      return Right(languages);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isFirstRun() async {
    try {
      final isFirstRun = await baseLocalizationLocalDataSource.isFirstRun();
      return Right(isFirstRun);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
