import 'package:equatable/equatable.dart';

/// Response entity for resend email change OTP operation
/// 
/// This entity represents the response from resending email change OTP.
/// 
/// Contains:
/// - [newEmail]: The new email address where the OTP was sent
/// - [expiresIn]: OTP validity period in seconds (10 minutes)
/// - [resendCountdown]: Resend countdown period in seconds (2 minutes)
class ResendEmailChangeOtpResponse extends Equatable {
  final String newEmail;
  final int expiresIn;
  final int resendCountdown;

  const ResendEmailChangeOtpResponse({
    required this.newEmail,
    required this.expiresIn,
    required this.resendCountdown,
  });

  @override
  List<Object> get props => [newEmail, expiresIn, resendCountdown];
}

