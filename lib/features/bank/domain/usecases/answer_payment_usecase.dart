import 'package:dartz/dartz.dart';
import 'package:delivery_manager/core/error/failure.dart';
import 'package:delivery_manager/features/bank/domain/repositories/base_bank_repository.dart';

class AnswerPaymentParams {
  final int transactionId;

  /// Received ([confirm]), or refused, saying why in [notes] (the payer
  /// reads it)
  final bool confirm;
  final String? notes;

  const AnswerPaymentParams({
    required this.transactionId,
    required this.confirm,
    this.notes,
  });
}

/// The manager's word on a payment a driver or a restaurant sent to the
/// platform from its app: it counts once confirmed.
class AnswerPaymentUseCase {
  final BaseBankRepository repository;

  AnswerPaymentUseCase(this.repository);

  Future<Either<Failure, Unit>> call(AnswerPaymentParams params) {
    return repository.answerPayment(
      transactionId: params.transactionId,
      confirm: params.confirm,
      notes: params.notes,
    );
  }
}
