import 'package:delivery_manager/features/profile/domain/entities/confirm_email_change_response.dart';
import 'package:delivery_manager/features/profile/data/models/profile_model.dart';

/// Data model for ConfirmEmailChangeResponse entity
class ConfirmEmailChangeResponseModel extends ConfirmEmailChangeResponse {
  const ConfirmEmailChangeResponseModel({
    required super.profile,
    required super.message,
  });

  factory ConfirmEmailChangeResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    // Backend returns partial data, so we need to fetch the full profile separately
    // For now, create a minimal profile from the available data
    // This is a workaround - the original implementation likely fetched the profile separately
    final profileData = {
      'id': data['user_id'] ?? 0,
      'name': '', // Will be fetched separately
      'email': data['new_email'] ?? '',
      'phone': '',
      'role': '',
      'email_verified_at': data['email_verified_at'],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': data['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
    };
    
    return ConfirmEmailChangeResponseModel(
      profile: ProfileModel.fromJson(profileData),
      message: json['message']?.toString() ?? 'Email changed successfully',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': (profile as ProfileModel).toJson(),
      'message': message,
    };
  }
}

