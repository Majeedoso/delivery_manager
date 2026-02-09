import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/profile/domain/entities/profile.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';

class GetProfileUseCase implements BaseUseCase<Profile, NoParameters> {
  final BaseProfileRepository baseProfileRepository;

  GetProfileUseCase(this.baseProfileRepository);

  @override
  Future<Either<Failure, Profile>> call(NoParameters parameters) async {
    return await baseProfileRepository.getProfile();
  }
}
