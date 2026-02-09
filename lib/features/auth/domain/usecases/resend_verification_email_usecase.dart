import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/auth/domain/entities/resend_verification_email_response.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_auth_repository.dart';

/// Use case for resending email verification OTP
/// 
/// This use case handles resending the email verification OTP to the user.
/// The user must be authenticated to use this feature.
class ResendVerificationEmailUseCase extends BaseUseCase<ResendVerificationEmailResponse, NoParameters> {
  /// The authentication repository to perform the resend operation
  final BaseAuthRepository baseAuthRepository;

  ResendVerificationEmailUseCase(this.baseAuthRepository);

  /// Execute the use case to resend verification email OTP
  /// 
  /// Returns:
  /// - Right(ResendVerificationEmailResponse) with email, expiresIn, and resendCountdown if OTP is sent successfully
  /// - Left(Failure) if an error occurs (e.g., email already verified, network error, rate limit)
  @override
  Future<Either<Failure, ResendVerificationEmailResponse>> call(NoParameters parameters) async {
    return await baseAuthRepository.resendVerificationEmail();
  }
}

