import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/entities/resend_password_reset_otp_response.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';

class SendPasswordResetOtpAuthenticatedUseCase implements BaseUseCase<ResendPasswordResetOtpResponse, NoParameters> {
  final BaseAuthRepository baseAuthRepository;

  SendPasswordResetOtpAuthenticatedUseCase(this.baseAuthRepository);

  @override
  Future<Either<Failure, ResendPasswordResetOtpResponse>> call(NoParameters parameters) async {
    return await baseAuthRepository.sendPasswordResetOtpAuthenticated();
  }
}

