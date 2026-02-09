import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';
import 'package:equatable/equatable.dart';

class VerifyPasswordResetOtpUseCase implements BaseUseCase<void, VerifyPasswordResetOtpParameters> {
  final BaseAuthRepository baseAuthRepository;

  VerifyPasswordResetOtpUseCase(this.baseAuthRepository);

  @override
  Future<Either<Failure, void>> call(VerifyPasswordResetOtpParameters parameters) async {
    return await baseAuthRepository.verifyPasswordResetOtp(
      email: parameters.email,
      otp: parameters.otp,
    );
  }
}

class VerifyPasswordResetOtpParameters extends Equatable {
  final String email;
  final String otp;

  const VerifyPasswordResetOtpParameters({
    required this.email,
    required this.otp,
  });

  @override
  List<Object> get props => [email, otp];
}

