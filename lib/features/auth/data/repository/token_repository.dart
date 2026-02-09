import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/core/error/exceptions.dart';
import 'package:delivery_manager/features/auth/domain/repository/base_token_repository.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_local_data_source.dart';
import 'package:delivery_manager/features/auth/data/datasource/token_remote_data_source.dart';

/// Implementation of [BaseTokenRepository]
/// 
/// This repository manages authentication tokens by coordinating between:
/// - Local data source: Secure token storage (Flutter Secure Storage)
/// - Remote data source: Token validation with backend API
/// 
/// Handles error conversion from exceptions to failures and provides
/// a unified interface for token operations.
class TokenRepository implements BaseTokenRepository {
  /// Local data source for secure token storage
  final BaseTokenLocalDataSource _localDataSource;
  
  /// Remote data source for token validation
  final BaseTokenRemoteDataSource _remoteDataSource;

  const TokenRepository({
    required BaseTokenLocalDataSource localDataSource,
    required BaseTokenRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, bool>> saveToken(String token) async {
    try {
      await _localDataSource.saveToken(token);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to save token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String?>> getToken() async {
    try {
      final token = await _localDataSource.getToken();
      return Right(token);
    } catch (e) {
      return Left(ServerFailure('Failed to get token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> clearToken() async {
    try {
      await _localDataSource.clearToken();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to clear token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasToken() async {
    try {
      final hasToken = await _localDataSource.hasToken();
      return Right(hasToken);
    } catch (e) {
      return Left(ServerFailure('Failed to check token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateToken(String token) async {
    try {
      final isValid = await _remoteDataSource.validateToken(token);
      return Right(isValid);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Token validation failed: ${e.toString()}'));
    }
  }
}
