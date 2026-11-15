import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/domain/entities/driver_balance.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';

/// What the payments of a history's days and kind moved, the confirmed ones:
/// paid and received in cash, and set off (the owner's ask, 2026-11-14).
class TransactionsSummary extends Equatable {
  final double paid;
  final double received;
  final double setOff;

  const TransactionsSummary({
    required this.paid,
    required this.received,
    required this.setOff,
  });

  @override
  List<Object?> get props => [paid, received, setOff];
}

class PaginatedTransactions {
  final List<Transaction> transactions;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  /// What the payments of these days and this kind moved (null: not said)
  final TransactionsSummary? summary;

  PaginatedTransactions({
    required this.transactions,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
    this.summary,
  });
}

abstract class BaseBankRepository {
  /// Get driver's balance summary
  Future<Either<Failure, DriverBalance>> getDriverBalance({
    String? from,
    String? to,
    String? counterpartyType,
    int? counterpartyId,
    String? side,
    int page = 1,
  });

  /// Record a payment to a restaurant
  Future<Either<Failure, Transaction>> recordRestaurantPayment({
    required int restaurantId,
    required double amount,
    String? selectedPeriod,
    String? startDate,
    String? endDate,
    String? notes,
  });

  /// Record a system fee payment
  Future<Either<Failure, Transaction>> recordSystemPayment({
    required int driverId,
    required double amount,
    String? notes,
  });

  /// The platform pays a restaurant or a driver what it owes them
  Future<Either<Failure, Transaction>> recordPlatformPayment({
    int? restaurantId,
    int? driverId,
    required double amount,
    String? notes,
  });

  /// Confirms (or refuses, saying why) a payment a driver or a restaurant sent
  Future<Either<Failure, Unit>> answerPayment({
    required int transactionId,
    required bool confirm,
    String? notes,
  });

  /// Get transaction history: of one status, one kind, and some local days
  /// ([from], [to], yyyy-MM-dd)
  Future<Either<Failure, PaginatedTransactions>> getTransactions({
    String? status,
    String? type,
    String? from,
    String? to,
    int page = 1,
    int perPage = 10,
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
    required int driverId,
    required String selectedPeriod,
    String? startDate,
    String? endDate,
  });
}
