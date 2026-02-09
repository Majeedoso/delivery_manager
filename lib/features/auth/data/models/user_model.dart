import 'package:delivery_manager/features/auth/domain/entities/user.dart';
import 'package:delivery_manager/core/utils/enums.dart';

/// Data model for User entity
///
/// Extends the domain [User] entity and provides JSON serialization
/// for data transfer between the app and backend API.
///
/// Handles conversion between:
/// - JSON maps (from API responses)
/// - Domain entities (for use in business logic)
/// - Local storage formats
///
/// Includes role parsing from string to [UserRole] enum.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.token,
    super.googleId,
    super.status,
    super.approvedBy,
    super.approvedAt,
    super.rejectionReason,
    super.emailVerifiedAt,
    super.hasPassword,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: _parseRole(json['role']?.toString() ?? 'operator'),
      token: json['token']?.toString(),
      googleId: json['google_id']?.toString(),
      status: json['status']?.toString(),
      approvedBy: json['approved_by'] is int
          ? json['approved_by']
          : int.tryParse(json['approved_by']?.toString() ?? ''),
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'] as String)
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.tryParse(json['email_verified_at'] as String)
          : null,
      hasPassword: json['has_password'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'token': token,
      'google_id': googleId,
      'status': status,
      'approved_by': approvedBy,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'has_password': hasPassword,
    };
  }

  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'restaurant':
        return UserRole.restaurant;
      case 'driver':
        return UserRole.driver;
      case 'manager':
        return UserRole.manager;
      case 'operator':
        return UserRole.operator;
      default:
        return UserRole.operator;
    }
  }
}
