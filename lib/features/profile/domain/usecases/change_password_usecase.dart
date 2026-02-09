import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';

class ChangePasswordUseCase implements BaseUseCase<void, ChangePasswordParameters> {
  final BaseProfileRepository baseProfileRepository;

  ChangePasswordUseCase(this.baseProfileRepository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParameters parameters) async {
    return await baseProfileRepository.changePassword(
      currentPassword: parameters.currentPassword,
      newPassword: parameters.newPassword,
      newPasswordConfirmation: parameters.newPasswordConfirmation,
    );
  }
}

class ChangePasswordParameters {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordParameters({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });
}
