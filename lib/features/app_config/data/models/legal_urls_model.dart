import 'package:delivery_manager/features/app_config/domain/entities/legal_urls.dart';

/// Data model for legal URLs
/// 
/// This model handles JSON serialization/deserialization for legal URLs.
/// It extends the domain entity to provide data layer functionality.
class LegalUrlsModel extends LegalUrls {
  const LegalUrlsModel({
    super.privacyPolicyUrl,
    super.termsOfServiceUrl,
  });

  /// Create LegalUrlsModel from JSON
  factory LegalUrlsModel.fromJson(Map<String, dynamic> json) {
    return LegalUrlsModel(
      privacyPolicyUrl: json['privacy_policy_url'] as String?,
      termsOfServiceUrl: json['terms_of_service_url'] as String?,
    );
  }

  /// Convert LegalUrlsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'privacy_policy_url': privacyPolicyUrl,
      'terms_of_service_url': termsOfServiceUrl,
    };
  }

  /// Convert to domain entity
  LegalUrls toEntity() {
    return LegalUrls(
      privacyPolicyUrl: privacyPolicyUrl,
      termsOfServiceUrl: termsOfServiceUrl,
    );
  }
}

