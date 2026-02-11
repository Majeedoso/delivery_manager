import 'package:equatable/equatable.dart';
import 'package:delivery_manager/core/utils/enums.dart';

enum UserStatus {
  pendingApproval,
  active,
  suspended,
  rejected,
}

extension UserStatusExtension on UserStatus {
  String get value {
    switch (this) {
      case UserStatus.pendingApproval:
        return 'pending_approval';
      case UserStatus.active:
        return 'active';
      case UserStatus.suspended:
        return 'suspended';
      case UserStatus.rejected:
        return 'rejected';
    }
  }

  String get displayName {
    switch (this) {
      case UserStatus.pendingApproval:
        return 'Pending Approval';
      case UserStatus.active:
        return 'Active';
      case UserStatus.suspended:
        return 'Suspended';
      case UserStatus.rejected:
        return 'Rejected';
    }
  }

  static UserStatus fromString(String status) {
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

class ManagedUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final UserStatus status;
  final String? googleId;
  final int? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime? emailVerifiedAt;
  final bool hasPassword;
  final int? trustLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ManagedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    this.googleId,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.emailVerifiedAt,
    this.hasPassword = false,
    this.trustLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  ManagedUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    UserStatus? status,
    String? googleId,
    int? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    DateTime? emailVerifiedAt,
    bool? hasPassword,
    int? trustLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ManagedUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      googleId: googleId ?? this.googleId,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      hasPassword: hasPassword ?? this.hasPassword,
      trustLevel: trustLevel ?? this.trustLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        status,
        googleId,
        approvedBy,
        approvedAt,
        rejectionReason,
        emailVerifiedAt,
        hasPassword,
        trustLevel,
        createdAt,
        updatedAt,
      ];
}
