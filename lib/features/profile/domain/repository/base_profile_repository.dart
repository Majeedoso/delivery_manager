import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/profile/domain/entities/profile.dart';
import 'package:delivery_manager/features/profile/domain/entities/resend_email_change_otp_response.dart';
import 'package:delivery_manager/features/profile/domain/entities/confirm_email_change_response.dart';
import 'package:delivery_manager/features/profile/domain/entities/send_delete_account_otp_response.dart';

abstract class BaseProfileRepository {
  Future<Either<Failure, Profile>> getProfile();
  Future<Either<Failure, Profile>> updateProfile({
    String? name,
    String? phone,
  });
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
  Future<Either<Failure, ResendEmailChangeOtpResponse>> changeEmail({
    required String newEmail,
    required String currentPassword,
  });
  Future<Either<Failure, ConfirmEmailChangeResponse>> confirmEmailChange({
    required String newEmail,
    required String otp,
  });
  Future<Either<Failure, SendDeleteAccountOtpResponse>> sendDeleteAccountOtp();
  Future<Either<Failure, void>> verifyDeleteAccountOtpAndDelete({
    required String otp,
  });
}
