import 'package:delivery_manager/core/utils/enums.dart';
import 'package:delivery_manager/features/users/domain/entities/managed_user.dart';

class UserManagementModel extends ManagedUser {
  const UserManagementModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    required super.status,
    super.googleId,
    super.approvedBy,
    super.approvedAt,
    super.rejectionReason,
    super.emailVerifiedAt,
    super.hasPassword,
    super.trustLevel,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserManagementModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    final id = idValue is int ? idValue : int.tryParse('$idValue') ?? 0;

    return UserManagementModel(
      id: id,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: _parseRole(json['role']?.toString() ?? 'customer'),
      status: _parseStatus(json['status']?.toString() ?? 'pending_approval'),
      googleId: json['google_id']?.toString(),
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
      hasPassword: json['has_password'] == true || json['has_password'] == 1,
      trustLevel: json['trust_level'] is int
          ? json['trust_level']
          : int.tryParse(json['trust_level']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
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
        return UserRole.customer;
    }
  }

  static UserStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending_approval':
        return UserStatus.pendingApproval;
      case 'active':
        return UserStatus.active;
      case 'suspended':
        return UserStatus.suspended;
      case 'rejected':
        return UserStatus.rejected;
      default:
        return UserStatus.pendingApproval;
    }
  }
}
