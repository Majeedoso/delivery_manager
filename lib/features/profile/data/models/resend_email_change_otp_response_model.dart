import 'package:delivery_manager/features/profile/domain/entities/resend_email_change_otp_response.dart';

/// Data model for ResendEmailChangeOtpResponse entity
/// 
/// Extends the domain [ResendEmailChangeOtpResponse] entity and provides JSON serialization
/// for resend email change OTP API responses.
/// 
/// Handles conversion between:
/// - JSON maps (from API responses)
/// - Domain entities (for use in business logic)
/// 
/// The API response structure is:
/// ```json
/// {
///   "success": true,
///   "message": "OTP sent successfully. Please check your new email.",
///   "data": {
///     "new_email": "newuser@example.com",
///     "expires_in": 600,
///     "resend_countdown": 120
///   }
/// }
/// ```
class ResendEmailChangeOtpResponseModel extends ResendEmailChangeOtpResponse {
  const ResendEmailChangeOtpResponseModel({
    required super.newEmail,
    required super.expiresIn,
    required super.resendCountdown,
  });

  factory ResendEmailChangeOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ResendEmailChangeOtpResponseModel(
      newEmail: data['new_email']?.toString() ?? '',
      expiresIn: data['expires_in'] as int? ?? 600,
      resendCountdown: data['resend_countdown'] as int? ?? 120,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new_email': newEmail,
      'expires_in': expiresIn,
      'resend_countdown': resendCountdown,
    };
  }
}

