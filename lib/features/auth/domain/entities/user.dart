import 'package:equatable/equatable.dart';
import 'package:delivery_manager/core/utils/enums.dart';

/// User entity representing an authenticated user in the system
/// 
/// This is a domain entity following Clean Architecture principles.
/// It contains user information including authentication status,
/// role, and account approval status.
/// 
/// The entity provides computed properties for easy status checking:
/// - [isApproved]: Check if account is active
/// - [isPendingApproval]: Check if account is waiting for approval
/// - [isSuspended]: Check if account is suspended
/// - [isRejected]: Check if account is rejected
/// - [canPerformBusinessOperations]: Check if user can perform business operations
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? token;
  final String? googleId;
  final String? status;
  final int? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime? emailVerifiedAt;
  final bool hasPassword;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.token,
    this.googleId,
    this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.emailVerifiedAt,
    this.hasPassword = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.operator,
      ),
      token: json['token'] as String?,
      googleId: json['google_id'] as String?,
      status: json['status'] as String?,
      approvedBy: json['approved_by'] as int?,
      approvedAt: json['approved_at'] != null 
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      hasPassword: json['has_password'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phone, role, token, googleId, status, approvedBy, approvedAt, rejectionReason, emailVerifiedAt, hasPassword];

  /// Check if user account is approved
  bool get isApproved => status == 'active';

  /// Check if user account is pending approval
  bool get isPendingApproval => status == 'pending_approval';

  /// Check if user account is suspended
  bool get isSuspended => status == 'suspended';

  /// Check if user account is rejected
  bool get isRejected => status == 'rejected';

  /// Check if user's email is verified
  bool get hasVerifiedEmail => emailVerifiedAt != null;

  /// Check if user can perform business operations
  bool get canPerformBusinessOperations => isApproved;
}
