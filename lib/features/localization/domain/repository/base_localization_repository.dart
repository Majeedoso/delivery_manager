import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/localization/domain/entities/language.dart';

abstract class BaseLocalizationRepository {
  Future<Either<Failure, Language>> getCurrentLanguage();
  Future<Either<Failure, void>> setLanguage(Language language);
  Future<Either<Failure, List<Language>>> getSupportedLanguages();

  /// Check if this is the first time the app is run (no language saved yet)
  Future<Either<Failure, bool>> isFirstRun();
}
