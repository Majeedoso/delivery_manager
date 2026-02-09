import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/profile/domain/entities/resend_email_change_otp_response.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';

class ChangeEmailUseCase implements BaseUseCase<ResendEmailChangeOtpResponse, ChangeEmailParameters> {
  final BaseProfileRepository baseProfileRepository;

  ChangeEmailUseCase(this.baseProfileRepository);

  @override
  Future<Either<Failure, ResendEmailChangeOtpResponse>> call(ChangeEmailParameters parameters) async {
    return await baseProfileRepository.changeEmail(
      newEmail: parameters.newEmail,
      currentPassword: parameters.currentPassword,
    );
  }
}

class ChangeEmailParameters {
  final String newEmail;
  final String currentPassword;

  ChangeEmailParameters({
    required this.newEmail,
    required this.currentPassword,
  });
}
