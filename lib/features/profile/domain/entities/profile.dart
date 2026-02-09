import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final WorkStatistics workStatistics;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.workStatistics,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String,
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      workStatistics: WorkStatistics.fromJson(json['work_statistics'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'work_statistics': workStatistics.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        emailVerifiedAt,
        createdAt,
        updatedAt,
        workStatistics,
      ];
}

class WorkStatistics extends Equatable {
  final int totalOrdersVerified;
  final int totalOrdersConfirmed;
  final int totalOrdersRejected;
  final double verificationRate;
  final double averageVerificationTimeMinutes;

  const WorkStatistics({
    required this.totalOrdersVerified,
    required this.totalOrdersConfirmed,
    required this.totalOrdersRejected,
    required this.verificationRate,
    required this.averageVerificationTimeMinutes,
  });

  factory WorkStatistics.fromJson(Map<String, dynamic> json) {
    return WorkStatistics(
      totalOrdersVerified: json['total_orders_verified'] as int,
      totalOrdersConfirmed: json['total_orders_confirmed'] as int,
      totalOrdersRejected: json['total_orders_rejected'] as int,
      verificationRate: (json['verification_rate'] as num).toDouble(),
      averageVerificationTimeMinutes: (json['average_verification_time_minutes'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders_verified': totalOrdersVerified,
      'total_orders_confirmed': totalOrdersConfirmed,
      'total_orders_rejected': totalOrdersRejected,
      'verification_rate': verificationRate,
      'average_verification_time_minutes': averageVerificationTimeMinutes,
    };
  }

  @override
  List<Object?> get props => [
        totalOrdersVerified,
        totalOrdersConfirmed,
        totalOrdersRejected,
        verificationRate,
        averageVerificationTimeMinutes,
      ];
}
