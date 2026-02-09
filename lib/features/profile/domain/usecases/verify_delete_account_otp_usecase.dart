import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';

class VerifyDeleteAccountOtpParameters extends Equatable {
  final String otp;

  const VerifyDeleteAccountOtpParameters({
    required this.otp,
  });

  @override
  List<Object?> get props => [otp];
}

class VerifyDeleteAccountOtpUseCase implements BaseUseCase<void, VerifyDeleteAccountOtpParameters> {
  final BaseProfileRepository baseProfileRepository;

  VerifyDeleteAccountOtpUseCase(this.baseProfileRepository);

  @override
  Future<Either<Failure, void>> call(VerifyDeleteAccountOtpParameters parameters) async {
    return await baseProfileRepository.verifyDeleteAccountOtpAndDelete(
      otp: parameters.otp,
    );
  }
}

