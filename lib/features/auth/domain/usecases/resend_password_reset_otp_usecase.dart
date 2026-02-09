import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/entities/resend_password_reset_otp_response.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';

/// Use case for resending password reset OTP
/// 
/// This use case handles resending the password reset OTP to the user's email.
/// This is an unauthenticated operation (user is not logged in when resetting password).
class ResendPasswordResetOtpUseCase extends BaseUseCase<ResendPasswordResetOtpResponse, ResendPasswordResetOtpParameters> {
  /// The authentication repository to perform the resend operation
  final BaseAuthRepository baseAuthRepository;

  ResendPasswordResetOtpUseCase(this.baseAuthRepository);

  /// Execute the use case to resend password reset OTP
  /// 
  /// Parameters:
  /// - [parameters.email]: The email address to send the OTP to
  /// 
  /// Returns:
  /// - Right(ResendPasswordResetOtpResponse) with email, expiresIn, and resendCountdown if OTP is sent successfully
  /// - Left(Failure) if an error occurs (e.g., email not found, network error, rate limit)
  @override
  Future<Either<Failure, ResendPasswordResetOtpResponse>> call(ResendPasswordResetOtpParameters parameters) async {
    return await baseAuthRepository.resendPasswordResetOtp(parameters.email);
  }
}

/// Parameters for resend password reset OTP use case
class ResendPasswordResetOtpParameters {
  final String email;

  ResendPasswordResetOtpParameters({
    required this.email,
  });
}

