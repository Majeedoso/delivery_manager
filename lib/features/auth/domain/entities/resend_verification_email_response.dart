import 'package:equatable/equatable.dart';

/// Response entity for resend verification email operation
/// 
/// This entity represents the response from resending email verification OTP.
/// 
/// Contains:
/// - [email]: The email address where the OTP was sent
/// - [expiresIn]: OTP validity period in seconds (10 minutes)
/// - [resendCountdown]: Resend countdown period in seconds (2 minutes)
class ResendVerificationEmailResponse extends Equatable {
  final String email;
  final int expiresIn;
  final int resendCountdown;

  const ResendVerificationEmailResponse({
    required this.email,
    required this.expiresIn,
    required this.resendCountdown,
  });

  @override
  List<Object> get props => [email, expiresIn, resendCountdown];
}

