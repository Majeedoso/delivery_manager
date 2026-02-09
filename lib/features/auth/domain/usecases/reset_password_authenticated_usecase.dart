import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';
import 'package:equatable/equatable.dart';

class ResetPasswordAuthenticatedUseCase implements BaseUseCase<String, ResetPasswordAuthenticatedParameters> {
  final BaseAuthRepository baseAuthRepository;

  ResetPasswordAuthenticatedUseCase(this.baseAuthRepository);

  @override
  Future<Either<Failure, String>> call(ResetPasswordAuthenticatedParameters parameters) async {
    return await baseAuthRepository.resetPasswordAuthenticated(
      otp: parameters.otp,
      newPassword: parameters.newPassword,
      newPasswordConfirmation: parameters.newPasswordConfirmation,
    );
  }
}

class ResetPasswordAuthenticatedParameters extends Equatable {
  final String otp;
  final String newPassword;
  final String newPasswordConfirmation;

  const ResetPasswordAuthenticatedParameters({
    required this.otp,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object> get props => [otp, newPassword, newPasswordConfirmation];
}

