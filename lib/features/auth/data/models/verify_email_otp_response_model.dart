import 'package:delivery_manager/features/auth/domain/entities/verify_email_otp_response.dart';
import 'package:delivery_manager/features/auth/data/models/user_model.dart';

/// Data model for VerifyEmailOtpResponse entity
class VerifyEmailOtpResponseModel extends VerifyEmailOtpResponse {
  const VerifyEmailOtpResponseModel({
    required super.user,
    required super.message,
  });

  factory VerifyEmailOtpResponseModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final data = json['data'] ?? {};
    final userData = Map<String, dynamic>.from(data);
    // Preserve token if provided (from current user state)
    if (token != null) {
      userData['token'] = token;
    }
    return VerifyEmailOtpResponseModel(
      user: UserModel.fromJson(userData),
      message: json['message']?.toString() ?? 'Email verified successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': (user as UserModel).toJson(),
      'message': message,
    };
  }
}

