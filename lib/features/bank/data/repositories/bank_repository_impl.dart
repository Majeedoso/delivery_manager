import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/data/datasource/bank_remote_data_source.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_balance.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';

class BankRepositoryImpl implements BaseBankRepository {
  final BankRemoteDataSource remoteDataSource;

  BankRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DriverBalance>> getDriverBalance({
    String? from,
    String? to,
  }) async {
    try {
      final balance = await remoteDataSource.getDriverBalance(
        from: from,
        to: to,
      );
      return Right(balance);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> recordRestaurantPayment({
    required int restaurantId,
    required double amount,
    String? notes,
  }) async {
    try {
      final transaction = await remoteDataSource.recordRestaurantPayment(
        restaurantId: restaurantId,
        amount: amount,
        notes: notes,
      );
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> recordSystemPayment({
    required double amount,
    String? notes,
  }) async {
    try {
      final transaction = await remoteDataSource.recordSystemPayment(
        amount: amount,
        notes: notes,
      );
      return Right(transaction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedTransactions>> getTransactions({
    String? status,
    String? type,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final result = await remoteDataSource.getTransactions(
        status: status,
        type: type,
        page: page,
        perPage: perPage,
      );
      return Right(
        PaginatedTransactions(
          transactions: result.transactions,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          hasMore: result.hasMore,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  calculateRestaurantPaymentAmount({
    required int restaurantId,
    required String selectedPeriod,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final result = await remoteDataSource.calculateRestaurantPaymentAmount(
        restaurantId: restaurantId,
        selectedPeriod: selectedPeriod,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> calculateSystemPaymentAmount({
    required String selectedPeriod,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final result = await remoteDataSource.calculateSystemPaymentAmount(
        selectedPeriod: selectedPeriod,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
