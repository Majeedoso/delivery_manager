import 'package:delivery_manager/features/profile/domain/entities/send_delete_account_otp_response.dart';

/// Data model for SendDeleteAccountOtpResponse entity
/// 
/// Extends the domain [SendDeleteAccountOtpResponse] entity and provides JSON serialization
/// for send delete account OTP API responses.
class SendDeleteAccountOtpResponseModel extends SendDeleteAccountOtpResponse {
  const SendDeleteAccountOtpResponseModel({
    required super.email,
    required super.expiresIn,
    required super.resendCountdown,
  });

  factory SendDeleteAccountOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return SendDeleteAccountOtpResponseModel(
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

