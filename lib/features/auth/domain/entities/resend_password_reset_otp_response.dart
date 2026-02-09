import 'package:equatable/equatable.dart';

/// Response entity for resend password reset OTP operation
/// 
/// This entity represents the response from resending password reset OTP.
/// 
/// Contains:
/// - [email]: The email address where the OTP was sent
/// - [expiresIn]: OTP validity period in seconds (10 minutes)
/// - [resendCountdown]: Resend countdown period in seconds (2 minutes)
class ResendPasswordResetOtpResponse extends Equatable {
  final String email;
  final int expiresIn;
  final int resendCountdown;

  const ResendPasswordResetOtpResponse({
    required this.email,
    required this.expiresIn,
    required this.resendCountdown,
  });

  @override
  List<Object> get props => [email, expiresIn, resendCountdown];
}

