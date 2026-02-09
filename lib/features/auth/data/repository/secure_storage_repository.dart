import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_secure_storage_repository.dart';
import 'package:delivery_manager/features/auth/data/datasource/secure_storage_local_data_source.dart';

/// Implementation of [BaseSecureStorageRepository]
/// 
/// This repository manages user credentials (email/password) securely
/// for "Remember Me" functionality using Flutter Secure Storage.
/// 
/// Handles error conversion from exceptions to failures and provides
/// a unified interface for credential operations.
class SecureStorageRepository implements BaseSecureStorageRepository {
  /// Local data source for secure credential storage
  final BaseSecureStorageLocalDataSource _localDataSource;

  const SecureStorageRepository(this._localDataSource);

  @override
  Future<Either<Failure, bool>> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      await _localDataSource.saveCredentials(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to save credentials: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, String?>>> loadCredentials() async {
    try {
      final credentials = await _localDataSource.loadCredentials();
      return Right(credentials);
    } catch (e) {
      return Left(ServerFailure('Failed to load credentials: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> clearCredentials() async {
    try {
      await _localDataSource.clearCredentials();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to clear credentials: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasSavedCredentials() async {
    try {
      final hasCredentials = await _localDataSource.hasSavedCredentials();
      return Right(hasCredentials);
    } catch (e) {
      return Left(ServerFailure('Failed to check saved credentials: ${e.toString()}'));
    }
  }
}
