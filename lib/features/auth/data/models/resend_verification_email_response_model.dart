import 'package:delivery_manager/features/auth/domain/entities/resend_verification_email_response.dart';

/// Data model for ResendVerificationEmailResponse entity
/// 
/// Extends the domain [ResendVerificationEmailResponse] entity and provides JSON serialization
/// for resend verification email API responses.
/// 
/// Handles conversion between:
/// - JSON maps (from API responses)
/// - Domain entities (for use in business logic)
/// 
/// The API response structure is:
/// ```json
/// {
///   "success": true,
///   "message": "Verification OTP sent successfully. Please check your email.",
///   "data": {
///     "email": "user@example.com",
///     "expires_in": 600,
///     "resend_countdown": 120
///   }
/// }
/// ```
class ResendVerificationEmailResponseModel extends ResendVerificationEmailResponse {
  const ResendVerificationEmailResponseModel({
    required super.email,
    required super.expiresIn,
    required super.resendCountdown,
  });

  factory ResendVerificationEmailResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ResendVerificationEmailResponseModel(
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

