import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';
import 'package:equatable/equatable.dart';

class VerifyPasswordResetOtpAuthenticatedUseCase implements BaseUseCase<void, VerifyPasswordResetOtpAuthenticatedParameters> {
  final BaseAuthRepository baseAuthRepository;

  VerifyPasswordResetOtpAuthenticatedUseCase(this.baseAuthRepository);

  @override
  Future<Either<Failure, void>> call(VerifyPasswordResetOtpAuthenticatedParameters parameters) async {
    return await baseAuthRepository.verifyPasswordResetOtpAuthenticated(
      otp: parameters.otp,
    );
  }
}

class VerifyPasswordResetOtpAuthenticatedParameters extends Equatable {
  final String otp;

  const VerifyPasswordResetOtpAuthenticatedParameters({
    required this.otp,
  });

  @override
  List<Object> get props => [otp];
}

