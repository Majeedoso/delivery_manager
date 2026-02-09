import 'package:equatable/equatable.dart';

/// Legal URLs entity representing URLs for legal documents
/// 
/// This entity contains:
/// - privacyPolicyUrl: URL for privacy policy document
/// - termsOfServiceUrl: URL for terms of service document
class LegalUrls extends Equatable {
  final String? privacyPolicyUrl;
  final String? termsOfServiceUrl;

  const LegalUrls({
    this.privacyPolicyUrl,
    this.termsOfServiceUrl,
  });

  @override
  List<Object?> get props => [
        privacyPolicyUrl,
        termsOfServiceUrl,
      ];
}

