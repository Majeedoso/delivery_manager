import 'package:delivery_manager/features/app_config/domain/entities/contact_info.dart';

/// Data model for contact information
class ContactInfoModel extends ContactInfo {
  const ContactInfoModel({
    super.email,
    super.phone,
    super.website,
  });

  /// Create ContactInfoModel from JSON
  factory ContactInfoModel.fromJson(Map<String, dynamic> json) {
    return ContactInfoModel(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
    );
  }

  /// Convert ContactInfoModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'phone': phone,
      'website': website,
    };
  }

  /// Convert to domain entity
  ContactInfo toEntity() {
    return ContactInfo(
      email: email,
      phone: phone,
      website: website,
    );
  }
}

