import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';

/// Abstract repository interface for app version operations
/// 
/// This repository defines the contract for app version checking:
/// - Check app version from server
/// 
/// The implementation is responsible for:
/// - Communicating with remote backend API
/// - Handling error conversion (exceptions to failures)
/// 
/// This follows the Repository Pattern to abstract data sources from business logic.
abstract class BaseAppVersionRepository {
  /// Check app version from server
  /// 
  /// Returns:
  /// - [Right(AppVersion)]: If version information is retrieved successfully
  /// - [Left(Failure)]: If an error occurs (network, server, etc.)
  Future<Either<Failure, AppVersion>> checkAppVersion();
}

