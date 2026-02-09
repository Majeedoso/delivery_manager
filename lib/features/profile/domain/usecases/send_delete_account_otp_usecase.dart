import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';
import 'package:delivery_manager/features/profile/domain/entities/send_delete_account_otp_response.dart';

class SendDeleteAccountOtpUseCase implements BaseUseCase<SendDeleteAccountOtpResponse, NoParameters> {
  final BaseProfileRepository baseProfileRepository;

  SendDeleteAccountOtpUseCase(this.baseProfileRepository);

  @override
  Future<Either<Failure, SendDeleteAccountOtpResponse>> call(NoParameters parameters) async {
    return await baseProfileRepository.sendDeleteAccountOtp();
  }
}

