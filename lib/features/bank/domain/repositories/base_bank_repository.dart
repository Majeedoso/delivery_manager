import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_balance.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';

class PaginatedTransactions {
  final List<Transaction> transactions;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  PaginatedTransactions({
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });
}

abstract class BaseBankRepository {
  /// Get driver's balance summary
  Future<Either<Failure, DriverBalance>> getDriverBalance({
    String? from,
    String? to,
  });

  /// Record a payment to a restaurant
  Future<Either<Failure, Transaction>> recordRestaurantPayment({
    required int restaurantId,
    required double amount,
    String? notes,
  });

  /// Record a system fee payment
  Future<Either<Failure, Transaction>> recordSystemPayment({
    required double amount,
    String? notes,
  });

  /// Get transaction history
  Future<Either<Failure, PaginatedTransactions>> getTransactions({
    String? status,
    String? type,
    int page = 1,
    int perPage = 15,
  });

  /// Calculate the amount driver owes to a restaurant for a date range
  Future<Either<Failure, Map<String, dynamic>>>
  calculateRestaurantPaymentAmount({
    required int restaurantId,
    required String selectedPeriod,
    String? startDate,
    String? endDate,
  });

  /// Calculate the amount driver owes to the system for a date range
  Future<Either<Failure, Map<String, dynamic>>> calculateSystemPaymentAmount({
    required String selectedPeriod,
    String? startDate,
    String? endDate,
  });
}
