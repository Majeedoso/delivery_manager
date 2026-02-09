import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/profile/domain/entities/profile.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';

class UpdateProfileUseCase implements BaseUseCase<Profile, UpdateProfileParameters> {
  final BaseProfileRepository baseProfileRepository;

  UpdateProfileUseCase(this.baseProfileRepository);

  @override
  Future<Either<Failure, Profile>> call(UpdateProfileParameters parameters) async {
    return await baseProfileRepository.updateProfile(
      name: parameters.name,
      phone: parameters.phone,
    );
  }
}

class UpdateProfileParameters {
  final String? name;
  final String? phone;

  UpdateProfileParameters({
    this.name,
    this.phone,
  });
}
