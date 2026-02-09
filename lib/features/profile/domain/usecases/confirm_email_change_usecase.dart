import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/profile/domain/entities/confirm_email_change_response.dart';
import 'package:delivery_manager/features/profile/domain/repository/base_profile_repository.dart';
import 'package:equatable/equatable.dart';

class ConfirmEmailChangeUseCase implements BaseUseCase<ConfirmEmailChangeResponse, ConfirmEmailChangeParameters> {
  final BaseProfileRepository baseProfileRepository;

  ConfirmEmailChangeUseCase(this.baseProfileRepository);

  @override
  Future<Either<Failure, ConfirmEmailChangeResponse>> call(ConfirmEmailChangeParameters parameters) async {
    return await baseProfileRepository.confirmEmailChange(
      newEmail: parameters.newEmail,
      otp: parameters.otp,
    );
  }
}

class ConfirmEmailChangeParameters extends Equatable {
  final String newEmail;
  final String otp;

  const ConfirmEmailChangeParameters({
    required this.newEmail,
    required this.otp,
  });

  @override
  List<Object> get props => [newEmail, otp];
}

