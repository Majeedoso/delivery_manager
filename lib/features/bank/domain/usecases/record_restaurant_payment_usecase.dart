import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';

class RecordRestaurantPaymentParams {
  final int restaurantId;
  final double amount;
  final String? selectedPeriod;
  final String? startDate;
  final String? endDate;
  final String? notes;

  RecordRestaurantPaymentParams({
    required this.restaurantId,
    required this.amount,
    this.selectedPeriod,
    this.startDate,
    this.endDate,
    this.notes,
  });
}

class RecordRestaurantPaymentUseCase {
  final BaseBankRepository repository;

  RecordRestaurantPaymentUseCase(this.repository);

  Future<Either<Failure, Transaction>> call(
    RecordRestaurantPaymentParams params,
  ) async {
    return await repository.recordRestaurantPayment(
      restaurantId: params.restaurantId,
      amount: params.amount,
      selectedPeriod: params.selectedPeriod,
      startDate: params.startDate,
      endDate: params.endDate,
      notes: params.notes,
    );
  }
}
