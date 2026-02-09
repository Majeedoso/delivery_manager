import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';
import 'package:equatable/equatable.dart';

class ResetPasswordUseCase implements BaseUseCase<String, ResetPasswordParameters> {
  final BaseAuthRepository baseAuthRepository;

  ResetPasswordUseCase(this.baseAuthRepository);

  @override
  Future<Either<Failure, String>> call(ResetPasswordParameters parameters) async {
    return await baseAuthRepository.resetPassword(
      email: parameters.email,
      otp: parameters.otp,
      password: parameters.password,
      passwordConfirmation: parameters.passwordConfirmation,
    );
  }
}

class ResetPasswordParameters extends Equatable {
  final String email;
  final String otp;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordParameters({
    required this.email,
    required this.otp,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [email, otp, password, passwordConfirmation];
}

