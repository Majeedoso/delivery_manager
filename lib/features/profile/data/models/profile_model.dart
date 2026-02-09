import 'package:delivery_manager/features/profile/domain/entities/profile.dart';
import 'package:delivery_manager/core/services/logging_service.dart';
import 'package:delivery_manager/core/services/services_locator.dart';
import 'package:flutter/foundation.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.role,
    super.emailVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
    required super.workStatistics,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    LoggingService? logger;
    try {
      logger = sl<LoggingService>();
    } catch (e) {
      logger = null;
    }
    
    if (kDebugMode && logger != null) {
      logger.debug('ProfileModel.fromJson - Input JSON: $json');
    }
    
    try {
      final id = json['id'] as int;
      if (kDebugMode && logger != null) {
        logger.debug('ProfileModel.fromJson - ID: $id');
      }
      
      final name = json['name'] as String;
      if (kDebugMode && logger != null) {
        logger.debug('ProfileModel.fromJson - Name: $name');
      }
      
      final email = json['email'] as String? ?? '';
      if (kDebugMode && logger != null) {
        logger.debug('ProfileModel.fromJson - Email: $email');
      }
      
      final phone = json['phone'] as String? ?? '';
      if (kDebugMode && logger != null) {
        logger.debug('ProfileModel.fromJson - Phone: $phone');
      }
      
      // Role is always present in /auth/user response
      final role = json['role'] as String;
      if (kDebugMode && logger != null) {
        logger.debug('ProfileModel.fromJson - Role: $role');
      }
      
      final emailVerifiedAt = json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at'] as String)
          : null;
      if (kDebugMode && logger != null) {
        logger.debug('ProfileModel.fromJson - Email Verified At: $emailVerifiedAt');
      }
      
      final createdAt = json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now();
      if (kDebugMode && logger != null) {
        logger.debug('ProfileModel.fromJson - Created At: $createdAt');
      }
      
      final updatedAt = json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now();
      if (kDebugMode && logger != null) {
        logger.debug('ProfileModel.fromJson - Updated At: $updatedAt');
      }
      
      // Work statistics only exist for operators, not for restaurant users
      final workStatistics = json['work_statistics'] != null 
          ? WorkStatisticsModel.fromJson(json['work_statistics'] as Map<String, dynamic>)
          : const WorkStatisticsModel(
              totalOrdersVerified: 0,
              totalOrdersConfirmed: 0,
              totalOrdersRejected: 0,
              verificationRate: 0.0,
              averageVerificationTimeMinutes: 0.0,
            );
      if (kDebugMode && logger != null) {
        logger.debug('ProfileModel.fromJson - Work Statistics: $workStatistics');
      }
      
      return ProfileModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        role: role,
        emailVerifiedAt: emailVerifiedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
        workStatistics: workStatistics,
      );
    } catch (e) {
      if (kDebugMode && logger != null) {
        logger.error('ProfileModel.fromJson - Error', error: e);
        logger.debug('ProfileModel.fromJson - JSON keys: ${json.keys.toList()}');
      }
      rethrow;
    }
  }

  @override
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
      'work_statistics': (workStatistics as WorkStatisticsModel).toJson(),
    };
  }
}

class WorkStatisticsModel extends WorkStatistics {
  const WorkStatisticsModel({
    required super.totalOrdersVerified,
    required super.totalOrdersConfirmed,
    required super.totalOrdersRejected,
    required super.verificationRate,
    required super.averageVerificationTimeMinutes,
  });

  factory WorkStatisticsModel.fromJson(Map<String, dynamic> json) {
    LoggingService? logger;
    try {
      logger = sl<LoggingService>();
    } catch (e) {
      logger = null;
    }
    
    if (kDebugMode && logger != null) {
      logger.debug('WorkStatisticsModel.fromJson - Input JSON: $json');
    }
    
    try {
      final totalOrdersVerified = json['total_orders_verified'] as int;
      if (kDebugMode && logger != null) {
        logger.debug('WorkStatisticsModel.fromJson - Total Orders Verified: $totalOrdersVerified');
      }
      
      final totalOrdersConfirmed = json['total_orders_confirmed'] as int;
      if (kDebugMode && logger != null) {
        logger.debug('WorkStatisticsModel.fromJson - Total Orders Confirmed: $totalOrdersConfirmed');
      }
      
      final totalOrdersRejected = json['total_orders_rejected'] as int;
      if (kDebugMode && logger != null) {
        logger.debug('WorkStatisticsModel.fromJson - Total Orders Rejected: $totalOrdersRejected');
      }
      
      final verificationRate = (json['verification_rate'] as num).toDouble();
      if (kDebugMode && logger != null) {
        logger.debug('WorkStatisticsModel.fromJson - Verification Rate: $verificationRate');
      }
      
      final averageVerificationTimeMinutes = (json['average_verification_time_minutes'] as num).toDouble();
      if (kDebugMode && logger != null) {
        logger.debug('WorkStatisticsModel.fromJson - Average Verification Time: $averageVerificationTimeMinutes');
      }
      
      return WorkStatisticsModel(
        totalOrdersVerified: totalOrdersVerified,
        totalOrdersConfirmed: totalOrdersConfirmed,
        totalOrdersRejected: totalOrdersRejected,
        verificationRate: verificationRate,
        averageVerificationTimeMinutes: averageVerificationTimeMinutes,
      );
    } catch (e) {
      if (kDebugMode && logger != null) {
        logger.error('WorkStatisticsModel.fromJson - Error', error: e);
        logger.debug('WorkStatisticsModel.fromJson - JSON keys: ${json.keys.toList()}');
      }
      rethrow;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'total_orders_verified': totalOrdersVerified,
      'total_orders_confirmed': totalOrdersConfirmed,
      'total_orders_rejected': totalOrdersRejected,
      'verification_rate': verificationRate,
      'average_verification_time_minutes': averageVerificationTimeMinutes,
    };
  }
}
