import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/app_config/domain/entities/legal_urls.dart';
import 'package:delivery_manager/features/app_config/domain/repository/base_app_config_repository.dart';
import 'package:delivery_manager/features/app_config/domain/usecases/get_legal_urls_parameters.dart';

/// Use case for getting legal document URLs
/// 
/// This use case retrieves URLs for privacy policy and terms of service
/// from the backend in the specified language. It follows the Clean Architecture pattern by
/// depending only on the repository interface.
class GetLegalUrlsUseCase implements BaseUseCase<LegalUrls, GetLegalUrlsParameters> {
  final BaseAppConfigRepository repository;

  GetLegalUrlsUseCase(this.repository);

  @override
  Future<Either<Failure, LegalUrls>> call(GetLegalUrlsParameters parameters) async {
    return await repository.getLegalUrls(languageCode: parameters.languageCode);
  }
}

