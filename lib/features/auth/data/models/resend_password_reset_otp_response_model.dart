import 'package:delivery_manager/features/auth/domain/entities/resend_password_reset_otp_response.dart';

/// Data model for ResendPasswordResetOtpResponse entity
/// 
/// Extends the domain [ResendPasswordResetOtpResponse] entity and provides JSON serialization
/// for resend password reset OTP API responses.
/// 
/// Handles conversion between:
/// - JSON maps (from API responses)
/// - Domain entities (for use in business logic)
/// 
/// The API response structure is:
/// ```json
/// {
///   "success": true,
///   "message": "Password reset OTP sent successfully. Please check your email.",
///   "data": {
///     "email": "user@example.com",
///     "expires_in": 600,
///     "resend_countdown": 120
///   }
/// }
/// ```
class ResendPasswordResetOtpResponseModel extends ResendPasswordResetOtpResponse {
  const ResendPasswordResetOtpResponseModel({
    required super.email,
    required super.expiresIn,
    required super.resendCountdown,
  });

  factory ResendPasswordResetOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ResendPasswordResetOtpResponseModel(
      email: data['email']?.toString() ?? '',
      expiresIn: data['expires_in'] as int? ?? 600,
      resendCountdown: data['resend_countdown'] as int? ?? 120,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'expires_in': expiresIn,
      'resend_countdown': resendCountdown,
    };
  }
}

