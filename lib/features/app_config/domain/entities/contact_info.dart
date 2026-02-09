import 'package:equatable/equatable.dart';

/// Contact information entity
class ContactInfo extends Equatable {
  final String? email;
  final String? phone;
  final String? website;

  const ContactInfo({
    this.email,
    this.phone,
    this.website,
  });

  @override
  List<Object?> get props => [email, phone, website];
}

