import 'package:equatable/equatable.dart';
import 'package:delivery_manager/features/auth/domain/entities/user.dart';

/// Response entity for email verification OTP operation
/// 
/// This entity represents the response from verifying email OTP.
/// 
/// Contains:
/// - [user]: The updated user with verified email
/// - [message]: Success message
class VerifyEmailOtpResponse extends Equatable {
  final User user;
  final String message;

  const VerifyEmailOtpResponse({
    required this.user,
    required this.message,
  });

  @override
  List<Object> get props => [user, message];
}

