import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/domain/entities/transaction.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';

class RecordSystemPaymentParams {
  final double amount;
  final String? notes;

  RecordSystemPaymentParams({required this.amount, this.notes});
}

class RecordSystemPaymentUseCase {
  final BaseBankRepository repository;

  RecordSystemPaymentUseCase(this.repository);

  Future<Either<Failure, Transaction>> call(
    RecordSystemPaymentParams params,
  ) async {
    return await repository.recordSystemPayment(
      amount: params.amount,
      notes: params.notes,
    );
  }
}
