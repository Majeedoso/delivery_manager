import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/usecase/base_usecase.dart';
import 'package:delivery_manager/features/app_version/domain/entities/app_version.dart';
import 'package:delivery_manager/features/app_version/domain/repository/base_app_version_repository.dart';

/// Use case for checking app version
/// 
/// This use case retrieves version information from the server to:
/// - Check minimum required version
/// - Get current/latest version
/// - Get update URLs for iOS and Android
/// 
/// Used during app startup to verify if the app version is supported.
class CheckAppVersionUseCase implements BaseUseCase<AppVersion, NoParameters> {
  /// The app version repository to check version from server
  final BaseAppVersionRepository repository;

  const CheckAppVersionUseCase(this.repository);

  /// Execute the use case to check app version
  /// 
  /// Returns:
  /// - [Right(AppVersion)]: If version information is retrieved successfully
  /// - [Left(Failure)]: If an error occurs during version check
  @override
  Future<Either<Failure, AppVersion>> call(NoParameters parameters) async {
    return await repository.checkAppVersion();
  }
}

