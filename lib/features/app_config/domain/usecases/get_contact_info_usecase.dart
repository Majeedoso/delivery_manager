import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/app_config/domain/entities/contact_info.dart';
import 'package:delivery_manager/features/app_config/domain/repository/base_app_config_repository.dart';

/// Use case for getting contact information
class GetContactInfoUseCase implements BaseUseCase<ContactInfo, NoParameters> {
  final BaseAppConfigRepository repository;

  GetContactInfoUseCase(this.repository);

  @override
  Future<Either<Failure, ContactInfo>> call(NoParameters parameters) async {
    return await repository.getContactInfo();
  }
}

