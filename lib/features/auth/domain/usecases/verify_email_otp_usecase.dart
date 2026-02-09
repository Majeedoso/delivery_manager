import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/entities/verify_email_otp_response.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';
import 'package:equatable/equatable.dart';

class VerifyEmailOtpUseCase implements BaseUseCase<VerifyEmailOtpResponse, VerifyEmailOtpParameters> {
  final BaseAuthRepository baseAuthRepository;

  VerifyEmailOtpUseCase(this.baseAuthRepository);

  @override
  Future<Either<Failure, VerifyEmailOtpResponse>> call(VerifyEmailOtpParameters parameters) async {
    return await baseAuthRepository.verifyEmailOtp(
      email: parameters.email,
      otp: parameters.otp,
    );
  }
}

class VerifyEmailOtpParameters extends Equatable {
  final String email;
  final String otp;

  const VerifyEmailOtpParameters({
    required this.email,
    required this.otp,
  });

  @override
  List<Object> get props => [email, otp];
}

